/// lib/views/preparation_detail_view.dart
/// Interactive preparation plan detail view with per-step completion tracking
/// Operate mode: scannable checklist, immediate feedback, persistent state
/// Enhanced: keyboard nav, AI personality, error visibility, step metadata

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/prepared_plan_model.dart';
import '../models/user_model.dart';
import '../controllers/prepared_plan_controller.dart';
import '../controllers/auth_controller.dart';
import '../views/theme/app_theme.dart';
import 'dart:convert';
import 'dart:html' as html;

class PreparationDetailView extends StatefulWidget {
  final PreparedPlanModel plan;

  const PreparationDetailView({super.key, required this.plan});

  @override
  State<PreparationDetailView> createState() => _PreparationDetailViewState();
}

class _PreparationDetailViewState extends State<PreparationDetailView> {
  bool _resourcesExpanded = false;
  final List<FocusNode> _stepFocusNodes = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Create focus nodes for each step
    final ctrl = Get.find<PreparedPlanController>();
    final plan = ctrl.plans.firstWhere(
      (p) => p.id == widget.plan.id,
      orElse: () => widget.plan,
    );
    for (int i = 0; i < plan.steps.length; i++) {
      _stepFocusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (final node in _stepFocusNodes) {
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preparedPlanCtrl = Get.find<PreparedPlanController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 640;

    return Scaffold(
      backgroundColor: isWide ? AppTheme.textPrimary.withValues(alpha: 0.5) : AppTheme.backgroundLight,
      body: SafeArea(
        child: isWide ? _buildWideLayout(preparedPlanCtrl) : _buildNarrowLayout(preparedPlanCtrl),
      ),
    );
  }

  Widget _buildWideLayout(PreparedPlanController ctrl) {
    return Center(
      child: Container(
        width: 640,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(ctrl),
            Flexible(child: _buildScrollContent(ctrl)),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(PreparedPlanController ctrl) {
    return Column(
      children: [
        _buildHeader(ctrl),
        Expanded(child: _buildScrollContent(ctrl)),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader(PreparedPlanController ctrl) {
    return Obx(() {
      // Get updated plan from controller
      final updatedPlan = ctrl.plans.firstWhere(
        (p) => p.id == widget.plan.id,
        orElse: () => widget.plan,
      );

      return Container(
        padding: const EdgeInsets.all(AppTheme.space16),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceLight,
          border: Border(
            bottom: BorderSide(color: AppTheme.borderColor, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button + Progress indicator + AI badge
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'กลับ',
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        updatedPlan.eventTitle,
                        style: AppTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      _buildAiBadge(),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                _buildProgressIndicator(updatedPlan),
              ],
            ),
            const SizedBox(height: AppTheme.space8),
            // Event datetime and location
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: AppTheme.space4),
                Text(
                  _formatEventDateTime(updatedPlan.eventDateTime),
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
            if (updatedPlan.eventLocation.isNotEmpty) ...[
              const SizedBox(height: AppTheme.space4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: AppTheme.space4),
                  Expanded(
                    child: Text(
                      updatedPlan.eventLocation,
                      style: AppTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildAiBadge() {
    return Tooltip(
      message: 'แผนนี้ถูกสร้างโดย AI โดยวิเคราะห์จากข้อมูลของกิจกรรม',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.accentGreen.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 12, color: AppTheme.accentGreen),
            const SizedBox(width: 4),
            Text(
              'AI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentGreen,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(PreparedPlanModel plan) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: plan.isCompleted ? AppTheme.accentGreen : AppTheme.borderStrong,
          width: 4,
        ),
        boxShadow: plan.isCompleted ? const [
          BoxShadow(
            color: Color(0x204CAF50),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ] : null,
      ),
      child: Center(
        child: Text(
          '${plan.progressPercent}%',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: plan.isCompleted ? AppTheme.accentGreen : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildScrollContent(PreparedPlanController ctrl) {
    return Obx(() {
      final updatedPlan = ctrl.plans.firstWhere(
        (p) => p.id == widget.plan.id,
        orElse: () => widget.plan,
      );

      return SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Objective section
            const Text(
              'วัตถุประสงค์',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.space8),
            Text(
              updatedPlan.objective,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppTheme.space24),

            // Preparation steps
            Row(
              children: [
                Text(
                  'ขั้นตอนเตรียมงาน (${updatedPlan.completedStepCount}/${updatedPlan.totalSteps})',
                  style: AppTheme.titleMedium,
                ),
                const Spacer(),
                _buildPersonalityHint(updatedPlan),
              ],
            ),
            const SizedBox(height: AppTheme.space8),
            ...updatedPlan.steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return _buildStepRow(ctrl, updatedPlan, step, index);
            }),

            const SizedBox(height: AppTheme.space24),

            // Resources section (expandable)
            if (updatedPlan.resources.isNotEmpty) ...[
              InkWell(
                onTap: () {
                  setState(() {
                    _resourcesExpanded = !_resourcesExpanded;
                  });
                },
                child: Row(
                  children: [
                    const Text(
                      'ทรัพยากรที่ต้องใช้',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space8),
                    Icon(
                      _resourcesExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
              if (_resourcesExpanded) ...[
                const SizedBox(height: AppTheme.space8),
                ...updatedPlan.resources.map((resource) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.space8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                      Expanded(
                        child: Text(
                          resource,
                          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
              const SizedBox(height: AppTheme.space24),
            ],

            // Timeline section with personality
            const Text(
              'ไทม์ไลน์แนะนำ',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.space8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: AppTheme.space8),
                Expanded(
                  child: Text(
                    updatedPlan.timeline,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.space80),
          ],
        ),
      );
    });
  }

  Widget _buildPersonalityHint(PreparedPlanModel plan) {
    final authCtrl = Get.find<AuthController>();
    final personality = authCtrl.currentUser.value?.personality ?? AiPersonality.politeJarvis;

    // Show encouraging message based on AI personality and progress
    if (plan.isCompleted) return const SizedBox.shrink();

    final progressPercent = plan.progressPercent;
    String hint = '';

    if (progressPercent == 0) {
      switch (personality) {
        case AiPersonality.politeJarvis:
          hint = 'เริ่มทำขั้นตอนแรกได้เลยครับ';
          break;
        case AiPersonality.friendly:
          hint = 'มาเริ่มกันเลย!';
          break;
        case AiPersonality.aggressiveMotivator:
          hint = 'เริ่มเลย! อย่าผัดวันประกันพรุ่ง';
          break;
      }
    } else if (progressPercent < 50) {
      switch (personality) {
        case AiPersonality.politeJarvis:
          hint = 'ทำไปได้ดีครับ';
          break;
        case AiPersonality.friendly:
          hint = 'เก่งมาก! ทำต่อไปเลย';
          break;
        case AiPersonality.aggressiveMotivator:
          hint = 'ยังไม่ถึงครึ่ง ไปต่อ!';
          break;
      }
    } else {
      switch (personality) {
        case AiPersonality.politeJarvis:
          hint = 'เกือบเสร็จแล้วครับ';
          break;
        case AiPersonality.friendly:
          hint = 'อีกนิดเดียว เสร็จแล้ว!';
          break;
        case AiPersonality.aggressiveMotivator:
          hint = 'เร่งให้เสร็จ!';
          break;
      }
    }

    return Text(
      hint,
      style: TextStyle(
        fontSize: 13,
        color: AppTheme.accentGreen,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildStepRow(PreparedPlanController ctrl, PreparedPlanModel plan, PreparationStep step, int index) {
    final stepKey = '${plan.id}_${step.id}';
    final isSyncing = ctrl.stepSyncInProgress[stepKey] ?? false;
    final syncError = ctrl.stepSyncErrors[stepKey];
    final focusNode = index < _stepFocusNodes.length ? _stepFocusNodes[index] : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space12),
      child: Focus(
        focusNode: focusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.enter) {
              ctrl.toggleStep(plan.id, step.id);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              final nextIndex = index + 1;
              if (nextIndex < _stepFocusNodes.length) {
                _stepFocusNodes[nextIndex].requestFocus();
              }
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              final prevIndex = index - 1;
              if (prevIndex >= 0) {
                _stepFocusNodes[prevIndex].requestFocus();
              }
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;
            return InkWell(
              onTap: () => ctrl.toggleStep(plan.id, step.id),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space8,
                  vertical: AppTheme.space12,
                ),
                decoration: BoxDecoration(
                  border: isFocused
                      ? Border.all(color: AppTheme.accentGreen, width: 2)
                      : null,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox container (48px touch target, centered 24px visual)
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Checkbox visual
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: step.isCompleted
                                    ? AppTheme.accentGreen
                                    : (syncError != null
                                        ? AppTheme.accentRed
                                        : AppTheme.borderStrong),
                                width: 2,
                              ),
                              color: step.isCompleted ? AppTheme.accentGreen : AppTheme.surfaceLight,
                            ),
                            child: step.isCompleted
                                ? const Icon(Icons.check, size: 16, color: AppTheme.surfaceLight)
                                : null,
                          ),
                          // Loading spinner overlay
                          if (isSyncing)
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Step number and text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Step number
                              Text(
                                '${step.order}. ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: step.isCompleted
                                      ? AppTheme.textTertiary
                                      : AppTheme.textPrimary,
                                  decoration: step.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  height: 1.5,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  step.text,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: step.isCompleted
                                        ? AppTheme.textTertiary
                                        : AppTheme.textPrimary,
                                    decoration: step.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Completion timestamp
                          if (step.isCompleted && step.completedAt != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'เสร็จเมื่อ ${_formatCompletionTime(step.completedAt!)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ],
                          // Sync error message
                          if (syncError != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 14,
                                  color: AppTheme.accentRed,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    syncError,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.accentRed,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceLight,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: _downloadTxt,
          icon: const Icon(Icons.download_rounded, size: 20),
          label: const Text(
            'ดาวน์โหลด TXT',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.borderStrong),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
          ),
        ),
      ),
    );
  }

  String _formatEventDateTime(DateTime dt) {
    // Buddhist calendar year format
    final buddhistYear = dt.year + 543;
    return '${dt.day}/${dt.month}/$buddhistYear, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatCompletionTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'เมื่อสักครู่';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} นาทีที่แล้ว';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ชั่วโมงที่แล้ว';
    } else {
      final buddhistYear = dt.year + 543;
      return '${dt.day}/${dt.month}/$buddhistYear ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }

  void _downloadTxt() {
    final plan = widget.plan;

    // Generate TXT content
    final buffer = StringBuffer();
    buffer.writeln('='.padRight(60, '='));
    buffer.writeln('แผนเตรียมงาน: ${plan.eventTitle}');
    buffer.writeln('='.padRight(60, '='));
    buffer.writeln();
    buffer.writeln('📅 วันที่: ${_formatEventDateTime(plan.eventDateTime)}');
    if (plan.eventLocation.isNotEmpty) {
      buffer.writeln('📍 สถานที่: ${plan.eventLocation}');
    }
    buffer.writeln();

    buffer.writeln('วัตถุประสงค์');
    buffer.writeln('-'.padRight(60, '-'));
    buffer.writeln(plan.objective);
    buffer.writeln();

    buffer.writeln('ขั้นตอนเตรียมงาน (${plan.completedStepCount}/${plan.totalSteps})');
    buffer.writeln('-'.padRight(60, '-'));
    for (final step in plan.steps) {
      final checkbox = step.isCompleted ? '✓' : '☐';
      buffer.writeln('$checkbox ${step.order}. ${step.text}');
    }
    buffer.writeln();

    if (plan.resources.isNotEmpty) {
      buffer.writeln('ทรัพยากรที่ต้องใช้');
      buffer.writeln('-'.padRight(60, '-'));
      for (final resource in plan.resources) {
        buffer.writeln('• $resource');
      }
      buffer.writeln();
    }

    buffer.writeln('ไทม์ไลน์แนะนำ');
    buffer.writeln('-'.padRight(60, '-'));
    buffer.writeln(plan.timeline);
    buffer.writeln();

    if (plan.isCompleted) {
      buffer.writeln('✓ เสร็จสมบูรณ์แล้ว');
      buffer.writeln('วันที่เสร็จ: ${_formatEventDateTime(plan.completedAt!)}');
    } else {
      buffer.writeln('ความคืบหน้า: ${plan.progressPercent}%');
    }

    // Create blob and trigger download
    final content = buffer.toString();
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], 'text/plain; charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'preparation_${plan.eventId}.txt')
      ..click();

    html.Url.revokeObjectUrl(url);
    anchor.remove(); // Clean up DOM element

    Get.snackbar(
      'ดาวน์โหลดแล้ว',
      'บันทึกแผนเตรียมงานเป็นไฟล์ TXT เรียบร้อย',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
