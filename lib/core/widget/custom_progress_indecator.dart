import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants/assets.dart';

class CustomProgressIndicator extends StatefulWidget {
  const CustomProgressIndicator({super.key, this.size = 100.0});

  final double size;

  @override
  State<CustomProgressIndicator> createState() =>
      _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<CustomProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 0,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Lottie.asset(
            AppAssets.loadingLogo,
            controller: _controller,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            onLoaded: (composition) {
              _controller
                ..duration = composition.duration.inMilliseconds > 0
                    ? composition.duration
                    : const Duration(seconds: 2)
                ..repeat();
            },
          ),
        ),
      ),
    );
  }
}
