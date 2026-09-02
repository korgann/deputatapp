import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/deputy_model.dart';
import '../../qa/screens/ask_question_screen.dart';
import '../../reception/screens/book_meeting_screen.dart';

class DeputyProfileScreen extends StatefulWidget {
  final DeputyModel deputy;
  const DeputyProfileScreen({super.key, required this.deputy});

  @override
  State<DeputyProfileScreen> createState() => _DeputyProfileScreenState();
}

class _DeputyProfileScreenState extends State<DeputyProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final questions = provider.getQuestionsForDeputy(widget.deputy.id);
    final posts = provider.getPostsForDeputy(widget.deputy.id);
    final isCurrentDeputy = provider.currentUser?.id == widget.deputy.id;
    final isVoter = provider.currentUser?.isVoter ?? false;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A3D8F), Color(0xFF1976D2)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white.withAlpha(51),
                        child: Text(widget.deputy.avatarInitials,
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      Text(widget.deputy.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(widget.deputy.levelLabel, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: const Color(0xFF4FC3F7),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'Профиль'),
                Tab(text: 'Вопросы'),
                Tab(text: 'Блог'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // Profile Tab
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _InfoCard(deputy: widget.deputy),
                const SizedBox(height: 12),
                _RatingCard(deputy: widget.deputy),
                if (isVoter) ...[
                  const SizedBox(height: 16),
                  _ActionButtons(deputy: widget.deputy),
                ],
              ],
            ),
            // Questions Tab
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: questions.isEmpty ? 1 : questions.length,
              itemBuilder: (ctx, i) {
                if (questions.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Вопросов пока нет', style: TextStyle(color: AppColors.textGrey)),
                  ));
                }
                final q = questions[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          CircleAvatar(backgroundColor: AppColors.backgroundBlue, radius: 14,
                            child: Text(q.voterName[0], style: const TextStyle(color: AppColors.primaryBlue, fontSize: 12))),
                          const SizedBox(width: 8),
                          Text(q.voterName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: q.isCompleted ? AppColors.success.withAlpha(26) : AppColors.warning.withAlpha(26),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(q.statusLabel,
                              style: TextStyle(fontSize: 10, color: q.isCompleted ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Text(q.text, style: const TextStyle(fontSize: 14)),
                        if (q.answer != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.reply, size: 14, color: AppColors.primaryBlue),
                                const SizedBox(width: 6),
                                Expanded(child: Text(q.answer!, style: const TextStyle(fontSize: 13, color: AppColors.textDark))),
                              ],
                            ),
                          ),
                        ],
                        if (isCurrentDeputy && q.answer == null) ...[
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => _showAnswerDialog(context, q.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              side: const BorderSide(color: AppColors.primaryBlue),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: const Text('Ответить'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            // Blog Tab
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.isEmpty ? 1 : posts.length,
              itemBuilder: (ctx, i) {
                if (posts.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Публикаций нет', style: TextStyle(color: AppColors.textGrey))));
                final p = posts[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(p.content, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.thumb_up_outlined, size: 14, color: AppColors.textGrey),
                        const SizedBox(width: 4),
                        Text('${p.likes}', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                      ]),
                    ]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: isVoter ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AskQuestionScreen(deputy: widget.deputy))),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.question_answer, color: Colors.white),
        label: const Text('Задать вопрос', style: TextStyle(color: Colors.white)),
      ) : null,
    );
  }

  void _showAnswerDialog(BuildContext context, String questionId) {
    final ctrl = TextEditingController();
    bool isCompleted = true;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Ответить на вопрос'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: ctrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Введите ответ...')),
            const SizedBox(height: 12),
            Row(children: [
              Checkbox(value: isCompleted, onChanged: (v) => setState(() => isCompleted = v!)),
              const Text('Вопрос решён (Выполнено)'),
            ]),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (ctrl.text.trim().isEmpty) return;
                context.read<AppProvider>().answerQuestion(questionId: questionId, answer: ctrl.text.trim(), isCompleted: isCompleted);
                Navigator.pop(ctx);
              },
              child: const Text('Отправить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final DeputyModel deputy;
  const _InfoCard({required this.deputy});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row('Партия', deputy.party),
            _row('Регион', deputy.region),
            _row('Город', deputy.city),
            _row('Округ', 'Округ №${deputy.districtNumber}'),
            _row('Должность', deputy.position),
            _row('Организация', deputy.organization),
            if (deputy.phone != null) _row('Телефон', deputy.phone!),
            if (deputy.bio != null) ...[
              const Divider(),
              Text(deputy.bio!, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 13))),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(20)),
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    ),
  );
}

class _RatingCard extends StatelessWidget {
  final DeputyModel deputy;
  const _RatingCard({required this.deputy});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Рейтинг депутата', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _RatingStat(label: 'Оценка', value: deputy.voterRating.toStringAsFixed(1), icon: Icons.star, color: Colors.amber),
                _RatingStat(label: 'Выполнено', value: '${deputy.completedQuestions}/${deputy.totalQuestions}', icon: Icons.check_circle, color: AppColors.success),
                _RatingStat(label: 'Активность', value: '${deputy.ratingScore.toStringAsFixed(0)}%', icon: Icons.trending_up, color: AppColors.primaryBlue),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: deputy.totalQuestions > 0 ? deputy.completedQuestions / deputy.totalQuestions : 0,
              backgroundColor: Colors.grey[200],
              color: AppColors.primaryBlue,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _RatingStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
    ],
  );
}

class _ActionButtons extends StatelessWidget {
  final DeputyModel deputy;
  const _ActionButtons({required this.deputy});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AskQuestionScreen(deputy: deputy))),
            icon: const Icon(Icons.question_answer),
            label: const Text('Задать вопрос'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookMeetingScreen(deputy: deputy))),
            icon: const Icon(Icons.event),
            label: const Text('Записаться на приём'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.primaryBlue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
