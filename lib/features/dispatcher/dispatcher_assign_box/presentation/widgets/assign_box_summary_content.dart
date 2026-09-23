import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/assign_box_summary_entity.dart';
import 'assign_box_summary_meal_row.dart';

class AssignBoxSummaryContent extends StatelessWidget {
  const AssignBoxSummaryContent({super.key, required this.summary});

  final AssignBoxSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Box Code, Box Count, and Selectable Barcode
        Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
            border: Border.all(color: color.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_rounded,
                        size: Spacing.iconMd,
                        color: color.primary,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        summary.boxCode,
                        style: getBoldStyle(
                          color: color.primary,
                          fontSize: FontSize.size16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: Spacing.xs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.primaryContainer,
                      borderRadius: BorderRadius.circular(Spacing.radiusPill),
                    ),
                    child: Text(
                      '${summary.boxCount} بوكس',
                      style: getSemiBoldStyle(
                        color: color.primary,
                        fontSize: FontSize.size11,
                      ),
                    ),
                  ),
                ],
              ),
              if (summary.barcode != null && summary.barcode!.isNotEmpty) ...[
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded,
                      size: Spacing.iconSm,
                      color: color.onSurfaceVariant,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      '${locale.assignBoxBarcode}: ',
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size11,
                      ),
                    ),
                    SelectableText(
                      summary.barcode!,
                      style: getBoldStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),

        // 2. Customer Information
        _buildSectionHeader(
          context,
          locale.assignBoxCustomerInfo,
          Icons.person_outline_rounded,
        ),
        const SizedBox(height: Spacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
            border: Border.all(color: color.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (summary.customerNameMasked != null &&
                  summary.customerNameMasked!.isNotEmpty)
                Text(
                  summary.customerNameMasked!,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size13,
                  ),
                ),
              if (summary.customerPhoneMasked != null &&
                  summary.customerPhoneMasked!.isNotEmpty) ...[
                const SizedBox(height: Spacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: Spacing.iconXs,
                      color: color.onSurfaceVariant,
                    ),
                    const SizedBox(width: Spacing.xs / 2),
                    Text(
                      summary.customerPhoneMasked!,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size12,
                      ),
                    ),
                  ],
                ),
              ],
              if (summary.customerMaskedId != null &&
                  summary.customerMaskedId!.isNotEmpty) ...[
                const SizedBox(height: Spacing.xs),
                Text(
                  summary.customerMaskedId!,
                  style: getRegularStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size11,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),

        // 3. Delivery Details
        _buildSectionHeader(
          context,
          locale.assignBoxDeliveryInfo,
          Icons.location_on_outlined,
        ),
        const SizedBox(height: Spacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
            border: Border.all(color: color.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (summary.zoneName != null && summary.zoneName!.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: Spacing.iconXs,
                      color: color.primary,
                    ),
                    const SizedBox(width: Spacing.xs / 2),
                    Text(
                      summary.zoneName!,
                      style: getBoldStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size12,
                      ),
                    ),
                  ],
                ),
              if (summary.address != null && summary.address!.isNotEmpty) ...[
                const SizedBox(height: Spacing.xs),
                Text(
                  summary.address!,
                  style: getRegularStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size12,
                  ),
                ),
              ],
              if (summary.deliveryTimeWindow != null &&
                  summary.deliveryTimeWindow!.isNotEmpty) ...[
                const SizedBox(height: Spacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: Spacing.iconXs,
                      color: color.onSurfaceVariant,
                    ),
                    const SizedBox(width: Spacing.xs / 2),
                    Text(
                      summary.deliveryTimeWindow!,
                      style: getMediumStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size11,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),

        // 4. Delivery Notes (if any)
        if (summary.deliveryNotes != null &&
            summary.deliveryNotes!.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            locale.assignBoxDeliveryNotes,
            Icons.notes_rounded,
          ),
          const SizedBox(height: Spacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
              border: Border.all(color: color.outlineVariant),
            ),
            child: Text(
              summary.deliveryNotes!,
              style: getRegularStyle(
                color: color.onSurface,
                fontSize: FontSize.size12,
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
        ],

        // 5. Allergies
        _buildSectionHeader(
          context,
          locale.assignBoxAllergiesTitle,
          Icons.warning_amber_rounded,
        ),
        const SizedBox(height: Spacing.xs),
        if (summary.allergies.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
            child: Text(
              locale.assignBoxNoAllergies,
              style: getRegularStyle(
                color: color.onSurfaceVariant,
                fontSize: FontSize.size12,
              ),
            ),
          )
        else
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: summary.allergies
                .map(
                  (allergy) => Chip(
                    label: Text(allergy),
                    labelStyle: getMediumStyle(
                      color: color.error,
                      fontSize: FontSize.size11,
                    ),
                    backgroundColor: color.errorContainer,
                    side: BorderSide(color: color.error),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: Spacing.md),

        // 6. Meals List
        _buildSectionHeader(
          context,
          locale.assignBoxMealsTitle,
          Icons.restaurant_rounded,
        ),
        const SizedBox(height: Spacing.xs),
        if (summary.meals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
            child: Text(
              locale.assignBoxNoMeals,
              style: getRegularStyle(
                color: color.onSurfaceVariant,
                fontSize: FontSize.size12,
              ),
            ),
          )
        else
          ...summary.meals.map((meal) => AssignBoxSummaryMealRow(meal: meal)),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final color = context.colorScheme;
    return Row(
      children: [
        Icon(icon, size: Spacing.iconSm, color: color.primary),
        const SizedBox(width: Spacing.xs),
        Text(
          title,
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size13,
          ),
        ),
      ],
    );
  }
}
