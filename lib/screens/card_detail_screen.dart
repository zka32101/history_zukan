import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_zukan/models/index.dart';
import 'package:history_zukan/providers/seed_data_provider.dart';
import 'causal_chain_screen.dart';
import 'person_detail_screen.dart';
import 'person_chat_screen.dart'; // Phase 2: D1

class CardDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const CardDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends ConsumerState<CardDetailScreen> {
  late Map<int, String?> _userAnswers;
  late Set<int> _revealedPoints;

  @override
  void initState() {
    super.initState();
    _userAnswers = {};
    _revealedPoints = {};
  }

  HistoryEvent _mockFallback() {
    return HistoryEvent(
      id: widget.eventId,
      title: '本能寺の変',
      titleReading: 'ほんのうじのへん',
      description:
          '天正10年（1582年）、織田信長は京都の本能寺に宿泊していた。その時、配下の明智光秀が謀反を企て、信長を襲撃した。信長は…',
      year: 1582,
      yearDisplay: '天正10年',
      era: '戦国時代',
      regionJp: '京都',
      regionWorld: 'アジア',
      country: '日本',
      locationName: '京都府京都市中京区',
      themeIds: ['politics', 'military'],
      tags: ['戦国', '信長'],
      relatedEventIds: ['event_002', 'event_003'],
      relatedPersonIds: ['person_j001', 'person_j002'],
      imageUrl: 'https://via.placeholder.com/400x300?text=Honno-ji+Incident',
      historyType: 'event',
      isPremium: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      searchKeywords: ['本能寺', '信長', '光秀'],
      source: 'history-db-v1',
      isVerified: true,
      wowFactor: '天下統一まであと一歩だった信長が、まさかの部下による裏切りで倒された！',
      howItChanged: 'この後、秀吉が天下を取り、日本は戦国時代から安土桃山時代へ大きく変わった。',
      quizPoints: [
        QuizPoint(
          characterOffset: 50,
          question: 'この後、明智光秀はどうなったと思う？',
          choices: [
            '光秀は逃亡に成功した',
            '光秀は信長に倒された',
            '光秀は天下を統一した',
          ],
          correctAnswer: '光秀は逃亡に成功したが、その後秀吉に滅ぼされた',
          explanation:
              '実際には光秀は信長に倒されず逃亡しました。しかし11日後、秀吉の追撃で滅ぼされてしまいました。',
          countAsCorrect: true,
        ),
        QuizPoint(
          characterOffset: 100,
          question: '信長の後継者は誰になった？',
          choices: [
            '明智光秀',
            '豊臣秀吉',
            '徳川家康',
          ],
          correctAnswer: '豊臣秀吉が信長の遺志を継いで天下を統一した',
          explanation: '秀吉は信長の後を継ぎ、1590年に全国統一を達成しました。',
          countAsCorrect: true,
        ),
      ],
      month: 6,
      day: 21,
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(seedEventByIdProvider(widget.eventId)) ?? _mockFallback();
    final allPersons = ref.watch(seedPersonsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('歴史カード詳細'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero image
            Container(
              height: 220,
              color: Colors.grey[300],
              child: Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.brown.shade100,
                    child: Center(
                      child: Text(
                        event.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Title section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.titleReading,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Chip(
                        label: Text(event.yearDisplay),
                        avatar: const Icon(Icons.calendar_today, size: 14),
                      ),
                      Chip(label: Text(event.era)),
                      if (event.country.isNotEmpty)
                        Chip(
                          label: Text(event.country),
                          avatar: const Icon(Icons.flag, size: 14),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // WOW factor
            if (event.wowFactor != null) _buildWowFactor(context, event.wowFactor!),

            // A3: Description with embedded quiz points
            _buildDescriptionWithQuizPoints(event),

            // How it changed
            if (event.howItChanged != null) _buildHowItChanged(context, event.howItChanged!),

            // Related persons
            if (event.relatedPersonIds.isNotEmpty)
              _buildRelatedPersons(context, event.relatedPersonIds, allPersons),

            // Tags / 関連する歴史
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '関連する歴史',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: event.tags.map((tag) => Chip(label: Text(tag))).toList(),
                  ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (event.causalChainIds != null && event.causalChainIds!.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CausalChainScreen(
                            chainId: event.causalChainIds!.first,
                          ),
                        ));
                      },
                      icon: const Icon(Icons.trending_down),
                      label: const Text('このストーリーをたどる'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.trending_down),
                      label: const Text('関連ストーリーなし'),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('お気に入りに追加しました')),
                      );
                    },
                    icon: const Icon(Icons.favorite_outline),
                    label: const Text('お気に入りに追加'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWowFactor(BuildContext context, String wowFactor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚡', style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'これがすごい！',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  wowFactor,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItChanged(BuildContext context, String howItChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🔄', style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'どう変わった？',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  howItChanged,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedPersons(
      BuildContext context, List<String> personIds, List<HistoryPerson> allPersons) {
    final persons = allPersons.where((p) => personIds.contains(p.id)).toList();
    if (persons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, size: 20, color: Colors.blue.shade700),
              const SizedBox(width: 6),
              Text(
                '関わった人物',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: persons.map((person) {
              return GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PersonDetailScreen(personId: person.id),
                )),
                child: Chip(
                  avatar: const Icon(Icons.person, size: 16),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      if (person.whatTheyDid != null)
                        Text(
                          person.whatTheyDid!.length > 20
                              ? '${person.whatTheyDid!.substring(0, 20)}…'
                              : person.whatTheyDid!,
                          style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                        ),
                    ],
                  ),
                  backgroundColor: Colors.blue.shade50,
                  side: BorderSide(color: Colors.blue.shade200),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDescriptionWithQuizPoints(HistoryEvent event) {
    if (event.quizPoints == null || event.quizPoints!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          event.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(left: BorderSide(width: 4, color: Colors.blue)),
            ),
            child: Text(
              '💡 ここで立ち止まって考えてみよう！下のクイズに答えてから続きを読んでください。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(event.quizPoints!.length, (index) {
            final point = event.quizPoints![index];
            final isRevealed = _revealedPoints.contains(index);
            final userAnswer = _userAnswers[index];

            return _buildQuizPointCard(
              point: point,
              pointIndex: index,
              isRevealed: isRevealed,
              userAnswer: userAnswer,
              onAnswerSelected: (choice) {
                setState(() {
                  _userAnswers[index] = choice;
                  _revealedPoints.add(index);
                });
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuizPointCard({
    required QuizPoint point,
    required int pointIndex,
    required bool isRevealed,
    required String? userAnswer,
    required Function(String) onAnswerSelected,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              point.question,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            if (!isRevealed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(point.choices.length, (choiceIndex) {
                  final choice = point.choices[choiceIndex];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: OutlinedButton(
                      onPressed: () => onAnswerSelected(choice),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('${String.fromCharCode(65 + choiceIndex)}) $choice'),
                      ),
                    ),
                  );
                }),
              ),
            if (isRevealed && userAnswer != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'あなたの予想: $userAnswer',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '実際のこと:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            point.correctAnswer,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            point.explanation,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
