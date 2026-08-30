import 'package:flutter/material.dart';

import '../extensions/extensions.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () => context.maybePopRoute(),
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
    );
  }
}
