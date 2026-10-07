/// lib/views/ai_personality_view.dart
/// [Mockup 2] — AI Personality Selection
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/user_model.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_button.dart';

class AiPersonalityView extends StatefulWidget {
  const AiPersonalityView({super.key});
  @override
  State<AiPersonalityView> createState() => _AiPersonalityViewState();
}

class _AiPersonalityViewState extends State<AiPersonalityView> {
  AiPersonality _selectedPersonality = AiPersonality.politeJarvis;

  @override
  Widget build(BuildContext context) {
    final AuthController authCtrl = Get.find<AuthController>();
    final SettingsController settingsCtrl = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: <Widget>[
                      const Text('ต้องการให้เราช่วยคุณยังไง?\nจงอธิบายรูปแบบที่คุณ\nต้องการให้เราช่วยเหลือคุณมาได้เลย',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.4), textAlign: TextAlign.center),
                      const SizedBox(height: 40),
                      _buildCard('Polite Jarvis (สุภาพ)', 'สื่อสารสุภาพแบบมืออาชีพ', Icons.sentiment_satisfied_outlined, AiPersonality.politeJarvis),
                      const SizedBox(height: 12),
                      _buildCard('Friendly (เป็นกันเอง)', 'สื่อสารแบบเพื่อน ใจเย็น', Icons.sentiment_very_satisfied_outlined, AiPersonality.friendly),
                      const SizedBox(height: 12),
                      _buildCard('Aggressive Motivator (กระตุ้นแรง)', 'กระตุ้นและท้าทาย', Icons.local_fire_department_outlined, AiPersonality.aggressiveMotivator),
                      const SizedBox(height: 40),
                      CustomButton(
                        label: 'เริ่มใช้งาน',
                        onPressed: () async {
                          await authCtrl.updateAiPersonality(_selectedPersonality);
                          settingsCtrl.setAiAggressionLevel(AiPersonality.values.indexOf(_selectedPersonality));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 24, right: 24,
              child: Obx(() => GestureDetector(
                    onTap: settingsCtrl.toggleLanguage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.circular(AppTheme.radiusPill)),
                      child: Text(settingsCtrl.languageCode.value == 'th' ? 'TH/EN' : 'EN/TH',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String label, String desc, IconData icon, AiPersonality value) {
    final bool isSelected = _selectedPersonality == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPersonality = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentPrimary.withOpacity(0.12) : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: isSelected ? AppTheme.accentPrimary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 32, color: isSelected ? AppTheme.accentPrimary : AppTheme.textPrimary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppTheme.accentPrimary),
          ],
        ),
      ),
    );
  }
}
