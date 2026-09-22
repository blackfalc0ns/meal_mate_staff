import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DispatcherHomeShimmer extends StatelessWidget {
  const DispatcherHomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ShimmerWidget(height: 72, borderRadius: Spacing.radiusMd),
          const SizedBox(height: Spacing.base),
          Row(
            children: List.generate(
              4,
              (index) => const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: ShimmerWidget(
                    height: 84,
                    borderRadius: Spacing.radiusMd,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          const ShimmerWidget(height: 62, borderRadius: Spacing.radiusMd),
          const SizedBox(height: Spacing.lg),
          const ShimmerWidget(height: 240, borderRadius: Spacing.cardRadius),
          const SizedBox(height: Spacing.lg),
          const Row(
            children: [
              Expanded(child: ShimmerWidget(height: 260)),
              SizedBox(width: Spacing.sm),
              Expanded(child: ShimmerWidget(height: 260)),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          const ShimmerWidget(height: 80),
        ],
      ),
    );
  }
}
