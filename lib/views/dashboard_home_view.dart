library;

/// lib/views/dashboard_home_view.dart
/// Yharbid — Home Dashboard
/// Impeccable Operate mode: clarity, role-adaptive, AI insights first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/proactive_controller.dart';
import '../models/user_model.dart';
import 'theme/app_theme.dart';
import 'widgets/incoming_work_card.dart';
import 'widgets/work_in_week_card.dart';
import 'widgets/add_task_dialog.dart';
import 'widgets/ai_insights_card.dart';
import 'preparation_detail_view.dart';

class DashboardHomeView extends StatefulWidget {
  const DashboardHomeView({super.key});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  DateTime? lastSyncTime;
  final FocusNode _dashboardFocus = FocusNode();
  bool _showKeyboardHint = false;

  @override
  void initState() {
    super.initState();
    // Request focus for keyboard shortcuts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dashboardFocus.requestFocus();
      _checkFirstVisit();
    });
  }

  Future<void> _checkFirstVisit() async {
    // Check if user has seen keyboard shortcut hint
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenHint = prefs.getBool('keyboard_hint_seen') ?? false;

    if (!hasSeenHint && mounted) {
      setState(() {
        _showKeyboardHint = true;
      });

      // Auto-dismiss after 8 seconds
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted) {
          _dismissKeyboardHint();
        }
      });
    }
  }

  Future<void> _dismissKeyboardHint() async {
    setState(() {
      _showKeyboardHint = false;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keyboard_hint_seen', true);
  }

  @override
  void dispose() {
    _dashboardFocus.dispose();
    super.dispose();
  }

  /// Keyboard shortcuts handler
  void _handleKeyPress(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final bool isCtrlOrCmd = event.logicalKey == LogicalKeyboardKey.control ||
        event.logicalKey == LogicalKeyboardKey.meta;

    // Cmd/Ctrl + R: Sync Calendar
    if ((HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed) &&
        event.logicalKey == LogicalKeyboardKey.keyR) {
      _performSync();
    }
    // Cmd/Ctrl + N: Add Task
    else if ((HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed) &&
        event.logicalKey == LogicalKeyboardKey.keyN) {
      _openAddTaskDialog();
    }
    // R key alone: Sync Calendar
    else if (event.logicalKey == LogicalKeyboardKey.keyR && !isCtrlOrCmd) {
      _performSync();
    }
    // N key alone: Add Task
    else if (event.logicalKey == LogicalKeyboardKey.keyN && !isCtrlOrCmd) {
      _openAddTaskDialog();
    }
  }

  Future<void> _performSync() async {
    final CalendarController calendarCtrl = Get.find<CalendarController>();
    await calendarCtrl.fetchEvents();
    setState(() {
      lastSyncTime = DateTime.now();
    });

    if (!mounted) return;

    if (calendarCtrl.errorMessage.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.surfaceLight, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_getRoleAdaptiveText('sync_success')}: ${calendarCtrl.events.length} ${_getRoleAdaptiveText('items')}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: AppTheme.surfaceLight, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_getRoleAdaptiveText('sync_failed')}: ${calendarCtrl.errorMessage.value}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.accentRed,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _openAddTaskDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => const AddTaskDialog(),
    );
  }

  /// Get role-adaptive text based on current user's role
  String _getRoleAdaptiveText(String key) {
    final AuthController authCtrl = Get.find<AuthController>();
    final UserModel? user = authCtrl.currentUser.value;
    final UserRole? role = user?.role;

    // Role-adaptive terminology
    final Map<String, Map<UserRole, String>> roleAdaptiveTexts = {
      'sync_success': {
        UserRole.student: 'ดึงตารางเรียนสำเร็จ'.tr,
        UserRole.corporateEmployee: 'ซิงค์ปฏิทินงานสำเร็จ'.tr,
        UserRole.educator: 'ดึงตารางสอนสำเร็จ'.tr,
      },
      'sync_failed': {
        UserRole.student: 'ดึงตารางเรียนล้มเหลว'.tr,
        UserRole.corporateEmployee: 'ซิงค์ปฏิทินงานล้มเหลว'.tr,
        UserRole.educator: 'ดึงตารางสอนล้มเหลว'.tr,
      },
      'items': {
        UserRole.student: 'รายการเรียน'.tr,
        UserRole.corporateEmployee: 'นัดหมาย'.tr,
        UserRole.educator: 'บทเรียน'.tr,
      },
      'your_schedule': {
        UserRole.student: 'ตารางเรียนของคุณ'.tr,
        UserRole.corporateEmployee: 'ตารางงานของคุณ'.tr,
        UserRole.educator: 'ตารางสอนของคุณ'.tr,
      },
    };

    if (role != null && roleAdaptiveTexts.containsKey(key)) {
      return roleAdaptiveTexts[key]![role] ?? key.tr;
    }
    return key.tr;
  }

  String _getLastSyncText() {
    if (lastSyncTime == null) return 'ยังไม่เคยซิงค์'.tr;

    final Duration diff = DateTime.now().difference(lastSyncTime!);
    if (diff.inMinutes < 1) return 'เมื่อสักครู่'.tr;
    if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว'.tr;
    if (diff.inHours < 24) return '${diff.inHours} ชั่วโมงที่แล้ว'.tr;
    return '${diff.inDays} วันที่แล้ว'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final CalendarController calendarCtrl = Get.find<CalendarController>();
    final AuthController authCtrl = Get.find<AuthController>();
    final ProactiveController proactiveCtrl = Get.find<ProactiveController>();
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth >= 640;

    return KeyboardListener(
      focusNode: _dashboardFocus,
      onKeyEvent: _handleKeyPress,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Obx(() {
            final user = authCtrl.currentUser.value;
            return Text(
              user != null
                  ? _getRoleAdaptiveText('your_schedule')
                  : 'Dashboard',
              style: AppTheme.titleMedium,
            );
          }),
          centerTitle: false,
          actions: [
            // Help button with keyboard shortcuts reference
            IconButton(
              onPressed: _showKeyboardShortcutsDialog,
              icon: const Icon(Icons.help_outline, size: 22),
              color: AppTheme.textSecondary,
              tooltip: 'Keyboard Shortcuts',
            ),
            const SizedBox(width: 4),
            // Keyboard shortcut hint — desktop only
            if (isWide)
              Padding(
                padding: const EdgeInsets.only(right: AppTheme.space8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space8, vertical: AppTheme.space4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGray,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.keyboard_outlined,
                            size: 13, color: AppTheme.textTertiary),
                        SizedBox(width: AppTheme.space4),
                        Text(
                          'R: Sync  N: New',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.space16),
              child: Center(
                child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppTheme.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // AI Insights card — HERO: elevated size and prominence
                  Container(
                    constraints: const BoxConstraints(minHeight: 220),
                    child: AiInsightsCard(
                      proactiveController: proactiveCtrl,
                      authController: authCtrl,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space24),

                  // Stat cards — responsive: side-by-side on wide, stacked on narrow
                  isWide
                      ? const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: IncomingWorkCard()),
                            SizedBox(width: AppTheme.space16),
                            Expanded(child: WorkInWeekCard()),
                          ],
                        )
                      : const Column(
                          children: [
                            IncomingWorkCard(),
                            SizedBox(height: AppTheme.space12),
                            WorkInWeekCard(),
                          ],
                        ),

                  const SizedBox(height: AppTheme.space24),

                  // Calendar section with preparation coverage overlay
                  _buildCalendarContainer(calendarCtrl, proactiveCtrl),
                  const SizedBox(height: AppTheme.space80),
                ],
              ),
            ),
            ),
          ),

          // First-visit keyboard shortcut hint overlay
          if (_showKeyboardHint && isWide)
            Positioned(
              top: 80,
              right: 24,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(color: AppTheme.accentGreen, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.keyboard,
                              color: AppTheme.surfaceLight,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'ทางลัด',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _dismissKeyboardHint,
                            icon: const Icon(Icons.close, size: 20),
                            color: AppTheme.textSecondary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildShortcutRow('R', 'ซิงค์ตารางงาน'),
                      const SizedBox(height: 10),
                      _buildShortcutRow('N', 'เพิ่มงานใหม่'),
                      const SizedBox(height: 16),
                      const Text(
                        'หรือกด Cmd+R / Cmd+N บน Mac, Ctrl+R / Ctrl+N บน Windows',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _showKeyboardShortcutsDialog,
                        icon: const Icon(Icons.help_outline, size: 14),
                        label: const Text('ดูทางลัดทั้งหมด'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.accentGreen,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddTaskDialog,
          backgroundColor: AppTheme.accentGreen,
          foregroundColor: AppTheme.surfaceLight,
          elevation: 2,
          label: Text(
            'add_task'.tr,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          icon: const Icon(Icons.add, size: 20),
          tooltip: 'N หรือ Cmd+N',
        ),
      ),
    );
  }

  Widget _buildCalendarContainer(CalendarController calendarCtrl, ProactiveController proactiveCtrl) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.shadowCard,
      ),
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: role-adaptive title + sync button + timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getRoleAdaptiveText('your_schedule'),
                      style: AppTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.space4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_outlined,
                            size: 13, color: AppTheme.textTertiary),
                        const SizedBox(width: AppTheme.space4),
                        Obx(() => Text(
                              calendarCtrl.isLoading.value
                                  ? 'กำลังซิงค์...'
                                  : 'ซิงค์ล่าสุด: ${_getLastSyncText()}',
                              style: AppTheme.caption,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Obx(() => ElevatedButton.icon(
                    onPressed:
                        calendarCtrl.isLoading.value ? null : _performSync,
                    icon: calendarCtrl.isLoading.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.surfaceLight),
                          )
                        : const Icon(Icons.sync_rounded, size: 16),
                    label: Text(
                      calendarCtrl.isLoading.value ? 'กำลังซิงค์...' : 'ซิงค์',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      foregroundColor: AppTheme.surfaceLight,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.space12,
                          vertical: AppTheme.space8),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: AppTheme.space16),
          const Divider(height: 1, color: AppTheme.dividerColor),
          const SizedBox(height: AppTheme.space8),

          // Calendar widget with preparation coverage markers
          Obx(() {
            // Build map of dates with events and their preparation status
            final Map<DateTime, List<Map<String, dynamic>>> eventsWithPrepStatus = {};
            for (final event in calendarCtrl.events) {
              final eventDate = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);

              // Check if this event has an approved preparation plan
              final hasPrep = proactiveCtrl.proposals.any(
                (proposal) => proposal.event.id == event.id && proposal.status == PreparationStatus.approved
              );

              eventsWithPrepStatus.putIfAbsent(eventDate, () => []);
              eventsWithPrepStatus[eventDate]!.add({
                'event': event,
                'hasPrep': hasPrep,
              });
            }

            return TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: calendarCtrl.focusedDay.value,
              selectedDayPredicate: (DateTime day) =>
                  isSameDay(calendarCtrl.selectedDay.value, day),
              onDaySelected: (DateTime selectedDay, DateTime focusedDay) =>
                  calendarCtrl.selectDay(selectedDay, focusedDay),
              calendarBuilders: CalendarBuilders(
                // Custom marker builder to show preparation status
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;

                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  final dayEvents = eventsWithPrepStatus[normalizedDay] ?? [];

                  if (dayEvents.isEmpty) return null;

                  // Count events with and without preparation
                  final int withPrep = dayEvents.where((e) => e['hasPrep'] == true).length;
                  final int withoutPrep = dayEvents.length - withPrep;

                  return Positioned(
                    bottom: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Green dot: events WITH preparation plans
                        if (withPrep > 0)
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: const BoxDecoration(
                              color: AppTheme.accentGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        // Orange dot: events WITHOUT preparation plans
                        if (withoutPrep > 0)
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: const BoxDecoration(
                              color: AppTheme.accentOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: const BoxDecoration(
                  color: AppTheme.accentGreen,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.accentGreenDark,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                weekendTextStyle: const TextStyle(
                  color: AppTheme.accentGreenDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                todayTextStyle: const TextStyle(
                  color: AppTheme.surfaceLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                selectedTextStyle: const TextStyle(
                  color: AppTheme.surfaceLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                outsideTextStyle: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 13,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppTheme.accentGreen,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                markerSize: 5.0,
                cellMargin: const EdgeInsets.all(4),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                leftChevronIcon: Icon(Icons.chevron_left_rounded,
                    color: AppTheme.textPrimary, size: 22),
                rightChevronIcon: Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textPrimary, size: 22),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                weekendStyle: TextStyle(
                  color: AppTheme.accentGreenDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              eventLoader: (DateTime day) =>
                  calendarCtrl.getEventsForDay(day),
            );
          }),

          // Legend for preparation coverage markers
          const SizedBox(height: AppTheme.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                color: AppTheme.accentGreen,
                label: 'มีแผนเตรียมงาน',
              ),
              const SizedBox(width: AppTheme.space16),
              _buildLegendItem(
                color: AppTheme.accentOrange,
                label: 'ยังไม่มีแผน',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutRow(String key, String description) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.surfaceGray,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.borderStrong),
          ),
          child: Center(
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  void _showKeyboardShortcutsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.keyboard,
                    color: AppTheme.accentGreen,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Keyboard Shortcuts',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDialogShortcut('R', 'Cmd/Ctrl + R', 'ซิงค์ตารางงานจาก Google Calendar'),
              const SizedBox(height: 14),
              _buildDialogShortcut('N', 'Cmd/Ctrl + N', 'เปิดหน้าต่างเพิ่มงานใหม่'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppTheme.textSecondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ทางลัดเหล่านี้ทำงานเมื่อคุณอยู่ที่หน้า Dashboard',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogShortcut(String solo, String combo, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceGray,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.borderStrong),
          ),
          child: Text(
            solo,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'หรือ',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textTertiary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceGray,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.borderStrong),
          ),
          child: Text(
            combo,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
