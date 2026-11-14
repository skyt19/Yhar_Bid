/// lib/services/ai_service_types.dart
/// Shared types for AI Service parsing and validation

import '../models/ai_discovery_model.dart';

/// Parse result wrapper with success/error state
class ParseResult {
  final bool success;
  final AnalysisResult? result;
  final String? error;

  const ParseResult.success(this.result)
      : success = true,
        error = null;

  const ParseResult.failure(this.error)
      : success = false,
        result = null;
}

/// Validation result with detailed error list
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult.valid()
      : isValid = true,
        errors = const [];

  const ValidationResult.invalid(this.errors) : isValid = false;
}
