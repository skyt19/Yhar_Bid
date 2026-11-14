library;

/// lib/views/widgets/ai_insights_card.dart
/// NEW WIDGET (P1): Surface AI Personality and Proactive Insights
/// Shows AI-generated preparation suggestions with personality-matched messaging
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/proactive_controller.dart';
import '../../models/user_model.dart';
import '../theme/app_theme.dart';

class AiInsightsCard extends StatelessWidget {
  final ProactiveController proactiveController;
  final AuthController authController;

  const AiInsightsCard({
    super.key,
    required this.proactiveController,
    required this.authController,
  });

  String _getPersonalityGreeting(AiPersonality personality, String displayName) {
    final firstName = displayName.split(' ').first;

    switch (personality) {
      case AiPersonality.politeJarvis:
        return 'สวัสดีครับ คุณ$firstName มีงานที่ต้องเตรียมการดังนี้';
      case AiPersonality.friendly:
        return 'ว่าไง $firstName! มีงานน่าสนใจให้เตรียมตัวนะ';
      case AiPersonality.aggressiveMotivator:
        return '$firstName! ลุยเลยต้องเตรียมงานเดี๋ยวนี้!';
    }
  }

  IconData _getPersonalityIcon(AiPersonality personality) {
    switch (personality) {
      case AiPersonality.politeJarvis:
        return Icons.psychology_outlined;
      case AiPersonality.friendly:
        return Icons.emoji_emotions_outlined;
      case AiPersonality.aggressiveMotivator:
        return Icons.flash_on_outlined;
    }
  }

