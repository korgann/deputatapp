import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/deputy_model.dart';
import '../../deputies/screens/deputy_profile_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _selectedRegion;

  final Map<String, Color> _regionColors = {
    'Абай область': const Color(0xFF1565C0),
    'Акмолинская область': const Color(0xFF2E7D32),
    'Актюбинская область': const Color(0xFF6A1B9A),
    'Алматинская область': const Color(0xFFE65100),
    'Атырауская область': const Color(0xFF00838F),
    'Астана': const Color(0xFFC62828),
    'Алматы': const Color(0xFF37474F),
    'Шымкент': const Color(0xFF558B2F),
    'Карагандинская область': const Color(0xFF4527A0),
    'Костанайская область': const Color(0xFF00695C),
    'Кызылординская область': const Color(0xFFAD1457),
    'Мангистауская область': const Color(0xFF0277BD),
    'Павлодарская область': const Color(0xFF283593),
    'Северо-Казахстанская область': const Color(0xFF4E342E),
    'Туркестанская область': const Color(0xFF1B5E20),
    'Восточно-Казахстанская область': const Color(0xFF880E4F),
    'Жамбылская область': const Color(0xFF33691E),
    'Жетысуская область': const Color(0xFFBF360C),
    'Западно-Казахстанская область': const Color(0xFF006064),
    'Улытауская область': const Color(0xFF311B92),
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final deputies = provider.deputies;

    final regionDeputies = _selectedRegion != null
        ? deputies.where((d) => d.region == _selectedRegion).toList()
        : <DeputyModel>[];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Карта округов'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(children: [
        // Map placeholder
        Container(
          margin: const EdgeInsets.all(16),
          height: 220,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4FD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightBlue.withAlpha(77)),
          ),
          child: Stack(children: [
            Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.map_outlined, size: 60, color: AppColors.primaryBlue.withAlpha(77)),
                const SizedBox(height: 8),
                const Text('Карта Казахстана', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                const SizedBox(height: 4),
                const Text('Выберите регион ниже', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
              ]),
            ),
            // Decorative circles representing regions
            ...List.generate(6, (i) {
              final positions = [
                const Offset(0.2, 0.3), const Offset(0.5, 0.4), const Offset(0.7, 0.3),
                const Offset(0.3, 0.6), const Offset(0.6, 0.6), const Offset(0.8, 0.5),
              ];
              final colors = [const Color(0xFF1565C0), const Color(0xFF2E7D32), const Color(0xFF6A1B9A),
                const Color(0xFFE65100), const Color(0xFF00838F), const Color(0xFFC62828)];
              return Positioned(
                left: positions[i].dx * 300,
                top: positions[i].dy * 180,
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: colors[i].withAlpha(179), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.location_on, size: 14, color: Colors.white),
                ),
              );
            }),
          ]),
        ),
        // Region selector
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Выберите регион', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: _regionColors.keys.length,
            itemBuilder: (ctx, i) {
              final region = _regionColors.keys.elementAt(i);
              final isSelected = region == _selectedRegion;
              final color = _regionColors[region]!;
              return GestureDetector(
                onTap: () => setState(() => _selectedRegion = isSelected ? null : region),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? color : Colors.grey[300]!),
                  ),
                  child: Text(region, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textDark, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Deputies in selected region
        if (_selectedRegion != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Container(width: 4, height: 16, color: _regionColors[_selectedRegion]!, margin: const EdgeInsets.only(right: 8)),
              Text(_selectedRegion!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const Spacer(),
              Text('${regionDeputies.length} депутатов', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: regionDeputies.isEmpty
                ? Center(child: Text('Нет депутатов для $_selectedRegion', style: const TextStyle(color: AppColors.textGrey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: regionDeputies.length,
                    itemBuilder: (ctx, i) {
                      final d = regionDeputies[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _regionColors[_selectedRegion] ?? AppColors.primaryBlue,
                            child: Text(d.avatarInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('${d.levelLabel} · Округ №${d.districtNumber}', style: const TextStyle(fontSize: 11)),
                          trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DeputyProfileScreen(deputy: d))),
                        ),
                      );
                    },
                  ),
          ),
        ] else
          Expanded(
            child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.touch_app, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 8),
                const Text('Выберите регион для просмотра депутатов', style: TextStyle(color: AppColors.textGrey, fontSize: 13), textAlign: TextAlign.center),
              ]),
            ),
          ),
      ]),
    );
  }
}
