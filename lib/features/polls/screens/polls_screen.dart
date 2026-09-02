import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/poll_model.dart';
import 'create_poll_screen.dart';

class PollsScreen extends StatelessWidget {
  const PollsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final polls = provider.polls;
    final isDeputy = provider.currentUser?.isDeputy ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Опросы'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: isDeputy ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePollScreen())),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Создать опрос', style: TextStyle(color: Colors.white)),
      ) : null,
      body: polls.isEmpty
          ? const Center(child: Text('Опросов нет', style: TextStyle(color: AppColors.textGrey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: polls.length,
              itemBuilder: (ctx, i) => _PollCard(poll: polls[i]),
            ),
    );
  }
}

class _PollCard extends StatefulWidget {
  final PollModel poll;
  const _PollCard({required this.poll});

  @override
  State<_PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<_PollCard> {
  String? _selectedOptionId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final userId = provider.currentUser?.id ?? '';
    final hasVoted = widget.poll.votedUserIds.contains(userId);
    final deadline = DateFormat('dd.MM.yyyy').format(widget.poll.deadline);
    final daysLeft = widget.poll.deadline.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryBlue, radius: 16,
              child: Text(widget.poll.deputyName[0], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.poll.deputyName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: daysLeft > 0 ? AppColors.success.withAlpha(26) : Colors.grey.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                daysLeft > 0 ? 'До $deadline' : 'Завершён',
                style: TextStyle(fontSize: 10, color: daysLeft > 0 ? AppColors.success : Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Text(widget.poll.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text('${widget.poll.totalVotes} голосов', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 12),
          // Options
          ...widget.poll.options.map((opt) => _PollOption(
            option: opt,
            isSelected: _selectedOptionId == opt.id,
            hasVoted: hasVoted,
            percentage: widget.poll.getPercentage(opt.id),
            onTap: hasVoted ? null : () => setState(() => _selectedOptionId = opt.id),
          )),
          if (!hasVoted && _selectedOptionId != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  provider.votePoll(pollId: widget.poll.id, optionId: _selectedOptionId!);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Голос учтён!'), backgroundColor: AppColors.success));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Проголосовать'),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class _PollOption extends StatelessWidget {
  final PollOption option;
  final bool isSelected;
  final bool hasVoted;
  final double percentage;
  final VoidCallback? onTap;

  const _PollOption({required this.option, required this.isSelected, required this.hasVoted, required this.percentage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Stack(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? AppColors.backgroundBlue : Colors.white,
            ),
            child: Row(children: [
              Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? AppColors.primaryBlue : Colors.grey, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(option.text, style: TextStyle(fontSize: 14, color: isSelected ? AppColors.primaryBlue : AppColors.textDark, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal))),
              if (hasVoted) Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            ]),
          ),
          if (hasVoted)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: percentage / 100,
                    child: Container(color: AppColors.primaryBlue.withAlpha(26)),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
