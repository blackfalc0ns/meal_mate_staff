import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_assigned_box_entity.dart';
import '../../domain/entities/driver_box_delivery_status.dart';
import '../../domain/entities/driver_boxes_filter_type.dart';
import '../../domain/fake_data/driver_assigned_boxes_fake_data.dart';
import '../widgets/driver_assigned_box_card.dart';
import '../widgets/driver_boxes_filter_bar.dart';
import '../widgets/driver_boxes_header_logo.dart';
import '../widgets/driver_boxes_stats_banner.dart';
import '../widgets/driver_boxes_title_bar.dart';

class DriverAssignedBoxesScreen extends StatefulWidget {
  const DriverAssignedBoxesScreen({
    super.key,
    this.initialBoxes,
    this.onCompleteAction,
  });

  final List<DriverAssignedBoxEntity>? initialBoxes;
  final ValueChanged<DriverAssignedBoxEntity>? onCompleteAction;

  @override
  State<DriverAssignedBoxesScreen> createState() =>
      _DriverAssignedBoxesScreenState();
}

class _DriverAssignedBoxesScreenState extends State<DriverAssignedBoxesScreen> {
  DriverBoxesFilterType _selectedFilter = DriverBoxesFilterType.all;
  late List<DriverAssignedBoxEntity> _boxes;

  @override
  void initState() {
    super.initState();
    _boxes = List.of(widget.initialBoxes ?? DriverAssignedBoxesFakeData.defaultBoxes);
  }

  List<DriverAssignedBoxEntity> get _filteredBoxes {
    switch (_selectedFilter) {
      case DriverBoxesFilterType.all:
        return _boxes;
      case DriverBoxesFilterType.readyForDelivery:
        return _boxes
            .where((b) =>
                b.status == DriverBoxDeliveryStatus.ready ||
                b.status == DriverBoxDeliveryStatus.notLoaded)
            .toList();
      case DriverBoxesFilterType.delivered:
        return _boxes
            .where((b) => b.status == DriverBoxDeliveryStatus.delivered)
            .toList();
    }
  }

  void _handleFilterChanged(DriverBoxesFilterType filter) {
    if (_selectedFilter != filter) {
      setState(() {
        _selectedFilter = filter;
      });
    }
  }

  void _handleBoxAction(DriverAssignedBoxEntity box) {
    if (widget.onCompleteAction != null) {
      widget.onCompleteAction!(box);
      return;
    }

    setState(() {
      final index = _boxes.indexWhere((b) => b.boxId == box.boxId);
      if (index != -1) {
        final current = _boxes[index];
        if (current.status == DriverBoxDeliveryStatus.notLoaded) {
          _boxes[index] = current.copyWith(status: DriverBoxDeliveryStatus.ready);
        } else if (current.status == DriverBoxDeliveryStatus.ready) {
          _boxes[index] = current.copyWith(status: DriverBoxDeliveryStatus.delivered);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final currentBoxes = _filteredBoxes;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Spacing.sm),
              const DriverBoxesHeaderLogo(),
              const SizedBox(height: Spacing.md),
              const DriverBoxesTitleBar(),
              const SizedBox(height: Spacing.sm),
              const DriverBoxesStatsBanner(
                totalMeals: DriverAssignedBoxesFakeData.totalMealsCount,
                totalBoxes: DriverAssignedBoxesFakeData.totalBoxesCount,
              ),
              const SizedBox(height: Spacing.md),
              DriverBoxesFilterBar(
                selectedFilter: _selectedFilter,
                onFilterChanged: _handleFilterChanged,
              ),
              const SizedBox(height: Spacing.sm),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: Spacing.bottomNavHeight + Spacing.md),
                  itemCount: currentBoxes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: Spacing.sm),
                  itemBuilder: (context, index) {
                    final box = currentBoxes[index];
                    return DriverAssignedBoxCard(
                      box: box,
                      onCompleteAction: () => _handleBoxAction(box),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
