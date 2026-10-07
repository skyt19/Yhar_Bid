import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskCtrl = Get.put(TaskController());

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
                const Text('Tasks & Projects', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC))),
                ElevatedButton.icon(
                  onPressed: () => _showAddTaskDialog(taskCtrl),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Task', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Obx(() => _buildFilterChips(taskCtrl)),
            const SizedBox(height: 16),
            Expanded(child: Obx(() => _buildTasksList(taskCtrl))),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(TaskController taskCtrl) {
    return Row(
      children: [
        FilterChip(label: const Text('All', style: TextStyle(fontSize: 13)), selected: true, onSelected: (_) {}, backgroundColor: const Color(0xFF334155), selectedColor: const Color(0xFF38BDF8), labelStyle: const TextStyle(color: Color(0xFFF8FAFC))),
        const SizedBox(width: 8),
        FilterChip(label: const Text('Pending', style: TextStyle(fontSize: 13)), selected: false, onSelected: (_) {}, backgroundColor: const Color(0xFF334155), labelStyle: const TextStyle(color: Color(0xFFF8FAFC))),
        const SizedBox(width: 8),
        FilterChip(label: const Text('Completed', style: TextStyle(fontSize: 13)), selected: false, onSelected: (_) {}, backgroundColor: const Color(0xFF334155), labelStyle: const TextStyle(color: Color(0xFFF8FAFC))),
      ],
    );
  }

  Widget _buildTasksList(TaskController taskCtrl) {
    if (taskCtrl.isLoading.value) return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
    if (taskCtrl.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.task_alt, color: Color(0xFF64748B), size: 64),
            const SizedBox(height: 16),
            const Text('No tasks yet', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
            const SizedBox(height: 8),
            TextButton.icon(onPressed: () => taskCtrl.fetchTasks(), icon: const Icon(Icons.refresh), label: const Text('Load Tasks')),
          ],
        ),
      );
    }
    return ListView.builder(itemCount: taskCtrl.tasks.length, itemBuilder: (c, i) => _buildTaskCard(taskCtrl.tasks[i], taskCtrl));
  }



  Widget _buildTaskCard(TaskModel task, TaskController taskCtrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
      child: Row(
        children: [
          Checkbox(value: task.isDone, onChanged: (v) => taskCtrl.toggleTaskStatus(task), activeColor: const Color(0xFF4FD1C5)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: task.isDone ? const Color(0xFF64748B) : const Color(0xFFF8FAFC), decoration: task.isDone ? TextDecoration.lineThrough : null)),
                if (task.description.isNotEmpty) ...[const SizedBox(height: 4), Text(task.description, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)), maxLines: 2, overflow: TextOverflow.ellipsis)],
                if (task.dueDate != null) ...[const SizedBox(height: 8), Row(children: [const Icon(Icons.calendar_today, color: Color(0xFF94A3B8), size: 14), const SizedBox(width: 4), Text(_formatDate(task.dueDate!), style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))])],
              ],
            ),
          ),
          IconButton(onPressed: () => _showEditTaskDialog(task, taskCtrl), icon: const Icon(Icons.edit, color: Color(0xFF4FD1C5), size: 20)),
          IconButton(onPressed: () => _confirmDeleteTask(task, taskCtrl), icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 20)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  void _showAddTaskDialog(TaskController taskCtrl) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text('New Task', style: TextStyle(color: Color(0xFFF8FAFC))),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Task Title', labelStyle: TextStyle(color: Color(0xFF94A3B8)), border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))))),
        const SizedBox(height: 16),
        TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), maxLines: 3, decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Color(0xFF94A3B8)), border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8)))),
        ElevatedButton(onPressed: () async { if (titleCtrl.text.trim().isNotEmpty) { Get.back(); await taskCtrl.addTask(title: titleCtrl.text.trim(), description: descCtrl.text.trim()); } }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)), child: const Text('Add Task')),
      ],
    ));
  }

  void _showEditTaskDialog(TaskModel task, TaskController taskCtrl) {
    final titleCtrl = TextEditingController(text: task.title);
    final descCtrl = TextEditingController(text: task.description);
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text('Edit Task', style: TextStyle(color: Color(0xFFF8FAFC))),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Task Title', labelStyle: TextStyle(color: Color(0xFF94A3B8)), border: OutlineInputBorder())),
        const SizedBox(height: 16),
        TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), maxLines: 3, decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Color(0xFF94A3B8)), border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { Get.back(); Get.snackbar('Success', 'Task updated', snackPosition: SnackPosition.BOTTOM); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)), child: const Text('Update')),
      ],
    ));
  }

  void _confirmDeleteTask(TaskModel task, TaskController taskCtrl) {
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text('Delete Task', style: TextStyle(color: Color(0xFFF8FAFC))),
      content: Text('Delete "${task.title}"?', style: const TextStyle(color: Color(0xFF94A3B8))),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { Get.back(); taskCtrl.deleteTask(task); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)), child: const Text('Delete')),
      ],
    ));
  }
}
