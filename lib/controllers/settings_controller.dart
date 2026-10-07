/// lib/controllers/settings_controller.dart
/// Controller จัดการการตั้งค่าแอป — ภาษา, ระดับ AI, การแจ้งเตือน
import 'package:get/get.dart';
import '../models/user_model.dart';

class SettingsController extends GetxController {
  // ภาษาปัจจุบัน: 'th' หรือ 'en'
  final RxString languageCode = 'th'.obs;

  // ระดับความดุดันของ AI (0 = Polite, 1 = Friendly, 2 = Aggressive)
  final RxInt aiAggressionLevel = 0.obs;

  // เปิด/ปิดการแจ้งเตือน
  final RxBool notificationsEnabled = true.obs;

  // เสียงแจ้งเตือน
  final RxString notificationSoundId = 'default'.obs;

  /// สลับภาษา TH/EN
  void toggleLanguage() {
    languageCode.value = languageCode.value == 'th' ? 'en' : 'th';
  }

  /// เปลี่ยนระดับความดุดัน AI
  void setAiAggressionLevel(int level) {
    if (level < 0 || level > 2) return;
    aiAggressionLevel.value = level;
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
        return 'สุภาพ (Polite Jarvis)';
      case 1:
        return 'เป็นกันเอง (Friendly)';
      case 2:
        return 'กระตุ้นแรง (Aggressive Motivator)';
      default:
        return 'สุภาพ (Polite Jarvis)';
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
    // TODO: ล้างข้อมูลแคชจริงๆ ใน production
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
}
