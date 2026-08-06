// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 歴史図鑑 — 児童向けキャラクター/素材 画像定義リスト
// H:\マイドライブ\images\歴史図鑑\leonardo_prompts.md の
// セクション3・4・7・11・12・13 のプロンプトをそのまま構造化したもの。
// generate_leonardo.js はこのリストを1件ずつ Leonardo.ai API に投げる。
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const NEGATIVE_PROMPT_COMMON =
  'low quality, blurry, distorted, ugly, bad anatomy, watermark, text, scary, realistic photo, photorealistic, gore, violence';

const NEGATIVE_PROMPT_SQUARE_FRAME =
  'low quality, blurry, distorted, ugly, watermark, text, scary, photorealistic, ' +
  'face, character, person, portrait, human, animal, mascot inside frame';

const NEGATIVE_PROMPT_NO_TEXT =
  'low quality, blurry, distorted, ugly, watermark, scary, realistic photo, photorealistic, ' +
  'text, words, letters, typography, caption, title, writing, English text, Japanese text, speech bubble with text';

function chibiPersonPrompt(descriptor) {
  return `A cute chibi-style illustration of ${descriptor}, designed for elementary school children. ` +
    '2-3 head-tall proportions, big round friendly eyes, warm smile. ' +
    'Bright, warm color palette, thick clean outlines, flat cel-shaded coloring. ' +
    'Kid-friendly, approachable, storybook illustration style — NOT photorealistic, NOT scary. High quality, 400x300px.';
}

function mascotPrompt(poseDescriptor) {
  return 'A friendly, adorable mascot character for a history learning app for elementary school kids. ' +
    'Appearance: A round, huggable book-shaped character with big sparkling eyes, chubby short arms and legs, ' +
    'rosy cheeks, and a warm smile. The book cover has a small crown or ribbon accent, and it carries a tiny ' +
    'magnifying glass and hourglass charm. Color: soft purple and gold, bright and welcoming, pastel highlights. ' +
    'Style: kawaii chibi mascot, thick clean outlines, flat cel-shaded coloring, sticker-style. ' +
    `Pose: ${poseDescriptor}. Suitable for stickers, UI elements, loading screens. ` +
    'High quality, transparent background PNG, 500x500px.';
}

function gachaFramePrompt(rarityDescriptor) {
  return `A cute, rounded decorative border/frame graphic only, for a collectible history card game for kids. ${rarityDescriptor} ` +
    'The frame surrounds an EMPTY plain flat pastel-colored square in the very center — ' +
    'the center area must stay completely empty with NO face, NO character, NO portrait, NO illustration inside it, ' +
    'just decorative border artwork around a blank square. Square format, 512x512px, PNG.';
}

function eraIconPrompt(descriptor) {
  return `A cute, chibi-style rounded icon of ${descriptor}, warm orange gradient, ` +
    'thick outline flat icon style, transparent background, 200x200px.';
}

function diagnosisBgPrompt(themeConcept, elements) {
  return `A cute, friendly illustration background about ${themeConcept}, for a kids' personality quiz app. ` +
    `Elements: ${elements}. Color: bright purple to indigo gradient with pastel highlights. ` +
    'Style: playful, storybook illustration, thick outlines, NOT scary or dramatic. ' +
    'IMPORTANT: pure illustration only, absolutely no text, no words, no letters, no title, no captions anywhere in the image. ' +
    '1080x600px, suitable as a card header background.';
}

