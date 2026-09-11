import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class RegistrationStepProgress extends StatelessWidget {
  const RegistrationStepProgress({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final labels = [
      locale.registrationPersonalData,
      locale.registrationVehicleData,
      locale.registrationDocuments,
      locale.registrationReviewOrder,
    ];
    final progressFactor = labels.length <= 1
        ? 0.0
        : (currentStep - 1).clamp(0, labels.length - 1) / (labels.length - 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            height: Spacing.registrationStepCircle,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.registrationStepCircle / 2,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        key: const Key('registration-step-progress-track'),
                        height: Spacing.border,
                        color: color.outline,
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: FractionallySizedBox(
                          widthFactor: progressFactor,
                          child: Container(
                            key: const Key('registration-step-progress-fill'),
                            height: Spacing.border,
                            color: color.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(labels.length, (index) {
                    final step = index + 1;
                    final isActive = step == currentStep;
                    final isComplete = step < currentStep;

                    return Expanded(
                      child: _RegistrationStepCircle(
                        step: step,
                        isActive: isActive,
                        isComplete: isComplete,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: labels
                .map(
                  (label) => Expanded(
                    child: Text(
                      label,
                      style: getSemiBoldStyle(
                        color: labels.indexOf(label) + 1 == currentStep
                            ? color.onSurface
                            : color.onSurfaceVariant,
                        fontSize: FontSize.size10,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      );
  }
}

class _RegistrationStepCircle extends StatelessWidget {
  const _RegistrationStepCircle({
    required this.step,
    required this.isActive,
    required this.isComplete,
  });

  final int step;
  final bool isActive;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final isHighlighted = isActive || isComplete;

    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isHighlighted ? color.primary : color.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isHighlighted ? color.primary : color.outline,
          ),
        ),
        child: SizedBox.square(
          dimension: Spacing.registrationStepCircle,
          child: Center(
            child: isComplete
                ? Icon(
                    Icons.check_rounded,
                    color: color.onPrimary,
                    size: Spacing.iconSm,
                  )
                : Text(
                    '$step',
                    style: getBoldStyle(
                      color: isActive ? color.onPrimary : color.onSurface,
                      fontSize: FontSize.size16,
                      height: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
