import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DriverSupportTicketDetailsShimmer extends StatelessWidget {
  const DriverSupportTicketDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.screenV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary Card skeleton
          ShimmerWidget(
            height: 96,
            borderRadius: Spacing.cardRadius,
          ),
          SizedBox(height: Spacing.md),

          // Timeline Card skeleton
          ShimmerWidget(
            height: 180,
            borderRadius: Spacing.cardRadius,
          ),
          SizedBox(height: Spacing.md),

          // Issue Card skeleton
          ShimmerWidget(
            height: 110,
            borderRadius: Spacing.cardRadius,
          ),
          SizedBox(height: Spacing.md),

          // Photos Card skeleton
          ShimmerWidget(
            height: 120,
            borderRadius: Spacing.cardRadius,
          ),
          SizedBox(height: Spacing.md),

          // Order Info Card skeleton
          ShimmerWidget(
            height: 110,
            borderRadius: Spacing.cardRadius,
          ),
          SizedBox(height: Spacing.xl),
        ],
      ),
    );
  }
}
