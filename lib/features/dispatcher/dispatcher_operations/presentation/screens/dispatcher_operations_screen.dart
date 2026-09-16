import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../dispatcher_driver_filter/presentation/widgets/dispatcher_driver_filter_bottom_sheet.dart';
import '../../domain/entities/operation_item_entity.dart';
import '../../domain/entities/operation_status.dart';
import '../../domain/entities/operations_filter_entity.dart';
import '../../domain/fake_data/operations_fake_data.dart';
import '../widgets/operations_app_bar.dart';
import '../widgets/operations_card.dart';
import '../widgets/operations_pagination_bar.dart';
import '../widgets/operations_search_filter_bar.dart';
import '../widgets/operations_status_tabs.dart';

class DispatcherOperationsScreen extends StatefulWidget {
  const DispatcherOperationsScreen({super.key});

  @override
  State<DispatcherOperationsScreen> createState() =>
      _DispatcherOperationsScreenState();
}

class _DispatcherOperationsScreenState
    extends State<DispatcherOperationsScreen> {
  late final TextEditingController _searchController;
  OperationsFilterEntity _filter = OperationsFakeData.initialFilter;
  final List<OperationItemEntity> _allOperations =
      OperationsFakeData.sampleOperations;

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

  void _onSearchChanged(String query) {
    setState(() {
      _filter = _filter.copyWith(searchQuery: query);
    });
  }

  void _onStatusSelected(OperationStatus? status) {
    setState(() {
      _filter = _filter.copyWith(
        selectedStatus: status,
        clearStatus: status == null,
      );
    });
  }

  void _onFilterTap() {
    DispatcherDriverFilterBottomSheet.show(
      context: context,
      onApply: (_) {},
    );
  }

  void _onDateFilterTap() {
    // Toggles between last 7 days and last 30 days for mock interaction
    setState(() {
      final is7Days = _filter.dateRangeLabel == 'آخر 7 أيام';
      _filter = _filter.copyWith(
        dateRangeLabel: is7Days ? 'آخر 30 يوم' : 'آخر 7 أيام',
      );
    });
  }

  void _onPreviousPage() {
    if (_filter.currentPage > 1) {
      setState(() {
        _filter = _filter.copyWith(currentPage: _filter.currentPage - 1);
      });
    }
  }

  void _onNextPage() {
    if (_filter.currentPage < _filter.totalPages) {
      setState(() {
        _filter = _filter.copyWith(currentPage: _filter.currentPage + 1);
      });
    }
  }

  List<OperationItemEntity> get _filteredOperations {
    return _allOperations.where((op) {
      // 1. Status check
      if (_filter.selectedStatus != null &&
          op.status != _filter.selectedStatus) {
        return false;
      }
      // 2. Search query check
      final query = _filter.searchQuery.trim().toLowerCase();
      if (query.isNotEmpty) {
        final matchesOrder = op.orderId.toLowerCase().contains(query);
        final matchesCustomer = op.customerName.toLowerCase().contains(query);
        final matchesDriver =
            op.driverName?.toLowerCase().contains(query) ?? false;
        final matchesReassigned =
            op.reassignedToDriverName?.toLowerCase().contains(query) ?? false;
        return matchesOrder ||
            matchesCustomer ||
            matchesDriver ||
            matchesReassigned;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final operations = _filteredOperations;

    return Scaffold(
      backgroundColor: color.surfaceContainerLowest,
      appBar: OperationsAppBar(
        onBackPressed: () => Navigator.of(context).pop(),
        onFilterTap: _onFilterTap,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: Spacing.sm),
            OperationsSearchFilterBar(
              searchController: _searchController,
              onChanged: _onSearchChanged,
              onDateFilterTap: _onDateFilterTap,
              dateLabel: _filter.dateRangeLabel,
            ),
            const SizedBox(height: Spacing.sm),
            OperationsStatusTabs(
              filter: _filter,
              onStatusSelected: _onStatusSelected,
            ),
            const SizedBox(height: Spacing.sm),
            Expanded(
              child: operations.isEmpty
                  ? Center(
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: color.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    )
                  : ListView.builder(
                      itemCount: operations.length,
                      itemBuilder: (context, index) {
                        final item = operations[index];
                        return OperationsCard(
                          item: item,
                          onTap: () {},
                        );
                      },
                    ),
            ),
            OperationsPaginationBar(
              currentPage: _filter.currentPage,
              totalPages: _filter.totalPages,
              onPreviousTap: _onPreviousPage,
              onNextTap: _onNextPage,
            ),
          ],
        ),
      ),
    );
  }
}
