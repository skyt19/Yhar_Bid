import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/calendar_controller.dart';
import '../../models/calendar_event_model.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final calCtrl = Get.put(CalendarController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Calendar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC))),
                Row(
                  children: [
                    ElevatedButton.icon(onPressed: () => _showAddEventDialog(calCtrl), icon: const Icon(Icons.add, size: 18), label: const Text('Add Event'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.white)),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(onPressed: () => calCtrl.fetchEvents(), icon: const Icon(Icons.sync, size: 18), label: const Text('Sync'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FD1C5), foregroundColor: Colors.white)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildCalendar(calCtrl)),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: Obx(() => _buildEventsList(calCtrl))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(CalendarController calCtrl) {
    return Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF334155))),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: calCtrl.focusedDay.value,
            selectedDayPredicate: (day) => isSameDay(calCtrl.selectedDay.value, day),
            onDaySelected: (selected, focused) => calCtrl.selectDay(selected, focused),
            calendarStyle: const CalendarStyle(todayDecoration: BoxDecoration(color: Color(0xFF4FD1C5), shape: BoxShape.circle), selectedDecoration: BoxDecoration(color: Color(0xFF38BDF8), shape: BoxShape.circle), defaultTextStyle: TextStyle(color: Color(0xFFF8FAFC)), weekendTextStyle: TextStyle(color: Color(0xFF94A3B8))),
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: TextStyle(color: Color(0xFFF8FAFC), fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ));
  }

  Widget _buildEventsList(CalendarController calCtrl) {
    if (calCtrl.isLoading.value) return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
    final selectedEvents = calCtrl.events.where((event) => isSameDay(event.startTime, calCtrl.selectedDay.value)).toList();
    if (selectedEvents.isEmpty) {
      return Container(padding: const EdgeInsets.all(48), decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('No events for this day', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16))));
    }
    return Column(children: selectedEvents.map((event) => _buildEventCard(event, calCtrl)).toList());
  }

  Widget _buildEventCard(CalendarEventModel event, CalendarController calCtrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
      child: Row(
        children: [
          Container(width: 4, height: 60, decoration: BoxDecoration(color: const Color(0xFF38BDF8), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFF8FAFC))),
                const SizedBox(height: 4),
                Text('${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}', style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                if (event.description?.isNotEmpty ?? false) ...[const SizedBox(height: 8), Text(event.description ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)), maxLines: 2, overflow: TextOverflow.ellipsis)],
              ],
            ),
          ),
          IconButton(onPressed: () => _showEditEventDialog(event, calCtrl), icon: const Icon(Icons.edit, color: Color(0xFF4FD1C5), size: 20)),
          IconButton(onPressed: () => _confirmDeleteEvent(event, calCtrl), icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 20)),
        ],
      ),
    );
  }



  void _showAddEventDialog(CalendarController calCtrl) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text('Add New Event', style: TextStyle(color: Color(0xFFF8FAFC))),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Event Title', labelStyle: TextStyle(color: Color(0xFF94A3B8)), border: OutlineInputBorder())),
        const SizedBox(height: 16),
        TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), maxLines: 3, decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Color(0xFF94A3B8)), border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async { if (titleCtrl.text.trim().isNotEmpty) { Get.back(); await calCtrl.addEvent(title: titleCtrl.text.trim(), description: descCtrl.text.trim(), startTime: calCtrl.selectedDay.value, endTime: calCtrl.selectedDay.value.add(const Duration(hours: 1))); } }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)), child: const Text('Save')),
      ],
    ));
  }

  void _showEditEventDialog(CalendarEventModel event, CalendarController calCtrl) {
    final titleCtrl = TextEditingController(text: event.title);
    final descCtrl = TextEditingController(text: event.description);
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text('Edit Event', style: TextStyle(color: Color(0xFFF8FAFC))),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Event Title', labelStyle: TextStyle(color: Color(0xFF94A3B8)), border: OutlineInputBorder())),
        const SizedBox(height: 16),
        TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), maxLines: 3, decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Color(0xFF94A3B8)), border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { Get.back(); calCtrl.updateEvent(eventId: event.id, title: titleCtrl.text.trim(), description: descCtrl.text.trim()); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)), child: const Text('Update')),
      ],
    ));
  }

  void _confirmDeleteEvent(CalendarEventModel event, CalendarController calCtrl) {
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text('Delete Event', style: TextStyle(color: Color(0xFFF8FAFC))),
      content: Text('Are you sure you want to delete "${event.title}"?', style: const TextStyle(color: Color(0xFF94A3B8))),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { Get.back(); calCtrl.deleteEvent(event.id); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)), child: const Text('Delete')),
      ],
    ));
  }
}

  String _formatTime(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
