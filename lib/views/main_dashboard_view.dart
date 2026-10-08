/// lib/views/main_dashboard_view.dart
/// [Mockup 3_Main.jpg] — หน้า Dashboard หลัก: 2 Card บน + Calendar API Container ใหญ่ด้านล่าง
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/habit_controller.dart';
import '../controllers/ai_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/calendar_event_model.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/incoming_work_card.dart';
import 'widgets/work_in_week_card.dart';
import 'calendar_view.dart';
import 'habit_tracker_view.dart';
import 'settings_view.dart';
import 'package:intl/intl.dart';

class MainDashboardView extends StatefulWidget {
  const MainDashboardView({super.key});
  @override
  State<MainDashboardView> createState() => _MainDashboardViewState();
}

class _MainDashboardViewState extends State<MainDashboardView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CalendarController>()) Get.put<CalendarController>(CalendarController());
    if (!Get.isRegistered<HabitController>()) Get.put<HabitController>(HabitController());
    if (!Get.isRegistered<AiController>()) Get.put<AiController>(AiController());
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      _buildDashboardHome(),
      const CalendarView(),
      const HabitTrackerView(),
      const SettingsView(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (int index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildDashboardHome() {
    final CalendarController calendarCtrl = Get.find<CalendarController>();
    final AuthController authCtrl = Get.find<AuthController>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header
            Obx(() => Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: authCtrl.currentUser.value?.photoUrl != null &&
                              authCtrl.currentUser.value!.photoUrl.isNotEmpty
                          ? NetworkImage(authCtrl.currentUser.value!.photoUrl)
                          : null,
                      backgroundColor: AppTheme.accentPrimary,
                      child: authCtrl.currentUser.value?.photoUrl == null ||
                              authCtrl.currentUser.value!.photoUrl.isEmpty
                          ? const Icon(Icons.person, color: Colors.white, size: 28)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('welcome_back'.tr,
                              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                          Text(authCtrl.currentUser.value?.displayName ?? 'User',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 20),

            // Two Cards
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: IncomingWorkCard()),
                      SizedBox(width: 16),
                      Expanded(child: WorkInWeekCard()),
                    ],
                  );
                } else {
                  return const Column(
                    children: <Widget>[
                      IncomingWorkCard(),
                      SizedBox(height: 16),
                      WorkInWeekCard(),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // Calendar API Container
            _buildCalendarContainer(calendarCtrl),
          ],
        ),
      ),
    );
  }


  Widget _buildCalendarContainer(CalendarController calendarCtrl) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.calendar_today, color: AppTheme.accentPrimary, size: 24),
              const SizedBox(width: 8),
              Text('calendar_api'.tr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),

          Obx(() => TableCalendar<CalendarEventModel>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: calendarCtrl.focusedDay.value,
                selectedDayPredicate: (DateTime day) => isSameDay(calendarCtrl.selectedDay.value, day),
                onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                  calendarCtrl.selectedDay.value = selectedDay;
                  calendarCtrl.focusedDay.value = focusedDay;
                },
                eventLoader: (DateTime day) {
                  return calendarCtrl.events
                      .where((CalendarEventModel event) => isSameDay(event.startTime, day))
                      .toList();
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.accentPrimary.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.accentPrimary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppTheme.accentSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              )),

          const SizedBox(height: 16),

          Obx(() {
            final List<CalendarEventModel> dayEvents = calendarCtrl.events
                .where((CalendarEventModel event) => isSameDay(event.startTime, calendarCtrl.selectedDay.value))
                .toList();

            if (dayEvents.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('no_events'.tr,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dayEvents.length,
              itemBuilder: (BuildContext context, int index) => _buildEventCard(dayEvents[index]),
            );
          }),

          const SizedBox(height: 16),

          _buildActionButtons(calendarCtrl),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CalendarController calendarCtrl) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showAddEventDialog(context, calendarCtrl),
            icon: const Icon(Icons.add, size: 20),
            label: Text('add_appointment'.tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accentPrimary,
              side: const BorderSide(color: AppTheme.accentPrimary),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() => ElevatedButton.icon(
                onPressed: calendarCtrl.isLoading.value ? null : () => _syncCalendar(calendarCtrl),
                icon: calendarCtrl.isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.sync, size: 20),
                label: Text('sync_calendar'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentSecondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              )),
        ),
      ],
    );
  }




  Widget _buildEventCard(CalendarEventModel event) {
    final DateFormat timeFormat = DateFormat('HH:mm');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.accentPrimary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(color: AppTheme.accentPrimary, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(event.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                if (event.description != null && event.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(event.description!,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          Text(timeFormat.format(event.startTime),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.accentPrimary)),
        ],
      ),
    );
  }

  Future<void> _syncCalendar(CalendarController calendarCtrl) async {
    await calendarCtrl.fetchEvents();
    if (calendarCtrl.errorMessage.value.isEmpty) {
      Get.snackbar('calendar_synced'.tr, '${calendarCtrl.events.length} รายการ',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.accentSecondary,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
    } else {
      Get.snackbar('error'.tr, calendarCtrl.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showAddEventDialog(BuildContext context, CalendarController calendarCtrl) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    DateTime selectedStart = calendarCtrl.selectedDay.value;
    DateTime selectedEnd = selectedStart.add(const Duration(hours: 1));

    Get.dialog(
      AlertDialog(
        title: Text('add_appointment'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'event_title'.tr, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'event_description'.tr, border: const OutlineInputBorder()),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                Get.snackbar('error'.tr, 'กรุณาใส่ชื่อกิจกรรม', snackPosition: SnackPosition.BOTTOM);
                return;
              }

              final bool success = await calendarCtrl.createEvent(
                title: titleController.text.trim(),
                startTime: selectedStart,
                endTime: selectedEnd,
                description: descController.text.trim(),
              );

              Get.back();

              if (success) {
                Get.snackbar('success'.tr, 'event_created'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppTheme.accentSecondary,
                    colorText: Colors.white);
              } else {
                Get.snackbar('error'.tr, calendarCtrl.errorMessage.value,
                    snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPrimary),
            child: Text('add'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
