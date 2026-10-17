import 'package:web/web.dart' as web;

String browserSessionDiagnostic(
  String endpoint, {
  required bool fallbackHeaderPresent,
}) {
  final origin = web.window.location.origin;
  final fallbackPresent =
      web.window.localStorage.getItem('cookieFallback') != null;
  final cookieNames = web.document.cookie
      .split(';')
      .map((cookie) => cookie.trim())
      .where((cookie) => cookie.isNotEmpty)
      .map((cookie) => cookie.split('=').first.trim())
      .where((name) => name.isNotEmpty)
      .join(',');
  return 'web=true origin=$origin endpoint=$endpoint '
      'cookieFallbackPresent=$fallbackPresent '
      'cookieFallbackHeaderPresent=$fallbackHeaderPresent '
      'browserCookieNames=${cookieNames.isEmpty ? 'none' : cookieNames}';
}
