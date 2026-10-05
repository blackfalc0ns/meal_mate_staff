import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';

class DriverHomeMapCard extends StatelessWidget {
  const DriverHomeMapCard({super.key, this.onLocateTap});

  final VoidCallback? onLocateTap;

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.asset(
      AppAssets.driverHomeMapBg,
      fit: BoxFit.cover,
      width: double.infinity,
    );

    if (onLocateTap == null) {
      return imageWidget;
    }

    return Stack(
      fit: StackFit.passthrough,
      children: [
        imageWidget,
        Positioned(
          left: 20,
          bottom: 50,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onLocateTap,
              customBorder: const CircleBorder(),
              child: const SizedBox(width: 44, height: 44),
            ),
          ),
        ),
      ],
    );
  }
}
