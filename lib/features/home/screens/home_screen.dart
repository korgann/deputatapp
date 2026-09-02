import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../deputies/screens/deputies_list_screen.dart';
import '../../blog/screens/blog_screen.dart';
import '../../polls/screens/polls_screen.dart';
import '../../reception/screens/reception_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../map/screens/map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final unread = provider.unreadNotificationsCount;
    final isDeputy = user?.isDeputy ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 70,
            floating: true,
            snap: true,
            backgroundColor: AppColors.primaryBlue,
            automaticallyImplyLeading: false,
            title: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(text: 'Депутат', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  TextSpan(text: 'app', style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            leading: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Главная', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 8, top: 8,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text('$unread', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 9)),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'Здравствуйте, ${user?.name.split(' ').first ?? 'Пользователь'}!',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ),
                // News Banner
                _NewsBanner(),
                const SizedBox(height: 16),
                // Quick actions
                _QuickActions(isDeputy: isDeputy),
                const SizedBox(height: 16),
                // My deputies (for voters)
                if (!isDeputy) _MyDeputiesSection(provider: provider),
                // Reception
                _ReceptionSection(),
                const SizedBox(height: 16),
                // Calendar
                _CalendarSection(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  onDaySelected: (sel, foc) => setState(() { _selectedDay = sel; _focusedDay = foc; }),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A3D8F), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20, bottom: -20,
            child: Icon(Icons.how_to_vote, size: 120, color: Colors.white.withAlpha(26)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('6 октября —', style: TextStyle(color: Colors.white70, fontSize: 13)),
                SizedBox(height: 4),
                Text(
                  'РЕСПУБЛИКАНСКИЙ\nРЕФЕРЕНДУМ\nпо строительству АЭС',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final bool isDeputy;
  const _QuickActions({required this.isDeputy});

  @override
  Widget build(BuildContext context) {
    final actions = isDeputy
        ? [
            _ActionItem(icon: Icons.article_outlined, label: 'Мой блог', color: const Color(0xFF1565C0), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BlogScreen()))),
            _ActionItem(icon: Icons.poll_outlined, label: 'Опросы', color: const Color(0xFF00897B), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PollsScreen()))),
            _ActionItem(icon: Icons.event_outlined, label: 'Приём', color: const Color(0xFFE65100), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceptionScreen()))),
            _ActionItem(icon: Icons.map_outlined, label: 'Карта', color: const Color(0xFF6A1B9A), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()))),
          ]
        : [
            _ActionItem(icon: Icons.article_outlined, label: 'Новости', color: const Color(0xFF1565C0), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BlogScreen()))),
            _ActionItem(icon: Icons.poll_outlined, label: 'Опросы', color: const Color(0xFF00897B), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PollsScreen()))),
            _ActionItem(icon: Icons.event_outlined, label: 'Приём', color: const Color(0xFFE65100), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceptionScreen()))),
            _ActionItem(icon: Icons.map_outlined, label: 'Карта', color: const Color(0xFF6A1B9A), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()))),
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: actions.map((a) => Expanded(child: a)).toList(),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MyDeputiesSection extends StatelessWidget {
  final AppProvider provider;
  const _MyDeputiesSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final myDeputies = provider.myDeputies;
    if (myDeputies.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Мои депутаты', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeputiesListScreen())),
                child: const Text('Все депутаты', style: TextStyle(color: AppColors.primaryBlue, fontSize: 12)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: myDeputies.length,
            itemBuilder: (ctx, i) {
              final d = myDeputies[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/deputy', arguments: d),
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6)],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryBlue,
                        radius: 22,
                        child: Text(d.avatarInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(d.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(d.levelLabel, style: const TextStyle(fontSize: 10, color: AppColors.textGrey), maxLines: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ReceptionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('График приём граждан', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                SizedBox(height: 4),
                Text('Понедельник, среда: 10:00–13:00', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceptionScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
            child: const Text('Записаться'),
          ),
        ],
      ),
    );
  }
}

class _CalendarSection extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final void Function(DateTime, DateTime) onDaySelected;

  const _CalendarSection({required this.focusedDay, required this.selectedDay, required this.onDaySelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Календарь', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2027, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: onDaySelected,
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: AppColors.lightBlue.withAlpha(128), shape: BoxShape.circle),
              weekendTextStyle: const TextStyle(color: Colors.red),
              selectedTextStyle: const TextStyle(color: Colors.white),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}
