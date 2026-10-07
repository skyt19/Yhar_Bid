/// lib/views/role_selection_view.dart
/// [Extrapolate from SRS FR-1] — หน้าเลือกบทบาท 3 กลุ่ม
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_button.dart';
import '../main.dart';

class RoleSelectionView extends StatefulWidget {
  const RoleSelectionView({super.key});
  @override
  State<RoleSelectionView> createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends State<RoleSelectionView> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final AuthController authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
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
                  const Text('เลือกบทบาทของคุณ',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  const Text('เพื่อให้ AI เลขาปรับแต่งการช่วยเหลือให้ตรงกับความต้องการของคุณ',
                      style: TextStyle(fontSize: 15, color: AppTheme.textSecondary), textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  _buildRoleCard('นักศึกษา (Student)', 'ตรวจ Deadline งานส่ง สร้าง Task Outline ล่วงหน้า 3 วัน',
                      Icons.school_outlined, UserRole.student),
                  const SizedBox(height: 12),
                  _buildRoleCard('พนักงานองค์กร (Corporate Employee)', 'เตรียม Meeting Agenda และ Discussion Points',
                      Icons.business_center_outlined, UserRole.corporateEmployee),
                  const SizedBox(height: 12),
                  _buildRoleCard('ครู/อาจารย์ (Educator)', 'เตรียม Lesson Structure และ Exam Content',
                      Icons.assignment_ind_outlined, UserRole.educator),
                  const SizedBox(height: 40),
                  CustomButton(
                    label: 'ถัดไป',
                    onPressed: _selectedRole == null ? null : () async {
                      await authCtrl.updateUserRole(_selectedRole!);
                      Get.toNamed(AppRoutes.aiPersonality);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String label, String desc, IconData icon, UserRole role) {
    final bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
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