  Color _getPersonalityColor(AiPersonality personality) {
    switch (personality) {
      case AiPersonality.politeJarvis:
        return AppTheme.accentGreen;
      case AiPersonality.friendly:
        return AppTheme.accentGreen;
      case AiPersonality.aggressiveMotivator:
        return AppTheme.accentOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final UserModel? user = authController.currentUser.value;
      if (user == null) return const SizedBox.shrink();

      final pendingProposals = proactiveController.pendingProposals;
      final isScanning = proactiveController.isScanning.value;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getPersonalityColor(user.personality).withValues(alpha: 0.16),
              _getPersonalityColor(user.personality).withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          border: Border.all(
            color: _getPersonalityColor(user.personality).withValues(alpha: 0.4),
            width: 2.5,
          ),
          boxShadow: AppTheme.shadowElevated,
        ),
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header with personality icon and greeting
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(AppTheme.space10),
                  decoration: BoxDecoration(
                    color: _getPersonalityColor(user.personality),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x20000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getPersonalityIcon(user.personality),
                    color: AppTheme.textOnDark,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppTheme.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'AI ${_getPersonalityName(user.personality)}',
                        style: AppTheme.titleSmall.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getPersonalityGreeting(user.personality, user.displayName),
                        style: AppTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space16),

            // Scanning state with progress
            if (isScanning)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.space20),
                  child: Column(
                    children: <Widget>[
                      const CircularProgressIndicator(
                        color: AppTheme.accentGreen,
                      ),
                      const SizedBox(height: AppTheme.space12),
                      Obx(() {
                        final int scanned = proactiveController.scannedEventsCount.value;
                        final String status = proactiveController.statusMessage.value;

                        return Column(
                          children: [
                            if (scanned > 0)
                              Text(
                                'วิเคราะห์แล้ว $scanned กิจกรรม',
                                style: AppTheme.body13.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            if (status.isNotEmpty) ...[
                              const SizedBox(height: AppTheme.space6),
                              Text(
                                status,
                                style: AppTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              )
            // Empty state - no proposals yet
            else if (pendingProposals.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppTheme.space20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.lightbulb_outline,
                      size: 48,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppTheme.space12),
                    Text(
                      'ยังไม่มีข้อเสนอจาก AI',
                      style: AppTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.space8),
                    Text(
                      'กดปุ่มด้านล่างเพื่อให้ AI วิเคราะห์งานที่กำลังจะมาถึง',
                      textAlign: TextAlign.center,
                      style: AppTheme.body13.copyWith(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: AppTheme.space16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => proactiveController.runProactiveScan(),
                        icon: const Icon(Icons.auto_awesome, size: 20),
                        label: const Text('ให้ AI วิเคราะห์ตารางงาน'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                          foregroundColor: AppTheme.textOnDark,
                          padding: const EdgeInsets.symmetric(vertical: AppTheme.space14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            // Show proposals
            else ...[
              Text(
                'ข้อเสนอจาก AI (${pendingProposals.length})',
                style: AppTheme.titleSmall.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppTheme.space12),
              ...pendingProposals.take(2).map((proposal) {
                return _buildProposalPreview(proposal, user.personality);
              }).toList(),
              if (pendingProposals.length > 2) ...[
                const SizedBox(height: AppTheme.space8),
                Center(
                  child: Text(
                    'และอีก ${pendingProposals.length - 2} รายการ',
                    style: AppTheme.body13.copyWith(
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      );
    });
  }

  String _getPersonalityName(AiPersonality personality) {
    switch (personality) {
      case AiPersonality.politeJarvis:
        return 'Polite Jarvis';
      case AiPersonality.friendly:
        return 'Friendly';
      case AiPersonality.aggressiveMotivator:
        return 'Motivator';
    }
  }

  Widget _buildProposalPreview(PreparationProposal proposal, AiPersonality personality) {
    final DateFormat dateFormat = DateFormat('EEE, dd MMM yyyy', 'th');
    final DateFormat timeFormat = DateFormat('HH:mm');
    final bool hasLocation = proposal.event.location != null && proposal.event.location!.isNotEmpty;
    final bool hasDescription = proposal.event.description != null && proposal.event.description!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.space12),
      padding: const EdgeInsets.all(AppTheme.space14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Event title with expand indicator
          Row(
            children: <Widget>[
              Icon(
                Icons.event_note,
                size: 20,
                color: _getPersonalityColor(personality),
              ),
              const SizedBox(width: AppTheme.space10),
              Expanded(
                child: Text(
                  proposal.event.title,
                  style: AppTheme.titleMedium.copyWith(height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space10),

          // Full event details (always visible)
          Container(
            padding: const EdgeInsets.all(AppTheme.space10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGray,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Date and time
                Row(
                  children: <Widget>[
                    const Icon(Icons.calendar_today, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: AppTheme.space6),
                    Expanded(
                      child: Text(
                        dateFormat.format(proposal.event.startTime),
                        style: AppTheme.body13.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space6),
                Row(
                  children: <Widget>[
                    const Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: AppTheme.space6),
                    Text(
                      '${timeFormat.format(proposal.event.startTime)} - ${timeFormat.format(proposal.event.endTime)}',
                      style: AppTheme.body13,
                    ),
                  ],
                ),

                // Location (if present)
                if (hasLocation) ...[
                  const SizedBox(height: AppTheme.space6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: AppTheme.space6),
                      Expanded(
                        child: Text(
                          proposal.event.location!,
                          style: AppTheme.body13,
                        ),
                      ),
                    ],
                  ),
                ],

                // Description (if present)
                if (hasDescription) ...[
                  const SizedBox(height: AppTheme.space8),
                  const Divider(height: 1, color: AppTheme.dividerColor),
                  const SizedBox(height: AppTheme.space8),
                  Text(
                    proposal.event.description!,
                    style: AppTheme.body13.copyWith(height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppTheme.space10),

          // AI preparation content
          Text(
            'ข้อเสนอการเตรียมงาน:'.tr,
            style: AppTheme.labelMedium,
          ),
          const SizedBox(height: AppTheme.space6),
          Text(
            proposal.aiContent,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          if (proposal.suggestedTasks.isNotEmpty) ...[
            const SizedBox(height: AppTheme.space8),
            Row(
              children: <Widget>[
                Icon(
                  Icons.checklist_rounded,
                  size: 15,
                  color: _getPersonalityColor(personality),
                ),
                const SizedBox(width: AppTheme.space6),
                Text(
                  '${proposal.suggestedTasks.length} งานย่อยที่แนะนำ'.tr,
                  style: AppTheme.bodySmall.copyWith(
                    color: _getPersonalityColor(personality),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppTheme.space14),

          // Action buttons
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRejectConfirmation(proposal.id),
                  icon: const Icon(Icons.close, size: 17),
                  label: Text('ไม่รับ', style: AppTheme.titleSmall),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentRed,
                    side: const BorderSide(color: AppTheme.borderStrong),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => proactiveController.approveProposal(proposal.id),
                  icon: const Icon(Icons.check_circle, size: 17),
                  label: Text('อนุมัติและสร้างแผน', style: AppTheme.titleSmall),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPersonalityColor(personality),
                    foregroundColor: AppTheme.textOnDark,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRejectConfirmation(String proposalId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.help_outline,
                size: 48,
                color: AppTheme.accentOrange,
              ),
              const SizedBox(height: AppTheme.space16),
              Text(
                'ปฏิเสธข้อเสนอนี้?',
                style: AppTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.space12),
              Text(
                'ข้อเสนอการเตรียมงานนี้จะถูกลบออก และคุณจะไม่ได้รับคำแนะนำสำหรับงานนี้อีก',
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium.copyWith(height: 1.5),
              ),
              const SizedBox(height: AppTheme.space24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        side: const BorderSide(color: AppTheme.borderStrong),
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.space12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                      ),
                      child: Text('ยกเลิก', style: AppTheme.titleSmall),
                    ),
                  ),
                  const SizedBox(width: AppTheme.space12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        proactiveController.rejectProposal(proposalId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentRed,
                        foregroundColor: AppTheme.textOnDark,
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.space12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        elevation: 0,
                      ),
                      child: Text('ปฏิเสธ', style: AppTheme.titleSmall),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
