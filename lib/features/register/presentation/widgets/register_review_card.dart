import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/app_button.dart';
import 'register_review_field.dart';

class RegisterReviewCard extends StatelessWidget {
  const RegisterReviewCard({
    super.key,
    required this.title,
    required this.rows,
    required this.onEdit,
  });

  final String title;
  final List<List<RegisterReviewField>> rows;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final borderSide = BorderSide(color: color.outline);
    final tableRows = rows.where((row) => row.length > 1).toList();
    final singleRows = rows.where((row) => row.length == 1).toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surface,
        border: Border.all(color: color.outline),
        borderRadius: BorderRadius.circular(
          Spacing.registrationReviewCardRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: getBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size11,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(
                  width: Spacing.xxxl + Spacing.xl,
                  height: Spacing.xxl,
                  child: AppButton(
                    text: locale.registrationEdit,
                    onPressed: onEdit,
                    variant: AppButtonVariant.outlined,
                    icon: Icons.edit_outlined,
                    height: Spacing.xxl,
                    borderRadius: Spacing.registrationRadius,
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                    iconSize: Spacing.iconSm,
                    iconGap: Spacing.xs,
                    color: color.primary,
                    textColor: color.primary,
                    textStyle: getRegularStyle(
                      color: color.primary,
                      fontSize: FontSize.size9,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            if (tableRows.isNotEmpty)
              Table(
                key: const Key('register-review-card-table'),
                textDirection: Directionality.of(context),
                columnWidths: const {
                  0: FlexColumnWidth(),
                  1: FlexColumnWidth(),
                },
                border: TableBorder(
                  top: borderSide,
                  horizontalInside: borderSide,
                  verticalInside: borderSide,
                ),
                children: tableRows.map(_buildTableRow).toList(),
              ),
            ...singleRows.map((row) => _buildSingleRow(row.first, borderSide)),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(List<RegisterReviewField> fields) {
    final cells = fields.length == 1
        ? [fields.first, const SizedBox.shrink()]
        : fields.take(2).toList();

    return TableRow(
      children: cells
          .map(
            (field) => TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 28),
                  child: field,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSingleRow(RegisterReviewField field, BorderSide borderSide) {
    return DecoratedBox(
      key: const Key('register-review-single-row'),
      decoration: BoxDecoration(border: Border(top: borderSide)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 28),
          child: field,
        ),
      ),
    );
  }
}
