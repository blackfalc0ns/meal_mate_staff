import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/routing/app_routes.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../account_status/domain/account_status_kind.dart';
import '../../domain/register_document.dart';
import '../widgets/register_source_sheet.dart';
import 'register_personal_data_screen.dart';
import 'register_review_screen.dart';
import 'register_upload_documents_screen.dart';
import 'register_vehicle_data_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.imagePicker});

  final ImagePicker? imagePicker;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Map<String, String> _selectedImagePaths = {};
  var _currentStep = 1;
  var _selectedVehicleColor = const Color(0xFF603BC1);
  var _ownsVehicle = true;

  ImagePicker get _imagePicker => widget.imagePicker ?? ImagePicker();

  Future<void> _pickDocumentImage(RegisterDocument document) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => const RegisterSourceSheet(),
    );

    if (source == null || !mounted) {
      return;
    }

    final image = await _imagePicker.pickImage(source: source);
    if (image == null || !mounted) {
      return;
    }

    setState(() {
      _selectedImagePaths[document.id] = image.path;
    });
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  void _handleBack() {
    if (_currentStep == 1) {
      Navigator.of(context).maybePop();
      return;
    }

    _goToStep(_currentStep - 1);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_currentStep) {
      1 => RegisterPersonalDataScreen(
        onContinue: () => _goToStep(2),
        onBackPressed: _handleBack,
      ),
      2 => RegisterVehicleDataScreen(
        selectedVehicleColor: _selectedVehicleColor,
        ownsVehicle: _ownsVehicle,
        onColorSelected: (color) {
          setState(() {
            _selectedVehicleColor = color;
          });
        },
        onOwnsVehicleChanged: (ownsVehicle) {
          setState(() {
            _ownsVehicle = ownsVehicle;
          });
        },
        onContinue: () => _goToStep(3),
        onBackPressed: _handleBack,
      ),
      3 => RegisterUploadDocumentsScreen(
        selectedImagePaths: _selectedImagePaths,
        onDocumentTap: _pickDocumentImage,
        onSubmit: () => _goToStep(4),
        onBackPressed: _handleBack,
      ),
      _ => RegisterReviewScreen(
        selectedImagePaths: _selectedImagePaths,
        onDocumentTap: _pickDocumentImage,
        onSubmit: () {
          context.pushReplacementNamed(
            AppRoutes.accountStatus,
            arguments: AccountStatusKind.accepted,
          );
        },
        onBackToEdit: () => _goToStep(3),
        onBackPressed: _handleBack,
      ),
    };
  }
}
