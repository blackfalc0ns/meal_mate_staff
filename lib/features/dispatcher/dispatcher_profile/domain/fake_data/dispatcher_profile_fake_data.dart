import 'package:flutter/material.dart';

import '../../../../../core/constants/assets.dart';
import '../entities/dispatcher_notification_setting_entity.dart';
import '../entities/dispatcher_profile_entity.dart';

class DispatcherProfileFakeData {
  const DispatcherProfileFakeData._();

  static const String appVersion = 'V 1.2.0';

  static const DispatcherProfileEntity sampleProfile = DispatcherProfileEntity(
    name: 'محمد العازمي',
    roleTitle: 'مسؤول التوصيل',
    roleCode: 'DR-2011',
    isAvailable: true,
    avatarAsset: AppAssets.registrationDriverRole,
    phone: '+966 55 123 4567',
    email: 'm.alazmi@mealmate.com',
    isEmailEditable: false,
    maskedPassword: '•••••••••',
  );

  static const List<DispatcherNotificationSettingEntity> sampleNotificationSettings = [
    DispatcherNotificationSettingEntity(
      id: 'new_box',
      titleKey: 'new_box',
      subtitleKey: 'new_box',
      icon: Icons.inventory_2_rounded,
      isEnabled: true,
    ),
    DispatcherNotificationSettingEntity(
      id: 'box_problem',
      titleKey: 'box_problem',
      subtitleKey: 'box_problem',
      icon: Icons.warning_amber_rounded,
      isEnabled: true,
    ),
    DispatcherNotificationSettingEntity(
      id: 'driver_completed',
      titleKey: 'driver_completed',
      subtitleKey: 'driver_completed',
      icon: Icons.person_rounded,
      isEnabled: true,
    ),
    DispatcherNotificationSettingEntity(
      id: 'performance_updates',
      titleKey: 'performance_updates',
      subtitleKey: 'performance_updates',
      icon: Icons.trending_up_rounded,
      isEnabled: false,
    ),
  ];
}
