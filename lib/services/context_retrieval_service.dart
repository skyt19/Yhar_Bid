/// lib/services/context_retrieval_service.dart
/// Context Retrieval Service — Phase 1: Centralized data retrieval for AI reasoning
/// Retrieves user's current Tasks, Calendar Events, and Profile for context-aware AI

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/context_snapshot_model.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/calendar_event_model.dart';

/// Standard Service Response Format
class ContextRetrievalResponse {
  final bool status;
  final String message;
  final ContextSnapshot? data;
  const ContextRetrievalResponse({
    required this.status,
    required this.message,
    this.data,
  });
}

/// Context Retrieval Service
/// Centralizes all data retrieval needed for AI reasoning
class ContextRetrievalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retrieve complete context snapshot for authenticated user
  /// Returns ContextSnapshot with user profile, tasks, and calendar events
  /// Handles partial failures gracefully and reports retrieval errors
  Future<ContextRetrievalResponse> retrieveContext({
    bool includeTasks = true,
    bool includeCalendar = true,
  }) async {
    try {
      // Verify authentication
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        debugPrint('❌ [ContextRetrieval] No authenticated user');
        return const ContextRetrievalResponse(
          status: false,
          message: 'Authentication required',
        );
      }

      final String userId = firebaseUser.uid;
      debugPrint('✅ [ContextRetrieval] Authenticated: UID=$userId');

      final List<String> errors = [];
      bool isComplete = true;

      // Retrieve user profile
      UserModel? userProfile;
      UserRole userRole = UserRole.student;
      AiPersonality personality = AiPersonality.politeJarvis;
      String languageCode = 'th';

      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(userId)
            .get()
            .timeout(const Duration(seconds: 10));

        if (userDoc.exists) {
          userProfile = UserModel.fromFirestore(userDoc);
          userRole = userProfile.role;
          personality = userProfile.personality;
          languageCode = userProfile.languageCode;
          debugPrint('✅ [ContextRetrieval] User profile: role=${userRole.name}');
        } else {
          debugPrint('⚠️ [ContextRetrieval] User profile not found, using defaults');
          errors.add('User profile not found in Firestore');
          isComplete = false;
        }
      } catch (e) {
        debugPrint('⚠️ [ContextRetrieval] User profile retrieval failed: $e');
        errors.add('Failed to retrieve user profile: $e');
        isComplete = false;
      }

      // Retrieve tasks
      List<TaskModel> tasks = [];
      if (includeTasks) {
        try {
          final tasksSnapshot = await _firestore
              .collection('users')
              .doc(userId)
              .collection('tasks')
              .orderBy('createdAt', descending: true)
              .limit(100) // Limit to avoid excessive reads
              .get()
              .timeout(const Duration(seconds: 10));

          tasks = tasksSnapshot.docs
              .map((doc) => TaskModel.fromFirestore(doc.data(), doc.id))
              .toList();

          debugPrint('✅ [ContextRetrieval] Tasks retrieved: ${tasks.length}');
        } catch (e) {
          debugPrint('⚠️ [ContextRetrieval] Task retrieval failed: $e');
          errors.add('Failed to retrieve tasks: $e');
          isComplete = false;
          // Continue with empty task list
        }
      }

      // Retrieve calendar events (from Firestore cache or memory)
      // Note: Actual Google Calendar sync is handled by CalendarController
      // This retrieves already-synced events from memory/cache
      List<CalendarEventModel> calendarEvents = [];
      if (includeCalendar) {
        try {
          // Calendar events are typically managed in-memory by CalendarController
          // This service provides empty list by default
          // CalendarController should populate events via fetchEvents()
          // If needed, could add Firestore cache here later
          debugPrint('ℹ️ [ContextRetrieval] Calendar events from controller (not retrieved here)');
        } catch (e) {
          debugPrint('⚠️ [ContextRetrieval] Calendar retrieval warning: $e');
          errors.add('Calendar retrieval warning: $e');
          // Not marking as incomplete since calendar is optional
        }
      }

      // Create context snapshot
      final snapshot = ContextSnapshot(
        userId: userId,
        userRole: userRole,
        personality: personality,
        languageCode: languageCode,
        tasks: tasks,
        calendarEvents: calendarEvents,
        retrievedAt: DateTime.now(),
        isComplete: isComplete,
        retrievalErrors: errors,
      );

      debugPrint('✅ [ContextRetrieval] Context snapshot created:');
      debugPrint('   Tasks: ${tasks.length}');
      debugPrint('   Pending: ${snapshot.pendingTasks.length}');
      debugPrint('   Completed: ${snapshot.completedTasks.length}');
      debugPrint('   Calendar: ${calendarEvents.length}');
      debugPrint('   Complete: $isComplete');

      return ContextRetrievalResponse(
        status: true,
        message: 'Context retrieved successfully',
        data: snapshot,
      );
    } catch (e) {
      debugPrint('❌ [ContextRetrieval] Unexpected error: $e');
      return ContextRetrievalResponse(
        status: false,
        message: 'Context retrieval failed: $e',
      );
    }
  }

  /// Retrieve context with calendar events from CalendarController
  /// This is a helper that merges calendar data from controller
  Future<ContextRetrievalResponse> retrieveContextWithCalendar(
    List<CalendarEventModel> calendarEvents,
  ) async {
    final baseResponse = await retrieveContext(
      includeTasks: true,
      includeCalendar: false,
    );

    if (!baseResponse.status || baseResponse.data == null) {
      return baseResponse;
    }

    // Merge calendar events into snapshot
    final enrichedSnapshot = baseResponse.data!.copyWith(
      calendarEvents: calendarEvents,
    );

    debugPrint('✅ [ContextRetrieval] Context enriched with ${calendarEvents.length} calendar events');

    return ContextRetrievalResponse(
      status: true,
      message: 'Context retrieved with calendar data',
      data: enrichedSnapshot,
    );
  }

  /// Quick check if user has any actionable data
  Future<bool> hasActionableData() async {
    final response = await retrieveContext();
    if (!response.status || response.data == null) {
      return false;
    }
    return response.data!.hasData;
  }

  /// Get task by ID
  Future<TaskModel?> getTaskById(String userId, String taskId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .get()
          .timeout(const Duration(seconds: 5));

      if (doc.exists) {
        return TaskModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ [ContextRetrieval] getTaskById failed: $e');
      return null;
    }
  }

  /// Check if task exists
  Future<bool> taskExists(String userId, String taskId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .get()
          .timeout(const Duration(seconds: 5));
      return doc.exists;
    } catch (e) {
      debugPrint('⚠️ [ContextRetrieval] taskExists check failed: $e');
      return false;
    }
  }
}
