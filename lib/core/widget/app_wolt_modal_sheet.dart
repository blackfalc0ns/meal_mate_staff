import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../config/theme/font_manager.dart';
import '../../config/theme/spacing.dart';
import '../../config/theme/styles_manager.dart';
import '../extensions/extensions.dart';
import 'app_button.dart';

class RegistrationFakeData {
  const RegistrationFakeData._();

  static const List<String> nationalities = [
    'كويتي',
    'سعودي',
    'مصري',
    'أردني',
    'إماراتي',
    'بحريني',
    'عُماني',
    'قطري',
    'لبناني',
    'سوري',
    'سوداني',
    'عراقي',
    'يمني',
    'تونسي',
    'مغربي',
    'هندي',
    'باكستاني',
    'فلبيني',
  ];

  static const List<String> vehicleTypes = [
    'سيارة سيدان',
    'سيارة صغيرة (هاتشباك)',
    'سيارة دفع رباعي (SUV)',
    'دراجة نارية',
    'سكوتر',
    'فان نقل بضائع',
    'بيك أب',
  ];

  static const List<String> manufactureYears = [
    '2026',
    '2025',
    '2024',
    '2023',
    '2022',
    '2021',
    '2020',
    '2019',
    '2018',
    '2017',
    '2016',
    '2015',
    '2014',
    '2013',
    '2012',
    '2011',
    '2010',
  ];

  static const List<String> birthDates = [
    '1995/05/15',
    '1996/08/20',
    '1997/01/10',
    '1998/11/25',
    '1999/03/12',
    '2000/07/05',
    '2001/09/18',
    '2002/04/30',
    '2003/12/01',
    '1994/06/14',
    '1993/10/22',
    '1992/02/28',
  ];
}

class AppWoltPickerSheet {
  const AppWoltPickerSheet._();

  static Future<String?> show({
    required BuildContext context,
    required String title,
    required List<String> items,
    String? selectedItem,
    String? searchHint,
    IconData? itemLeadingIcon,
  }) {
    return WoltModalSheet.show<String>(
      context: context,
      useSafeArea: true,
      pageListBuilder: (modalContext) {
        return [
          WoltModalSheetPage(
            hasTopBarLayer: true,
            isTopBarLayerAlwaysVisible: true,
            topBarTitle: Text(
              title,
              style: getBoldStyle(
                fontSize: FontSize.size14,
                color: modalContext.colorScheme.onSurface,
              ),
            ),
            trailingNavBarWidget: IconButton(
              icon: const Icon(Icons.close_rounded),
              color: modalContext.colorScheme.onSurfaceVariant,
              onPressed: () => Navigator.of(modalContext).pop(),
            ),
            child: _PickerContent(
              items: items,
              selectedItem: selectedItem,
              searchHint: searchHint ?? 'ابحث هنا...',
              itemLeadingIcon: itemLeadingIcon,
              onItemSelected: (selected) {
                Navigator.of(modalContext).pop(selected);
              },
            ),
          ),
        ];
      },
    );
  }

