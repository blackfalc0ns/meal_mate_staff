import 'package:json_annotation/json_annotation.dart';

part 'validate_driver_barcode_request_dto.g.dart';

@JsonSerializable(createFactory: false)
class ValidateDriverBarcodeRequestDto {
  const ValidateDriverBarcodeRequestDto({
    required this.barcodeValue,
    this.isManualEntry = false,
  });

  final String barcodeValue;
  final bool isManualEntry;

  Map<String, dynamic> toJson() =>
      _$ValidateDriverBarcodeRequestDtoToJson(this);
}
