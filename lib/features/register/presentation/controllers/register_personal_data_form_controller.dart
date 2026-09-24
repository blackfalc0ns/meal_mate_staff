import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/app_cached_network_image.dart';
import '../../../../core/widget/app_wolt_modal_sheet.dart';
import '../../domain/entities/driver_nationality_entity.dart';
import '../../domain/entities/driver_restaurant_entity.dart';
import '../../domain/register_personal_data.dart';

/// Encapsulates controllers, selection state, and picker workflows for the Personal Data registration step.
class RegisterPersonalDataFormController {
  RegisterPersonalDataFormController([RegisterPersonalData? initialData]) {
    fullNameAr = TextEditingController(
      text: initialData?.resolvedFullNameAr ?? '',
    );
    fullNameEn = TextEditingController(
      text: initialData?.resolvedFullNameEn ?? '',
    );
    restaurant = TextEditingController(text: initialData?.restaurantName ?? '');
    phone = TextEditingController(text: initialData?.phone ?? '');
    password = TextEditingController(text: initialData?.password ?? '');
    email = TextEditingController(text: initialData?.email ?? '');
    birthDate = TextEditingController(text: initialData?.birthDate ?? '');
    nationality = TextEditingController(text: initialData?.nationality ?? '');
    civilId = TextEditingController(text: initialData?.civilId ?? '');
    nationalIdExpiry = TextEditingController(
      text: initialData?.nationalIdExpiry ?? '',
    );

    selectedRestaurantId = initialData?.restaurantId ?? '';
    selectedRestaurantName = initialData?.restaurantName ?? '';
  }

  late final TextEditingController fullNameAr;
  late final TextEditingController fullNameEn;
  late final TextEditingController restaurant;
  late final TextEditingController phone;
  late final TextEditingController password;
  late final TextEditingController email;
  late final TextEditingController birthDate;
  late final TextEditingController nationality;
  late final TextEditingController civilId;
  late final TextEditingController nationalIdExpiry;

  String selectedRestaurantId = '';
  String selectedRestaurantName = '';

  void dispose() {
    fullNameAr.dispose();
    fullNameEn.dispose();
    restaurant.dispose();
    phone.dispose();
    password.dispose();
    email.dispose();
    birthDate.dispose();
    nationality.dispose();
    civilId.dispose();
    nationalIdExpiry.dispose();
  }

  Future<void> pickRestaurant(
    BuildContext context,
    List<DriverRestaurantEntity> restaurants,
  ) async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final restaurantMap = <String, DriverRestaurantEntity>{};
    for (final item in restaurants) {
      final name = isArabic ? item.tradeNameAr : item.tradeNameEn;
      restaurantMap[name] = item;
    }
    final labels = restaurantMap.keys.toList();

    final selected = await AppWoltPickerSheet.show(
      context: context,
      title: context.localization.registrationRestaurant,
      items: labels,
      selectedItem: restaurant.text.isEmpty ? null : restaurant.text,
      searchHint: context.localization.registrationRestaurantHint,
      itemLeadingBuilder: (label) {
        final item = restaurantMap[label];
        return AppCachedNetworkImage(
          imageUrl: item?.logoUrl,
          width: 32,
          height: 32,
          shape: BoxShape.circle,
        );
      },
    );

    if (selected == null || !context.mounted) return;
    final item = restaurantMap[selected];
    if (item != null) {
      selectedRestaurantId = item.id;
      selectedRestaurantName = selected;
      restaurant.text = selected;
    }
  }

  Future<void> pickBirthDate(BuildContext context) async {
    final selected = await AppWoltPickerSheet.showDatePicker(
      context: context,
      title: context.localization.registrationBirthDate,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selected != null && context.mounted) {
      birthDate.text =
          '${selected.year}/${selected.month.toString().padLeft(2, '0')}/${selected.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> pickNationality(
    BuildContext context,
    List<DriverNationalityEntity> nationalities,
  ) async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final labels = nationalities
        .map(
          (item) => '${item.flagEmoji} ${isArabic ? item.nameAr : item.nameEn}',
        )
        .toList();

    final selected = await AppWoltPickerSheet.show(
      context: context,
      title: context.localization.registrationNationality,
      items: labels,
      selectedItem: nationality.text.isNotEmpty ? nationality.text : null,
      searchHint: isArabic ? 'ابحث عن الجنسية...' : 'Search nationality...',
    );

    if (selected != null && context.mounted) {
      nationality.text = selected;
    }
  }

  Future<void> pickNationalIdExpiry(BuildContext context) async {
    final now = DateTime.now();
    final selected = await AppWoltPickerSheet.showDatePicker(
      context: context,
      title: context.localization.registrationIdExpiry,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: DateTime(now.year + 30),
    );

    if (selected != null && context.mounted) {
      nationalIdExpiry.text =
          '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
    }
  }

  RegisterPersonalData toPersonalData() {
    final englishParts = fullNameEn.text.trim().split(RegExp(r'\s+'));
    return RegisterPersonalData(
      firstName: englishParts.first,
      lastName: englishParts.length > 1 ? englishParts.skip(1).join(' ') : '',
      phone: phone.text.trim(),
      email: email.text.trim(),
      birthDate: birthDate.text.trim(),
      nationality: nationality.text.trim(),
      civilId: civilId.text.trim(),
      restaurantId: selectedRestaurantId,
      restaurantName: selectedRestaurantName,
      fullNameAr: fullNameAr.text.trim(),
      fullNameEn: fullNameEn.text.trim(),
      nationalIdExpiry: nationalIdExpiry.text.trim(),
      password: password.text,
    );
  }
}