  static Future<DateTime?> showDatePicker({
    required BuildContext context,
    required String title,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return WoltModalSheet.show<DateTime>(
      context: context,
      useSafeArea: true,
      pageListBuilder: (modalContext) {
        return [
          WoltModalSheetPage(
            hasTopBarLayer: true,
            isTopBarLayerAlwaysVisible: true,
            topBarTitle: Text(
              title,
              style: getBoldStyle(
                fontSize: FontSize.size14,
                color: modalContext.colorScheme.onSurface,
              ),
            ),
            trailingNavBarWidget: IconButton(
              icon: const Icon(Icons.close_rounded),
              color: modalContext.colorScheme.onSurfaceVariant,
              onPressed: () => Navigator.of(modalContext).pop(),
            ),
            child: _DatePickerContent(
              initialDate: initialDate ?? DateTime(2000, 1, 1),
              firstDate: firstDate ?? DateTime(1950),
              lastDate: lastDate ?? DateTime.now(),
              onDateSelected: (date) {
                Navigator.of(modalContext).pop(date);
              },
            ),
          ),
        ];
      },
    );
  }
}

class _DatePickerContent extends StatefulWidget {
  const _DatePickerContent({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<_DatePickerContent> createState() => _DatePickerContentState();
}

class _DatePickerContentState extends State<_DatePickerContent> {
  late List<DateTime?> _selectedDates;

  @override
  void initState() {
    super.initState();
    _selectedDates = [widget.initialDate];
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CalendarDatePicker2(
            config: CalendarDatePicker2Config(
              calendarType: CalendarDatePicker2Type.single,
              selectedDayHighlightColor: color.primary,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              currentDate: widget.initialDate,
              selectedDayTextStyle: getBoldStyle(
                fontSize: FontSize.size14,
                color: color.onPrimary,
              ),
              todayTextStyle: getBoldStyle(
                fontSize: FontSize.size14,
                color: color.primary,
              ),
              dayTextStyle: getMediumStyle(
                fontSize: FontSize.size14,
                color: color.onSurface,
              ),
              disabledDayTextStyle: getRegularStyle(
                fontSize: FontSize.size14,
                color: color.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              yearTextStyle: getMediumStyle(
                fontSize: FontSize.size14,
                color: color.onSurface,
              ),
              controlsTextStyle: getBoldStyle(
                fontSize: FontSize.size14,
                color: color.onSurface,
              ),
            ),
            value: _selectedDates,
            onValueChanged: (dates) {
              setState(() {
                _selectedDates = dates;
              });
            },
          ),
          const SizedBox(height: Spacing.base),
          AppButton(
            text: 'تأكيد',
            height: Spacing.registrationButtonHeight,
            borderRadius: Spacing.registrationRadius,
            onPressed: () {
              if (_selectedDates.isNotEmpty && _selectedDates.first != null) {
                widget.onDateSelected(_selectedDates.first!);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(height: Spacing.md),
        ],
      ),
    );
  }
}

class _PickerContent extends StatefulWidget {
  const _PickerContent({
    required this.items,
    required this.onItemSelected,
    this.selectedItem,
    this.searchHint = 'ابحث...',
    this.itemLeadingIcon,
  });

  final List<String> items;
  final ValueChanged<String> onItemSelected;
  final String? selectedItem;
  final String searchHint;
  final IconData? itemLeadingIcon;

  @override
  State<_PickerContent> createState() => _PickerContentState();
}

class _PickerContentState extends State<_PickerContent> {
  late final TextEditingController _searchController;
  late List<String> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.contains(query.trim()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.items.length > 6) ...[
            TextField(
              controller: _searchController,
              onChanged: _filter,
              style: getMediumStyle(
                fontSize: FontSize.size12,
                color: color.onSurface,
              ),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: getRegularStyle(
                  fontSize: FontSize.size12,
                  color: color.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: color.onSurfaceVariant,
                  size: Spacing.iconMd,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _filter('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                filled: true,
                fillColor: color.surfaceContainerHighest.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  borderSide: BorderSide(color: color.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  borderSide: BorderSide(color: color.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  borderSide: BorderSide(color: color.primary),
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: _filteredItems.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(Spacing.xl),
                    child: Center(
                      child: Text(
                        'لا توجد نتائج مطابقة',
                        style: getRegularStyle(
                          fontSize: FontSize.size12,
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _filteredItems.length,
                    separatorBuilder: (_, _) => Divider(
                      height: Spacing.border,
                      color: color.outlineVariant.withValues(alpha: 0.4),
                    ),
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = item == widget.selectedItem;

                      return InkWell(
                        onTap: () => widget.onItemSelected(item),
                        borderRadius: BorderRadius.circular(Spacing.radiusSm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.sm,
                            vertical: Spacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.primary.withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(Spacing.radiusSm),
                          ),
                          child: Row(
                            children: [
                              if (widget.itemLeadingIcon != null) ...[
                                Icon(
                                  widget.itemLeadingIcon,
                                  size: Spacing.iconMd,
                                  color: isSelected
                                      ? color.primary
                                      : color.onSurfaceVariant,
                                ),
                                const SizedBox(width: Spacing.sm),
                              ],
                              Expanded(
                                child: Text(
                                  item,
                                  style: isSelected
                                      ? getBoldStyle(
                                          fontSize: FontSize.size12,
                                          color: color.primary,
                                        )
                                      : getMediumStyle(
                                          fontSize: FontSize.size12,
                                          color: color.onSurface,
                                        ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: Spacing.iconMd,
                                  color: color.primary,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: Spacing.sm),
        ],
      ),
    );
  }
}
