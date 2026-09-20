class DriverRestaurantEntity {
  const DriverRestaurantEntity({
    required this.id,
    required this.tradeName,
    required this.tradeNameAr,
    required this.tradeNameEn,
    this.logoUrl,
    this.contactPhone,
  });

  final String id;
  final String tradeName;
  final String tradeNameAr;
  final String tradeNameEn;
  final String? logoUrl;
  final String? contactPhone;
}
