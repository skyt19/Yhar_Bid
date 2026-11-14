/// lib/views/calendar/calendar_view.dart
/// Calendar Screen — Month view, upcoming events, day detail
/// Operate mode: warm neutral, green accent, clean scan-first layout
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../controllers/calendar_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/proactive_controller.dart';
import '../../models/calendar_event_model.dart';
import '../theme/app_theme.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final calCtrl = Get.put(CalendarController());
    final authCtrl = Get.find<AuthController>();
    final proactiveCtrl = Get.put(ProactiveController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppTheme.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCalendar(calCtrl),
                  const SizedBox(height: AppTheme.space20),
                  Obx(() {
                    if (authCtrl.currentUser.value == null) {
                      return _buildSignInSection(authCtrl);
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildWeeklySummaryCard(calCtrl),
                        const SizedBox(height: AppTheme.space16),
                        _buildUpcomingEventsCard(calCtrl, proactiveCtrl),
                        const SizedBox(height: AppTheme.space16),
                        _buildSelectedDayCard(calCtrl, proactiveCtrl),
                      ],
                    );
                  }),
                  const SizedBox(height: AppTheme.space80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Calendar widget ──────────────────────────────────────────────────────

  Widget _buildCalendar(CalendarController calCtrl) {
    return Obx(() => Container(
          decoration: AppTheme.cardDecoration,
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: calCtrl.focusedDay.value,
            selectedDayPredicate: (day) =>
                isSameDay(calCtrl.selectedDay.value, day),
            onDaySelected: (selected, focused) =>
                calCtrl.selectDay(selected, focused),
            onPageChanged: (focused) => calCtrl.focusedDay.value = focused,
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
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              weekendTextStyle: const TextStyle(
                color: AppTheme.accentGreenDark,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              todayTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
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
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              headerPadding: const EdgeInsets.symmetric(
                  vertical: AppTheme.space12,
                  horizontal: AppTheme.space16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLarge),
                  topRight: Radius.circular(AppTheme.radiusLarge),
                ),
              ),
              titleTextStyle: AppTheme.titleSmall,
              leftChevronIcon: const Icon(
                Icons.chevron_left_rounded,
                color: AppTheme.textSecondary,
                size: 22,
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
                size: 22,
              ),
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
            eventLoader: (day) =>
                calCtrl.events.where((e) => isSameDay(e.startTime, day)).toList(),
          ),
        ));
  }

  // ─── Weekly summary ───────────────────────────────────────────────────────

  Widget _buildWeeklySummaryCard(CalendarController calCtrl) {
    return Obx(() {
      final now = DateTime.now();
      final weekLater = now.add(const Duration(days: 7));
      final weekEvents = calCtrl.events
          .where((e) => e.startTime.isAfter(now) && e.startTime.isBefore(weekLater))
          .toList();
      final adherence = calCtrl.calendarComplianceRate.value * 100;

      return Container(
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded,
                    size: 18, color: AppTheme.accentGreen),
                const SizedBox(width: AppTheme.space8),
                Text('งานในสัปดาห์นี้', style: AppTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppTheme.space16),
            Row(
              children: [
                Expanded(
                    child: _metricTile(
                        'ทั้งหมด', weekEvents.length.toString(),
                        AppTheme.accentGreen)),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                    child: _metricTile(
                        'รอดำเนินการ', weekEvents.length.toString(),
                        AppTheme.accentOrange)),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                    child: _metricTile(
                        'ทำตามแผน', '${adherence.toStringAsFixed(0)}%',
                        AppTheme.statusSuccess)),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _metricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space12, vertical: AppTheme.space12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'NotoSansThai',
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          Text(label, style: AppTheme.caption),
        ],
      ),
    );
  }

  // ─── Upcoming events ──────────────────────────────────────────────────────

  Widget _buildUpcomingEventsCard(
      CalendarController calCtrl, ProactiveController proactiveCtrl) {
    return Obx(() {
      final now = DateTime.now();
      final twoWeeks = now.add(const Duration(days: 14));
      final upcoming = calCtrl.events
          .where((e) => e.startTime.isAfter(now) && e.startTime.isBefore(twoWeeks))
          .toList();

      return Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.space16,
                  AppTheme.space16, AppTheme.space16, AppTheme.space12),
              child: Row(
                children: [
                  const Icon(Icons.event_note_rounded,
                      size: 18, color: AppTheme.accentGreen),
                  const SizedBox(width: AppTheme.space8),
                  Text('งานที่กำลังจะมาถึง', style: AppTheme.titleSmall),
                  const Spacer(),
                  if (upcoming.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.space8, vertical: AppTheme.space2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      ),
                      child: Text(
                        '${upcoming.length} งาน',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentGreenDark,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.dividerColor,
                indent: AppTheme.space16, endIndent: AppTheme.space16),

            // Content
            if (upcoming.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppTheme.space32),
                child: Center(
                  child: Text(
                    'ไม่มีงานที่กำลังจะมาถึง',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTheme.space12),
                itemCount: upcoming.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppTheme.space8),
                itemBuilder: (context, i) =>
                    _eventListTile(upcoming[i], proactiveCtrl),
              ),
          ],
        ),
      );
    });
  }

  Widget _eventListTile(
      CalendarEventModel event, ProactiveController proactiveCtrl) {
    final df = DateFormat('dd/MM HH:mm');
    return Container(
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Green accent bar
              Container(
                width: 3,
                height: 36,
                margin: const EdgeInsets.only(right: AppTheme.space12, top: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: AppTheme.titleSmall),
                    const SizedBox(height: AppTheme.space2),
                    Text(df.format(event.startTime),
                        style: AppTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          if (!event.isReadOnly) ...[
            const SizedBox(height: AppTheme.space8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    proactiveCtrl.runProactiveScan(specificEventId: event.id),
                icon: const Icon(Icons.auto_awesome_rounded, size: 14),
                label: const Text('ให้ AI เตรียมงาน',
                    style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentGreen,
                  side: const BorderSide(
                      color: AppTheme.accentGreen, width: 1.0),
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.space6),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                ),
              ),
            ),
          ] else
            Container(
              margin: const EdgeInsets.only(top: AppTheme.space8),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space8, vertical: AppTheme.space4),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppTheme.radiusXS),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_busy_rounded,
                      size: 12, color: AppTheme.accentOrange),
                  SizedBox(width: AppTheme.space4),
                  Text(
                    'วันหยุด / อ่านอย่างเดียว',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.accentOrange,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─── Selected day events ──────────────────────────────────────────────────

  Widget _buildSelectedDayCard(
      CalendarController calCtrl, ProactiveController proactiveCtrl) {
    return Obx(() {
      final selected = calCtrl.selectedDay.value;
      final dayEvents = calCtrl.getEventsForDay(selected);
      if (dayEvents.isEmpty) return const SizedBox.shrink();

      final hdr = DateFormat('EEE, d MMM yyyy');
      final tf = DateFormat('HH:mm');

      return Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.space16,
                  AppTheme.space16, AppTheme.space16, AppTheme.space12),
              child: Row(
                children: [
                  const Icon(Icons.today_rounded,
                      size: 18, color: AppTheme.accentGreen),
                  const SizedBox(width: AppTheme.space8),
                  Expanded(
                    child: Text(hdr.format(selected), style: AppTheme.titleSmall),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space8, vertical: AppTheme.space2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: Text(
                      '${dayEvents.length} งาน',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentGreenDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.dividerColor,
                indent: AppTheme.space16, endIndent: AppTheme.space16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppTheme.space12),
              itemCount: dayEvents.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppTheme.dividerColor),
              itemBuilder: (context, i) {
                final e = dayEvents[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.space8),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 32,
                        margin: const EdgeInsets.only(right: AppTheme.space12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: Text(e.title, style: AppTheme.titleSmall),
                      ),
                      Text(tf.format(e.startTime),
                          style: AppTheme.bodySmall),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  // ─── Sign-in section ──────────────────────────────────────────────────────

  Widget _buildSignInSection(AuthController authCtrl) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space32),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          const Icon(Icons.calendar_month_outlined,
              size: 48, color: AppTheme.textTertiary),
          const SizedBox(height: AppTheme.space12),
          const Text(
            'เชื่อมต่อ Google Calendar',
            style: AppTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.space8),
          const Text(
            'เข้าสู่ระบบเพื่อดูและซิงค์ปฏิทินของคุณ',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.space20),
          ElevatedButton.icon(
            onPressed: () => authCtrl.signInWithGoogle(),
            icon: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4285F4),
                    Color(0xFFEA4335),
                    Color(0xFFFBBC05),
                    Color(0xFF34A853),
                  ],
                ),
              ),
              child: const Center(
                child: Text('G',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            label: const Text('เข้าสู่ระบบด้วย Google'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space24, vertical: AppTheme.space12),
            ),
          ),
        ],
      ),
    );
  }
}
