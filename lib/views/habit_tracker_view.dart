library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/task_controller.dart';
import 'theme/app_theme.dart';
import 'ai_chatbot_view.dart';

class HabitTrackerView extends StatefulWidget {
  const HabitTrackerView({super.key});
  @override
  State<HabitTrackerView> createState() => _HabitTrackerViewState();
}

class _HabitTrackerViewState extends State<HabitTrackerView> {
  int _selectedTab = 0;
  @override
  void initState() {
    super.initState();
    Get.find<TaskController>().fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('จัดการงาน', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog)],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(child: _tabBtn(0, 'ปฏิทิน')),
                Expanded(child: _tabBtn(1, 'งานของฉัน')),
              ],
            ),
          ),
          Expanded(child: _selectedTab == 0 ? _calendarTab() : _tasksTab()),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => Get.to(() => const AiChatbotView()),
              icon: const Icon(Icons.chat),
              label: const Text('Talk with Chatbot'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.accentSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(int idx, String label) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = idx),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _selectedTab == idx ? AppTheme.accentPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: _selectedTab == idx ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget _calendarTab() {
    final CalendarController calCtrl = Get.find<CalendarController>();
    return Obx(() {
      if (calCtrl.isLoading.value) return const Center(child: CircularProgressIndicator());
      if (calCtrl.events.isEmpty) return const Center(child: Text('ไม่มีกิจกรรม'));
      final events = calCtrl.events.where((e) => e.startTime.isAfter(DateTime.now())).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, i) => Card(
          child: ListTile(
            leading: const Icon(Icons.event),
            title: Text(events[i].title),
            subtitle: Text(DateFormat('MMM d, HH:mm').format(events[i].startTime)),
          ),
        ),
      );
    });
  }

  Widget _tasksTab() {
    final TaskController taskCtrl = Get.find<TaskController>();
    return Obx(() {
      if (taskCtrl.isLoading.value) return const Center(child: CircularProgressIndicator());
      if (taskCtrl.tasks.isEmpty) return const Center(child: Text('ไม่มีงาน'));
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: taskCtrl.tasks.length,
        itemBuilder: (context, i) => Card(
          child: ListTile(
            leading: Checkbox(value: taskCtrl.tasks[i].isDone, onChanged: (_) => taskCtrl.toggleTaskStatus(taskCtrl.tasks[i])),
            title: Text(taskCtrl.tasks[i].title, style: TextStyle(decoration: taskCtrl.tasks[i].isDone ? TextDecoration.lineThrough : null)),
            subtitle: taskCtrl.tasks[i].dueDate != null ? Text(DateFormat('MMM d, yyyy').format(taskCtrl.tasks[i].dueDate!)) : null,
            trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => taskCtrl.deleteTask(taskCtrl.tasks[i].id)),
          ),
        ),
      );
    });
  }

  void _showAddDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isNotEmpty) {
                await Get.find<TaskController>().addTask(title: ctrl.text);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
