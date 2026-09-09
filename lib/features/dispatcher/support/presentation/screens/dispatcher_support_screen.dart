import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_support_issue_entity.dart';
import '../../domain/entities/dispatcher_support_status.dart';
import '../../domain/fake_data/dispatcher_support_fake_data.dart';
import '../widgets/dispatcher_support_filter_chips.dart';
import '../widgets/dispatcher_support_header.dart';
import '../widgets/dispatcher_support_info_banner.dart';
import '../widgets/dispatcher_support_issue_card.dart';
import '../widgets/dispatcher_support_kpi_bar.dart';
import '../widgets/dispatcher_support_search_bar.dart';
import '../widgets/dispatcher_support_status_tabs.dart';

class DispatcherSupportScreen extends StatefulWidget {
  const DispatcherSupportScreen({
    super.key,
    this.onBack,
    this.onViewDetails,
    this.onAssignAlternativeDriver,
    this.showBottomNavBar = false,
  });

  final VoidCallback? onBack;
  final ValueChanged<DispatcherSupportIssueEntity>? onViewDetails;
  final ValueChanged<DispatcherSupportIssueEntity>? onAssignAlternativeDriver;
  final bool showBottomNavBar;

  @override
  State<DispatcherSupportScreen> createState() =>
      _DispatcherSupportScreenState();
}

class _DispatcherSupportScreenState extends State<DispatcherSupportScreen> {
  late final TextEditingController _searchController;
  DispatcherSupportStatus _selectedStatus = DispatcherSupportStatus.open;
  String _selectedArea = DispatcherSupportFakeData.areas.first;
  bool _isDateFilterActive = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DispatcherSupportIssueEntity> get _filteredIssues {
    return DispatcherSupportFakeData.issues.where((issue) {
      // Status filter
      if (issue.status != _selectedStatus) {
        return false;
      }
      // Area filter
      if (_selectedArea != DispatcherSupportFakeData.areas.first &&
          issue.area != _selectedArea) {
        return false;
      }
      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesBox = issue.boxCode.toLowerCase().contains(query);
        final matchesDriver = issue.driverName.toLowerCase().contains(query);
        final matchesArea = issue.area.toLowerCase().contains(query);
        if (!matchesBox && !matchesDriver && !matchesArea) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final issues = _filteredIssues;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: const DispatcherSupportHeader(),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
          children: [
            const DispatcherSupportKpiBar(
              kpi: DispatcherSupportFakeData.kpi,
            ),
            const SizedBox(height: Spacing.sm),
            DispatcherSupportStatusTabs(
              selectedStatus: _selectedStatus,
              openCount: DispatcherSupportFakeData.kpi.missingCount,
              inProgressCount: DispatcherSupportFakeData.kpi.inProgressCount,
              resolvedCount: DispatcherSupportFakeData.kpi.resolvedCount,
              onChanged: (status) {
                setState(() {
                  _selectedStatus = status;
                });
              },
            ),
            const SizedBox(height: Spacing.sm),
            DispatcherSupportSearchBar(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              onClear: () {
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
            const SizedBox(height: Spacing.sm),
            DispatcherSupportFilterChips(
              areas: DispatcherSupportFakeData.areas,
              selectedArea: _selectedArea,
              isDateFilterActive: _isDateFilterActive,
              onAreaSelected: (area) {
                setState(() {
                  _selectedArea = area;
                });
              },
              onDateFilterTap: () {
                setState(() {
                  _isDateFilterActive = !_isDateFilterActive;
                });
              },
            ),
            const SizedBox(height: Spacing.sm),
            ...issues.map(
              (issue) => DispatcherSupportIssueCard(
                issue: issue,
                onTap: () {
                  if (widget.onViewDetails != null) {
                    widget.onViewDetails!(issue);
                  } else {
                    context.pushNamed(AppRoutes.dispatcherSupportIssueDetails);
                  }
                },
                onViewDetails: () {
                  if (widget.onViewDetails != null) {
                    widget.onViewDetails!(issue);
                  } else {
                    context.pushNamed(AppRoutes.dispatcherSupportIssueDetails);
                  }
                },
                onAssignAlternativeDriver: () {
                  if (widget.onAssignAlternativeDriver != null) {
                    widget.onAssignAlternativeDriver!(issue);
                  } else {
                    context.pushNamed(AppRoutes.assignBox);
                  }
                },
              ),
            ),
            const SizedBox(height: Spacing.xs),
            const DispatcherSupportInfoBanner(),
            const SizedBox(height: Spacing.base),
          ],
        ),
      ),
    );
  }
}
