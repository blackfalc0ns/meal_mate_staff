import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/register/presentation/widgets/register_source_sheet.dart';

/// Reusable helper for image picking operations across the app.
class ImagePickerHelper {
  const ImagePickerHelper._();

  /// Prompts the user with a bottom sheet to select Camera or Gallery,
  /// then picks and returns the selected image as a [File], or `null` if cancelled.
  static Future<File?> pickImageWithSourceSheet(
    BuildContext context, {
    ImagePicker? picker,
    Widget? sourceSheet,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => sourceSheet ?? const RegisterSourceSheet(),
    );

    if (source == null || !context.mounted) {
      return null;
    }

    final imagePicker = picker ?? ImagePicker();
    final image = await imagePicker.pickImage(source: source);
    if (image == null) {
      return null;
    }

    return File(image.path);
  }

  /// Directly picks an image from the specified [ImageSource].
  static Future<File?> pickImage(
    ImageSource source, {
    ImagePicker? picker,
  }) async {
    final imagePicker = picker ?? ImagePicker();
    final image = await imagePicker.pickImage(source: source);
    if (image == null) {
      return null;
    }

    return File(image.path);
  }
}
