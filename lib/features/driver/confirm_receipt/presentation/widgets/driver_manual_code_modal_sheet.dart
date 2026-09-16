import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';
import '../../../../../core/widget/app_text_field.dart';

class DriverManualCodeModalSheet extends StatefulWidget {
  const DriverManualCodeModalSheet({
    super.key,
    required this.onCodeSubmitted,
    this.defaultCode = '',
  });

  final ValueChanged<String> onCodeSubmitted;
  final String defaultCode;

  static Future<void> show({
    required BuildContext context,
    required ValueChanged<String> onCodeSubmitted,
    String defaultCode = '',
  }) {
    final locale = context.localization;

    return WoltModalSheet.show<void>(
      context: context,
      useSafeArea: true,
      pageListBuilder: (modalContext) {
        return [
          WoltModalSheetPage(
            hasTopBarLayer: true,
            isTopBarLayerAlwaysVisible: true,
            topBarTitle: Text(
              locale.driverEnterCodeManually,
              style: getBoldStyle(
                fontSize: FontSize.size14,
                color: modalContext.colorScheme.onSurface,
              ),
            ),
            trailingNavBarWidget: IconButton(
              icon: const Icon(Icons.close_rounded),
              color: modalContext.colorScheme.onSurfaceVariant,
              onPressed: () => Navigator.of(modalContext).pop(),
            ),
            child: DriverManualCodeModalSheet(
              defaultCode: defaultCode,
              onCodeSubmitted: (code) {
                Navigator.of(modalContext).pop();
                onCodeSubmitted(code);
              },
            ),
          ),
        ];
      },
    );
  }

  @override
  State<DriverManualCodeModalSheet> createState() =>
      _DriverManualCodeModalSheetState();
}

class _DriverManualCodeModalSheetState
    extends State<DriverManualCodeModalSheet> {
  late final TextEditingController _codeController;
  bool _isCodeValid = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _codeController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final isValid = _codeController.text.trim().isNotEmpty;
    if (isValid != _isCodeValid) {
      setState(() {
        _isCodeValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _codeController.removeListener(_onTextChanged);
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _codeController.text.trim();
    if (code.isNotEmpty) {
      widget.onCodeSubmitted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            locale.driverQrScannerSubtitle,
            style: getRegularStyle(
              color: color.onSurfaceVariant,
              fontSize: FontSize.size12,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: Spacing.md),
          AppTextField(
            controller: _codeController,
            hint: widget.defaultCode.isNotEmpty
                ? widget.defaultCode
                : '#BOX-1256',
            prefixIcon: Icon(
              Icons.qr_code_2_rounded,
              size: Spacing.iconMd,
              color: color.primary,
            ),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: Spacing.base),
          AppButton(
            text: locale.registrationConfirm,
            onPressed: _isCodeValid ? _submit : null,
            variant: AppButtonVariant.filled,
            isExpanded: true,
            height: Spacing.buttonHeight,
            borderRadius: Spacing.radiusMd,
            color: _isCodeValid
                ? color.primary
                : color.outlineVariant.withValues(alpha: 0.3),
            textColor: _isCodeValid
                ? color.onPrimary
                : color.onSurfaceVariant.withValues(alpha: 0.4),
            textStyle: getBoldStyle(
              color: _isCodeValid
                  ? color.onPrimary
                  : color.onSurfaceVariant.withValues(alpha: 0.4),
              fontSize: FontSize.size14,
            ),
          ),
          const SizedBox(height: Spacing.md),
        ],
      ),
    );
  }
}
