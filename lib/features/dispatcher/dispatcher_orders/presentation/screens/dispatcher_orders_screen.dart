import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_filter_type.dart';
import '../../domain/entities/dispatcher_order_entity.dart';
import '../../domain/fake_data/dispatcher_fake_data.dart';
import '../widgets/dispatcher_bottom_nav_bar.dart';
import '../widgets/dispatcher_filter_bar.dart';
import '../widgets/dispatcher_metrics_grid.dart';
import '../widgets/dispatcher_orders_list.dart';
import '../widgets/dispatcher_title_section.dart';
import '../widgets/dispatcher_top_header.dart';

class DispatcherOrdersScreen extends StatefulWidget {
  const DispatcherOrdersScreen({
    super.key,
    this.onAssignOrder,
    this.onOrderDetails,
    this.showBottomNavBar = true,
  });

  final ValueChanged<DispatcherOrderEntity>? onAssignOrder;
  final ValueChanged<DispatcherOrderEntity>? onOrderDetails;
  final bool showBottomNavBar;

  @override
  State<DispatcherOrdersScreen> createState() => _DispatcherOrdersScreenState();
}

class _DispatcherOrdersScreenState extends State<DispatcherOrdersScreen> {
  DispatcherFilterType _selectedFilter = DispatcherFilterType.all;
  int _selectedNavIndex = 1;

  List<DispatcherOrderEntity> get _filteredOrders {
    return DispatcherFakeData.orders;
  }

  void _onFilterSelected(DispatcherFilterType filter) {
    if (_selectedFilter != filter) {
      setState(() {
        _selectedFilter = filter;
      });
    }
  }

  void _onNavItemSelected(int index) {
    if (_selectedNavIndex != index) {
      setState(() {
        _selectedNavIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DispatcherTopHeader(),
              const SizedBox(height: Spacing.xs),
              const DispatcherTitleSection(),
              const SizedBox(height: Spacing.xs),
              const DispatcherMetricsGrid(metrics: DispatcherFakeData.metrics),
              const SizedBox(height: Spacing.xs),
              DispatcherFilterBar(
                selectedFilter: _selectedFilter,
                onFilterSelected: _onFilterSelected,
              ),
              const SizedBox(height: Spacing.xs),
              DispatcherOrdersList(
                orders: _filteredOrders,
                onAssignOrder:
                    widget.onAssignOrder ??
                    (_) => context.pushNamed(AppRoutes.assignBox),
                onOrderDetails: widget.onOrderDetails,
              ),
              const SizedBox(height: Spacing.base),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNavBar
          ? DispatcherBottomNavBar(
              selectedIndex: _selectedNavIndex,
              onItemSelected: _onNavItemSelected,
            )
          : null,
    );
  }
}
