import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/widget/shimmer_widget.dart';

class AccountStatusShimmer extends StatelessWidget {
  const AccountStatusShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: Spacing.xl),
          ShimmerWidget(
            width: 120,
            height: 120,
            borderRadius: 60,
          ),
          SizedBox(height: Spacing.xl),
          ShimmerWidget(
            width: 200,
            height: 24,
            borderRadius: 6,
          ),
          SizedBox(height: Spacing.md),
          ShimmerWidget(
            width: 280,
            height: 16,
            borderRadius: 4,
          ),
          SizedBox(height: Spacing.xs),
          ShimmerWidget(
            width: 220,
            height: 16,
            borderRadius: 4,
          ),
          SizedBox(height: Spacing.xxl),
          ShimmerWidget(
            width: double.infinity,
            height: 140,
            borderRadius: 16,
          ),
          SizedBox(height: Spacing.xl),
          ShimmerWidget(
            width: double.infinity,
            height: 52,
            borderRadius: 12,
          ),
          SizedBox(height: Spacing.md),
          ShimmerWidget(
            width: double.infinity,
            height: 72,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}
