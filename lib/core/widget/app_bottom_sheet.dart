import 'package:flutter/material.dart';

import '../../config/theme/spacing.dart';

class AppBottomSheet {
  const AppBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = true,
    bool isScrollControlled = false,
    bool useSafeArea = true,
    Color? backgroundColor,
    double? elevation,
    BorderRadiusGeometry? borderRadius,
    Clip clipBehavior = Clip.antiAlias,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      backgroundColor: backgroundColor,
      elevation: elevation,
      clipBehavior: clipBehavior,
      shape: RoundedRectangleBorder(
        borderRadius:
            borderRadius ??
            const BorderRadius.vertical(top: Radius.circular(Spacing.radiusXl)),
      ),
      builder: builder,
    );
  }
}
