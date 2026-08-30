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

    return SizedBox(
      height: Spacing.registrationStepsHeight,
      child: Column(
        children: [
          Row(
            children: List.generate(labels.length, (index) {
              final step = index + 1;
              final isActive = step == currentStep;
              final isComplete = step < currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isComplete ? color.primary : color.outline,
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: isActive ? color.primary : color.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive || isComplete
                              ? color.primary
                              : color.outline,
                        ),
                      ),
                      child: SizedBox.square(
                        dimension: Spacing.registrationStepCircle,
                        child: Center(
                          child: Text(
                            '$step',
                            style: getBoldStyle(
                              color: isActive
                                  ? color.onPrimary
                                  : color.onSurface,
                              fontSize: FontSize.size16,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isComplete ? color.primary : color.outline,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
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
      ),
    );
  }
}
