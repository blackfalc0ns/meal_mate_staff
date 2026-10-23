import 'dart:convert';

class BackgroundNotificationContent {
  const BackgroundNotificationContent({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

BackgroundNotificationContent? resolveBackgroundNotificationContent({
  required bool hasSystemNotification,
  required Map<String, dynamic> data,
}) {
  if (hasSystemNotification) return null;

  if (_isTechnicalCallEvent(data)) return null;

  final title = data['title']?.toString().trim() ?? '';
  final body = data['body']?.toString().trim() ?? '';
  if (title.isEmpty && body.isEmpty) return null;

  return BackgroundNotificationContent(
    title: title.isEmpty ? 'MealMate' : title,
    body: body,
  );
}

// This only controls presentation. Call event consumers still receive the push.
bool _isTechnicalCallEvent(Map<String, dynamic> data) {
  Map<dynamic, dynamic>? envelope;
  final rawEnvelope = data['envelope'];
  if (rawEnvelope is Map) {
    envelope = rawEnvelope;
  } else if (rawEnvelope is String) {
    try {
      final decoded = jsonDecode(rawEnvelope);
      if (decoded is Map) envelope = decoded;
    } on FormatException {
      // Unrelated notifications must not be dropped for malformed metadata.
    }
  }

  final callId = data['callId'] ?? envelope?['callId'];
  if (callId == null || callId.toString().trim().isEmpty) return false;

  final payload = envelope?['payload'];
  final events =
      [
            data['type'],
            data['event'],
            data['eventKey'],
            data['eventType'],
            envelope?['eventType'],
            if (payload is Map) payload['status'],
          ]
          .whereType<String>()
          .map((value) => value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), ''))
          .toList();

  const incomingEvents = {
    'incoming',
    'incomingcall',
    'callincoming',
    'voicecallincoming',
  };
  if (events.any(incomingEvents.contains)) return false;

  const technicalEvents = {
    'created',
    'ringing',
    'accepted',
    'connecting',
    'active',
    'ended',
    'cancelled',
    'canceled',
    'rejected',
    'failed',
    'busy',
    'statuschanged',
    'statechanged',
  };
  return events.any(
    (event) => technicalEvents.any(
      (state) =>
          event == state || event == 'call$state' || event == 'voicecall$state',
    ),
  );
}
