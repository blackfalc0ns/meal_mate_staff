import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DispatcherHomeMapShimmer extends StatelessWidget {
  const DispatcherHomeMapShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerWidget(
      width: double.infinity,
      height: 210,
      borderRadius: Spacing.cardRadius,
    );
  }
}
