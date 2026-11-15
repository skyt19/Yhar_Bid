/// lib/models/sync_result_model.dart
/// Explicit synchronization result tracking to prevent false-positive reporting
enum SyncStatus {
  pending,
  success,
  failed,
  skipped
}

class SyncResult {
  final String operation;
  final SyncStatus status;
  final String? error;
  final int? recordsProcessed;
  final DateTime timestamp;

  const SyncResult._({
    required this.operation,
    required this.status,
    this.error,
    this.recordsProcessed,
    required this.timestamp,
  });

  factory SyncResult.success({
    required String operation,
    int? recordsProcessed,
  }) {
    return SyncResult._(
      operation: operation,
      status: SyncStatus.success,
      recordsProcessed: recordsProcessed,
      timestamp: DateTime.now(),
    );
  }

  factory SyncResult.failed({
    required String operation,
    required String error,
  }) {
    return SyncResult._(
      operation: operation,
      status: SyncStatus.failed,
      error: error,
      timestamp: DateTime.now(),
    );
  }

  factory SyncResult.skipped({
    required String operation,
    required String reason,
  }) {
    return SyncResult._(
      operation: operation,
      status: SyncStatus.skipped,
      error: reason,
      timestamp: DateTime.now(),
    );
  }

  bool get isSuccess => status == SyncStatus.success;
  bool get isFailed => status == SyncStatus.failed;
  bool get isSkipped => status == SyncStatus.skipped;
}
