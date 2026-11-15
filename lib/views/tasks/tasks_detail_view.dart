/// lib/views/tasks/tasks_detail_view.dart
/// Task Details View - Phase 7: View individual task details

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/task_model.dart';
import '../../controllers/task_controller.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class TaskDetailView extends StatelessWidget {
  final TaskModel task;

  const TaskDetailView({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskCtrl = Get.find<TaskController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _confirmDelete(context, taskCtrl);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Status
            _buildInfoRow(
              Icons.check_circle_outline,
              'Status',
              task.isDone ? 'Completed' : 'Pending',
              task.isDone ? Colors.green : Colors.orange,
            ),

            // Priority
            _buildInfoRow(
              Icons.flag_outlined,
              'Priority',
              task.priority,
              _getPriorityColor(task.priority),
            ),

            // Due Date
            if (task.dueDate != null)
              _buildInfoRow(
                Icons.calendar_today_outlined,
                'Due Date',
                DateFormat('MMM d, yyyy').format(task.dueDate!),
                task.dueDate!.isBefore(DateTime.now()) && !task.isDone
                    ? Colors.red
                    : AppTheme.textPrimary,
              ),

            // Category
            if (task.category != null)
              _buildInfoRow(
                Icons.label_outline,
                'Category',
                task.category!,
                AppTheme.textPrimary,
              ),

            // Created Date
            _buildInfoRow(
              Icons.schedule_outlined,
              'Created',
              DateFormat('MMM d, yyyy HH:mm').format(task.createdAt),
              AppTheme.textSecondary,
            ),

            const SizedBox(height: 24),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Text(
                task.description,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),

            const SizedBox(height: 32),

            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await taskCtrl.toggleTaskStatus(task);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: task.isDone
                      ? Colors.orange
                      : AppTheme.accentGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: Text(
                  task.isDone ? 'Mark as Pending' : 'Mark as Completed',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return AppTheme.textPrimary;
    }
  }

  void _confirmDelete(BuildContext context, TaskController taskCtrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              taskCtrl.deleteTask(task.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail view
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
