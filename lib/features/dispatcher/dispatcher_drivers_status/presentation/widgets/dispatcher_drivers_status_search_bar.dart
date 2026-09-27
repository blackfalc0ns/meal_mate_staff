import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversStatusSearchBar extends StatefulWidget {
  const DispatcherDriversStatusSearchBar({
    super.key,
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  State<DispatcherDriversStatusSearchBar> createState() =>
      _DispatcherDriversStatusSearchBarState();
}

class _DispatcherDriversStatusSearchBarState
    extends State<DispatcherDriversStatusSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: getRegularStyle(
          fontFamily: FontConstant.alexandria,
          fontSize: FontSize.size12,
          color: color.onSurface,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: locale.driversStatusSearchHint,
          hintStyle: getRegularStyle(
            fontFamily: FontConstant.alexandria,
            fontSize: FontSize.size12,
            color: color.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: Spacing.iconMd,
            color: color.onSurfaceVariant,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    size: Spacing.iconSm,
                    color: color.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
        ),
      ),
    );
  }
}
