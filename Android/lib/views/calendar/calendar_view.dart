import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/calendar_controller.dart';
import '../../controllers/auth_controller.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final calCtrl = Get.put(CalendarController());
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFCFD8DC),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCalendar(calCtrl),
            const SizedBox(height: 20),
            Obx(() {
              if (authCtrl.currentUser.value == null) {
                return _buildSignInSection(authCtrl);
              }
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF757575),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Synced with Google Calendar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(CalendarController calCtrl) {
    return Obx(() => Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: const Color(0xFFCFD8DC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                      onPressed: () {},
                    ),
                    const Text(
                      'Calendar 2026 (month)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                color: const Color(0xFFCFD8DC),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: calCtrl.focusedDay.value,
                  selectedDayPredicate: (day) => isSameDay(calCtrl.selectedDay.value, day),
                  onDaySelected: (selected, focused) => calCtrl.selectDay(selected, focused),
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFF2196F3),
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(color: Colors.black),
                    weekendTextStyle: TextStyle(color: Colors.black),
                  ),
                  headerVisible: false,
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    weekendStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildSignInSection(AuthController authCtrl) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF757575),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () => authCtrl.signInWithGoogle(),
          icon: Container(
            width: 32,
            height: 32,
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
              child: Text(
                'G',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          label: const Text(
            'Sign in Google Calendar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

