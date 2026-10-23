/// Resolve API-relative evidence against the origin, preserving signed queries.
String resolveSupportEvidenceUrl(String path, String baseUrl) {
  final uri = Uri.parse(path);
  if (uri.hasScheme) return path;
  final base = Uri.parse(baseUrl);
  final origin = Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
  );
  return origin.resolve(path.startsWith('/') ? path : '/$path').toString();
}

/// Only legacy, unsigned upload links on the exact API origin receive JWTs.
bool supportEvidenceNeedsBearer(String url, String baseUrl) {
  final uri = Uri.tryParse(url);
  final base = Uri.parse(baseUrl);
  if (uri == null || uri.queryParameters.containsKey('readToken')) return false;
  return uri.scheme == base.scheme &&
      uri.host == base.host &&
      uri.port == base.port &&
      uri.userInfo.isEmpty &&
      uri.path == '/api/v1/uploads/content';
}
