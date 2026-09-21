import 'package:flutter/material.dart';

import '../../config/theme/spacing.dart';
import '../network/network_constants.dart';

class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.loadingWidget,
    this.errorWidget,
    this.semanticLabel,
    this.onImageResolved,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape shape;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final String? semanticLabel;
  final ValueChanged<bool>? onImageResolved;

  @override
  Widget build(BuildContext context) {
    final url = _resolveUrl(imageUrl);
    final child = url == null || url.isEmpty
        ? _buildResolvedError(context)
        : Image.network(
            url,
            width: width,
            height: height,
            fit: fit,
            semanticLabel: semanticLabel,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                _notifyResolved(true);
                return child;
              }
              return _buildLoading(context);
            },
            errorBuilder: (context, error, stackTrace) =>
                _buildResolvedError(context),
          );

    final sizedChild = SizedBox(width: width, height: height, child: child);
    if (shape == BoxShape.circle) return ClipOval(child: sizedChild);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: sizedChild,
    );
  }

  String? _resolveUrl(String? url) {
    if (url == null || url.isEmpty) return url;
    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasScheme) return url;
    if (url.startsWith('/')) return '${NetworkConstants.baseUrl}$url';
    return url;
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child:
          loadingWidget ??
          SizedBox.square(
            dimension: Spacing.lg,
            child: CircularProgressIndicator(
              strokeWidth: Spacing.border,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child:
          errorWidget ??
          Icon(
            Icons.broken_image_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: Spacing.iconMd,
          ),
    );
  }

  Widget _buildResolvedError(BuildContext context) {
    _notifyResolved(false);
    return _buildError(context);
  }

  void _notifyResolved(bool didLoad) {
    final callback = onImageResolved;
    if (callback == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => callback(didLoad));
  }
}
