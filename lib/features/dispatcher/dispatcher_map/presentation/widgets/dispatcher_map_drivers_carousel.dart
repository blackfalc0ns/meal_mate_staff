import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../domain/entities/dispatcher_map_driver_entity.dart';
import 'dispatcher_map_driver_card.dart';

class DispatcherMapDriversCarousel extends StatefulWidget {
  const DispatcherMapDriversCarousel({
    super.key,
    required this.drivers,
    this.selectedDriverId,
    this.onSelectDriver,
    this.scrollController,
  });

  final List<DispatcherMapDriverEntity> drivers;
  final String? selectedDriverId;
  final ValueChanged<DispatcherMapDriverEntity>? onSelectDriver;
  final ScrollController? scrollController;

  @override
  State<DispatcherMapDriversCarousel> createState() =>
      _DispatcherMapDriversCarouselState();
}

class _DispatcherMapDriversCarouselState
    extends State<DispatcherMapDriversCarousel> {
  late final ScrollController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      _controller = widget.scrollController!;
    } else {
      _controller = ScrollController();
      _ownsController = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant DispatcherMapDriversCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDriverId != oldWidget.selectedDriverId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected(animate: true);
      });
    }
  }

  void _scrollToSelected({required bool animate}) {
    if (!mounted || !_controller.hasClients || widget.selectedDriverId == null) {
      return;
    }

    final index =
        widget.drivers.indexWhere((d) => d.id == widget.selectedDriverId);
    if (index == -1) return;

    final targetOffset =
        index * (Spacing.dispatcherMapBottomCardWidth + Spacing.sm);
    final maxOffset = _controller.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxOffset);

    // If already very close to the target offset, avoid animating again
    if ((_controller.offset - clampedOffset).abs() < 10) return;

    if (animate) {
      _controller.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _controller.jumpTo(clampedOffset);
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Spacing.dispatcherMapBottomCarouselHeight,
      child: ListView.separated(
        controller: _controller,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          vertical: Spacing.xs,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: widget.drivers.length,
        separatorBuilder: (_, _) => const SizedBox(width: Spacing.sm),
        itemBuilder: (context, index) {
          final driver = widget.drivers[index];
          final isSelected = driver.id == widget.selectedDriverId;

          return RepaintBoundary(
            child: DispatcherMapDriverCard(
              driver: driver,
              isSelected: isSelected,
              onTap: () => widget.onSelectDriver?.call(driver),
            ),
          );
        },
      ),
    );
  }
}
