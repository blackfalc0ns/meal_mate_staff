import 'package:flutter/material.dart';

class DispatcherNotificationSettingEntity {
  const DispatcherNotificationSettingEntity({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    this.isEnabled = true,
  });

  final String id;
  final String titleKey;
  final String subtitleKey;
  final IconData icon;
  final bool isEnabled;

  DispatcherNotificationSettingEntity copyWith({bool? isEnabled}) {
    return DispatcherNotificationSettingEntity(
      id: id,
      titleKey: titleKey,
      subtitleKey: subtitleKey,
      icon: icon,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
