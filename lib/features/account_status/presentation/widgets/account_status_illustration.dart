import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';

class AccountStatusIllustration extends StatelessWidget {
  const AccountStatusIllustration({
    super.key,
    required this.asset,
    this.width = Spacing.accountStatusResultImageWidth,
    this.height = Spacing.accountStatusResultImageHeight,
  });

  final String asset;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }
}
