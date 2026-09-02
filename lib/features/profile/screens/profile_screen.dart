import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';
import '../../auth/screens/role_selection_screen.dart';
import '../../notifications/screens/notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A3D8F), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white.withAlpha(51),
                      child: Text(
                        user.name.isNotEmpty ? user.name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join() : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    Text(user.isDeputy ? (user.position ?? 'Депутат') : 'Избиратель',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ]),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                const SizedBox(height: 8),
                _InfoSection(user: user),
                const SizedBox(height: 16),
                _MenuSection(user: user),
                const SizedBox(height: 24),
                _LogoutButton(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final UserModel user;
  const _InfoSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _infoRow(Icons.phone_outlined, 'Телефон', user.phone),
          _infoRow(Icons.badge_outlined, 'ИИН', '${user.iin.substring(0, 4)}••••••••'),
          _infoRow(Icons.location_on_outlined, 'Регион', user.region),
          _infoRow(Icons.location_city_outlined, 'Город', user.city),
          _infoRow(Icons.domain_outlined, 'Округ', user.district),
          _infoRow(Icons.home_outlined, 'Адрес', user.address),
          if (user.isDeputy) ...[
            if (user.party != null) _infoRow(Icons.flag_outlined, 'Партия', user.party!),
            if (user.position != null) _infoRow(Icons.work_outline, 'Должность', user.position!),
            if (user.organization != null) _infoRow(Icons.business_outlined, 'Организация', user.organization!),
          ],
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(icon, size: 18, color: AppColors.primaryBlue),
      const SizedBox(width: 12),
      SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 13))),
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(20)),
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
        ),
      ),
    ]),
  );
}

class _MenuSection extends StatelessWidget {
  final UserModel user;
  const _MenuSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        _MenuItem(icon: Icons.edit_outlined, label: 'Редактировать профиль', onTap: () {}),
        const Divider(height: 1, indent: 56),
        _MenuItem(icon: Icons.lock_outlined, label: 'Сменить код доступа', onTap: () {}),
        const Divider(height: 1, indent: 56),
        _MenuItem(icon: Icons.notifications_outlined, label: 'Уведомления', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
        const Divider(height: 1, indent: 56),
        _MenuItem(icon: Icons.help_outline, label: 'Помощь', onTap: () {}),
        const Divider(height: 1, indent: 56),
        _MenuItem(icon: Icons.info_outline, label: 'О приложении', onTap: () => _showAbout(context)),
      ]),
    );
  }

  void _showAbout(BuildContext context) => showAboutDialog(
    context: context,
    applicationName: 'ДепутатApp',
    applicationVersion: '1.0.0',
    applicationLegalese: '© 2026 ДепутатApp Kazakhstan',
    children: const [
      SizedBox(height: 8),
      Text('Приложение для взаимодействия избирателей с депутатами Казахстана.'),
    ],
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.primaryBlue),
    title: Text(label, style: const TextStyle(fontSize: 14)),
    trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey, size: 20),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
  );
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Выйти из аккаунта?'),
              content: const Text('Вы уверены, что хотите выйти?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
                ElevatedButton(
                  onPressed: () {
                    context.read<AppProvider>().logout();
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const RoleSelectionScreen()), (_) => false);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: const Text('Выйти'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text('Выйти из аккаунта', style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
