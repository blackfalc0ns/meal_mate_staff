class ValidateDriverBarcodeRequestEntity {
  const ValidateDriverBarcodeRequestEntity({
    required this.barcodeValue,
    this.isManualEntry = false,
  });

  final String barcodeValue;
  final bool isManualEntry;
}
