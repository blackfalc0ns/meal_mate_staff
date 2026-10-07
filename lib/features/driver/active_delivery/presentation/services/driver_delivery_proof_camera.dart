import 'package:image_picker/image_picker.dart';

import '../../../../../core/helpers/image_picker_helper.dart';

abstract class DriverDeliveryProofCameraService {
  Future<String?> captureProofPhoto({ImagePicker? picker});
}

class DriverDeliveryProofCameraServiceImpl
    implements DriverDeliveryProofCameraService {
  const DriverDeliveryProofCameraServiceImpl({this.picker});

  final ImagePicker? picker;

  @override
  Future<String?> captureProofPhoto({ImagePicker? picker}) async {
    final file = await ImagePickerHelper.pickImage(
      ImageSource.camera,
      picker: picker ?? this.picker,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 80,
    );
    return file?.path;
  }
}
