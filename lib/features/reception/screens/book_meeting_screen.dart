import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/deputy_model.dart';

class BookMeetingScreen extends StatefulWidget {
  final DeputyModel deputy;
  const BookMeetingScreen({super.key, required this.deputy});

  @override
  State<BookMeetingScreen> createState() => _BookMeetingScreenState();
}

class _BookMeetingScreenState extends State<BookMeetingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00';
  final _purposeCtrl = TextEditingController();

  final List<String> _availableTimes = ['09:00', '10:00', '11:00', '12:00', '14:00', '15:00', '16:00', '17:00'];

  @override
  void dispose() {
    _purposeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_purposeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Укажите цель визита')));
      return;
    }
    context.read<AppProvider>().bookMeeting(
      deputyId: widget.deputy.id,
      deputyName: widget.deputy.name,
      date: _selectedDate,
      time: _selectedTime,
      purpose: _purposeCtrl.text.trim(),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Запись на приём создана!'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Запись на приём'),
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
          const SizedBox(height: 24),
          const Text('Выберите дату', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark, fontSize: 15)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                selectableDayPredicate: (day) => day.weekday != DateTime.saturday && day.weekday != DateTime.sunday,
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primaryBlue)),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryBlue),
                borderRadius: BorderRadius.circular(14),
                color: AppColors.backgroundBlue,
              ),
              child: Row(children: [
                const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: AppColors.primaryBlue),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Выберите время', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark, fontSize: 15)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: _availableTimes.map((t) {
              final isSelected = t == _selectedTime;
              return GestureDetector(
                onTap: () => setState(() => _selectedTime = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlue : Colors.white,
                    border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(t, style: TextStyle(color: isSelected ? Colors.white : AppColors.textDark, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Цель визита', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark, fontSize: 15)),
          const SizedBox(height: 8),
          TextField(
            controller: _purposeCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Опишите вопрос, с которым хотите обратиться...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Записаться на приём', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }
}
