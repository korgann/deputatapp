import 'package:flutter/material.dart';
import 'pin_screen.dart';

class SmsVerificationScreen extends StatefulWidget {
  final String phone;
  final Future<void> Function(String pin) onVerified;

  const SmsVerificationScreen({super.key, required this.phone, required this.onVerified});

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  final List<TextEditingController> _ctrls = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;
  String _error = '';

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _nodes[index + 1].requestFocus();
    }
    if (_getCode().length == 4) _verify();
  }

  String _getCode() => _ctrls.map((c) => c.text).join();

  void _verify() async {
    final code = _getCode();
    // Mock: accept '1234'
    if (code == '1234') {
      setState(() => _isLoading = true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PinScreen(
            isSetup: true,
            onPinConfirmed: widget.onVerified,
          ),
        ),
      );
      setState(() => _isLoading = false);
    } else {
      setState(() => _error = 'Неверный код. Попробуйте 1234');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A3D8F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.sms_outlined, size: 64, color: Colors.white),
            const SizedBox(height: 24),
            const Text('Подтверждение', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Введите код из SMS,\nотправленного на ${widget.phone}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text('(Тест: используйте код 1234)', style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 12)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (i) => _OtpBox(ctrl: _ctrls[i], node: _nodes[i], onChanged: (v) => _onDigitEntered(i, v))),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(_error, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
            ],
            const SizedBox(height: 32),
            if (_isLoading) const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode node;
  final void Function(String) onChanged;

  const _OtpBox({required this.ctrl, required this.node, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: TextField(
        controller: ctrl,
        focusNode: node,
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
