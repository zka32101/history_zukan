import 'package:flutter/material.dart';
import 'package:history_zukan/widgets/gradient_app_bar.dart';

class _HelpItem {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _HelpItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}

const List<_HelpItem> _helpItems = [
  _HelpItem(
    icon: Icons.public,
    color: Colors.blue,
    title: '世界同時パノラマ',
    description: '年を選ぶと、その年に世界のどこで何が起きていたかを一度に見られます。同じ時代の日本と世界を比べてみましょう。',
  ),
  _HelpItem(
    icon: Icons.person_outline,
    color: Colors.green,
    title: '自分年表',
    description: '生年月日を入力すると、あなたの人生と歴史上の出来事を重ねたタイムラインが作れます。生年月日は端末内だけに保存され、外部には送信されません。',
  ),
  _HelpItem(
    icon: Icons.location_on,
    color: Colors.red,
    title: 'ここ歴史',
    description: '今いる場所の近くにある歴史的な出来事や史跡を探せます。位置情報は距離の計算にだけ使い、サーバーには送信しません。',
  ),
  _HelpItem(
    icon: Icons.library_books,
    color: Colors.deepPurple,
    title: '図鑑（人物検索）',
    description: '300人の歴史人物を検索・絞り込みできます。国やテーマ、名前で探してみましょう。',
  ),
  _HelpItem(
    icon: Icons.palette,
    color: Colors.orange,
    title: 'テーマ別学習',
    description: '政治・文化・科学など9つのテーマから、興味のある切り口で歴史を学べます。',
  ),
  _HelpItem(
    icon: Icons.casino,
    color: Colors.amber,
    title: '今日の偉人',
    description: '1日1回、歴史上の人物と出会えるコーナーです。得点や競争の要素はなく、集めることを楽しむための機能です。',
  ),
  _HelpItem(
    icon: Icons.quiz,
    color: Colors.teal,
    title: 'クイズ・パズル・診断',
    description: 'カードの途中に出てくるクイズや、人物のつながりを当てるパズル、あなたの歴史人物タイプがわかる診断など、遊びながら学べるコーナーです。正解・不正解よりも「考えてみること」を大事にしています。',
  ),
  _HelpItem(
    icon: Icons.local_fire_department,
    color: Colors.deepOrange,
    title: 'ログインストリーク',
    description: '毎日開くと、縄文時代から令和時代まで少しずつ時代が進んでいきます。',
  ),
  _HelpItem(
    icon: Icons.bedtime,
    color: Colors.indigo,
    title: '寝る前歴史',
    description: '読み上げ機能で、寝る前にゆっくり歴史の話を聞けます。',
  ),
  _HelpItem(
    icon: Icons.dark_mode,
    color: Colors.blueGrey,
    title: 'ダークモード',
    description: '右上のアイコンから、目にやさしいダークモードに切り替えられます。',
  ),
];

/// 使い方説明画面
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: '使い方ガイド'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _helpItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _helpItems[index];
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: item.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
