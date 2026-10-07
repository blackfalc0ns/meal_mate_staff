import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverDeliveryOptionalOtpSection extends StatefulWidget {
  const DriverDeliveryOptionalOtpSection({
    super.key,
    this.initialOtp = '',
    required this.onOtpChanged,
  });

  final String initialOtp;
  final ValueChanged<String> onOtpChanged;

  @override
  State<DriverDeliveryOptionalOtpSection> createState() =>
      _DriverDeliveryOptionalOtpSectionState();
}

class _DriverDeliveryOptionalOtpSectionState
    extends State<DriverDeliveryOptionalOtpSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialOtp);
  }

  @override
  void didUpdateWidget(covariant DriverDeliveryOptionalOtpSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialOtp != _controller.text &&
        widget.initialOtp != oldWidget.initialOtp) {
      _controller.text = widget.initialOtp;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: getSemiBoldStyle(
        color: color.onSurface,
        fontSize: FontSize.size20,
      ),
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: color.surface,
        border: Border.all(color: color.primary, width: 2),
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.pin_rounded,
                      color: color.primary,
                      size: Spacing.iconSm,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Flexible(
                      child: Text(
                        isAr ? 'رمز تأكيد الاستلام' : 'Receipt Confirmation Code',
                        style: getBoldStyle(
                          fontSize: FontSize.size13,
                          color: color.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs - 2,
                ),
                decoration: BoxDecoration(
                  color: color.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                ),
                child: Text(
                  isAr ? 'اختياري' : 'Optional',
                  style: getMediumStyle(
                    fontSize: FontSize.size10,
                    color: color.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            isAr
                ? 'رمز من 4 أرقام يقدمه العميل إن وجد (اختياري - التحقق غير مفعل بالخادم)'
                : '4-digit code provided by customer if available (Optional - backend verification not active)',
            style: getRegularStyle(
              fontSize: FontSize.size11,
              color: color.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: Pinput(
                key: const ValueKey('delivery_optional_otp_pinput'),
                controller: _controller,
                length: 4,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                onChanged: widget.onOtpChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
