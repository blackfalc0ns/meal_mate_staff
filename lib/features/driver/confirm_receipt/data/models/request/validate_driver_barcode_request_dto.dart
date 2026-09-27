import 'package:json_annotation/json_annotation.dart';

part 'validate_driver_barcode_request_dto.g.dart';

@JsonSerializable(createFactory: false)
class ValidateDriverBarcodeRequestDto {
  const ValidateDriverBarcodeRequestDto({required this.barcodeValue});

  final String barcodeValue;

  Map<String, dynamic> toJson() =>
      _$ValidateDriverBarcodeRequestDtoToJson(this);
}
