const functions = require('firebase-functions');
const admin = require('firebase-admin');
const Anthropic = require('@anthropic-ai/sdk');

admin.initializeApp();

const db = admin.firestore();

// D1 AI Chat quota: paid add-on caps total conversations per user.
const MAX_CONVERSATIONS_PER_USER = 100;

/**
 * Build the system prompt server-side from trusted Firestore person data.
 * The client is never trusted with system prompt content — it only sends
 * a personId, so it cannot turn this function into an arbitrary Claude proxy.
 */
function buildSystemPrompt(person) {
  const quotes = Array.isArray(person.famousQuotes)
    ? person.famousQuotes.join('\n')
    : '';
  const timeline =
    person.lifeTimeline && typeof person.lifeTimeline === 'object'
      ? Object.entries(person.lifeTimeline)
          .map(([k, v]) => `${k}: ${v}`)
          .join('\n')
      : '';

  return `あなたは${person.name}（${person.birthYear ?? '?'}〜${person.deathYear ?? '?'}年）になりきって会話します。

背景: ${person.description ?? ''}
性格: ${person.personality ?? '不詳'}

${quotes ? `名言:\n${quotes}\n` : ''}${timeline ? `主要事件:\n${timeline}\n` : ''}
会話ルール:
1. 一人称を「我」「わし」など歴史人物らしく使う
2. 5〜8文で簡潔に答える
3. 日本語のみで回答する
4. 歴史的に正確な情報を提供する
5. 子ども（小学生）にもわかりやすく話す`;
}

/**
 * personChat — Claude Haiku proxy for D1 AI Chat feature.
 *
 * Security:
 *  - Requires Firebase Auth (context.auth)
 *  - API key stored as Cloud Function secret (ANTHROPIC_API_KEY)
 *  - System prompt is rebuilt server-side from Firestore `persons/{personId}`
 *    data — the client only supplies personId, never raw prompt content, so
 *    it cannot repurpose this function into an unrestricted/unmoderated
 *    Claude proxy.
 *  - Input validation: message length, message count
 *  - Server-side per-uid conversation quota (mirrors the paid add-on's
 *    100-conversation cap so it can't be bypassed by clearing local storage
 *    or calling the callable directly).
 *
 * Callable via: FirebaseFunctions.instanceFor(region:'asia-northeast1').httpsCallable('personChat')
 */
exports.personChat = functions
  .region('asia-northeast1')
  .runWith({
    secrets: ['ANTHROPIC_API_KEY'],
    timeoutSeconds: 30,
    memory: '256MB',
  })
  .https.onCall(async (data, context) => {
    // Auth check
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'ログインが必要です。'
      );
    }

    const { personId, messages, maxTokens } = data;

    // Input validation
    if (!personId || typeof personId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'personId が必要です。'
      );
    }
    if (!Array.isArray(messages) || messages.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'messages が必要です。'
      );
    }
    if (messages.length > 20) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'メッセージ数が多すぎます（最大20件）。'
      );
    }

    const lastMessage = messages[messages.length - 1];
    if (
      !lastMessage ||
      lastMessage.role !== 'user' ||
      typeof lastMessage.content !== 'string' ||
      lastMessage.content.length > 500
    ) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        '最後のメッセージが不正です。'
      );
    }

    // Look up the person server-side — never trust a client-supplied prompt.
    const personSnap = await db.collection('persons').doc(personId).get();
    if (!personSnap.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        '人物が見つかりません。'
      );
    }
    const person = personSnap.data();
    if (!person.hasAiChat) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'この人物はAIチャットに対応していません。'
      );
    }
    const systemPrompt = buildSystemPrompt(person);

    // Server-side quota enforcement — transactionally increment a per-uid
    // counter so the 100-conversation add-on cap can't be bypassed by
    // clearing local app storage or calling this function directly.
    const quotaRef = db.collection('chatQuotas').doc(context.auth.uid);
    await db.runTransaction(async (tx) => {
      const quotaSnap = await tx.get(quotaRef);
      const used = quotaSnap.exists ? quotaSnap.data().conversationCount || 0 : 0;
      if (used >= MAX_CONVERSATIONS_PER_USER) {
        throw new functions.https.HttpsError(
          'resource-exhausted',
          `会話上限（${MAX_CONVERSATIONS_PER_USER}回）に達しました。`
        );
      }
      tx.set(
        quotaRef,
        {
          conversationCount: used + 1,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    });

    const client = new Anthropic({
      apiKey: process.env.ANTHROPIC_API_KEY,
    });

    try {
      const response = await client.messages.create({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: Math.min(maxTokens || 300, 500),
        system: systemPrompt,
        messages: messages.map((m) => ({
          role: m.role,
          content: m.content,
        })),
      });

      const text = response.content[0]?.text ?? '';

      functions.logger.info('personChat success', {
        uid: context.auth.uid,
        person: personId,
        inputTokens: response.usage.input_tokens,
        outputTokens: response.usage.output_tokens,
      });

      return {
        message: text,
        inputTokens: response.usage.input_tokens,
        outputTokens: response.usage.output_tokens,
      };
    } catch (err) {
      functions.logger.error('Anthropic API error', { error: err.message });
      if (err.status === 429) {
        throw new functions.https.HttpsError(
          'resource-exhausted',
          'APIレート制限に達しました。しばらくお待ちください。'
        );
      }
      throw new functions.https.HttpsError(
        'internal',
        'AI応答の取得に失敗しました。'
      );
    }
  });
