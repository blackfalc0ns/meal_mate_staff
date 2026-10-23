import 'dart:io';
import 'package:dio/dio.dart';

import 'server_clock.dart';

class ServerClockInterceptor extends Interceptor {
  ServerClockInterceptor(this.clock);

  final ServerClock clock;

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final raw = response.headers.value('date');
    if (raw != null) {
      try {
        clock.synchronize(HttpDate.parse(raw));
      } catch (_) {}
    }
    handler.next(response);
  }
}
