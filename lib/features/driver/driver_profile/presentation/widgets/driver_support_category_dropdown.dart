import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverSupportCategoryDropdown extends StatelessWidget {
  const DriverSupportCategoryDropdown({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;

  void _showCategoryPicker(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: color.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Spacing.cardRadius),
          ),
        ),
        builder: (modalContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.base,
                vertical: Spacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: color.outlineVariant,
                        borderRadius: BorderRadius.circular(Spacing.xs),
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.base),
                  Text(
                    locale.driverSupportCategoryLabel,
                    style: getBoldStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size16,
                      color: color.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.base),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: color.outlineVariant.withValues(alpha: 0.3),
                      ),
                      itemBuilder: (context, index) {
                        final item = categories[index];
                        final isSelected = item == selectedCategory;
                        return ListTile(
                          title: Text(
                            item,
                            style: isSelected
                                ? getBoldStyle(
                                    fontFamily: FontConstant.alexandria,
                                    fontSize: FontSize.size14,
                                    color: color.primary,
                                  )
                                : getRegularStyle(
                                    fontFamily: FontConstant.alexandria,
                                    fontSize: FontSize.size14,
                                    color: color.onSurface,
                                  ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: color.primary,
                                )
                              : null,
                          onTap: () {
                            Navigator.of(modalContext).pop();
                            onCategorySelected(item);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return InkWell(
      onTap: () => _showCategoryPicker(context),
      borderRadius: BorderRadius.circular(Spacing.cardRadius),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm + 2),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          border: Border.all(
            color: color.outlineVariant.withValues(alpha: 0.6),
            width: Spacing.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              locale.driverSupportCategoryLabel,
              style: getBoldStyle(
                fontFamily: FontConstant.alexandria,
                fontSize: FontSize.size10,
                color: color.onSurface,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCategory ?? locale.driverSupportCategoryHint,
                  style: selectedCategory != null
                      ? getMediumStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size11,
                          color: color.onSurface,
                        )
                      : getRegularStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size11,
                          color: color.onSurfaceVariant,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: Spacing.xs),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: color.onSurfaceVariant,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
