import 'package:flutter/material.dart';

class RouteGenerator {
  const RouteGenerator._();

  static Route<dynamic> getRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const SizedBox.shrink(),
    );
  }
}
