import 'package:flutter/material.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;
  final Future<void> Function(String pin) onPinConfirmed;

  const PinScreen({super.key, required this.isSetup, required this.onPinConfirmed});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isLoading = false;
  String _error = '';

  void _onKey(String key) {
    if (key == 'del') {
      setState(() {
        if (!_isConfirming) {
          if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
        } else {
          if (_confirmPin.isNotEmpty) _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
        _error = '';
      });
      return;
    }

    if (!_isConfirming) {
      if (_pin.length < 4) {
        setState(() => _pin += key);
        if (_pin.length == 4 && widget.isSetup) {
          setState(() { _isConfirming = true; _error = ''; });
        } else if (_pin.length == 4 && !widget.isSetup) {
          _submit(_pin);
        }
      }
    } else {
      if (_confirmPin.length < 4) {
        setState(() => _confirmPin += key);
        if (_confirmPin.length == 4) {
          if (_pin == _confirmPin) {
            _submit(_pin);
          } else {
            setState(() {
              _error = 'Коды не совпадают. Попробуйте снова';
              _pin = '';
              _confirmPin = '';
              _isConfirming = false;
            });
          }
        }
      }
    }
  }

  Future<void> _submit(String pin) async {
    setState(() => _isLoading = true);
    await widget.onPinConfirmed(pin);
    if (mounted) setState(() => _isLoading = false);
  }

  String get _currentInput => _isConfirming ? _confirmPin : _pin;

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
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.account_circle_outlined, size: 72, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                widget.isSetup
                    ? (_isConfirming ? 'Повторите код доступа' : 'Создайте код доступа')
                    : 'Введите код доступа',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => _PinDot(filled: i < _currentInput.length)),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(_error, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ],
              const Spacer(),
              if (_isLoading)
                const CircularProgressIndicator(color: Colors.white)
              else
                _Keypad(onKey: _onKey),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {},
                child: const Text('Забыли код доступа?', style: TextStyle(color: Colors.white60, fontSize: 13)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinDot extends StatelessWidget {
  final bool filled;
  const _PinDot({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? Colors.white : Colors.transparent,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  final void Function(String) onKey;
  const _Keypad({required this.onKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _keyRow(['1', '2', '3']),
          const SizedBox(height: 12),
          _keyRow(['4', '5', '6']),
          const SizedBox(height: 12),
          _keyRow(['7', '8', '9']),
          const SizedBox(height: 12),
          _keyRow(['', '0', 'del']),
        ],
      ),
    );
  }

  Widget _keyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) => _KeyButton(key: ValueKey(k), label: k, onTap: () { if (k.isNotEmpty) onKey(k); })).toList(),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _KeyButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox(width: 72, height: 56);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: label == 'del'
            ? const Icon(Icons.backspace_outlined, color: Colors.white, size: 22)
            : Text(label, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
