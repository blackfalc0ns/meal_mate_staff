class DeliveryFailureReasonEntity {
  const DeliveryFailureReasonEntity({
    required this.id,
    required this.title,
    this.description,
  });

  final String id;
  final String title;
  final String? description;
}
