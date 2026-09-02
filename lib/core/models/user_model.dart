enum UserRole { voter, deputy }

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String iin;
  final String address;
  final UserRole role;
  final String region;
  final String city;
  final String district;
  final String? pinCode;
  final String? avatarUrl;

  // Deputy-specific fields
  final String? party;
  final String? position;
  final String? organization;
  final int? districtNumber;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.iin,
    required this.address,
    required this.role,
    required this.region,
    required this.city,
    required this.district,
    this.pinCode,
    this.avatarUrl,
    this.party,
    this.position,
    this.organization,
    this.districtNumber,
  });

  bool get isDeputy => role == UserRole.deputy;
  bool get isVoter => role == UserRole.voter;

  UserModel copyWith({
    String? name,
    String? phone,
    String? address,
    String? region,
    String? city,
    String? district,
    String? pinCode,
    String? avatarUrl,
    String? party,
    String? position,
    String? organization,
    int? districtNumber,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      iin: iin,
      address: address ?? this.address,
      role: role,
      region: region ?? this.region,
      city: city ?? this.city,
      district: district ?? this.district,
      pinCode: pinCode ?? this.pinCode,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      party: party ?? this.party,
      position: position ?? this.position,
      organization: organization ?? this.organization,
      districtNumber: districtNumber ?? this.districtNumber,
    );
  }
}
