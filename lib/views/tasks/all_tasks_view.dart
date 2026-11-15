/// lib/views/tasks/all_tasks_view.dart
/// All Tasks View with View All and Delete All functionality

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../theme/app_theme.dart';
import 'tasks_detail_view.dart';
import 'package:intl/intl.dart';
import '../../utils/dialog_utils.dart';

class AllTasksView extends StatelessWidget {
  const AllTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskCtrl = Get.find<TaskController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('All Tasks'),
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, size: 20),
            onPressed: () => _confirmDeleteAll(context, taskCtrl),
            tooltip: 'Delete All Tasks',
          ),
        ],
      ),
      body: Obx(() {
        final tasks = taskCtrl.tasks;
        if (tasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No tasks yet', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }

        final pending = tasks.where((t) => !t.isDone).toList();
        final completed = tasks.where((t) => t.isDone).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(tasks.length.toString(), 'Total'),
                  _buildStat(pending.length.toString(), 'Pending'),
                  _buildStat(completed.length.toString(), 'Done'),
                ],
              ),
            ),
            if (pending.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Pending Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...pending.map((task) => _buildTaskCard(context, task)),
            ],
            if (completed.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Completed Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...completed.map((task) => _buildTaskCard(context, task)),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label.tr, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(task.isDone ? Icons.check_circle : Icons.radio_button_unchecked),
        title: Text(task.title),
        subtitle: task.dueDate != null ? Text(DateFormat('MMM d, yyyy').format(task.dueDate!)) : null,
        trailing: Text(task.priority),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDetailView(task: task)));
        },
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, TaskController taskCtrl) {
    final taskCount = taskCtrl.tasks.length;
    if (taskCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No tasks to delete')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Tasks'),
        content: Text('Delete all $taskCount tasks? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await taskCtrl.deleteAllTasks();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted $taskCount tasks')));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
