import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class OtpCodeField extends StatelessWidget {
  const OtpCodeField({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final pinWidth = ((constraints.maxWidth - (Spacing.sm * 5)) / 6)
            .clamp(44.0, 52.0)
            .toDouble();
        final pinHeight = pinWidth + 14;
        final defaultPinTheme = PinTheme(
          width: pinWidth,
          height: pinHeight,
          textStyle: getSemiBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size18,
          ),
          decoration: BoxDecoration(
            color: color.surface,
            border: Border.all(color: color.outlineVariant),
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
          ),
        );

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Pinput(
            length: 6,
            keyboardType: TextInputType.number,
            mainAxisAlignment: MainAxisAlignment.center,
            separatorBuilder: (_) => const SizedBox(width: Spacing.sm),
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyDecorationWith(
              border: Border.all(color: color.primary, width: 1.2),
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
            ),
            submittedPinTheme: defaultPinTheme.copyDecorationWith(
              border: Border.all(color: color.primary, width: 1.2),
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
            ),
            cursor: Center(
              child: Container(width: 1, height: 28, color: color.primary),
            ),
          ),
        );
      },
    );
  }
}
