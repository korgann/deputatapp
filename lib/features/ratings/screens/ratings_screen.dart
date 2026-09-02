import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/deputy_model.dart';
import '../../deputies/screens/deputy_profile_screen.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _selectedRegion = 'Все';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final top10 = provider.getTop10Deputies();
    final allByRating = provider.deputiesByRating;

    final regions = ['Все', ...{for (final d in allByRating) d.region}];
    final filtered = _selectedRegion == 'Все' ? allByRating : allByRating.where((d) => d.region == _selectedRegion).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Рейтинг депутатов'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF4FC3F7),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Топ-10'),
            Tab(text: 'Все'),
            Tab(text: 'Регионы'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // Top 10
          _Top10List(deputies: top10),
          // All
          _AllDeputiesList(deputies: allByRating),
          // By Region
          Column(children: [
            _RegionFilter(regions: regions, selected: _selectedRegion, onChanged: (v) => setState(() => _selectedRegion = v)),
            Expanded(child: _AllDeputiesList(deputies: filtered)),
          ]),
        ],
      ),
    );
  }
}

class _Top10List extends StatelessWidget {
  final List<DeputyModel> deputies;
  const _Top10List({required this.deputies});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Podium for top 3
        if (deputies.length >= 3) _Podium(deputies: deputies.take(3).toList()),
        const SizedBox(height: 16),
        // Rest of top 10
        ...deputies.asMap().entries.map((e) => _RankCard(rank: e.key + 1, deputy: e.value)),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  final List<DeputyModel> deputies;
  const _Podium({required this.deputies});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0A3D8F), Color(0xFF1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        const Text('Лучшие депутаты', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.end, children: [
          _PodiumItem(deputy: deputies[1], rank: 2, height: 70),
          _PodiumItem(deputy: deputies[0], rank: 1, height: 90),
          _PodiumItem(deputy: deputies[2], rank: 3, height: 55),
        ]),
      ]),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final DeputyModel deputy;
  final int rank;
  final double height;

  const _PodiumItem({required this.deputy, required this.rank, required this.height});

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.amber, Colors.grey[300]!, Colors.brown[300]!];
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DeputyProfileScreen(deputy: deputy))),
      child: Column(children: [
        CircleAvatar(
          radius: rank == 1 ? 28 : 22,
          backgroundColor: Colors.white.withAlpha(51),
          child: Text(deputy.avatarInitials, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: rank == 1 ? 16 : 13)),
        ),
        const SizedBox(height: 6),
        Text(deputy.name.split(' ').first, style: const TextStyle(color: Colors.white, fontSize: 11), textAlign: TextAlign.center),
        Text('${deputy.ratingScore.toStringAsFixed(0)}%', style: TextStyle(color: colors[rank - 1], fontSize: 11, fontWeight: FontWeight.bold)),
        Container(
          width: 60, height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors[rank - 1].withAlpha(77),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Text('$rank', style: TextStyle(color: colors[rank - 1], fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}

class _AllDeputiesList extends StatelessWidget {
  final List<DeputyModel> deputies;
  const _AllDeputiesList({required this.deputies});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deputies.length,
      itemBuilder: (ctx, i) => _RankCard(rank: i + 1, deputy: deputies[i]),
    );
  }
}

class _RankCard extends StatelessWidget {
  final int rank;
  final DeputyModel deputy;

  const _RankCard({required this.rank, required this.deputy});

  Color get _rankColor {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.brown;
    return AppColors.textGrey;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DeputyProfileScreen(deputy: deputy))),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            SizedBox(width: 32, child: Text('$rank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _rankColor))),
            CircleAvatar(
              backgroundColor: AppColors.primaryBlue, radius: 20,
              child: Text(deputy.avatarInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(deputy.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${deputy.city} · ${deputy.party}', style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(children: [
                Icon(Icons.star, size: 14, color: Colors.amber[600]),
                const SizedBox(width: 3),
                Text(deputy.voterRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ]),
              Text('${deputy.ratingScore.toStringAsFixed(0)}% выполнено', style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _RegionFilter extends StatelessWidget {
  final List<String> regions;
  final String selected;
  final void Function(String) onChanged;

  const _RegionFilter({required this.regions, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: regions.length,
        itemBuilder: (ctx, i) {
          final r = regions[i];
          final isSelected = r == selected;
          return GestureDetector(
            onTap: () => onChanged(r),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.grey[300]!),
              ),
              child: Text(r, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textDark, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
            ),
          );
        },
      ),
    );
  }
}
