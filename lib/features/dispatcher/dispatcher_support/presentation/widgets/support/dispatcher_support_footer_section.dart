import 'package:flutter/material.dart';

import '../../../../../../config/theme/spacing.dart';
import 'dispatcher_support_info_banner.dart';
import 'dispatcher_support_pagination_footer.dart';

class DispatcherSupportFooterSection extends StatelessWidget {
  const DispatcherSupportFooterSection({
    super.key,
    required this.isNextPageLoading,
    required this.hasPageFailure,
    required this.onRetry,
  });

  final bool isNextPageLoading;
  final bool hasPageFailure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DispatcherSupportPaginationFooter(
            isLoading: isNextPageLoading,
            hasError: hasPageFailure,
            onRetry: onRetry,
          ),
          const Padding(
            padding: EdgeInsets.only(top: Spacing.xs),
            child: DispatcherSupportInfoBanner(),
          ),
          const SizedBox(height: Spacing.bottomNavHeight + Spacing.xl),
        ],
      ),
    );
  }
}
