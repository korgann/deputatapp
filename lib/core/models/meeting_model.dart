enum MeetingStatus { scheduled, completed, cancelled }

class MeetingModel {
  final String id;
  final String voterId;
  final String voterName;
  final String deputyId;
  final String deputyName;
  final DateTime date;
  final String time;
  final String purpose;
  MeetingStatus status;
  String? notes;

  MeetingModel({
    required this.id,
    required this.voterId,
    required this.voterName,
    required this.deputyId,
    required this.deputyName,
    required this.date,
    required this.time,
    required this.purpose,
    this.status = MeetingStatus.scheduled,
    this.notes,
  });

  String get statusLabel {
    switch (status) {
      case MeetingStatus.scheduled:
        return 'Запланировано';
      case MeetingStatus.completed:
        return 'Завершено';
      case MeetingStatus.cancelled:
        return 'Отменено';
    }
  }
}
