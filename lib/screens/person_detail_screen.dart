import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_zukan/models/index.dart';
import 'package:history_zukan/providers/seed_data_provider.dart';
import 'card_detail_screen.dart';
import 'person_chat_screen.dart';

class PersonDetailScreen extends ConsumerWidget {
  final String personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final person = ref.watch(seedPersonByIdProvider(personId));

    if (person == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('人物詳細')),
        body: const Center(child: Text('人物が見つかりませんでした')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, person),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 画像クレジット表示
                if (person.imageAttribution != null || person.imageLicense != null)
                  _buildImageCredit(context, person),
                if (person.whatTheyDid != null)
                  _buildWhatTheyDid(context, person.whatTheyDid!),
                _buildBasicInfo(context, person),
                if (person.lifeTimeline != null && person.lifeTimeline!.isNotEmpty)
                  _buildLifeTimeline(context, person.lifeTimeline!),
                if (person.keyRelationships != null && person.keyRelationships!.isNotEmpty)
                  _buildKeyRelationships(context, person.keyRelationships!),
                if (person.famousQuotes != null && person.famousQuotes!.isNotEmpty)
                  _buildFamousQuotes(context, person.famousQuotes!),
                if (person.extendedDescription != null)
                  _buildExtendedDescription(context, person.extendedDescription!),
                if (person.relatedEventIds.isNotEmpty)
                  _buildRelatedEvents(context, ref, person.relatedEventIds),
                if (person.hasAiChat)
                  _buildAiChatButton(context, person),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, HistoryPerson person) {
    final years = [
      if (person.birthYear != null) person.birthYear!,
      if (person.deathYear != null) person.deathYear!,
    ].join('〜');

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          person.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              person.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.amber.shade100,
                child: Center(
                  child: Text(
                    person.name[0],
                    style: const TextStyle(fontSize: 80, color: Colors.amber),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            if (years.isNotEmpty)
              Positioned(
                bottom: 52,
                left: 16,
                child: Text(
                  years,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCredit(BuildContext context, HistoryPerson person) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.image, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  '画像情報',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (person.imageAttribution != null)
              Text(
                '© ${person.imageAttribution}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (person.imageLicense != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'ライセンス: ${person.imageLicense}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            if (person.imageSourceUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: GestureDetector(
                  onTap: () {
                    // TODO: Open image source URL in browser
                  },
                  child: Text(
                    '出典を見る →',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatTheyDid(BuildContext context, String whatTheyDid) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 6),
              Text(
                'この人はどんな人？',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            whatTheyDid,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context, HistoryPerson person) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            person.nameReading,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(
                label: Text(person.country),
                avatar: const Icon(Icons.flag, size: 16),
              ),
              ...person.themeIds.take(3).map(
                (t) => Chip(label: Text(_themeLabel(t))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            person.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLifeTimeline(BuildContext context, Map<String, String> timeline) {
    final entries = timeline.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, Icons.timeline, 'できごとの年表'),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final entry = entries[i];
            final isLast = i == entries.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 56,
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber.shade700, width: 2),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(width: 2, color: Colors.amber.shade200),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      child: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildKeyRelationships(BuildContext context, Map<String, String> relationships) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, Icons.people, '関わった人たち'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: relationships.entries.map((e) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          e.key,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e.value,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFamousQuotes(BuildContext context, List<String> quotes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, Icons.format_quote, '名言・ことば'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: quotes.map((quote) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  border: Border(
                    left: BorderSide(color: Colors.purple.shade300, width: 4),
                  ),
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                ),
                child: Text(
                  '「$quote」',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.purple.shade900,
                    height: 1.6,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildExtendedDescription(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(Icons.auto_stories, color: Colors.teal.shade600, size: 20),
            const SizedBox(width: 8),
            const Text('もっと詳しく', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.7),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRelatedEvents(
      BuildContext context, WidgetRef ref, List<String> eventIds) {
    final allEvents = ref.watch(seedEventsProvider);
    final events = allEvents.where((e) => eventIds.contains(e.id)).toList();

    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, Icons.history_edu, '関わったできごと'),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length,
            itemBuilder: (context, i) {
              final event = events[i];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CardDetailScreen(eventId: event.id),
                )),
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.yearDisplay,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(event.era, style: const TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAiChatButton(BuildContext context, HistoryPerson person) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PersonChatScreen(person: person),
        )),
        icon: const Icon(Icons.chat_bubble_outline),
        label: Text('${person.name}に話しかける'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.brown.shade600),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade800,
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(String themeId) {
    const labels = {
      'politics': '政治',
      'military': '戦争',
      'culture': '文化',
      'religion': '宗教',
      'science': '科学',
      'economy': '経済',
      'exploration': '探検',
      'human_rights': '人権',
      'education': '教育',
      'art': '芸術',
      'diplomacy': '外交',
      'reform': '改革',
      'agriculture': '農業',
      'daily_life': '生活',
      'change': '変革',
      'law': '法律',
      'government': '政府',
      'democracy': '民主主義',
      'peace': '平和',
    };
    return labels[themeId] ?? themeId;
  }
}
