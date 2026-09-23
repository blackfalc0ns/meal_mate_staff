import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import 'dispatcher_drivers_shimmer.dart';

/// Shimmer shown when the content portion (KPI, section header, driver cards)
/// is reloading due to tab switch or area selection.
class DispatcherDriversContentShimmer extends StatelessWidget {
  const DispatcherDriversContentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. KPI card shimmer
        DispatcherDriversKpiShimmer(),
        SizedBox(height: Spacing.sm),

        // 2. Section header shimmer
        DispatcherDriversSectionHeaderShimmer(),
        SizedBox(height: Spacing.xs),

        // 3. Driver cards shimmer (3 cards)
        DispatcherDriversCardShimmer(),
        DispatcherDriversCardShimmer(),
        DispatcherDriversCardShimmer(),
      ],
    );
  }
}
