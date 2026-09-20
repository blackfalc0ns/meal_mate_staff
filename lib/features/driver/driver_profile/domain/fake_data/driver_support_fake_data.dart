import 'package:flutter/material.dart';

import '../entities/driver_support_topic_entity.dart';

class DriverSupportFakeData {
  const DriverSupportFakeData._();

  static const String phoneNumber = '800 123 4567';
  static const String emailAddress = 'support@Resturant.com';

  static const List<DriverSupportTopicEntity> defaultTopics = [
    DriverSupportTopicEntity(
      id: 'delivery_issue',
      title: 'مشكلة في تسليم الطلب',
      subtitle: 'تأخير ، عدم استلام ، أو مشكلة في العنوان',
      icon: Icons.inventory_2_outlined,
    ),
    DriverSupportTopicEntity(
      id: 'app_issue',
      title: 'مشكلة في التطبيق',
      subtitle: 'أعطال ، تسجيل دخول ، أو أخطاء في التطبيق',
      icon: Icons.phone_android_rounded,
    ),
    DriverSupportTopicEntity(
      id: 'orders_billing',
      title: 'الطلبات والمدفوعات',
      subtitle: 'استفسارات عن الطلبات الفواتير',
      icon: Icons.receipt_long_rounded,
    ),
    DriverSupportTopicEntity(
      id: 'account_profile',
      title: 'الحساب والملف الشخصي',
      subtitle: 'تحديث البيانات ، تغيير رقم الهاتف',
      icon: Icons.person_outline_rounded,
    ),
  ];

  static const List<String> defaultCategories = [
    'مشكلة في تسليم الطلب',
    'مشكلة في التطبيق',
    'الطلبات والمدفوعات',
    'الحساب والملف الشخصي',
    'أخرى',
  ];
}
