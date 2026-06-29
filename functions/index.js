const functions = require('firebase-functions');
const admin = require('firebase-admin');
const Anthropic = require('@anthropic-ai/sdk');

admin.initializeApp();

/**
 * personChat — Claude Haiku proxy for D1 AI Chat feature.
 *
 * Security:
 *  - Requires Firebase Auth (context.auth)
 *  - API key stored as Cloud Function secret (ANTHROPIC_API_KEY)
 *  - Input validation: message length, message count
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

    const { personName, systemPrompt, messages, maxTokens } = data;

    // Input validation
    if (!systemPrompt || typeof systemPrompt !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'systemPrompt が必要です。'
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
    if (!lastMessage || lastMessage.role !== 'user' || lastMessage.content.length > 500) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        '最後のメッセージが不正です。'
      );
    }

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
        person: personName,
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
