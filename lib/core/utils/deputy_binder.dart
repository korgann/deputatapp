import '../models/deputy_model.dart';

const List<String> majorCities = ['Астана', 'Алматы', 'Шымкент'];

class DeputyBinder {
  static List<DeputyModel> getDeputiesForUser({
    required String city,
    required String region,
    required int districtNumber,
    required List<DeputyModel> allDeputies,
  }) {
    final isMajorCity = majorCities.contains(city);

    if (isMajorCity) {
      // 2 deputies: city maslikhat + kurultai
      final cityDeputy = allDeputies.firstWhere(
        (d) => d.city == city && d.level == DeputyLevel.city && d.districtNumber == districtNumber,
        orElse: () => allDeputies.firstWhere(
          (d) => d.city == city && d.level == DeputyLevel.city,
          orElse: () => allDeputies.first,
        ),
      );
      final kurultaiDeputy = allDeputies.firstWhere(
        (d) => d.city == city && d.level == DeputyLevel.kurultai,
        orElse: () => allDeputies.firstWhere(
          (d) => d.level == DeputyLevel.kurultai,
          orElse: () => allDeputies.last,
        ),
      );
      return [cityDeputy, kurultaiDeputy];
    } else {
      // 3 deputies: district + regional + kurultai
      final districtDeputy = allDeputies.firstWhere(
        (d) => d.region == region && d.level == DeputyLevel.district && d.districtNumber == districtNumber,
        orElse: () => allDeputies.firstWhere(
          (d) => d.region == region && d.level == DeputyLevel.district,
          orElse: () => allDeputies.first,
        ),
      );
      final regionalDeputy = allDeputies.firstWhere(
        (d) => d.region == region && d.level == DeputyLevel.regional,
        orElse: () => allDeputies.firstWhere(
          (d) => d.level == DeputyLevel.regional,
          orElse: () => allDeputies[1],
        ),
      );
      final kurultaiDeputy = allDeputies.firstWhere(
        (d) => d.region == region && d.level == DeputyLevel.kurultai,
        orElse: () => allDeputies.firstWhere(
          (d) => d.level == DeputyLevel.kurultai,
          orElse: () => allDeputies.last,
        ),
      );
      return [districtDeputy, regionalDeputy, kurultaiDeputy];
    }
  }
}
