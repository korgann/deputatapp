import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/meeting_model.dart';
import '../../deputies/screens/deputies_list_screen.dart';

class ReceptionScreen extends StatelessWidget {
  const ReceptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final meetings = provider.myMeetings;
    final isDeputy = provider.currentUser?.isDeputy ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Приём граждан'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: !isDeputy ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeputiesListScreen())),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Записаться', style: TextStyle(color: Colors.white)),
      ) : null,
      body: Column(children: [
        // Schedule info card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Row(children: [
              Icon(Icons.schedule, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('График приёма граждан', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ]),
            SizedBox(height: 12),
            _ScheduleRow(day: 'Понедельник', time: '10:00 – 13:00'),
            _ScheduleRow(day: 'Среда', time: '14:00 – 17:00'),
            _ScheduleRow(day: 'Пятница', time: '10:00 – 12:00'),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isDeputy ? 'Записи на приём' : 'Мои записи',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              Text('${meetings.length} записей', style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: meetings.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.event_busy, size: 60, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    const Text('Записей нет', style: TextStyle(color: AppColors.textGrey, fontSize: 15)),
                    if (!isDeputy) ...[
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeputiesListScreen())),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        child: const Text('Записаться на приём'),
                      ),
                    ],
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: meetings.length,
                  itemBuilder: (ctx, i) => _MeetingCard(meeting: meetings[i]),
                ),
        ),
      ]),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String day;
  final String time;
  const _ScheduleRow({required this.day, required this.time});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4FC3F7), shape: BoxShape.circle)),
      const SizedBox(width: 10),
      Text(day, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      const SizedBox(width: 8),
      Text(time, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _MeetingCard extends StatelessWidget {
  final MeetingModel meeting;
  const _MeetingCard({required this.meeting});

  Color get _statusColor {
    switch (meeting.status) {
      case MeetingStatus.scheduled: return AppColors.primaryBlue;
      case MeetingStatus.completed: return AppColors.success;
      case MeetingStatus.cancelled: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMMM yyyy', 'ru').format(meeting.date);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.event, color: AppColors.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text('$dateStr в ${meeting.time}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _statusColor.withAlpha(26), borderRadius: BorderRadius.circular(10)),
              child: Text(meeting.statusLabel, style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w600)),
            ),
          ]),
          const Divider(height: 16),
          Row(children: [
            const Icon(Icons.person_outline, size: 16, color: AppColors.textGrey),
            const SizedBox(width: 6),
            Text('Депутат: ${meeting.deputyName}', style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
          ]),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.notes, size: 16, color: AppColors.textGrey),
            const SizedBox(width: 6),
            Expanded(child: Text('Цель: ${meeting.purpose}', style: const TextStyle(fontSize: 13, color: AppColors.textGrey))),
          ]),
        ]),
      ),
    );
  }
}
