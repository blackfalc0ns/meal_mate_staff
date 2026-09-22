import 'package:flutter/material.dart';

import '../../../../../../core/widget/app_cached_network_image.dart';

class DispatcherEvidencePhotoViewer extends StatelessWidget {
  const DispatcherEvidencePhotoViewer({super.key, required this.photoUrl});

  final String photoUrl;

  static Future<void> show(BuildContext context, String photoUrl) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => DispatcherEvidencePhotoViewer(photoUrl: photoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNetwork =
        photoUrl.startsWith('http://') || photoUrl.startsWith('https://');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: isNetwork
              ? AppCachedNetworkImage(
                  imageUrl: photoUrl,
                  fit: BoxFit.contain,
                  errorWidget: const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white54,
                    size: 64,
                  ),
                )
              : Image.asset(
                  photoUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
        ),
      ),
    );
  }
}
