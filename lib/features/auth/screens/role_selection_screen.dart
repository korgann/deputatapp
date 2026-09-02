import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'voter_registration_screen.dart';
import 'deputy_registration_screen.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A3D8F), Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const Icon(Icons.account_balance, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Депутат',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      TextSpan(
                        text: 'app',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4FC3F7)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Регистрация',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const Spacer(flex: 2),
                _RoleButton(
                  label: 'Депутат',
                  icon: Icons.how_to_vote_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DeputyRegistrationScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                _RoleButton(
                  label: 'Избиратель',
                  icon: Icons.person_outline,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VoterRegistrationScreen()),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text(
                    'Уже есть аккаунт? Войти',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.primaryBlue),
        label: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
      ),
    );
  }
}
