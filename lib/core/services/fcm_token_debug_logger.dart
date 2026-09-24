Future<void> logFcmTokenForDebug({
  required bool enabled,
  required Future<String?> Function() loadToken,
  required void Function(String message) writeLog,
}) async {
  if (!enabled) return;

  final token = await loadToken();
  if (token == null || token.trim().isEmpty) return;

  writeLog('\x1B[33m[FCMToken] FCM token retrieved: $token\x1B[0m');
}
