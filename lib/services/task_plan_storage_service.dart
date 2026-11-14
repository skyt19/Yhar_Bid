/// lib/services/task_plan_storage_service.dart
/// Phase 3: Firebase Storage Integration
/// Handles upload, download, and deletion of TXT files

import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/task_plan_file_model.dart';

class TaskPlanStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _storageBasePath = 'task_plans';
  static const String _metadataCollection = 'taskPlanFiles';

  /// Upload TXT file to Firebase Storage and save metadata
  /// Returns TaskPlanFile metadata
  Future<TaskPlanFile> uploadTaskPlan({
    required String filename,
    required List<int> txtBytes,
    required DateTime planningStartDate,
    required DateTime planningEndDate,
    required List<String> sourceEventIds,
    required int eventCount,
  }) async {
    try {
      // Verify authentication
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userId = user.uid;

      // Validate inputs
      if (filename.isEmpty || !filename.endsWith('.txt')) {
        throw Exception('Invalid filename');
      }
      if (txtBytes.isEmpty) {
        throw Exception('Empty file content');
      }
      if (eventCount <= 0) {
        throw Exception('Event count must be positive');
      }
      if (sourceEventIds.isEmpty) {
        throw Exception('Source event IDs required');
      }

      // Generate storage path: task_plans/{userId}/{filename}
      final storagePath = '$_storageBasePath/$userId/$filename';

      debugPrint('📤 [StorageService] Uploading file');
      debugPrint('   Path: $storagePath');
      debugPrint('   Size: ${txtBytes.length} bytes');

      // Upload to Firebase Storage
      final ref = _storage.ref().child(storagePath);
      final metadata = SettableMetadata(
        contentType: 'text/plain',
        customMetadata: {
          'userId': userId,
          'planningStartDate': planningStartDate.toIso8601String(),
          'planningEndDate': planningEndDate.toIso8601String(),
          'eventCount': eventCount.toString(),
        },
      );

      final uploadTask = ref.putData(Uint8List.fromList(txtBytes), metadata);
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ [StorageService] Upload complete');
      debugPrint('   Download URL: ${downloadUrl.substring(0, 50)}...');

      // Save metadata to Firestore
      final fileMetadata = TaskPlanFile(
        id: '', // Will be set after Firestore add
        userId: userId,
        filename: filename,
        storagePath: storagePath,
        downloadUrl: downloadUrl,
        sizeBytes: txtBytes.length,
        mimeType: 'text/plain',
        createdAt: DateTime.now(),
        planningStartDate: planningStartDate,
        planningEndDate: planningEndDate,
        sourceEventIds: sourceEventIds,
        eventCount: eventCount,
      );

      final docRef = await _firestore
          .collection(_metadataCollection)
          .add(fileMetadata.toFirestore());

      debugPrint('✅ [StorageService] Metadata saved: ${docRef.id}');

      // Return metadata with Firestore ID
      return TaskPlanFile(
        id: docRef.id,
        userId: fileMetadata.userId,
        filename: fileMetadata.filename,
        storagePath: fileMetadata.storagePath,
        downloadUrl: fileMetadata.downloadUrl,
        sizeBytes: fileMetadata.sizeBytes,
        mimeType: fileMetadata.mimeType,
        createdAt: fileMetadata.createdAt,
        planningStartDate: fileMetadata.planningStartDate,
        planningEndDate: fileMetadata.planningEndDate,
        sourceEventIds: fileMetadata.sourceEventIds,
        eventCount: fileMetadata.eventCount,
      );
    } catch (e) {
      debugPrint('❌ [StorageService] Upload failed: $e');
      rethrow;
    }
  }

  /// List all files for current user
  Future<List<TaskPlanFile>> listUserFiles() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection(_metadataCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final files = querySnapshot.docs
          .map((doc) => TaskPlanFile.fromFirestore(doc))
          .toList();

      debugPrint('📂 [StorageService] Listed ${files.length} files');
      return files;
    } catch (e) {
      debugPrint('❌ [StorageService] List failed: $e');
      rethrow;
    }
  }

  /// Download file content
  Future<String> downloadFile(TaskPlanFile file) async {
    try {
      // Verify ownership
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      if (file.userId != user.uid) {
        throw Exception('Permission denied');
      }

      debugPrint('📥 [StorageService] Downloading file: ${file.filename}');

      final ref = _storage.ref().child(file.storagePath);
      final data = await ref.getData();

      if (data == null) {
        throw Exception('File not found in storage');
      }

      // Decode UTF-8
      final content = String.fromCharCodes(data);

      debugPrint('✅ [StorageService] Downloaded ${data.length} bytes');
      return content;
    } catch (e) {
      debugPrint('❌ [StorageService] Download failed: $e');
      rethrow;
    }
  }

  /// Delete file from Storage and Firestore
  /// Returns true if both operations succeeded
  Future<bool> deleteFile(TaskPlanFile file) async {
    bool storageDeleted = false;
    bool metadataDeleted = false;

    try {
      // Verify ownership
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      if (file.userId != user.uid) {
        throw Exception('Permission denied');
      }

      debugPrint('🗑️ [StorageService] Deleting file: ${file.filename}');

      // Step 1: Delete from Storage
      try {
        final ref = _storage.ref().child(file.storagePath);
        await ref.delete();
        storageDeleted = true;
        debugPrint('   ✅ Storage object deleted');
      } catch (e) {
        if (e.toString().contains('object-not-found')) {
          debugPrint('   ⚠️ Storage object not found (already deleted?)');
          storageDeleted = true; // Consider it success if already gone
        } else {
          debugPrint('   ❌ Storage deletion failed: $e');
          // Continue to metadata deletion anyway
        }
      }

      // Step 2: Delete metadata from Firestore
      try {
        await _firestore.collection(_metadataCollection).doc(file.id).delete();
        metadataDeleted = true;
        debugPrint('   ✅ Metadata deleted');
      } catch (e) {
        debugPrint('   ❌ Metadata deletion failed: $e');
      }

      // Both must succeed for full success
      if (storageDeleted && metadataDeleted) {
        debugPrint('✅ [StorageService] File fully deleted');
        return true;
      } else if (!storageDeleted && metadataDeleted) {
        debugPrint('⚠️ [StorageService] Orphan metadata deleted (storage object was missing)');
        return true; // Acceptable state
      } else if (storageDeleted && !metadataDeleted) {
        debugPrint('❌ [StorageService] Partial deletion: storage deleted but metadata remains');
        throw Exception('Metadata deletion failed - orphaned Storage object');
      } else {
        debugPrint('❌ [StorageService] Complete deletion failure');
        throw Exception('Both storage and metadata deletion failed');
      }
    } catch (e) {
      debugPrint('❌ [StorageService] Delete error: $e');
      rethrow;
    }
  }

  /// Verify file exists and is accessible
  Future<bool> verifyFileExists(TaskPlanFile file) async {
    try {
      final ref = _storage.ref().child(file.storagePath);
      final metadata = await ref.getMetadata();
      return metadata.size != null && metadata.size! > 0;
    } catch (e) {
      debugPrint('⚠️ [StorageService] Verify failed: $e');
      return false;
    }
  }

  /// Get file metadata from Firestore
  Future<TaskPlanFile?> getFileMetadata(String fileId) async {
    try {
      final doc = await _firestore
          .collection(_metadataCollection)
          .doc(fileId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return TaskPlanFile.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
    } catch (e) {
      debugPrint('❌ [StorageService] Get metadata failed: $e');
      return null;
    }
  }
}
