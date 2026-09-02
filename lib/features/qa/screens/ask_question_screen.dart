import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/deputy_model.dart';
import '../../../core/utils/profanity_filter.dart';

class AskQuestionScreen extends StatefulWidget {
  final DeputyModel deputy;
  const AskQuestionScreen({super.key, required this.deputy});

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final _ctrl = TextEditingController();
  String _selectedCategory = 'Общие';
  bool _hasProfanity = false;
  bool _isLoading = false;

  final List<String> _categories = ['Общие', 'Коммунальные услуги', 'Дороги', 'Образование', 'Здравоохранение', 'Экология', 'Благоустройство', 'Транспорт', 'Другое'];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _checkText(String text) {
    setState(() => _hasProfanity = ProfanityFilter.containsProfanity(text));
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _isLoading = true);
    final filtered = ProfanityFilter.filter(text);
    context.read<AppProvider>().askQuestion(
      deputyId: widget.deputy.id,
      deputyName: widget.deputy.name,
      text: filtered,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Вопрос отправлен!'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Задать вопрос'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Deputy info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.backgroundBlue, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryBlue, radius: 24,
                child: Text(widget.deputy.avatarInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.deputy.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(widget.deputy.levelLabel, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
              ])),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Категория', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _categories.map((cat) => ChoiceChip(
              label: Text(cat, style: TextStyle(fontSize: 12, color: _selectedCategory == cat ? Colors.white : AppColors.primaryBlue)),
              selected: _selectedCategory == cat,
              selectedColor: AppColors.primaryBlue,
              backgroundColor: AppColors.backgroundBlue,
              side: BorderSide.none,
              onSelected: (_) => setState(() => _selectedCategory = cat),
            )).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Ваш вопрос', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            maxLines: 6,
            maxLength: 500,
            onChanged: _checkText,
            decoration: InputDecoration(
              hintText: 'Опишите вашу проблему или вопрос...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _hasProfanity ? Colors.red : AppColors.lightBlue.withAlpha(128)),
              ),
            ),
          ),
          if (_hasProfanity) ...[
            const SizedBox(height: 4),
            const Row(children: [
              Icon(Icons.warning_amber, size: 14, color: Colors.orange),
              SizedBox(width: 4),
              Text('Нецензурная лексика будет заменена на XXXX', style: TextStyle(color: Colors.orange, fontSize: 12)),
            ]),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _ctrl.text.trim().isNotEmpty ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text('Отправить вопрос', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }
}
