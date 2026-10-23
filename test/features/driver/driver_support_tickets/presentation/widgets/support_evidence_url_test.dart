import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/widgets/support_evidence_url.dart';

void main() {
  test('resolves signed path against origin and preserves encoded query', () {
    const path = '/api/v1/uploads/content?key=a%2Fb&readToken=a%2Bb%3D';
    expect(
      resolveSupportEvidenceUrl(path, 'https://example.com/api/v1'),
      'https://example.com$path',
    );
  });
  test('signed links never need bearer, legacy requires exact origin', () {
    const base = 'https://example.com';
    expect(
      supportEvidenceNeedsBearer(
        '$base/api/v1/uploads/content?readToken=x',
        base,
      ),
      isFalse,
    );
    expect(
      supportEvidenceNeedsBearer('$base/api/v1/uploads/content?key=x', base),
      isTrue,
    );
    expect(
      supportEvidenceNeedsBearer(
        'http://example.com/api/v1/uploads/content?key=x',
        base,
      ),
      isFalse,
    );
    expect(
      supportEvidenceNeedsBearer(
        'https://example.com:444/api/v1/uploads/content?key=x',
        base,
      ),
      isFalse,
    );
    expect(
      supportEvidenceNeedsBearer('https://cdn.example.com/a', base),
      isFalse,
    );
  });
}
