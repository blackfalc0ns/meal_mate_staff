class RegisterPersonalData {
  const RegisterPersonalData({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.birthDate,
    required this.nationality,
    required this.civilId,
    this.restaurantId = '',
    this.restaurantName = '',
    this.fullNameAr = '',
    this.fullNameEn = '',
    this.nationalIdExpiry = '',
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String birthDate;
  final String nationality;
  final String civilId;
  final String restaurantId;
  final String restaurantName;
  final String fullNameAr;
  final String fullNameEn;
  final String nationalIdExpiry;

  String get resolvedFullNameAr =>
      fullNameAr.isNotEmpty ? fullNameAr : '$firstName $lastName'.trim();
  String get resolvedFullNameEn =>
      fullNameEn.isNotEmpty ? fullNameEn : '$firstName $lastName'.trim();
  String get resolvedNationalId => civilId;

  RegisterPersonalData copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? birthDate,
    String? nationality,
    String? civilId,
    String? restaurantId,
    String? restaurantName,
    String? fullNameAr,
    String? fullNameEn,
    String? nationalIdExpiry,
  }) {
    return RegisterPersonalData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      nationality: nationality ?? this.nationality,
      civilId: civilId ?? this.civilId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      fullNameAr: fullNameAr ?? this.fullNameAr,
      fullNameEn: fullNameEn ?? this.fullNameEn,
      nationalIdExpiry: nationalIdExpiry ?? this.nationalIdExpiry,
    );
  }
}
