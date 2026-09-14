import 'package:flutter/material.dart';

import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/widget/custom_bottom_sheet.dart';
import '../../domain/entities/driver_filter_criteria_entity.dart';
import 'driver_filter_action_buttons.dart';
import 'driver_filter_area_section.dart';
import 'driver_filter_distance_section.dart';
import 'driver_filter_header.dart';
import 'driver_filter_orders_section.dart';
import 'driver_filter_rating_section.dart';
import 'driver_filter_search_section.dart';
import 'driver_filter_status_section.dart';

class DriverFilterBottomSheet extends StatefulWidget {
  const DriverFilterBottomSheet({
    super.key,
    this.initialCriteria,
    this.onApply,
  });

  final DriverFilterCriteriaEntity? initialCriteria;
  final ValueChanged<DriverFilterCriteriaEntity>? onApply;

  static Future<DriverFilterCriteriaEntity?> show({
    required BuildContext context,
    DriverFilterCriteriaEntity? initialCriteria,
    ValueChanged<DriverFilterCriteriaEntity>? onApply,
  }) {
    return showModalBottomSheet<DriverFilterCriteriaEntity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DriverFilterBottomSheet(
        initialCriteria: initialCriteria,
        onApply: onApply,
      ),
    );
  }

  @override
  State<DriverFilterBottomSheet> createState() =>
      _DriverFilterBottomSheetState();
}

class _DriverFilterBottomSheetState extends State<DriverFilterBottomSheet> {
  late DriverFilterCriteriaEntity _criteria;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _criteria = widget.initialCriteria ?? DriverFilterCriteriaEntity.initial();
    _searchController = TextEditingController(text: _criteria.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onReset() {
    setState(() {
      _criteria = DriverFilterCriteriaEntity.initial();
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
        child: DriverFilterHeader(
          onReset: _onReset,
          onClose: () => Navigator.of(context).maybePop(),
        ),
      ),
      footer: DriverFilterActionButtons(onReset: _onReset, onApply: _onApply),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          DriverFilterAreaSection(
            selectedArea: _criteria.selectedArea,
            onAreaSelected: (area) => setState(() {
              _criteria = _criteria.copyWith(
                selectedArea: area,
                clearArea: area == null,
              );
            }),
          ),
          const SizedBox(height: Spacing.sm),
          DriverFilterStatusSection(
            selectedStatus: _criteria.selectedStatus,
            onStatusSelected: (status) => setState(() {
              _criteria = _criteria.copyWith(
                selectedStatus: status,
                clearStatus: status == null,
              );
            }),
          ),
          const SizedBox(height: Spacing.sm),
          DriverFilterRatingSection(
            minRating: _criteria.minRating,
            onRatingSelected: (rating) => setState(() {
              _criteria = _criteria.copyWith(
                minRating: rating,
                clearRating: rating == null,
              );
            }),
          ),
          const SizedBox(height: Spacing.sm),
          DriverFilterDistanceSection(
            distanceKm: _criteria.distanceKm,
            onDistanceChanged: (dist) => setState(() {
              _criteria = _criteria.copyWith(
                distanceKm: dist,
                clearDistance: dist == null,
              );
            }),
          ),
          const SizedBox(height: Spacing.sm),
          DriverFilterOrdersSection(
            completedOrders: _criteria.completedOrders,
            onOrdersChanged: (orders) => setState(() {
              _criteria = _criteria.copyWith(
                completedOrders: orders,
                clearOrders: orders == null,
              );
            }),
          ),
          const SizedBox(height: Spacing.sm),
          DriverFilterSearchSection(
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
