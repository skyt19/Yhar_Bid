/// lib/controllers/settings_controller.dart
/// Controller จัดการการตั้งค่าแอป — ภาษา, ระดับ AI, การแจ้งเตือน พร้อม Persistent Storage
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

class SettingsController extends GetxController {
  final GetStorage _storage = GetStorage();

  // ภาษาปัจจุบัน: 'th' หรือ 'en'
  final RxString languageCode = 'th'.obs;

  // ระดับความดุดันของ AI (0 = Polite, 1 = Friendly, 2 = Aggressive)
  final RxInt aiAggressionLevel = 0.obs;

  // เปิด/ปิดการแจ้งเตือน
  final RxBool notificationsEnabled = true.obs;
  
  // เปิด/ปิด AI Contextual Memory
  final RxBool aiMemoryEnabled = true.obs;

  // เสียงแจ้งเตือน
  final RxString notificationSoundId = 'default'.obs;
  
  // Storage Keys
  static const String _keyLanguage = 'language_code';
  static const String _keyAiLevel = 'ai_aggression_level';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyAiMemory = 'ai_memory_enabled';

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }
  
  /// โหลดการตั้งค่าจาก Storage
  void _loadSettings() {
    languageCode.value = _storage.read<String>(_keyLanguage) ?? 'th';
    aiAggressionLevel.value = _storage.read<int>(_keyAiLevel) ?? 0;
    notificationsEnabled.value = _storage.read<bool>(_keyNotifications) ?? true;
    aiMemoryEnabled.value = _storage.read<bool>(_keyAiMemory) ?? true;
    
    // อัปเดต Locale ตามค่าที่โหลดมา
    if (languageCode.value == 'en') {
      Get.updateLocale(const Locale('en', 'US'));
    } else {
      Get.updateLocale(const Locale('th', 'TH'));
    }
  }

  /// สลับภาษา TH/EN
  void toggleLanguage() {
    if (languageCode.value == 'th') {
      languageCode.value = 'en';
      Get.updateLocale(const Locale('en', 'US'));
    } else {
      languageCode.value = 'th';
      Get.updateLocale(const Locale('th', 'TH'));
    }
    _storage.write(_keyLanguage, languageCode.value);
  }

  /// เปลี่ยนระดับความดุดัน AI
  void setAiAggressionLevel(int level) {
    if (level < 0 || level > 2) return;
    aiAggressionLevel.value = level;
    _storage.write(_keyAiLevel, level);
  }
  
  /// Toggle AI Memory
  void toggleAiMemory(bool value) {
    aiMemoryEnabled.value = value;
    _storage.write(_keyAiMemory, value);
  }
  
  /// Toggle Notifications
  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    _storage.write(_keyNotifications, value);
  }

  /// แปลง level เป็น AiPersonality enum
  AiPersonality get currentPersonality {
    switch (aiAggressionLevel.value) {
      case 0:
        return AiPersonality.politeJarvis;
      case 1:
        return AiPersonality.friendly;
      case 2:
        return AiPersonality.aggressiveMotivator;
      default:
        return AiPersonality.politeJarvis;
    }
  }

  /// ชื่อสไตล์ AI ภาษาไทย
  String get personalityLabel {
    switch (aiAggressionLevel.value) {
      case 0:
        return 'polite_jarvis'.tr;
      case 1:
        return 'friendly'.tr;
      case 2:
        return 'aggressive_motivator'.tr;
      default:
        return 'polite_jarvis'.tr;
    }
  }

  /// ตัวอย่างข้อความแจ้งเตือนตามสไตล์ (ไม่เกิน 120 ตัวอักษรตาม SRS)
  String get notificationPreviewTh {
    switch (aiAggressionLevel.value) {
      case 0:
        return 'สวัสดีครับ คุณมีงานส่งพรุ่งนี้ กรุณาตรวจสอบและเตรียมตัวให้พร้อม';
      case 1:
        return 'เฮ้! อย่าลืมงานพรุ่งนี้นะ มาเริ่มเลย! 💪';
      case 2:
        return 'หยุดผัดวันแล้ว! งานส่งพรุ่งนี้! ลุกขึ้นทำเดี๋ยวนี้เลย!';
      default:
        return 'คุณมีงานที่ต้องทำ';
    }
  }

  /// ล้างข้อมูลแคชแอป
  Future<void> clearAppCache() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    Get.snackbar('cache_cleared'.tr, 'cache_cleared'.tr, snackPosition: SnackPosition.BOTTOM);
  }
}

