import 'package:flutter/material.dart';

import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/widget/custom_bottom_sheet.dart';
import '../../domain/entities/dispatcher_driver_filter_criteria_entity.dart';
import 'dispatcher_driver_filter_action_buttons.dart';
import 'dispatcher_driver_filter_area_section.dart';
import 'dispatcher_driver_filter_distance_section.dart';
import 'dispatcher_driver_filter_header.dart';
import 'dispatcher_driver_filter_orders_section.dart';
import 'dispatcher_driver_filter_rating_section.dart';
import 'dispatcher_driver_filter_search_section.dart';
import 'dispatcher_driver_filter_status_section.dart';

class DispatcherDriverFilterBottomSheet extends StatefulWidget {
  const DispatcherDriverFilterBottomSheet({
    super.key,
    this.initialCriteria,
    this.onApply,
  });

  final DispatcherDriverFilterCriteriaEntity? initialCriteria;
  final ValueChanged<DispatcherDriverFilterCriteriaEntity>? onApply;

  static Future<DispatcherDriverFilterCriteriaEntity?> show({
    required BuildContext context,
    DispatcherDriverFilterCriteriaEntity? initialCriteria,
    ValueChanged<DispatcherDriverFilterCriteriaEntity>? onApply,
  }) {
    return showModalBottomSheet<DispatcherDriverFilterCriteriaEntity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DispatcherDriverFilterBottomSheet(
        initialCriteria: initialCriteria,
        onApply: onApply,
      ),
    );
  }

  @override
  State<DispatcherDriverFilterBottomSheet> createState() =>
      _DispatcherDriverFilterBottomSheetState();
}

class _DispatcherDriverFilterBottomSheetState
    extends State<DispatcherDriverFilterBottomSheet> {
  late DispatcherDriverFilterCriteriaEntity _criteria;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _criteria =
        widget.initialCriteria ??
        DispatcherDriverFilterCriteriaEntity.initial();
    _searchController = TextEditingController(text: _criteria.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onReset() {
    setState(() {
      _criteria = DispatcherDriverFilterCriteriaEntity.initial();
      _searchController.clear();
    });
  }

  void _onApply() {
    final updatedCriteria = _criteria.copyWith(
      searchQuery: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
    );

    widget.onApply?.call(updatedCriteria);
    Navigator.of(context).pop(updatedCriteria);
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      maxHeightFactor: 0.92,
      showDragHandle: true,
      header: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.screenH,
          vertical: Spacing.xs,
        ),
        child: DispatcherDriverFilterHeader(
          onReset: _onReset,
          onClose: () => Navigator.of(context).maybePop(),
        ),
      ),
      footer: DispatcherDriverFilterActionButtons(
        onReset: _onReset,
        onApply: _onApply,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          DispatcherDriverFilterAreaSection(
            selectedArea: _criteria.selectedArea,
            onAreaSelected: (area) => setState(() {
              _criteria = _criteria.copyWith(
                selectedArea: area,
                clearArea: area == null,
              );
            }),
          ),
          const SizedBox(height: Spacing.sm),
          DispatcherDriverFilterStatusSection(
            selectedStatus: _criteria.selectedStatus,
            onStatusSelected: (status) => setState(() {
              _criteria = _criteria.copyWith(
                selectedStatus: status,
                clearStatus: status == null,
              );
            }),
          ),
          const SizedBox(height: Spacing.sm),
          DispatcherDriverFilterRatingSection(
            minRating: _criteria.minRating,
            onRatingSelected: (rating) => setState(() {
              _criteria = _criteria.copyWith(
                minRating: rating,
                clearRating: rating == null,
              );
            }),
          ),
          const SizedBox(height: Spacing.sm),
          DispatcherDriverFilterDistanceSection(
            distanceKm: _criteria.distanceKm,
            onDistanceChanged: (dist) => setState(() {
              _criteria = _criteria.copyWith(
                distanceKm: dist,
                clearDistance: dist == null,
              );
            }),
          ),
          const SizedBox(height: Spacing.sm),
          DispatcherDriverFilterOrdersSection(
            completedOrders: _criteria.completedOrders,
            onOrdersChanged: (orders) => setState(() {
              _criteria = _criteria.copyWith(
                completedOrders: orders,
                clearOrders: orders == null,
              );
            }),
          ),
          const SizedBox(height: Spacing.sm),
          DispatcherDriverFilterSearchSection(
            controller: _searchController,
            onChanged: (text) {
              _criteria = _criteria.copyWith(searchQuery: text);
            },
          ),
          const SizedBox(height: Spacing.sm),
        ],
      ),
    );
  }
}
