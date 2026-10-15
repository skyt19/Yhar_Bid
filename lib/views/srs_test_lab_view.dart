/// lib/views/srs_test_lab_view.dart
/// Interactive SRS Live Evaluation & Test Panel for Instructor Demo
/// Demonstrates FR-1 through FR-6 and NFR-7/NFR-8 in a unified interface

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/proactive_controller.dart';
import '../controllers/habit_controller.dart';
import '../controllers/analytics_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';
import 'theme/app_theme.dart';

class SrsTestLabView extends StatelessWidget {
  const SrsTestLabView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authCtrl = Get.find<AuthController>();
    final CalendarController calendarCtrl = Get.find<CalendarController>();
    final ProactiveController proactiveCtrl = Get.find<ProactiveController>();
    final HabitController habitCtrl = Get.find<HabitController>();
    final AnalyticsController analyticsCtrl = Get.find<AnalyticsController>();
    final SettingsController settingsCtrl = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('SRS Live Evaluation Lab', 
          style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildGoldenThreadBanner(authCtrl),
            const SizedBox(height: 24),
            _buildTestSection(
              title: 'FR-1: Role & AI Style Selection',
              description: 'Switch between roles and styles to see instant adaptation',
              child: Column(
                children: <Widget>[
                  _buildRoleSwitcher(authCtrl, settingsCtrl),
                  const SizedBox(height: 12),
                  _buildStyleSwitcher(authCtrl, settingsCtrl),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTestSection(
              title: 'FR-2: Two-Way Google Calendar Sync',
              description: 'Real read/write synchronization with Google Calendar',
              child: _buildCalendarTestPanel(calendarCtrl, authCtrl),
            ),
            const SizedBox(height: 16),
            _buildTestSection(
              title: 'FR-3: Proactive Secretary (gemma-4-26b-a4b-it)',
              description: 'AI prepares role-specific content for upcoming events',
              child: _buildProactiveTestPanel(proactiveCtrl),
            ),
            const SizedBox(height: 16),
            _buildTestSection(
              title: 'FR-4: Role-Contextual Habit Tracker',
              description: 'Habits and sub-tasks adapted to active role',
              child: _buildHabitTestPanel(habitCtrl),
            ),
            const SizedBox(height: 16),
            _buildTestSection(
              title: 'FR-5 & NFR-7: Styled Notifications + Fallback',
              description: 'Short notifications (<120 chars) with AI outage simulation',
              child: _buildNotificationTestPanel(authCtrl, settingsCtrl),
            ),
            const SizedBox(height: 16),
            _buildTestSection(
              title: 'FR-6 & NFR-8: Behavioral Analytics',
              description: 'Real-time metrics with standard error format',
              child: _buildAnalyticsTestPanel(analyticsCtrl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldenThreadBanner(AuthController authCtrl) {
    return Obx(() {
      final user = authCtrl.currentUser.value;
      if (user == null) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.accentGreen.withOpacity(0.2), AppTheme.accentGreen.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.accentGreen, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.stars, color: AppTheme.accentGreen, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'GOLDEN THREAD: Role-Based Context',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContextBadge('Active Role', _getRoleDisplayName(user.role), _getRoleIcon(user.role)),
            const SizedBox(height: 8),
            _buildContextBadge('AI Communication Style', _getPersonalityDisplayName(user.personality), Icons.chat),
            const SizedBox(height: 16),
            Text(
              'The same calendar event requires completely different preparation and reminder tone depending on your role.',
              style: TextStyle(fontSize: 13, color: Colors.grey[700], fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildContextBadge(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: AppTheme.accentGreen),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.accentGreen)),
        ],
      ),
    );
  }

  Widget _buildTestSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildRoleSwitcher(AuthController authCtrl, SettingsController settingsCtrl) {
    return Obx(() {
      final currentRole = authCtrl.currentUser.value?.role ?? UserRole.student;
      
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: UserRole.values.map((role) {
          final bool isSelected = currentRole == role;
          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(_getRoleIcon(role), size: 16, color: isSelected ? Colors.white : AppTheme.accentGreen),
                const SizedBox(width: 6),
                Text(_getRoleDisplayName(role)),
              ],
            ),
            selected: isSelected,
            onSelected: (bool selected) async {
              if (selected) {
                await authCtrl.updateUserRole(role);
                Get.snackbar('Role Updated', 'Now acting as ${_getRoleDisplayName(role)}',
                  snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
              }
            },
            selectedColor: AppTheme.accentGreen,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.accentGreen, fontWeight: FontWeight.bold),
          );
        }).toList(),
      );
    });
  }

  Widget _buildStyleSwitcher(AuthController authCtrl, SettingsController settingsCtrl) {
    return Obx(() {
      final currentPersonality = authCtrl.currentUser.value?.personality ?? AiPersonality.politeJarvis;
      
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: AiPersonality.values.map((personality) {
          final bool isSelected = currentPersonality == personality;
          return ChoiceChip(
            label: Text(_getPersonalityDisplayName(personality)),
            selected: isSelected,
            onSelected: (bool selected) async {
              if (selected) {
                await authCtrl.updateAiPersonality(personality);
                Get.snackbar('AI Style Updated', 'Now using ${_getPersonalityDisplayName(personality)} tone',
                  snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
              }
            },
            selectedColor: AppTheme.accentGreen,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.accentGreen, fontWeight: FontWeight.w600),
          );
        }).toList(),
      );
    });
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.corporateEmployee:
        return 'Corporate Employee';
      case UserRole.educator:
        return 'Educator';
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school;
      case UserRole.corporateEmployee:
        return Icons.business_center;
      case UserRole.educator:
        return Icons.person;
    }
  }

  String _getPersonalityDisplayName(AiPersonality personality) {
    switch (personality) {
      case AiPersonality.politeJarvis:
        return 'Polite Jarvis';
      case AiPersonality.friendly:
        return 'Friendly';
      case AiPersonality.aggressiveMotivator:
        return 'Aggressive Motivator';
    }
  }

  Widget _buildCalendarTestPanel(CalendarController calendarCtrl, AuthController authCtrl) {
    return Obx(() {
      final eventCount = calendarCtrl.events.length;
      final bool isLoading = calendarCtrl.isLoading.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.event, color: AppTheme.accentGreen, size: 20),
              const SizedBox(width: 8),
              Text('Events in Calendar: $eventCount', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: isLoading ? null : () async {
              await calendarCtrl.fetchEvents();
            },
            icon: isLoading 
              ? const SizedBox(width: 18, height: 18, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.sync),
            label: Text(isLoading ? 'Syncing...' : 'Sync Google Calendar Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              await calendarCtrl.createSampleRoleEvents();
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Create Sample Role Events (Two-Way Write)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGray,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProactiveTestPanel(ProactiveController proactiveCtrl) {
    return Obx(() {
      final bool isScanning = proactiveCtrl.isScanning.value;
      final int proposalCount = proactiveCtrl.pendingProposals.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.smart_toy, color: AppTheme.accentGreen, size: 20),
              const SizedBox(width: 8),
              Text('Pending Proposals: $proposalCount', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: isScanning ? null : () async {
              await proactiveCtrl.runProactiveScan();
            },
            icon: isScanning 
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.psychology),
            label: Text(isScanning ? 'Analyzing Events...' : 'Run Proactive Secretary Scan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHabitTestPanel(HabitController habitCtrl) {
    return Obx(() {
      final habitCount = habitCtrl.habits.length;
      final completedCount = habitCtrl.habits.where((h) => h.completedDates.isNotEmpty).length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 20),
              const SizedBox(width: 8),
              Text('Active Habits: $habitCount', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Completed Today: $completedCount', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              habitCtrl.loadRoleContextualHabits();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reload Role Habits'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildNotificationTestPanel(AuthController authCtrl, SettingsController settingsCtrl) {
    return Obx(() {
      final bool aiOutageMode = settingsCtrl.testModeAiOutage.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.notifications_active, color: AppTheme.accentGreen, size: 20),
              const SizedBox(width: 8),
              const Text('Test Notification System', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('AI Outage Simulation (NFR-7)'),
            subtitle: Text(aiOutageMode ? 'Fallback templates active' : 'Using Gemini API'),
            value: aiOutageMode,
            activeColor: AppTheme.accentGreen,
            onChanged: (bool value) {
              settingsCtrl.toggleTestModeAiOutage();
            },
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              final notificationService = NotificationService();
              await notificationService.sendTestNotification(
                authCtrl.currentUser.value?.role ?? UserRole.student,
                authCtrl.currentUser.value?.personality ?? AiPersonality.politeJarvis,
              );
              Get.snackbar('Notification Sent', 'Check your notification panel',
                snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
            },
            icon: const Icon(Icons.send),
            label: const Text('Send Styled Notification (<120 chars)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildAnalyticsTestPanel(AnalyticsController analyticsCtrl) {
    return Obx(() {
      final calendarRate = analyticsCtrl.weeklyCalendarComplianceRate.value;
      final habitRate = analyticsCtrl.weeklyHabitSuccessRate.value;
      final overallScore = analyticsCtrl.overallScore;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildMetricRow('Calendar Compliance', calendarRate),
          const SizedBox(height: 8),
          _buildMetricRow('Habit Success Rate', habitRate),
          const SizedBox(height: 8),
          _buildMetricRow('Overall Score', overallScore),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              analyticsCtrl.recalculateMetrics();
            },
            icon: const Icon(Icons.analytics),
            label: const Text('Recalculate Metrics (Live)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMetricRow(String label, double value) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Expanded(
          flex: 2,
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              value >= 80 ? Colors.green : value >= 60 ? Colors.orange : Colors.red,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            '${value.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

