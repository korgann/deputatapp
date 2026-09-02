import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../navigation/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _iinCtrl = TextEditingController();
  String _pin = '';
  bool _isLoading = false;
  String _error = '';

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _iinCtrl.dispose();
    super.dispose();
  }

  void _onKey(String key) {
    if (key == 'del') {
      setState(() { if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1); });
      return;
    }
    if (_pin.length < 4) {
      setState(() => _pin += key);
      if (_pin.length == 4) _login();
    }
  }

  Future<void> _login() async {
    if (_phoneCtrl.text.length < 10 || _iinCtrl.text.length != 12) {
      setState(() { _error = 'Введите телефон и ИИН'; _pin = ''; });
      return;
    }
    setState(() { _isLoading = true; _error = ''; });
    final ok = await context.read<AppProvider>().login(
      phone: _phoneCtrl.text.trim(),
      iin: _iinCtrl.text.trim(),
      pin: _pin,
    );
    if (mounted) {
      if (ok) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
      } else {
        setState(() { _error = 'Неверные данные. Попробуйте снова.'; _pin = ''; _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A3D8F), Color(0xFF1565C0)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Icon(Icons.account_circle_outlined, size: 72, color: Colors.white),
                const SizedBox(height: 16),
                const Text('Вход в ДепутатApp', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                _inputField(_phoneCtrl, 'Номер телефона', '+7 (7xx) xxx-xx-xx', TextInputType.phone),
                const SizedBox(height: 12),
                _inputField(_iinCtrl, 'ИИН', '000000000000', TextInputType.number, maxLen: 12),
                const SizedBox(height: 28),
                const Text('Код доступа', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _pin.length ? Colors.white : Colors.transparent,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  )),
                ),
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_error, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ],
                const SizedBox(height: 28),
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  _buildKeypad(),
                const SizedBox(height: 16),
                const Text('Демо: любой телефон + 12 цифр ИИН + 4 цифры PIN',
                  style: TextStyle(color: Colors.white38, fontSize: 11), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, String hint, TextInputType type, {int? maxLen}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLength: maxLen,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withAlpha(26),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Colors.white.withAlpha(77))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Colors.white, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withAlpha(26), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _row(['1','2','3']),
          const SizedBox(height: 10),
          _row(['4','5','6']),
          const SizedBox(height: 10),
          _row(['7','8','9']),
          const SizedBox(height: 10),
          _row(['','0','del']),
        ],
      ),
    );
  }

  Widget _row(List<String> keys) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: keys.map((k) => GestureDetector(
      onTap: () { if (k.isNotEmpty) _onKey(k); },
      child: Container(
        width: 68, height: 52,
        decoration: BoxDecoration(
          color: k.isEmpty ? Colors.transparent : Colors.white.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: k == 'del'
            ? const Icon(Icons.backspace_outlined, color: Colors.white, size: 20)
            : k.isEmpty ? null
            : Text(k, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500)),
      ),
    )).toList(),
  );
}
