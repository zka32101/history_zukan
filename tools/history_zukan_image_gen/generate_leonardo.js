#!/usr/bin/env node
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 歴史図鑑 — 児童向けキャラクター/素材 一括生成ツール（Leonardo.ai版）
// card_crown/tools/seed_card_image_gen/generate_leonardo.js のコスト最小設定・
// スキップ機構をそのまま踏襲し、assets_list.js の静的リストを1件ずつ生成する。
//
// コスト最小化のため:
//   - alchemy: false, photoReal: false
//   - num_images: 1
//   - 既存ファイルは自動スキップ（--allを何度実行しても未生成分だけ課金される）
//
// 使い方:
//   （PowerShellでは事前に $env:LEONARDO_API_KEY="xxxx" を実行しておく）
//   node generate_leonardo.js --count 2               # 先頭2枚だけ（未生成分のみ）
//   node generate_leonardo.js --ids mascot_standing,era_jomon
//   node generate_leonardo.js --category mascot        # カテゴリ単位で生成
//   node generate_leonardo.js --all                    # 34枚まとめて生成（推奨）
//   node generate_leonardo.js --all --force             # 既存分も含めて全部作り直す
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const fs = require('fs');
const path = require('path');
const { ASSETS } = require('./assets_list');

const LEONARDO_API_KEY = process.env.LEONARDO_API_KEY;
// デフォルト: Leonardo Phoenix 1.0（要検証・エラー時は環境変数で上書き）
const LEONARDO_MODEL_ID = process.env.LEONARDO_MODEL_ID || 'de7d3faf-762f-48e0-b3b7-9d0ac3a3fcf3';
const OUTPUT_DIR = path.join(__dirname, 'output');
const API_BASE = 'https://cloud.leonardo.ai/api/rest/v1';

// Leonardo は最小512pxのみ許容するため、生成は常に512x512で行い、
// 用途別の最終サイズ（400x300等）はFlutter側 or 手動クロップで調整する。
const GEN_WIDTH = 512;
const GEN_HEIGHT = 512;

async function generateImage(prompt, negativePrompt) {
  const createRes = await fetch(`${API_BASE}/generations`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${LEONARDO_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      prompt,
      negative_prompt: negativePrompt,
      modelId: LEONARDO_MODEL_ID,
      width: GEN_WIDTH,
      height: GEN_HEIGHT,
      num_images: 1,
      alchemy: false,
      photoReal: false,
    }),
  });

  if (!createRes.ok) {
    throw new Error(`Leonardo API error (create): ${createRes.status} ${await createRes.text()}`);
  }

  const created = await createRes.json();
  const genId = created?.sdGenerationJob?.generationId;
  if (!genId) {
    throw new Error(`generationId が取得できませんでした: ${JSON.stringify(created)}`);
  }

  let attempts = 0;
  let images = null;
  while (attempts < 30) {
    await new Promise((r) => setTimeout(r, 2000));
    const poll = await fetch(`${API_BASE}/generations/${genId}`, {
      headers: { Authorization: `Bearer ${LEONARDO_API_KEY}` },
    });
    if (!poll.ok) {
      throw new Error(`Leonardo API error (poll): ${poll.status} ${await poll.text()}`);
    }
    const data = await poll.json();
    const gen = data.generations_by_pk;
    if (gen?.status === 'COMPLETE') {
      images = gen.generated_images;
      break;
    }
    if (gen?.status === 'FAILED') {
      throw new Error(`generation failed: ${JSON.stringify(gen)}`);
    }
    attempts++;
  }

  if (!images || !images[0]?.url) {
    throw new Error('画像生成がタイムアウトしました');
  }

  return images[0].url;
}

async function downloadTo(url, filePath) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`download failed: ${res.status}`);
  const buf = Buffer.from(await res.arrayBuffer());
  fs.writeFileSync(filePath, buf);
}

function parseArgs() {
  const args = process.argv.slice(2);
  const opts = { count: null, ids: null, category: null, all: false, force: false };
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--count') opts.count = parseInt(args[++i], 10);
    else if (args[i] === '--ids') opts.ids = args[++i].split(',').map((s) => s.trim());
    else if (args[i] === '--category') opts.category = args[++i];
    else if (args[i] === '--all') opts.all = true;
    else if (args[i] === '--force') opts.force = true;
  }
  return opts;
}

async function main() {
  if (!LEONARDO_API_KEY) {
    console.error('❌ LEONARDO_API_KEY が設定されていません。');
    console.error('   例: $env:LEONARDO_API_KEY="xxxx"; node generate_leonardo.js --count 2');
    process.exit(1);
  }

  const opts = parseArgs();
  console.log(`📋 assets_list.js から ${ASSETS.length} 件の画像定義を読み込みました`);

  let target;
  if (opts.ids) {
    target = ASSETS.filter((a) => opts.ids.includes(a.id));
  } else if (opts.category) {
    target = ASSETS.filter((a) => a.category === opts.category);
  } else if (opts.all) {
    target = ASSETS;
  } else {
    const n = opts.count || 2;
    target = ASSETS.slice(0, n);
  }

  if (target.length === 0) {
    console.error('❌ 対象アセットが見つかりません');
    process.exit(1);
  }

  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  const manifestPath = path.join(OUTPUT_DIR, 'manifest.json');
  const manifest = fs.existsSync(manifestPath)
    ? JSON.parse(fs.readFileSync(manifestPath, 'utf8'))
    : {};

  let skipped = 0;
  const toGenerate = opts.force
    ? target
    : target.filter((asset) => {
        const exists = fs.existsSync(path.join(OUTPUT_DIR, `${asset.id}.png`));
        if (exists) skipped++;
        return !exists;
      });

  if (skipped > 0) {
    console.log(`⏭️  既存の${skipped}枚をスキップ（再生成するには --force を付けてください）`);
  }
  console.log(`🎨 ${toGenerate.length} 枚を生成します（Leonardo.ai / modelId=${LEONARDO_MODEL_ID} / alchemy=off / ${GEN_WIDTH}x${GEN_HEIGHT}）\n`);

  for (const asset of toGenerate) {
    process.stdout.write(`  ${asset.id} (${asset.category}) ... `);
    try {
      const imageUrl = await generateImage(asset.prompt, asset.negativePrompt);
      const outFile = path.join(OUTPUT_DIR, `${asset.id}.png`);
      await downloadTo(imageUrl, outFile);
      manifest[asset.id] = {
        category: asset.category,
        targetWidth: asset.width,
        targetHeight: asset.height,
        file: `${asset.id}.png`,
        prompt: asset.prompt,
        provider: 'leonardo',
        modelId: LEONARDO_MODEL_ID,
        generatedAt: new Date().toISOString(),
      };
      fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
      console.log('✅');
    } catch (e) {
      console.log(`❌ ${e.message}`);
    }
  }

  console.log(`\n完了（生成${toGenerate.length}枚 / スキップ${skipped}枚）。出力先: ${OUTPUT_DIR}`);
  console.log('※ Leonardoは512x512固定で生成しています。実サイズへのリサイズ/クロップは別途行ってください。');
}

main().catch((e) => {
  console.error(`❌ 予期しないエラー: ${e.message}`);
  process.exit(1);
});
