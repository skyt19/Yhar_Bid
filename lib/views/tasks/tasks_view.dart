/// lib/views/tasks/tasks_view.dart
/// Tasks Screen — Task list with priority, status, file lifecycle
/// Operate mode: scan-first, status-driven, green accent actions
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/proactive_controller.dart';
import '../../controllers/prepared_plan_controller.dart';
import '../../models/task_model.dart';
import '../widgets/add_task_dialog.dart';
import '../preparation_detail_view.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskCtrl = Get.put(TaskController());
    final proactiveCtrl = Get.find<ProactiveController>();
    Get.put(PreparedPlanController()); // Initialize if not already

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page header
            _buildHeader(context, taskCtrl),
            // Filter chips
            _buildFilters(taskCtrl),
            // Task list
            Expanded(child: _buildTaskList(taskCtrl, proactiveCtrl, context)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.dialog(const AddTaskDialog()),
        backgroundColor: AppTheme.accentGreen,
        foregroundColor: AppTheme.surfaceLight,
        elevation: 2,
        label: const Text('เพิ่มงาน',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        icon: const Icon(Icons.add, size: 20),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, TaskController taskCtrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.space16, AppTheme.space16,
          AppTheme.space16, AppTheme.space8),
      child: Obx(() {
        final total = taskCtrl.tasks.length;
        final done = taskCtrl.tasks.where((t) => t.isDone).length;
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('งานทั้งหมด', style: AppTheme.titleMedium),
                  const SizedBox(height: AppTheme.space2),
                  Text(
                    '$done/$total เสร็จแล้ว',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ─── Filters ──────────────────────────────────────────────────────────────

  Widget _buildFilters(TaskController taskCtrl) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(AppTheme.space16, 0,
              AppTheme.space16, AppTheme.space8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('ทั้งหมด', 'all', taskCtrl),
                const SizedBox(width: AppTheme.space8),
                _filterChip('รอดำเนินการ', 'pending', taskCtrl),
                const SizedBox(width: AppTheme.space8),
                _filterChip('เสร็จแล้ว', 'completed', taskCtrl),
                const SizedBox(width: AppTheme.space8),
                _filterChip('แผนเตรียมงาน', 'preparations', taskCtrl),
              ],
            ),
          ),
        ));
  }

  Widget _filterChip(String label, String value, TaskController taskCtrl) {
    final bool active = taskCtrl.selectedFilter.value == value;
    return FilterChip(
      label: Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            color: active ? AppTheme.surfaceLight : AppTheme.textSecondary,
          )),
      selected: active,
      onSelected: (_) => taskCtrl.selectedFilter.value = value,
      backgroundColor: AppTheme.surfaceLight,
      selectedColor: AppTheme.accentGreen,
      side: BorderSide(
        color: active ? AppTheme.accentGreen : AppTheme.borderColor,
        width: 1.0,
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusPill)),
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space8, vertical: AppTheme.space4),
      showCheckmark: false,
    );
  }

  // ─── Task list ────────────────────────────────────────────────────────────

  Widget _buildTaskList(TaskController taskCtrl,
      ProactiveController proactiveCtrl, BuildContext context) {
    return Obx(() {
      final String filter = taskCtrl.selectedFilter.value;

      // Show approved preparation plans when filter is 'preparations'
      if (filter == 'preparations') {
        final approvedPlans = proactiveCtrl.approvedProposals;
        if (approvedPlans.isEmpty) {
          return _buildEmptyPreparationsState();
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(AppTheme.space16, 0,
              AppTheme.space16, AppTheme.space80),
          itemCount: approvedPlans.length,
          itemBuilder: (context, i) => _preparationCard(approvedPlans[i], context),
        );
      }

      // Show regular tasks
      final tasks = taskCtrl.filteredTasks;
      if (tasks.isEmpty) {
        return _buildEmptyState(filter);
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(AppTheme.space16, 0,
            AppTheme.space16, AppTheme.space80),
        itemCount: tasks.length,
        itemBuilder: (context, i) =>
            _taskCard(tasks[i], taskCtrl, proactiveCtrl, context),
      );
    });
  }

  Widget _buildEmptyState(String filter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.task_alt_rounded,
                size: 48, color: AppTheme.textTertiary),
            const SizedBox(height: AppTheme.space12),
            Text(
              filter == 'completed' ? 'ยังไม่มีงานที่เสร็จ' : 'ไม่มีงานในขณะนี้',
              style: AppTheme.titleSmall.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.space8),
            const Text(
              'กด + เพื่อเพิ่มงานใหม่',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPreparationsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.psychology_outlined,
                size: 48, color: AppTheme.textTertiary),
            const SizedBox(height: AppTheme.space12),
            Text(
              'ยังไม่มีแผนเตรียมงานที่อนุมัติ',
              style: AppTheme.titleSmall.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.space8),
            const Text(
              'อนุมัติข้อเสนอจาก AI Insights ใน Dashboard',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Preparation card ─────────────────────────────────────────────────────

  Widget _preparationCard(dynamic proposal, BuildContext context) {
    final preparedPlanCtrl = Get.find<PreparedPlanController>();
    final event = proposal.event;
    final aiContent = proposal.aiContent as String;
    final createdAt = proposal.createdAt;

    return Obx(() {
      // Get the prepared plan for this proposal
      final plan = preparedPlanCtrl.getPlanByProposalId(proposal.id);

      return Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.space12),
        child: InkWell(
          onTap: plan != null
              ? () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => PreparationDetailView(plan: plan),
                  ))
              : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: AppTheme.shadowCard,
              border: Border.all(
                color: AppTheme.accentGreen.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event title and badges
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                          border: Border.all(
                            color: AppTheme.accentGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 14, color: AppTheme.accentGreen),
                            SizedBox(width: 4),
                            Text(
                              'อนุมัติแล้ว',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Progress badge
                      if (plan != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: plan.isCompleted
                                ? AppTheme.accentGreen.withValues(alpha: 0.15)
                                : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                            border: Border.all(
                              color: plan.isCompleted
                                  ? AppTheme.accentGreen.withValues(alpha: 0.3)
                                  : AppTheme.borderStrong,
                            ),
                          ),
                          child: Text(
                            plan.isCompleted
                                ? 'เสร็จแล้ว'
                                : '${plan.completedStepCount}/${plan.totalSteps} เสร็จแล้ว',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: plan.isCompleted
                                  ? AppTheme.accentGreen
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space12),
                  // Event title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space8),
                  // Event datetime and location
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${event.startTime.day}/${event.startTime.month} ${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')}',
                          style: AppTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  if (event.location.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.space4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: AppTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppTheme.space12),
                  const Divider(color: AppTheme.dividerColor, height: 1),
                  const SizedBox(height: AppTheme.space12),
                  // AI preparation content preview
                  Text(
                    plan?.objective ?? aiContent,
                    style: AppTheme.bodyMedium,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // ─── Task card ────────────────────────────────────────────────────────────

  Widget _taskCard(TaskModel task, TaskController taskCtrl,
      ProactiveController proactiveCtrl, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.shadowCard,
          border: task.isDone
              ? Border.all(
                  color: AppTheme.accentGreen.withValues(alpha: 0.3),
                  width: 1.0)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task header row
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.space12,
                  AppTheme.space12, AppTheme.space12, AppTheme.space8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: task.isDone,
                        onChanged: (_) => taskCtrl.toggleTaskStatus(task),
                        activeColor: AppTheme.accentGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusXS)),
                        side: const BorderSide(
                            color: AppTheme.borderStrong, width: 1.5),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.space8),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: task.isDone
                                ? AppTheme.textTertiary
                                : AppTheme.textPrimary,
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.space4),
                          Text(
                            task.description,
                            style: AppTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.space8),
                  // Priority badge
                  _priorityBadge(task.priority),
                ],
              ),
            ),

            // File expiry indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.space12, 0,
                  AppTheme.space12, AppTheme.space8),
              child: _fileTimer(task),
            ),

            const Divider(
                height: 1,
                color: AppTheme.dividerColor,
                indent: AppTheme.space12,
                endIndent: AppTheme.space12),

            // Actions row
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.space12,
                  AppTheme.space8, AppTheme.space12, AppTheme.space12),
              child: Row(
                children: [
                  // Download outline
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => taskCtrl.downloadTaskOutline(task),
                      icon: const Icon(Icons.download_rounded, size: 14),
                      label: const Text('ดาวน์โหลด',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentGreen,
                        side: const BorderSide(
                            color: AppTheme.accentGreen, width: 1.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.space6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusSmall)),
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.space8),
                  // Delete
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppTheme.accentRed),
                    onPressed: () =>
                        _confirmDelete(context, task, taskCtrl),
                    tooltip: 'ลบงาน',
                    style: IconButton.styleFrom(
                      backgroundColor:
                          AppTheme.accentRed.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppTheme.radiusSmall)),
                      minimumSize: const Size(36, 36),
                      padding: const EdgeInsets.all(AppTheme.space8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityBadge(String priority) {
    Color color;
    String label;
    switch (priority.toLowerCase()) {
      case 'high':
        color = AppTheme.accentRed;
        label = 'สูง';
        break;
      case 'medium':
        color = AppTheme.accentOrange;
        label = 'กลาง';
        break;
      default:
        color = AppTheme.statusSuccess;
        label = 'ต่ำ';
    }
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space8, vertical: AppTheme.space2),
      decoration: AppTheme.statusBadgeDecoration(color),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _fileTimer(TaskModel task) {
    final now = DateTime.now();
    String text;
    Color color;
    IconData icon;

    if (task.firstDownloadedAt == null) {
      final expires = task.createdAt.add(const Duration(days: 7));
      final remaining = expires.difference(now);
      if (remaining.isNegative) {
        text = 'ไฟล์หมดอายุแล้ว';
        color = AppTheme.accentRed;
        icon = Icons.timer_off_rounded;
      } else {
        final d = remaining.inDays;
        text = 'อายุไฟล์: เหลือ $d วัน';
        color = d <= 2 ? AppTheme.accentOrange : AppTheme.textTertiary;
        icon = Icons.timer_outlined;
      }
    } else {
      final expires =
          task.firstDownloadedAt!.add(const Duration(hours: 48));
      final remaining = expires.difference(now);
      if (remaining.isNegative) {
        text = 'หมดเวลาแล้ว';
        color = AppTheme.accentRed;
        icon = Icons.timer_off_rounded;
      } else {
        final h = remaining.inHours;
        text = 'ดาวน์โหลดแล้ว: เหลือ $h ชม.';
        color = h <= 12 ? AppTheme.accentOrange : AppTheme.textTertiary;
        icon = Icons.timer_outlined;
      }
    }

    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: AppTheme.space4),
        Text(text,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _confirmDelete(
      BuildContext context, TaskModel task, TaskController taskCtrl) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
        title: const Text('ยืนยันการลบ', style: AppTheme.titleMedium),
        content: Text(
          'ลบ "${task.title}" ใช่ไหม?',
          style: AppTheme.bodyMedium,
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
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed,
                foregroundColor: AppTheme.surfaceLight,
                elevation: 0),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
