import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../../config/theme/spacing.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../domain/entities/dispatcher_support_date_preset.dart';
import '../../manager/dispatcher_support_event.dart';
import '../../manager/dispatcher_support_state.dart';
import '../../manager/dispatcher_support_view_model.dart';
import 'dispatcher_support_filter_chips.dart';
import 'dispatcher_support_kpi_bar.dart';
import 'dispatcher_support_search_bar.dart';
import 'dispatcher_support_status_tabs.dart';

class DispatcherSupportFiltersSection extends StatelessWidget {
  const DispatcherSupportFiltersSection({
    super.key,
    required this.state,
    required this.searchController,
    required this.viewModel,
    required this.onDateFilterTap,
  });

  final DispatcherSupportState state;
  final TextEditingController searchController;
  final DispatcherSupportViewModel viewModel;
  final VoidCallback onDateFilterTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final counters = state.response!.counters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Spacing.xs),
        DispatcherSupportKpiBar(kpi: counters),
        const SizedBox(height: Spacing.sm),
        DispatcherSupportStatusTabs(
          selectedStatus: state.query.status,
          openCount: counters.openCount,
          inProgressCount: counters.inProgressCount,
          resolvedCount: counters.resolvedCount,
          onChanged: (status) {
            unawaited(
              viewModel.doIntent(ChangeDispatcherSupportStatusEvent(status)),
            );
          },
        ),
        const SizedBox(height: Spacing.sm),
        DispatcherSupportSearchBar(
          controller: searchController,
          onChanged: (val) {
            unawaited(
              viewModel.doIntent(ChangeDispatcherSupportSearchEvent(val)),
            );
          },
          onClear: () {
            searchController.clear();
            unawaited(
              viewModel.doIntent(const ClearDispatcherSupportSearchEvent()),
            );
          },
        ),
        const SizedBox(height: Spacing.sm),
        DispatcherSupportFilterChips(
          areaChips: state.response!.areaChips,
          selectedArea: state.query.area ?? '',
          isDateFilterActive:
              state.query.datePreset != DispatcherSupportDatePreset.last7Days,
          onAreaSelected: (areaKey) {
            unawaited(
              viewModel.doIntent(
                ChangeDispatcherSupportAreaEvent(
                  areaKey.isEmpty ? null : areaKey,
                ),
              ),
            );
          },
          onDateFilterTap: onDateFilterTap,
        ),
        if (state.isFilterLoading) ...[
          const SizedBox(height: Spacing.xs),
          LinearProgressIndicator(
            minHeight: 2,
            color: color.primary,
            backgroundColor: color.primary.withValues(alpha: 0.1),
          ),
        ],
        const SizedBox(height: Spacing.sm),
      ],
    );
  }
}
