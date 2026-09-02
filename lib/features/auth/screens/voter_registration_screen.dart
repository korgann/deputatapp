import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'sms_verification_screen.dart';

class VoterRegistrationScreen extends StatefulWidget {
  const VoterRegistrationScreen({super.key});

  @override
  State<VoterRegistrationScreen> createState() => _VoterRegistrationScreenState();
}

class _VoterRegistrationScreenState extends State<VoterRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _iinCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _selectedRegion = 'Абай область';
  String _selectedCity = 'Семей';
  String _selectedDistrict = 'Округ №6';

  final List<String> _regions = [
    'Абай область', 'Акмолинская область', 'Актюбинская область',
    'Алматинская область', 'Атырауская область', 'Астана',
    'Алматы', 'Шымкент', 'Карагандинская область',
    'Костанайская область', 'Кызылординская область',
    'Мангистауская область', 'Павлодарская область',
    'Северо-Казахстанская область', 'Туркестанская область',
    'Восточно-Казахстанская область', 'Жамбылская область',
    'Жетысуская область', 'Западно-Казахстанская область',
    'Улытауская область',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _iinCtrl.dispose();
    _addressCtrl.dispose();
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
    await provider.registerVoter(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      iin: _iinCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      region: _selectedRegion,
      city: _selectedCity,
      district: _selectedDistrict,
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
        title: const Text('Регистрация избирателя', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Регистрация для\nизбирателя',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildField(
                controller: _nameCtrl,
                label: 'Ваши имя и фамилия',
                hint: 'ФИО',
                validator: (v) => v!.isEmpty ? 'Введите ФИО' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _phoneCtrl,
                label: 'Номер телефона',
                hint: '+7 (7xx) xxx-xx-xx',
                keyboardType: TextInputType.phone,
                validator: (v) => v!.length < 10 ? 'Введите корректный номер' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _iinCtrl,
                label: 'ИИН',
                hint: '000000000000',
                keyboardType: TextInputType.number,
                maxLength: 12,
                validator: (v) => v!.length != 12 ? 'ИИН должен содержать 12 цифр' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _addressCtrl,
                label: 'Адрес',
                hint: 'Укажите ваш адрес',
                validator: (v) => v!.isEmpty ? 'Введите адрес' : null,
              ),
              const SizedBox(height: 12),
              _buildDropdown('Регион', _regions, _selectedRegion, (v) => setState(() => _selectedRegion = v!)),
              const SizedBox(height: 12),
              _buildField(
                controller: TextEditingController(text: _selectedCity),
                label: 'Город / Район',
                hint: 'Город',
                onChanged: (v) => _selectedCity = v,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: TextEditingController(text: _selectedDistrict),
                label: 'Округ',
                hint: 'Округ №',
                onChanged: (v) => _selectedDistrict = v,
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

  Widget _buildField({
    TextEditingController? controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          onChanged: onChanged,
          validator: validator,
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

  Widget _buildDropdown(String label, List<String> items, String value, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
