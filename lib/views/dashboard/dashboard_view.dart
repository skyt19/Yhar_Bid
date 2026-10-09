import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/calendar_controller.dart';
import '../../controllers/auth_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});
  
  @override
  Widget build(BuildContext context) {
    final calCtrl = Get.find<CalendarController>();
    final authCtrl = Get.find<AuthController>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildTaskCard('(task)', '(Time)', true),
                    const SizedBox(height: 12),
                    _buildIncomingWorkSection(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _buildTaskCard('(task)', '(Time)', true),
                    const SizedBox(height: 12),
                    _buildWeekTaskCard(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalendarApiSection(calCtrl, authCtrl),
        ],
      ),
    );
  }

  Widget _buildTaskCard(String title, String timeLabel, bool isToggled) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF9E9E9E), width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(timeLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
              _buildToggleSwitch(isToggled),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch(bool value) {
    return Container(
      width: 56,
      height: 30,
      decoration: BoxDecoration(
        color: value ? const Color(0xFF4CAF50) : const Color(0xFFBDBDBD),
        borderRadius: BorderRadius.circular(15),
      ),
      child: AnimatedAlign(
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: 26,
          height: 26,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildIncomingWorkSection() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF757575),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF616161), width: 3),
      ),
      child: const Center(
        child: Text('Incoming Work\n(On Day)', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, height: 1.5)),
      ),
    );
  }

  Widget _buildWeekTaskCard() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF757575),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF616161), width: 3),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('word in week (task)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('(Time)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                    _buildToggleSwitch(true),
                  ],
                ),
              ],
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildCalendarApiSection(CalendarController calCtrl, AuthController authCtrl) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF757575),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF616161), width: 3),
      ),
      child: const Center(
        child: Text('Calendar API', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );
  }
}
