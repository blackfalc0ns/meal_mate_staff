import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/upload_diagnostics_interceptor.dart';

void main() {
  test('keeps response structure and storage key while redacting secrets', () {
    final result = sanitizeUploadDiagnostic({
      'data': {'storageKey': '/uploads/drivers/issue-evidence/example.jpg', 'readUrl': 'https://example.test/a?readToken=secret'},
      'Authorization': 'Bearer secret',
      'readToken': 'secret',
    }) as Map;
    expect((result['data'] as Map)['storageKey'], '/uploads/drivers/issue-evidence/example.jpg');
    expect(result.toString(), isNot(contains('secret')));
    expect((result['data'] as Map).containsKey('readUrl'), isTrue);
  });
}
