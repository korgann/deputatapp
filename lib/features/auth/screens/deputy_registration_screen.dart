import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'sms_verification_screen.dart';

class DeputyRegistrationScreen extends StatefulWidget {
  const DeputyRegistrationScreen({super.key});

  @override
  State<DeputyRegistrationScreen> createState() => _DeputyRegistrationScreenState();
}

class _DeputyRegistrationScreenState extends State<DeputyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _iinCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _partyCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _orgCtrl = TextEditingController();
  int _districtNumber = 1;
  String _selectedRegion = 'Абай область';
  String _selectedCity = 'Семей';

  final List<String> _regions = [
    'Абай область', 'Акмолинская область', 'Актюбинская область',
    'Алматинская область', 'Астана', 'Алматы', 'Шымкент',
    'Карагандинская область', 'Костанайская область',
    'Северо-Казахстанская область', 'Туркестанская область',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _iinCtrl.dispose();
    _addressCtrl.dispose(); _partyCtrl.dispose(); _positionCtrl.dispose(); _orgCtrl.dispose();
    super.dispose();
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    provider.sendSmsCode(_phoneCtrl.text.trim());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SmsVerificationScreen(
          phone: _phoneCtrl.text.trim(),
          onVerified: (pin) => _register(pin),
        ),
      ),
    );
  }

  Future<void> _register(String pin) async {
    final provider = context.read<AppProvider>();
    await provider.registerDeputy(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      iin: _iinCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      region: _selectedRegion,
      city: _selectedCity,
      districtNumber: _districtNumber,
      party: _partyCtrl.text.trim(),
      position: _positionCtrl.text.trim(),
      organization: _orgCtrl.text.trim(),
      pin: pin,
    );
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
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
        title: const Text('Регистрация депутата', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Регистрация для\nдепутата',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _field(_nameCtrl, 'ФИО', 'Ваше имя и фамилия', validator: (v) => v!.isEmpty ? 'Введите ФИО' : null),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Номер телефона', '+7 (7xx) xxx-xx-xx', type: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_iinCtrl, 'ИИН', '000000000000', type: TextInputType.number, maxLen: 12,
                  validator: (v) => v!.length != 12 ? 'ИИН должен содержать 12 цифр' : null),
              const SizedBox(height: 12),
              _field(_addressCtrl, 'Адрес', 'Укажите адрес'),
              const SizedBox(height: 12),
              _dropdown('Регион', _regions, _selectedRegion, (v) => setState(() => _selectedRegion = v!)),
              const SizedBox(height: 12),
              _field(TextEditingController(text: _selectedCity), 'Город', 'Город', onChanged: (v) => _selectedCity = v),
              const SizedBox(height: 12),
              _field(_partyCtrl, 'Партия', 'Название партии'),
              const SizedBox(height: 12),
              _field(_positionCtrl, 'Должность', 'Депутат маслихата / Курултая'),
              const SizedBox(height: 12),
              _field(_orgCtrl, 'Организация', 'Место работы'),
              const SizedBox(height: 12),
              const Text('Номер округа', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove), onPressed: () { if (_districtNumber > 1) setState(() => _districtNumber--); }),
                    Expanded(child: Text('Округ №$_districtNumber', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                    IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _districtNumber++)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Далее', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, String hint, {TextInputType? type, int? maxLen, String? Function(String?)? validator, void Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: type,
          maxLength: maxLen,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(String label, List<String> items, String value, void Function(String?) onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: onChange,
            ),
          ),
        ),
      ],
    );
  }
}
