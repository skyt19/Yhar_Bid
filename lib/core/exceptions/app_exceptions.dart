/// lib/core/exceptions/app_exceptions.dart
/// Custom Exception Classes สำหรับ Yharbid Application
/// ตาม NFR-8: Standard Error Response Format

/// Base Exception Class สำหรับ Yharbid
abstract class YharbidException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  const YharbidException({
    required this.message,
    this.code,
    this.data,
  });

  /// แปลง Exception เป็น Standard Response Format
  Map<String, dynamic> toResponse() {
    return <String, dynamic>{
      'status': false,
      'message': message,
      'data': data,
      if (code != null) 'code': code,
    };
  }

  @override
  String toString() => 'YharbidException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Calendar Service Exceptions
class CalendarServiceException extends YharbidException {
  const CalendarServiceException({
    required super.message,
    super.code,
    super.data,
  });
}

/// AI Service Exceptions
class AiServiceException extends YharbidException {
  const AiServiceException({
    required super.message,
    super.code,
    super.data,
  });
}

/// Authentication Exceptions
class AuthException extends YharbidException {
  const AuthException({
    required super.message,
    super.code,
    super.data,
  });
}

/// Notification Service Exceptions
class NotificationException extends YharbidException {
  const NotificationException({
    required super.message,
    super.code,
    super.data,
  });
}

/// Network/Connectivity Exceptions
class NetworkException extends YharbidException {
  const NetworkException({
    required super.message,
    super.code,
    super.data,
  });
}

/// Validation Exceptions
class ValidationException extends YharbidException {
  const ValidationException({
    required super.message,
    super.code,
    super.data,
  });
}
