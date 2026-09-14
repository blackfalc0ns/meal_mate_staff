import 'package:flutter/material.dart';

import '../../config/theme/font_manager.dart';
import '../../config/theme/spacing.dart';
import '../../config/theme/styles_manager.dart';
import '../extensions/extensions.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({
    super.key,
    this.header,
    this.title,
    this.subtitle,
    this.headerLeading,
    this.headerTrailing,
    required this.child,
    this.footer,
    this.padding,
    this.maxHeightFactor = 0.9,
    this.showDragHandle = true,
  });

  final Widget? header;
  final String? title;
  final String? subtitle;
  final Widget? headerLeading;
  final Widget? headerTrailing;
  final Widget child;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;
  final double maxHeightFactor;
  final bool showDragHandle;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    Widget? header,
    String? title,
    String? subtitle,
    Widget? headerLeading,
    Widget? headerTrailing,
    Widget? footer,
    EdgeInsetsGeometry? padding,
    double maxHeightFactor = 0.9,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomBottomSheet(
        header: header,
        title: title,
        subtitle: subtitle,
        headerLeading: headerLeading,
        headerTrailing: headerTrailing,
        footer: footer,
        padding: padding,
        maxHeightFactor: maxHeightFactor,
        showDragHandle: showDragHandle,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final hasHeader =
        title != null ||
        subtitle != null ||
        headerLeading != null ||
        headerTrailing != null;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * maxHeightFactor),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Spacing.radiusXl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDragHandle) ...[
              const SizedBox(height: Spacing.sm),
              Center(
                child: Container(
                  width: Spacing.xxl + Spacing.sm,
                  height: Spacing.xs,
                  decoration: BoxDecoration(
                    color: color.outlineVariant,
                    borderRadius: BorderRadius.circular(Spacing.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xs),
            ],
            if (header != null)
              header!
            else if (hasHeader)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.screenH,
                  vertical: Spacing.xs,
                ),
                child: Row(
                  children: [
                    if (headerLeading != null)
                      headerLeading!
                    else
                      const SizedBox(width: Spacing.xl),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (title != null)
                            Text(
                              title!,
                              style: getBoldStyle(
                                color: color.onSurface,
                                fontSize: FontSize.size16,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (subtitle != null) ...[
                            const SizedBox(height: Spacing.xs / 2),
                            Text(
                              subtitle!,
                              style: getRegularStyle(
                                color: color.onSurfaceVariant,
                                fontSize: FontSize.size12,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (headerTrailing != null)
                      headerTrailing!
                    else
                      const SizedBox(width: Spacing.xl),
                  ],
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding:
                    padding ??
                    const EdgeInsets.symmetric(
                      horizontal: Spacing.screenH,
                      vertical: Spacing.sm,
                    ),
                child: child,
              ),
            ),
            if (footer != null)
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(width: Spacing.border)),
                ),
                child: footer!,
              ),
          ],
        ),
      ),
    );
  }
}
