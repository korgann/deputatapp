import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/theme/app_theme.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({super.key});

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final _questionCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls = [TextEditingController(), TextEditingController()];
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (final c in _optionCtrls) c.dispose();
    super.dispose();
  }

  void _addOption() {
    if (_optionCtrls.length < 4) setState(() => _optionCtrls.add(TextEditingController()));
  }

  void _removeOption(int i) {
    if (_optionCtrls.length > 2) {
      setState(() { _optionCtrls[i].dispose(); _optionCtrls.removeAt(i); });
    }
  }

  void _submit() {
    if (_questionCtrl.text.trim().isEmpty) return;
    final options = _optionCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Добавьте минимум 2 варианта ответа')));
      return;
    }
    context.read<AppProvider>().createPoll(question: _questionCtrl.text.trim(), options: options, deadline: _deadline);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Опрос создан!'), backgroundColor: AppColors.success));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать опрос'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [TextButton(onPressed: _submit, child: const Text('Создать', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Вопрос', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 8),
          TextField(
            controller: _questionCtrl,
            maxLines: 3,
            decoration: InputDecoration(hintText: 'Введите вопрос...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 20),
          const Text('Варианты ответов', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 8),
          ...List.generate(_optionCtrls.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: TextField(
                controller: _optionCtrls[i],
                decoration: InputDecoration(
                  hintText: 'Вариант ${i + 1}',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              )),
              if (_optionCtrls.length > 2) IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _removeOption(i),
              ),
            ]),
          )),
          if (_optionCtrls.length < 4)
            TextButton.icon(onPressed: _addOption, icon: const Icon(Icons.add), label: const Text('Добавить вариант'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue)),
          const SizedBox(height: 16),
          const Text('Дата окончания', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: _deadline, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (picked != null) setState(() => _deadline = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Text('${_deadline.day}.${_deadline.month}.${_deadline.year}', style: const TextStyle(fontSize: 15)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
