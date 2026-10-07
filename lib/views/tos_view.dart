/// lib/views/tos_view.dart
/// [Mockup 8] — Terms of Service (ToS)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';

class TosView extends StatelessWidget {
  const TosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('ToS', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('นโยบาย', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('แอพนึ้ถูกสร้างขึ้นเพื่อ....', style: TextStyle(fontSize: 15, height: 1.6, color: AppTheme.textPrimary)),
                const SizedBox(height: 300),
                const Text(
                  '''
Yharbid AI Assistant — Terms of Service

1. ข้อตกลงการใช้งาน
การใช้งานแอปพลิเคชันนี้ถือว่าผู้ใช้ยอมรับข้อตกลงทั้งหมด

2. การเก็บข้อมูล
เราเก็บข้อมูล Google Calendar และการใช้งาน AI เพื่อปรับปรุงประสบการณ์

3. ความเป็นส่วนตัว
ข้อมูลของคุณจะถูกเข้ารหัสและไม่แบ่งปันกับบุคคลที่สาม

4. การยกเลิก
คุณสามารถลบบัญชีได้ทุกเมื่อผ่านหน้าการตั้งค่า

ติดต่อ: support@yharbid.app
                  ''',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
