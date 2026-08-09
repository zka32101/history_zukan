import 'package:flutter/material.dart';

class ThemeBadge extends StatelessWidget {
  final String themeId;

  const ThemeBadge(this.themeId, {super.key});

  ({IconData icon, Color color, String label}) _getThemeInfo(String id) {
    const themes = {
      'politics': (icon: Icons.account_balance, color: Color(0xFF1976D2), label: '政治'),
      'culture': (icon: Icons.palette, color: Color(0xFF7B1FA2), label: '文化'),
      'arts': (icon: Icons.brush, color: Color(0xFFC2185B), label: '芸術'),
      'science': (icon: Icons.science, color: Color(0xFF0097A7), label: '科学'),
      'economics': (icon: Icons.trending_up, color: Color(0xFFF57C00), label: '経済'),
      'military': (icon: Icons.shield, color: Color(0xFFD32F2F), label: '軍事'),
      'religion': (icon: Icons.sentiment_satisfied, color: Color(0xFF558B2F), label: '宗教'),
      'education': (icon: Icons.school, color: Color(0xFF6A1B9A), label: '教育'),
      'social': (icon: Icons.group, color: Color(0xFF00796B), label: '社会'),
    };
    return themes[id] ?? (icon: Icons.info, color: const Color(0xFF9E9E9E), label: 'その他');
  }

  @override
  Widget build(BuildContext context) {
    final info = _getThemeInfo(themeId);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: info.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: info.color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            info.icon,
            size: 12,
            color: info.color,
          ),
          const SizedBox(width: 4),
          Text(
            info.label,
            style: TextStyle(
              fontSize: 10,
              color: info.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
