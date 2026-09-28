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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 228,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: pageController,
                itemCount: stops.length,
                onPageChanged: onPageChanged,
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  final isSelected = index == currentIndex;

                  return AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: isSelected ? 0 : 10,
                    ),
                    child: DriverMapStopCard(
                      stop: stops[index],
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
                  );
                },
              ),
              PositionedDirectional(
                start: Spacing.xs,
                child: DriverMapCarouselNavButton(
                  icon: Icons.chevron_left_rounded,
                  isEnabled: currentIndex > 0,
                  onPressed: onPrevious,
                ),
              ),
              PositionedDirectional(
                end: Spacing.xs,
                child: DriverMapCarouselNavButton(
                  icon: Icons.chevron_right_rounded,
                  isEnabled: currentIndex < stops.length - 1,
                  onPressed: onNext,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        DriverMapPageIndicator(
          itemCount: stops.length,
          currentIndex: currentIndex,
          onDotTapped: (index) {
            unawaited(
              pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
            );
          },
        ),
      ],
    );
  }
}
