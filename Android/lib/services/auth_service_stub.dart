/// lib/services/auth_service_stub.dart
/// Stub implementation for non-web platforms (Android/iOS)
/// This file provides empty implementations for web-specific functions

// Empty stub - Android/iOS ไม่ต้องใช้ js_util
void initializeWebAuth() {
  // No-op for Android/iOS
}

String? getWebAccessToken() {
  // Android/iOS uses GoogleSignInAuthentication.accessToken directly
  return null;
}

void setWebAccessToken(String? token) {
  // No-op for Android/iOS
}
