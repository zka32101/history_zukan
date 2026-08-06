import 'package:flutter/material.dart';

/// 歴史図鑑 デザインシステム — 統一トークン集
/// 色・余白・角丸・影・タイポグラフィを一元管理し、画面間の一貫性を保つ。
class AppColors {
  AppColors._();

  // ブランドカラー（紫系グラデーション基調）
  static const Color primary = Color(0xFF6A1B9A);
  static const Color primaryLight = Color(0xFF9C4DCC);
  static const Color primaryDark = Color(0xFF38006B);

  // 機能別アクセントカラー
  static const Color gachaGold = Color(0xFFFFB300);
  static const Color gachaPink = Color(0xFFEC407A);
  static const Color streakRed = Color(0xFFE53935);
  static const Color streakOrange = Color(0xFFFB8C00);
  static const Color diagnosisPurple = Color(0xFF7C4DFF);
  static const Color diagnosisIndigo = Color(0xFF5C6BC0);
  static const Color puzzleTeal = Color(0xFF00897B);
  static const Color puzzleCyan = Color(0xFF00ACC1);

  // レアリティカラー（ガチャ）
  static const Color rarityN = Color(0xFF90A4AE);
  static const Color rarityR = Color(0xFFCD7F32);
  static const Color raritySR = Color(0xFFB0BEC5);
  static const Color raritySSR = Color(0xFFFFD700);

  static Color rarityColor(int rarity) {
    switch (rarity) {
      case 4:
        return raritySSR;
      case 3:
        return raritySR;
      case 2:
        return rarityR;
      default:
        return rarityN;
    }
  }

  // ニュートラル
  static const Color surfaceLight = Color(0xFFFAF7FC);
  static const Color surfaceDark = Color(0xFF1E1B24);
  static const Color textMuted = Color(0xFF8A8A8A);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryLight],
  );

  static const LinearGradient gacha = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gachaGold, AppColors.gachaPink],
  );

  static const LinearGradient streak = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.streakRed, AppColors.streakOrange],
  );

  static const LinearGradient diagnosis = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.diagnosisPurple, AppColors.diagnosisIndigo],
  );

  static const LinearGradient puzzle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.puzzleTeal, AppColors.puzzleCyan],
  );

  static LinearGradient rarity(int rarityLevel) {
    final base = AppColors.rarityColor(rarityLevel);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [base, base.withValues(alpha: 0.55)],
    );
  }
}

/// AI生成アセットのパス解決ヘルパー
class AppAssets {
  AppAssets._();

  static String eraIcon(String eraId) => 'assets/images/era_icons/era_$eraId.png';
  static String mascot(String pose) => 'assets/images/mascot/mascot_$pose.png';
  static String gachaFrame(int rarity) {
    final label = switch (rarity) {
      4 => 'ssr',
      3 => 'sr',
      2 => 'r',
      _ => 'n',
    };
    return 'assets/images/gacha_frames/gacha_frame_$label.png';
  }
  static String diagnosisBg(String theme) => 'assets/images/diagnosis_backgrounds/diagnosis_bg_$theme.png';

  /// 診断のテーマ表示名（例: "戦国武将タイプ"）から背景画像キーを解決する。
  /// 一致しないテーマは null を返す（呼び出し側でグラデーションのみにフォールバック）。
  static String? diagnosisBgForThemeName(String themeName) {
    const table = {
      '戦国武将': 'sengoku',
      '思想家': 'philosopher',
      'リーダー': 'leader',
      '芸術家': 'artist',
      '発明家': 'inventor',
      '科学者': 'inventor',
    };
    for (final entry in table.entries) {
      if (themeName.contains(entry.key)) return diagnosisBg(entry.value);
    }
    return null;
  }
  static String personPlaceholder(String key) => 'assets/images/person_placeholders/person_$key.png';
}

class AppRadius {
  AppRadius._();

  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double pill = 999;

  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> soft(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}

/// グラデーション背景 + 影付きのブランド統一カード。
/// 各ミニゲーム画面のヘッダーやハイライト表示に使う。
class GradientPanel extends StatelessWidget {
  final Gradient gradient;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  final String? backgroundImage;

  const GradientPanel({
    required this.gradient,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = AppRadius.lg,
    this.backgroundImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = (gradient is LinearGradient)
        ? (gradient as LinearGradient).colors.first
        : AppColors.primary;
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppShadows.soft(baseColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (backgroundImage != null)
            Positioned.fill(
              child: Image.asset(
                backgroundImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          if (backgroundImage != null)
            Positioned.fill(
              child: Container(color: baseColor.withValues(alpha: 0.35)),
            ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// ミニゲーム／機能導線用の統一カード。
class FeatureEntryCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;
  final Widget? trailing;

  const FeatureEntryCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final accent = (gradient is LinearGradient)
        ? (gradient as LinearGradient).colors.first
        : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppRadius.mdRadius,
            boxShadow: AppShadows.card,
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: AppRadius.smRadius,
                  boxShadow: AppShadows.soft(accent),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ?? Icon(Icons.chevron_right, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

/// レアリティ・ステータス表示用のピル型バッジ。
class AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const AppBadge({required this.label, required this.color, this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.smRadius,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
