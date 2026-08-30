import 'package:dio/dio.dart';

import 'language_service.dart';

class LanguageInterceptor extends Interceptor {
  LanguageInterceptor(this._languageService);

  final LanguageService _languageService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = _languageService.getLanguageCode();
    handler.next(options);
  }
}
