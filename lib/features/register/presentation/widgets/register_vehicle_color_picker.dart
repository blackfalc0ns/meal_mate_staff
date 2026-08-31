import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class RegisterVehicleColorPicker extends StatelessWidget {
  const RegisterVehicleColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  static const _colors = [
    Color(0xFFFFFFFF),
    Color(0xFF603BC1),
    Color(0xFF090909),
    Color(0xFFC4C4C4),
    Color(0xFF508BD9),
    Color(0xFFBF1520),
  ];

  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          locale.registrationVehicleColor,
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size13,
            height: 1.2,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: Spacing.base),
        Row(
          children: [
            ..._colors.map(
              (vehicleColor) => Padding(
                padding: const EdgeInsetsDirectional.only(start: Spacing.md),
                child: _RegisterVehicleColorOption(
                  color: vehicleColor,
                  selected: vehicleColor == selectedColor,
                  onTap: () => onColorSelected(vehicleColor),
                ),
              ),
            ),
            const Spacer(),
            Text(
              locale.registrationOther,
              style: getRegularStyle(
                color: color.onSurfaceVariant,
                fontSize: FontSize.size14,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RegisterVehicleColorOption extends StatelessWidget {
  const _RegisterVehicleColorOption({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? scheme.primary : scheme.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: const SizedBox.square(dimension: 28),
      ),
    );
  }
}
