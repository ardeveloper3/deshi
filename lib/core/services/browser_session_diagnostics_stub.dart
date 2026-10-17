String browserSessionDiagnostic(
  String endpoint, {
  required bool fallbackHeaderPresent,
}) =>
    'web=false endpoint=$endpoint '
    'cookieFallbackHeaderPresent=$fallbackHeaderPresent';
