import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/proactive_controller.dart';
import '../../models/task_model.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskCtrl = Get.put(TaskController());
    final proactiveCtrl = Get.find<ProactiveController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      appBar: AppBar(
        title: const Text('งานทั้งหมด'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => _showAddTaskDialog(context, taskCtrl),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('เพิ่มงาน', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildFilterChips(taskCtrl),
          const SizedBox(height: 8),
          Expanded(child: _buildTasksList(taskCtrl, proactiveCtrl)),
        ],
      ),
    );
  }

  Widget _buildFilterChips(TaskController taskCtrl) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('ทั้งหมด', 'all', taskCtrl),
              const SizedBox(width: 8),
              _buildFilterChip('รอดำเนินการ', 'pending', taskCtrl),
              const SizedBox(width: 8),
              _buildFilterChip('เสร็จแล้ว', 'completed', taskCtrl),
            ],
          ),
        ));
  }

  Widget _buildFilterChip(String label, String value, TaskController taskCtrl) {
    final isSelected = taskCtrl.selectedFilter.value == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => taskCtrl.selectedFilter.value = value,
      backgroundColor: const Color(0xFF1E293B),
      selectedColor: AppTheme.accentGreen,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildTasksList(TaskController taskCtrl, ProactiveController proactiveCtrl) {
    return Obx(() {
      final tasks = taskCtrl.filteredTasks;

      if (tasks.isEmpty) {
        return const Center(
          child: Text(
            'ไม่มีงานในขณะนี้',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return _buildTaskCard(tasks[index], taskCtrl, proactiveCtrl, context);
        },
      );
    });
  }

  Widget _buildTaskCard(TaskModel task, TaskController taskCtrl, ProactiveController proactiveCtrl, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: task.isDone,
                  onChanged: (val) {
                    if (val != null) {
                      taskCtrl.toggleTaskStatus(task);
                    }
                  },
                  activeColor: AppTheme.accentGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (task.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            task.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildPriorityBadge(task.priority),
              ],
            ),
            const SizedBox(height: 8),
            _buildFileStatusTimer(task),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => taskCtrl.downloadTaskOutline(task),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('ดาวน์โหลดโครงร่าง'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    proactiveCtrl.runProactiveScan();
                    Get.snackbar(
                      'สร้างใหม่',
                      'กำลังสร้างงานใหม่...',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: AppTheme.accentOrange,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('สร้างใหม่'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentOrange,
                    side: BorderSide(color: AppTheme.accentOrange.withValues(alpha: 0.5)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmDialog(context, task, taskCtrl),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color badgeColor;
    switch (priority.toLowerCase()) {
      case 'high':
        badgeColor = AppTheme.accentRed;
        break;
      case 'medium':
        badgeColor = AppTheme.accentOrange;
        break;
      case 'low':
      default:
        badgeColor = AppTheme.accentGreen;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFileStatusTimer(TaskModel task) {
    final now = DateTime.now();
    String timerText;
    Color timerColor;

    if (task.firstDownloadedAt == null) {
      final createdAt = task.createdAt;
      final expiresAt = createdAt.add(const Duration(days: 7));
      final remaining = expiresAt.difference(now);

      if (remaining.isNegative) {
        timerText = 'ไฟล์หมดอายุแล้ว';
        timerColor = AppTheme.accentRed;
      } else {
        final daysLeft = remaining.inDays;
        timerText = 'อายุไฟล์: เหลืออีก $daysLeft วัน';
        timerColor = daysLeft <= 2 ? AppTheme.accentOrange : AppTheme.accentGreen;
      }
    } else {
      final downloadedAt = task.firstDownloadedAt!;
      final expiresAt = downloadedAt.add(const Duration(hours: 48));
      final remaining = expiresAt.difference(now);

      if (remaining.isNegative) {
        timerText = 'หมดเวลาแล้ว';
        timerColor = AppTheme.accentRed;
      } else {
        final hoursLeft = remaining.inHours;
        timerText = 'ดาวน์โหลดแล้ว: เหลือเวลา $hoursLeft ชม.';
        timerColor = hoursLeft <= 12 ? AppTheme.accentOrange : AppTheme.accentGreen;
      }
    }

    return Row(
      children: [
        Icon(Icons.timer, size: 16, color: timerColor),
        const SizedBox(width: 4),
        Text(
          timerText,
          style: TextStyle(
            color: timerColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context, TaskController taskCtrl) {
    Get.snackbar(
      'เพิ่มงาน',
      'ใช้ปุ่ม + ที่หน้าปฏิทินเพื่อเพิ่มงาน',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppTheme.accentOrange,
      colorText: Colors.white,
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, TaskModel task, TaskController taskCtrl) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('ยืนยันการลบ', style: TextStyle(color: Colors.white)),
        content: Text(
          'คุณต้องการลบงาน "${task.title}" หรือไม่?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              taskCtrl.deleteTask(task);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
