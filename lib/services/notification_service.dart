/// lib/services/notification_service.dart
/// Service Layer สำหรับ Local Notifications พร้อม AI-Generated Messages
/// ตาม FR-5, NFR-1, NFR-7: Customized Notifications + Offline Fallback

import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/calendar_event_model.dart';
import '../models/user_model.dart';
import '../core/exceptions/app_exceptions.dart';
import 'ai_service.dart';

/// Standard Notification Service Response
class NotificationServiceResponse {
  final bool status;
  final String message;
  final dynamic data;
  const NotificationServiceResponse({required this.status, required this.message, this.data});
}

/// Notification Service Layer — Pure Business Logic
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AiService _aiService = AiService();
  bool _isInitialized = false;

  /// Initialize Flutter Local Notifications (Android & iOS)
  Future<NotificationServiceResponse> initialize() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      final bool? result = await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (result == true || result == null) {
        _isInitialized = true;
        
        if (Platform.isAndroid) {
          await _requestAndroidPermissions();
        }
        
        return const NotificationServiceResponse(
          status: true,
          message: 'Notification Service initialized successfully',
        );
      } else {
        return const NotificationServiceResponse(
          status: false,
          message: 'Failed to initialize Notification Service',
        );
      }
    } catch (e) {
      throw NotificationException(
        message: 'เกิดข้อผิดพลาดในการเริ่มต้น Notification: ${e.toString()}',
        code: 'INIT_ERROR',
      );
    }
  }

  Future<void> _requestAndroidPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  /// แสดง Notification พื้นฐาน
  Future<NotificationServiceResponse> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'yharbid_default',
        'Yharbid Notifications',
        channelDescription: 'การแจ้งเตือนทั่วไปจาก Yharbid AI Assistant',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );

      return const NotificationServiceResponse(
        status: true,
        message: 'Notification displayed successfully',
      );
    } catch (e) {
      throw NotificationException(
        message: 'ไม่สามารถแสดง Notification ได้: ${e.toString()}',
        code: 'SHOW_ERROR',
      );
    }
  }

  /// สร้างและแสดง AI-Generated Notification จาก Calendar Event
  /// ตาม FR-5: Customized Short Notifications (120 ตัวอักษร)
  /// NFR-7: Offline Fallback Templates
  Future<NotificationServiceResponse> showEventNotification({
    required CalendarEventModel event,
    required UserRole role,
    required AiPersonality personality,
  }) async {
    try {
      String notificationBody = '';
      bool usedAI = false;

      try {
        final String aiPrompt = _buildNotificationPrompt(event, role, personality);
        final AiServiceResponse aiResponse = await _aiService.generateContent(
          prompt: aiPrompt,
          role: role,
          maxTokens: 150,
        ).timeout(const Duration(seconds: 10));

        if (aiResponse.status && aiResponse.data != null) {
          notificationBody = (aiResponse.data as String).trim();
          
          if (notificationBody.length > 120) {
            notificationBody = '${notificationBody.substring(0, 117)}...';
          }
          
          usedAI = true;
        }
      } catch (e) {
        print('⚠️ AI Notification failed, using fallback: $e');
      }

      if (!usedAI || notificationBody.isEmpty) {
        notificationBody = _getFallbackNotificationMessage(event, role, personality);
      }

      await showNotification(
        id: event.id.hashCode,
        title: '🔔 ${event.title}',
        body: notificationBody,
        payload: event.id,
      );

      return NotificationServiceResponse(
        status: true,
        message: usedAI ? 'AI Notification sent' : 'Fallback Notification sent',
        data: <String, dynamic>{'usedAI': usedAI, 'body': notificationBody},
      );
    } catch (e) {
      throw NotificationException(
        message: 'ไม่สามารถส่ง Event Notification ได้: ${e.toString()}',
        code: 'EVENT_NOTIF_ERROR',
      );
    }
  }

  String _buildNotificationPrompt(CalendarEventModel event, UserRole role, AiPersonality personality) {
    final String timeStr = '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')}';
    final String personalityInstruction = _getPersonalityInstruction(personality);
    
    return '''สร้างข้อความแจ้งเตือนสั้นๆ (ไม่เกิน 120 ตัวอักษร) ในน้ำเสียง$personalityInstruction
งาน: ${event.title}
เวลา: $timeStr
รายละเอียด: ${event.description ?? 'ไม่มี'}

ตอบเฉพาะข้อความแจ้งเตือนเท่านั้น ห้ามเกิน 120 ตัวอักษร''';
  }

  String _getPersonalityInstruction(AiPersonality personality) {
    switch (personality) {
      case AiPersonality.politeJarvis:
        return 'สุภาพและเป็นมืออาชีพ เหมือนเลขาส่วนตัว';
      case AiPersonality.friendly:
        return 'เป็นกันเองและให้กำลังใจ';
      case AiPersonality.aggressiveMotivator:
        return 'กระตุ้นแรงและท้าทาย';
    }
  }

  /// Offline Fallback Templates (NFR-7): 3 Roles × 3 Personalities = 9 แบบ
  String _getFallbackNotificationMessage(
    CalendarEventModel event,
    UserRole role,
    AiPersonality personality,
  ) {
    final String timeStr = '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} น.';
    final String title = event.title.length > 30 ? '${event.title.substring(0, 27)}...' : event.title;

    if (role == UserRole.student) {
      switch (personality) {
        case AiPersonality.politeJarvis:
          return 'เวลา $timeStr: $title — กรุณาเตรียมตัวให้พร้อม';
        case AiPersonality.friendly:
          return 'อีกนิดเดียว! $timeStr มี $title รอคุณอยู่นะ 📚';
        case AiPersonality.aggressiveMotivator:
          return 'เวลา $timeStr แล้ว! $title — อย่าพลาดนะ! 🔥';
      }
    }
    
    if (role == UserRole.corporateEmployee) {
      switch (personality) {
        case AiPersonality.politeJarvis:
          return 'เวลา $timeStr: $title — เตรียมเอกสารพร้อมหรือยัง?';
        case AiPersonality.friendly:
          return 'สวัสดี! $timeStr มีงาน $title นะ พร้อมไหม? 💼';
        case AiPersonality.aggressiveMotivator:
          return '$timeStr: $title กำลังรอ อย่าทำให้ทีมรอ! ⚡';
      }
    }
    
    if (role == UserRole.educator) {
      switch (personality) {
        case AiPersonality.politeJarvis:
          return 'เวลา $timeStr: $title — สื่อการสอนพร้อมหรือยัง?';
        case AiPersonality.friendly:
          return 'เตรียมพบนักเรียนเวลา $timeStr! $title 🎓';
        case AiPersonality.aggressiveMotivator:
          return '$timeStr: $title — นักเรียนรอคุณอยู่แล้ว! 📖';
      }
    }

    return 'เวลา $timeStr: $title';
  }

  /// ทดสอบส่ง Notification (ปุ่มทดสอบใน Settings - FR-5)
  Future<NotificationServiceResponse> sendTestNotification(
    UserRole role,
    AiPersonality personality,
  ) async {
    // สร้าง Mock Event สำหรับ Test
    final testEvent = CalendarEventModel(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      title: 'การประชุมทีม - ทดสอบระบบ',
      description: 'ทดสอบการแจ้งเตือนแบบ ${_getPersonalityName(personality)}',
      startTime: DateTime.now().add(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      isAllDay: false,
      calendarId: 'primary',
    );
    
    return await showEventNotification(
      event: testEvent,
      role: role,
      personality: personality,
    );
  }
  
  String _getPersonalityName(AiPersonality personality) {
    switch (personality) {
      case AiPersonality.politeJarvis:
        return 'Polite Jarvis';
      case AiPersonality.friendly:
        return 'Friendly';
      case AiPersonality.aggressiveMotivator:
        return 'Aggressive Motivator';
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
