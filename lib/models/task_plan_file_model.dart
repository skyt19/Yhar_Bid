/// lib/models/task_plan_file_model.dart
/// File metadata for stored task plan TXT files
/// Phase 3-4: Storage metadata and file management

import 'package:cloud_firestore/cloud_firestore.dart';

/// Lifecycle state for file deletion
enum FileDeletionState {
  idle,
  confirmationRequested,
  deleting,
  deleted,
  failed,
}

/// Metadata for a stored task plan file
class TaskPlanFile {
  final String id; // Firestore document ID
  final String userId; // Owner UID
  final String filename; // Display filename
  final String storagePath; // Firebase Storage path
  final String downloadUrl; // Public download URL
  final int sizeBytes;
  final String mimeType;
  final DateTime createdAt;
  final DateTime planningStartDate;
  final DateTime planningEndDate;
  final List<String> sourceEventIds; // Linked Calendar event IDs
  final int eventCount;
  final FileDeletionState deletionState;

  const TaskPlanFile({
    required this.id,
    required this.userId,
    required this.filename,
    required this.storagePath,
    required this.downloadUrl,
    required this.sizeBytes,
    required this.mimeType,
    required this.createdAt,
    required this.planningStartDate,
    required this.planningEndDate,
    required this.sourceEventIds,
    required this.eventCount,
    this.deletionState = FileDeletionState.idle,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'filename': filename,
      'storagePath': storagePath,
      'downloadUrl': downloadUrl,
      'sizeBytes': sizeBytes,
      'mimeType': mimeType,
      'createdAt': Timestamp.fromDate(createdAt),
      'planningStartDate': Timestamp.fromDate(planningStartDate),
      'planningEndDate': Timestamp.fromDate(planningEndDate),
      'sourceEventIds': sourceEventIds,
      'eventCount': eventCount,
    };
  }

  /// Create from Firestore document
  factory TaskPlanFile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TaskPlanFile(
      id: doc.id,
      userId: data['userId'] as String,
      filename: data['filename'] as String,
      storagePath: data['storagePath'] as String,
      downloadUrl: data['downloadUrl'] as String,
      sizeBytes: data['sizeBytes'] as int,
      mimeType: data['mimeType'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      planningStartDate: (data['planningStartDate'] as Timestamp).toDate(),
      planningEndDate: (data['planningEndDate'] as Timestamp).toDate(),
      sourceEventIds: (data['sourceEventIds'] as List<dynamic>).cast<String>(),
      eventCount: data['eventCount'] as int,
    );
  }

  /// Copy with new deletion state
  TaskPlanFile copyWith({
    FileDeletionState? deletionState,
    String? downloadUrl,
  }) {
    return TaskPlanFile(
      id: id,
      userId: userId,
      filename: filename,
      storagePath: storagePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      sizeBytes: sizeBytes,
      mimeType: mimeType,
      createdAt: createdAt,
      planningStartDate: planningStartDate,
      planningEndDate: planningEndDate,
      sourceEventIds: sourceEventIds,
      eventCount: eventCount,
      deletionState: deletionState ?? this.deletionState,
    );
  }

  /// Validate required fields
  bool get isValid {
    if (id.isEmpty) return false;
    if (userId.isEmpty) return false;
    if (filename.isEmpty) return false;
    if (storagePath.isEmpty) return false;
    if (downloadUrl.isEmpty) return false;
    if (sizeBytes <= 0) return false;
    if (!filename.endsWith('.txt')) return false;
    if (mimeType != 'text/plain') return false;
    if (eventCount <= 0) return false;
    if (sourceEventIds.isEmpty) return false;

    return true;
  }

  /// Format file size for display
  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Format date range for display
  String get dateRangeDisplay {
    final startStr = '${planningStartDate.day}/${planningStartDate.month}/${planningStartDate.year}';
    final endStr = '${planningEndDate.day}/${planningEndDate.month}/${planningEndDate.year}';
    return '$startStr - $endStr';
  }
}
