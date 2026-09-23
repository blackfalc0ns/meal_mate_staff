import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_map_connection_status.dart';

class DispatcherMapReconnectBanner extends StatelessWidget {
  const DispatcherMapReconnectBanner({
    super.key,
    required this.status,
    this.onRetry,
  });

  final DispatcherMapConnectionStatus status;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (status == DispatcherMapConnectionStatus.connected) {
      return const SizedBox.shrink();
    }

    final color = context.colorScheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final bool isReconnecting =
        status == DispatcherMapConnectionStatus.reconnecting;
    final String message;
    final Color bannerColor;
    final Color textColor;

    if (isReconnecting) {
      message = isAr
          ? 'جارٍ إعادة الاتصال بالبث المباشر...'
          : 'Reconnecting live stream...';
      bannerColor = color.warning.withValues(alpha: 0.15);
      textColor = color.warning;
    } else if (status == DispatcherMapConnectionStatus.unauthorized) {
      message = isAr ? 'انتهت صلاحية الجلسة' : 'Session expired';
      bannerColor = color.error.withValues(alpha: 0.15);
      textColor = color.error;
    } else {
      message = isAr ? 'البث المباشر متوقف' : 'Live stream disconnected';
      bannerColor = color.onSurfaceVariant.withValues(alpha: 0.15);
      textColor = color.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
        border: Border.all(
          color: textColor.withValues(alpha: 0.3),
          width: Spacing.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isReconnecting)
            SizedBox(
              width: Spacing.xs * 2,
              height: Spacing.xs * 2,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          else
            Icon(
              Icons.cloud_off_rounded,
              size: Spacing.iconXs,
              color: textColor,
            ),
          const SizedBox(width: Spacing.xs),
          Text(
            message,
            style: getMediumStyle(fontSize: FontSize.size10, color: textColor),
          ),
          if (!isReconnecting && onRetry != null) ...[
            const SizedBox(width: Spacing.xs),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                isAr ? 'إعادة المحاولة' : 'Retry',
                style: getBoldStyle(
                  fontSize: FontSize.size10,
                  color: color.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
