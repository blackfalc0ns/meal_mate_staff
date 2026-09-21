import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_vehicle_color_entity.dart';

String? canonicalVehicleColorHex(String? value) {
  final raw = value?.trim().toUpperCase() ?? '';
  final withHash = raw.startsWith('#') ? raw : '#$raw';
  return RegExp(r'^#[0-9A-F]{6}$').hasMatch(withHash) ? withHash : null;
}

Color? _colorFromHex(String? value) {
  final canonical = canonicalVehicleColorHex(value);
  if (canonical == null) return null;
  return Color(0xFF000000 | int.parse(canonical.substring(1), radix: 16));
}

class RegisterVehicleColorPicker extends StatelessWidget {
  const RegisterVehicleColorPicker({
    super.key,
    required this.colors,
    required this.selectedHex,
    required this.onColorSelected,
  });

  final List<DriverVehicleColorEntity> colors;
  final String selectedHex;
  final ValueChanged<String> onColorSelected;

  Future<void> _showOtherColorDialog(BuildContext context) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => _OtherColorDialog(
        initialHex: canonicalVehicleColorHex(selectedHex)?.substring(1) ?? '',
      ),
    );

    if (selected != null) onColorSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final visibleColors =
        colors
            .where(
              (entry) =>
                  entry.isDefault &&
                  canonicalVehicleColorHex(entry.hex) != null,
            )
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final selectedCanonical = canonicalVehicleColorHex(selectedHex);
    final selectedIsDefault = visibleColors.any(
      (entry) => canonicalVehicleColorHex(entry.hex) == selectedCanonical,
    );

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
        Wrap(
          spacing: Spacing.md,
          runSpacing: Spacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...visibleColors.map((entry) {
              final canonical = canonicalVehicleColorHex(entry.hex)!;
              return _RegisterVehicleColorOption(
                color: _colorFromHex(canonical)!,
                label: isArabic ? entry.nameAr : entry.nameEn,
                selected: canonical == canonicalVehicleColorHex(selectedHex),
                onTap: () => onColorSelected(canonical),
              );
            }),
            if (selectedCanonical != null && !selectedIsDefault)
              _RegisterVehicleColorOption(
                key: const ValueKey('selectedCustomVehicleColorPreview'),
                color: _colorFromHex(selectedCanonical)!,
                label: '${locale.registrationOther} $selectedCanonical',
                selected: true,
                onTap: () => onColorSelected(selectedCanonical),
              ),
            TextButton(
              onPressed: () => _showOtherColorDialog(context),
              child: Text(
                locale.registrationOther,
                style: getRegularStyle(
                  color: color.onSurfaceVariant,
                  fontSize: FontSize.size14,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OtherColorDialog extends StatefulWidget {
  const _OtherColorDialog({required this.initialHex});

  final String initialHex;

  @override
  State<_OtherColorDialog> createState() => _OtherColorDialogState();
}

class _OtherColorDialogState extends State<_OtherColorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialHex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;
    final previewColor = _colorFromHex(_controller.text);
    return AlertDialog(
      title: Text(locale.registrationVehicleColor),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const ValueKey('vehicleColorHexInput'),
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: locale.registrationHexColor,
                hintText: '#5E35B1',
              ),
              validator: (value) => canonicalVehicleColorHex(value) == null
                  ? locale.registrationInvalidHexColor
                  : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: Spacing.md),
            Semantics(
              label: locale.registrationVehicleColor,
              child: Container(
                key: const ValueKey('vehicleColorPreview'),
                height: 48,
                decoration: BoxDecoration(
                  color: previewColor ?? Colors.transparent,
                  border: Border.all(color: context.colorScheme.outline),
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.of(
              context,
            ).pop(canonicalVehicleColorHex(_controller.text));
          },
          child: Text(locale.registrationUseColor),
        ),
      ],
    );
  }
}

class _RegisterVehicleColorOption extends StatelessWidget {
  const _RegisterVehicleColorOption({
    super.key,
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
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
            child: const SizedBox.square(dimension: 40),
          ),
        ),
      ),
    );
  }
}
