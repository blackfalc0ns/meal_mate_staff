import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';

import '../../domain/entities/driver_map_stop_entity.dart';
import 'driver_map_carousel_nav_button.dart';
import 'driver_map_page_indicator.dart';
import 'driver_map_stop_card.dart';

class DriverMapStopsCarousel extends StatelessWidget {
  const DriverMapStopsCarousel({
    super.key,
    required this.stops,
    required this.currentIndex,
    required this.pageController,
    required this.onPageChanged,
    required this.onPrevious,
    required this.onNext,
  });

  final List<DriverMapStopEntity> stops;
  final int currentIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final outerDirection = Directionality.of(context);
    final isLooping = stops.length > 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 185,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: isLooping ? null : stops.length,
                  onPageChanged: (page) {
                    final realIndex =
                        stops.isEmpty ? 0 : page % stops.length;
                    onPageChanged(realIndex);
                  },
                  clipBehavior: Clip.none,
                  itemBuilder: (context, index) {
                    final stopIndex = stops.isEmpty
                        ? 0
                        : (isLooping ? index % stops.length : index);
                    final isSelected = stopIndex == currentIndex;

                    return Directionality(
                      textDirection: outerDirection,
                      child: AnimatedPadding(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.xs,
                          vertical: isSelected ? Spacing.zero : Spacing.sm,
                        ),
                        child: DriverMapStopCard(
                          stop: stops[stopIndex],
                          isSelected: isSelected,
                          onTap: () {
                            unawaited(
                              pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: Spacing.xs,
                child: DriverMapCarouselNavButton(
                  icon: Icons.chevron_left_rounded,
                  isEnabled: stops.length > 1,
                  onPressed: onPrevious,
                ),
              ),
              Positioned(
                right: Spacing.xs,
                child: DriverMapCarouselNavButton(
                  icon: Icons.chevron_right_rounded,
                  isEnabled: stops.length > 1,
                  onPressed: onNext,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.xs),
        DriverMapPageIndicator(
          itemCount: stops.length,
          currentIndex: currentIndex,
          onDotTapped: (targetIndex) {
            if (pageController.hasClients) {
              final currentPage =
                  pageController.page?.round() ?? pageController.initialPage;
              final currentModulo =
                  stops.isEmpty ? 0 : currentPage % stops.length;
              var diff = targetIndex - currentModulo;
              if (stops.isNotEmpty) {
                if (diff > stops.length / 2) diff -= stops.length;
                if (diff < -stops.length / 2) diff += stops.length;
              }
              unawaited(
                pageController.animateToPage(
                  currentPage + diff,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
