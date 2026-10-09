import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class ReassignmentSubmissionShimmer extends StatelessWidget {
  const ReassignmentSubmissionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;

    return Semantics(
      label: localization.reassignSubmitting,
      liveRegion: true,
      child: const SizedBox(
        width: double.infinity,
        height: Spacing.buttonHeight,
        child: ShimmerWidget(
          width: double.infinity,
          height: Spacing.buttonHeight,
          borderRadius: Spacing.radiusLg,
        ),
      ),
    );
  }
}
