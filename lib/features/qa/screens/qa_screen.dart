import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/question_model.dart';

class QaScreen extends StatefulWidget {
  const QaScreen({super.key});

  @override
  State<QaScreen> createState() => _QaScreenState();
}

class _QaScreenState extends State<QaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDeputy = provider.currentUser?.isDeputy ?? false;
    final myQuestions = provider.myQuestions;
    final allQuestions = provider.questions;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Вопросы и ответы'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF4FC3F7),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: isDeputy ? 'Мои вопросы' : 'Мои вопросы'),
            const Tab(text: 'Все вопросы'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _QuestionsList(questions: myQuestions, isDeputy: isDeputy, emptyText: 'У вас ещё нет вопросов'),
          _QuestionsList(questions: allQuestions, isDeputy: isDeputy, emptyText: 'Вопросов пока нет'),
        ],
      ),
    );
  }
}

class _QuestionsList extends StatelessWidget {
  final List<QuestionModel> questions;
  final bool isDeputy;
  final String emptyText;

  const _QuestionsList({required this.questions, required this.isDeputy, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.question_answer_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(emptyText, style: const TextStyle(color: AppColors.textGrey, fontSize: 15)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (ctx, i) => _QuestionCard(question: questions[i], isDeputy: isDeputy),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final bool isDeputy;

  const _QuestionCard({required this.question, required this.isDeputy});

  Color get _statusColor {
    switch (question.status) {
      case QuestionStatus.pending: return AppColors.warning;
      case QuestionStatus.inProgress: return AppColors.lightBlue;
      case QuestionStatus.answered: return question.isCompleted ? AppColors.success : AppColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 16, backgroundColor: AppColors.backgroundBlue,
              child: Text(question.voterName[0], style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(question.voterName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text('→ ${question.deputyName}', style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
            ])),
            _StatusChip(label: question.statusLabel, color: _statusColor),
          ]),
          const SizedBox(height: 10),
          Text(question.text, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
          if (question.category != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.backgroundBlue, borderRadius: BorderRadius.circular(10)),
              child: Text(question.category!, style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue)),
            ),
          ],
          if (question.answer != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.backgroundBlue, borderRadius: BorderRadius.circular(12)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.reply, size: 16, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(question.deputyName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primaryBlue)),
                  const SizedBox(height: 4),
                  Text(question.answer!, style: const TextStyle(fontSize: 13)),
                ])),
              ]),
            ),
          ],
          const SizedBox(height: 8),
          Row(children: [
            GestureDetector(
              onTap: () => provider.likeQuestion(question.id),
              child: Row(children: [
                const Icon(Icons.thumb_up_outlined, size: 16, color: AppColors.textGrey),
                const SizedBox(width: 4),
                Text('${question.likes}', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
              ]),
            ),
            const Spacer(),
            if (isDeputy && question.answer == null)
              TextButton(
                onPressed: () => _showAnswerDialog(context, question.id, provider),
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue, padding: EdgeInsets.zero),
                child: const Text('Ответить', style: TextStyle(fontSize: 12)),
              ),
          ]),
        ]),
      ),
    );
  }

  void _showAnswerDialog(BuildContext context, String questionId, AppProvider provider) {
    final ctrl = TextEditingController();
    bool isCompleted = true;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Ответить на вопрос'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: ctrl, maxLines: 4, decoration: InputDecoration(
              hintText: 'Введите ответ...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            )),
            const SizedBox(height: 12),
            Row(children: [
              Checkbox(value: isCompleted, onChanged: (v) => setState(() => isCompleted = v ?? true),
                activeColor: AppColors.primaryBlue),
              const Expanded(child: Text('Вопрос решён (Выполнено)', style: TextStyle(fontSize: 13))),
            ]),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (ctrl.text.trim().isEmpty) return;
                provider.answerQuestion(questionId: questionId, answer: ctrl.text.trim(), isCompleted: isCompleted);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
              child: const Text('Отправить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withAlpha(77))),
    child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
  );
}
