// Manage static configuration and URL resolution for the Piston judge endpoint.
class JudgeConfig {
  JudgeConfig._();

  static const String defaultLocalUrl = 'http://localhost:2001';

  static String? _explicitOverrideUrl;

  static String? _firestoreBaseUrl;

  static String get pistonBaseUrl {
    if (_explicitOverrideUrl != null &&
        _explicitOverrideUrl != defaultLocalUrl) {
      return _explicitOverrideUrl!;
    }
    if (_firestoreBaseUrl != null && _firestoreBaseUrl!.isNotEmpty) {
      return _firestoreBaseUrl!;
    }
    return _explicitOverrideUrl ?? defaultLocalUrl;
  }
}