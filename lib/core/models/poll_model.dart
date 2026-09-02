class PollOption {
  final String id;
  final String text;
  int votes;

  PollOption({required this.id, required this.text, this.votes = 0});
}

class PollModel {
  final String id;
  final String deputyId;
  final String deputyName;
  final String question;
  final List<PollOption> options;
  final DateTime createdAt;
  final DateTime deadline;
  bool isActive;
  List<String> votedUserIds;

  PollModel({
    required this.id,
    required this.deputyId,
    required this.deputyName,
    required this.question,
    required this.options,
    required this.createdAt,
    required this.deadline,
    this.isActive = true,
    this.votedUserIds = const [],
  });

  int get totalVotes => options.fold(0, (sum, o) => sum + o.votes);

  double getPercentage(String optionId) {
    if (totalVotes == 0) return 0;
    final option = options.firstWhere((o) => o.id == optionId, orElse: () => PollOption(id: '', text: ''));
    return (option.votes / totalVotes) * 100;
  }
}