const ASSETS = [
  // ===== 3. 日本人物プレースホルダー（3枚） =====
  {
    id: 'person_jp_ancient',
    category: 'person_placeholders',
    width: 400,
    height: 300,
    prompt: chibiPersonPrompt(
      'a historical Japanese figure from Heian to Edo period, wearing simplified kimono, hakama, or formal court dress'
    ),
    negativePrompt: NEGATIVE_PROMPT_COMMON,
  },
  {
    id: 'person_jp_modern',
    category: 'person_placeholders',
    width: 400,
    height: 300,
    prompt: chibiPersonPrompt(
      'a Meiji-Showa era Japanese intellectual or leader, wearing a simplified Western suit or hakama'
    ),
    negativePrompt: NEGATIVE_PROMPT_COMMON,
  },
  {
    id: 'person_jp_contemporary',
    category: 'person_placeholders',
    width: 400,
    height: 300,
    prompt: chibiPersonPrompt(
      'a modern Japanese artist, scientist, or business leader, wearing simplified contemporary clothing'
    ),
    negativePrompt: NEGATIVE_PROMPT_COMMON,
  },

  // ===== 4. 世界人物プレースホルダー（3枚） =====
  {
    id: 'person_world_ancient',
    category: 'person_placeholders',
    width: 400,
    height: 300,
    prompt: chibiPersonPrompt(
      'an ancient or medieval Western historical figure, wearing simplified Greek, Roman, or European medieval clothing'
    ),
    negativePrompt: NEGATIVE_PROMPT_COMMON,
  },
  {
    id: 'person_world_renaissance',
    category: 'person_placeholders',
    width: 400,
    height: 300,
    prompt: chibiPersonPrompt(
      'a Renaissance to modern Western historical figure, wearing simplified formal clothing from their era'
    ),
    negativePrompt: NEGATIVE_PROMPT_COMMON,
  },
  {
    id: 'person_world_other',
    category: 'person_placeholders',
    width: 400,
    height: 300,
    prompt: chibiPersonPrompt(
      'a historical figure from Africa, Middle East, or Asia, wearing traditional clothing appropriate to their region, simplified but respectful'
    ),
    negativePrompt: NEGATIVE_PROMPT_COMMON,
  },

  // ===== 7. マスコット（4ポーズ） =====
  {
    id: 'mascot_standing',
    category: 'mascot',
    width: 500,
    height: 500,
    prompt: mascotPrompt('standing confidently, one hand waving hello'),
    negativePrompt: NEGATIVE_PROMPT_COMMON,
  },
  {
    id: 'mascot_pointing',
    category: 'mascot',
    width: 500,
    height: 500,
    prompt: mascotPrompt('pointing forward excitedly with sparkles around, as if guiding the way'),
    negativePrompt: NEGATIVE_PROMPT_COMMON,
  },
  {
    id: 'mascot_thinking',
    category: 'mascot',
    width: 500,
    height: 500,
    prompt: mascotPrompt('tilting head with one finger on chin, thought bubble with a small lightbulb'),
    negativePrompt: NEGATIVE_PROMPT_COMMON,
  },
  {
    id: 'mascot_celebrating',
    category: 'mascot',
    width: 500,
    height: 500,
    prompt: mascotPrompt('jumping with both arms up, confetti and stars around, big joyful smile'),
    negativePrompt: NEGATIVE_PROMPT_COMMON,
  },

  // ===== 11. ガチャレアリティ枠（4枚） =====
  {
    id: 'gacha_frame_n',
    category: 'gacha_frames',
    width: 512,
    height: 512,
    prompt: gachaFramePrompt(
      'Rarity: Common (N). Color: soft blue-gray pastel, simple friendly rounded border with tiny star accent. Style: thick rounded outline, minimal but cheerful, flat cel-shaded coloring.'
    ),
    negativePrompt: NEGATIVE_PROMPT_SQUARE_FRAME,
  },
  {
    id: 'gacha_frame_r',
    category: 'gacha_frames',
    width: 512,
    height: 512,
    prompt: gachaFramePrompt(
      'Rarity: Rare (R). Color: warm bronze/copper tones, playful sticker-style border with small star accents. Style: thick rounded outline, friendly ornamentation, small corner sparkles.'
    ),
    negativePrompt: NEGATIVE_PROMPT_SQUARE_FRAME,
  },
  {
    id: 'gacha_frame_sr',
    category: 'gacha_frames',
    width: 512,
    height: 512,
    prompt: gachaFramePrompt(
      'Rarity: Super Rare (SR). Color: bright silver with soft glowing edge, playful star and ribbon pattern. Style: thick rounded outline, cheerful sparkle rays in background corners.'
    ),
    negativePrompt: NEGATIVE_PROMPT_SQUARE_FRAME,
  },
  {
    id: 'gacha_frame_ssr',
    category: 'gacha_frames',
    width: 512,
    height: 512,
    prompt: gachaFramePrompt(
      'Rarity: Special Super Rare (SSR). Color: radiant gold and rainbow-tinted sparkle, festive star and confetti accents. Style: thick rounded outline, exciting eye-catching sparkle/glitter effect around border, similar to a birthday party celebration frame.'
    ),
    negativePrompt: NEGATIVE_PROMPT_SQUARE_FRAME,
  },

  // ===== 12. 時代アイコン（15枚） =====
  { id: 'era_jomon', category: 'era_icons', width: 200, height: 200, prompt: eraIconPrompt('a Jomon-era clay pot (dogu figure) with a friendly face'), negativePrompt: NEGATIVE_PROMPT_COMMON },
  { id: 'era_yayoi', category: 'era_icons', width: 200, height: 200, prompt: eraIconPrompt('a Yayoi-era rice paddy with a small raised-floor storehouse'), negativePrompt: NEGATIVE_PROMPT_COMMON },
  { id: 'era_kofun', category: 'era_icons', width: 200, height: 200, prompt: eraIconPrompt('a keyhole-shaped kofun burial mound, simplified and friendly'), negativePrompt: NEGATIVE_PROMPT_COMMON },
  { id: 'era_asuka', category: 'era_icons', width: 200, height: 200, prompt: eraIconPrompt('a small five-story pagoda (Horyuji style)'), negativePrompt: NEGATIVE_PROMPT_COMMON },
  { id: 'era_nara', category: 'era_icons', width: 200, height: 200, prompt: eraIconPrompt('the Great Buddha Hall (Todaiji), simplified and adorable'), negativePrompt: NEGATIVE_PROMPT_COMMON },
  { id: 'era_heian', category: 'era_icons', width: 200, height: 200, prompt: eraIconPrompt("a Heian-era court noble's ox-drawn carriage"), negativePrompt: NEGATIVE_PROMPT_COMMON },
  { id: 'era_kamakura', category: 'era_icons', width: 200, height: 200, prompt: eraIconPrompt('a friendly samurai helmet (kabuto) beside a small temple gate'), negativePrompt: NEGATIVE_PROMPT_COMMON },
  { id: 'era_muromachi', category: 'era_icons', width: 200, height: 200, prompt: eraIconPrompt('Kinkaku-ji (Golden Pavilion), simplified and shiny'), negativePrompt: NEGATIVE_PROMPT_COMMON },
  { id: 'era_azuchi', category: 'era_icons', width: 200, height: 200, prompt: eraIconPrompt('a small Japanese castle tower (Azuchi-Momoyama style)'), negativePrompt: NEGATIVE_PROMPT_COMMON },
  { id: 'era_edo', category: 'era_icons', width: 200, height: 200, prompt: eraIconPrompt('a small torii gate with cherry blossoms'), negativePrompt: NEGATIVE_PROMPT_COMMON },
  { id: 'era_meiji', category: 'era_icons', width: 200, height: 200, prompt: eraIconPrompt('a small Meiji-era Western-style brick building with a mini steam train'), negativePrompt: NEGATIVE_PROMPT_COMMON },
  { id: 'era_taisho', category: 'era_icons', width: 200, height: 200, prompt: eraIconPrompt('a Taisho-era Western lamp post beside a small modern building facade'), negativePrompt: NEGATIVE_PROMPT_COMMON },
  { id: 'era_showa', category: 'era_icons', width: 200, height: 200, prompt: eraIconPrompt('a friendly Tokyo Tower character'), negativePrompt: NEGATIVE_PROMPT_COMMON },
  { id: 'era_heisei', category: 'era_icons', width: 200, height: 200, prompt: eraIconPrompt('a small modern Japanese skyscraper skyline'), negativePrompt: NEGATIVE_PROMPT_COMMON },
  { id: 'era_reiwa', category: 'era_icons', width: 200, height: 200, prompt: eraIconPrompt('a small futuristic torii gate with soft sparkling light rays'), negativePrompt: NEGATIVE_PROMPT_COMMON },

  // ===== 13. 診断テーマ背景（5枚） =====
  {
    id: 'diagnosis_bg_sengoku',
    category: 'diagnosis_backgrounds',
    width: 1080,
    height: 600,
    prompt: diagnosisBgPrompt(
      'Sengoku-era warlords and samurai spirit',
      'chibi-style samurai armor and helmet, small cheerful war banners, a cute castle silhouette'
    ),
    negativePrompt: NEGATIVE_PROMPT_NO_TEXT,
  },
  {
    id: 'diagnosis_bg_philosopher',
    category: 'diagnosis_backgrounds',
    width: 1080,
    height: 600,
    prompt: diagnosisBgPrompt(
      'philosophers and deep thinkers',
      'small stack of books, a cute quill pen, a playful empty thought bubble, mini columns'
    ),
    negativePrompt: NEGATIVE_PROMPT_NO_TEXT,
  },
  {
    id: 'diagnosis_bg_leader',
    category: 'diagnosis_backgrounds',
    width: 1080,
    height: 600,
    prompt: diagnosisBgPrompt(
      'world leaders and global history',
      'a cheerful cartoon world map, small flags, a mini podium, colorful landmark silhouettes'
    ),
    negativePrompt: NEGATIVE_PROMPT_NO_TEXT,
  },
  {
    id: 'diagnosis_bg_artist',
    category: 'diagnosis_backgrounds',
    width: 1080,
    height: 600,
    prompt: diagnosisBgPrompt(
      'artists and creativity',
      'playful paintbrush strokes, a small palette, a cute sculpture shape, floating musical notes'
    ),
    negativePrompt: NEGATIVE_PROMPT_NO_TEXT,
  },
  {
    id: 'diagnosis_bg_inventor',
    category: 'diagnosis_backgrounds',
    width: 1080,
    height: 600,
    prompt: diagnosisBgPrompt(
      'inventors and scientists',
      'small friendly gears, a glowing cute lightbulb character, simple blueprint doodles, a mini telescope'
    ),
    negativePrompt: NEGATIVE_PROMPT_NO_TEXT,
  },
];

module.exports = { ASSETS };
