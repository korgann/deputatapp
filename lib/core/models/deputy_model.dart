enum DeputyLevel { district, regional, city, kurultai }

class DeputyModel {
  final String id;
  final String name;
  final String party;
  final String region;
  final String city;
  final int districtNumber;
  final String position;
  final String organization;
  final DeputyLevel level;
  final String? phone;
  final String? email;
  final String? bio;
  final String avatarInitials;

  // Rating fields
  int totalQuestions;
  int completedQuestions;
  double voterRating;
  int monthlyScore;
  int annualScore;

  DeputyModel({
    required this.id,
    required this.name,
    required this.party,
    required this.region,
    required this.city,
    required this.districtNumber,
    required this.position,
    required this.organization,
    required this.level,
    this.phone,
    this.email,
    this.bio,
    required this.avatarInitials,
    this.totalQuestions = 0,
    this.completedQuestions = 0,
    this.voterRating = 0.0,
    this.monthlyScore = 0,
    this.annualScore = 0,
  });

  double get ratingScore {
    if (totalQuestions == 0) return 0.0;
    return (completedQuestions / totalQuestions) * 100;
  }

  String get levelLabel {
    switch (level) {
      case DeputyLevel.district:
        return 'Депутат районного маслихата';
      case DeputyLevel.regional:
        return 'Депутат областного маслихата';
      case DeputyLevel.city:
        return 'Депутат городского маслихата';
      case DeputyLevel.kurultai:
        return 'Депутат Курултая';
    }
  }
}
