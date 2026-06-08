// Admin verification configuration.
//
// PRODUCTION: Set ADMIN_VERIFICATION_CODE via a Firebase Remote Config
// parameter or server-side secret. For local development / pre-production,
// you may set it via the --dart-define flag:
//
//   flutter build apk --dart-define=ADMIN_VERIFICATION_CODE=dev_secret_code
//
// The String.fromEnvironment() call reads a Dart compile-time variable.
// An empty string (default) means the secret is not configured —
// in that case the admin verification check FAILS by default, preventing
// anyone from registering as admin without a properly configured secret.
String get adminVerificationCode {
  const fromEnv = String.fromEnvironment(
    'ADMIN_VERIFICATION_CODE',
    defaultValue: '',
  );
  return fromEnv;
}

const String kAdminVerificationCode = ''; // No embedded secret.
