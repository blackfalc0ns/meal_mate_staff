import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DriverProfileShimmer extends StatelessWidget {
  const DriverProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero card skeleton
        ShimmerWidget(
          height: 220,
          borderRadius: Spacing.cardRadius,
        ),
        SizedBox(height: Spacing.md),

        // Vehicle card skeleton
        ShimmerWidget(
          height: 120,
          borderRadius: Spacing.cardRadius,
        ),
        SizedBox(height: Spacing.md),

        // Documents card skeleton
        ShimmerWidget(
          height: 160,
          borderRadius: Spacing.cardRadius,
        ),
        SizedBox(height: Spacing.md),

        // Support card skeleton
        ShimmerWidget(
          height: 90,
          borderRadius: Spacing.cardRadius,
        ),
        SizedBox(height: Spacing.md),

        // Ticket card skeleton
        ShimmerWidget(
          height: 130,
          borderRadius: Spacing.cardRadius,
        ),
        SizedBox(height: Spacing.md),

        // Quick actions row skeleton
        ShimmerWidget(
          height: 60,
          borderRadius: Spacing.cardRadius,
        ),
      ],
    );
  }
}
