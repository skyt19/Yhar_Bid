/// lib/views/ai/ai_context_analysis_view.dart
/// AI Context Analysis View — Display context-aware analysis and task proposals
/// Phase 1-3: Dynamic Discovery Engine UI

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ai_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/ai_discovery_model.dart';
import '../../models/context_snapshot_model.dart';
import '../theme/app_theme.dart';

class AIContextAnalysisView extends StatelessWidget {
  const AIContextAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    final aiCtrl = Get.find<AiController>();
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(authCtrl, aiCtrl),
            const Divider(height: 1, color: AppTheme.dividerColor),
            Expanded(
              child: Obx(() {
                final isAnalyzing = aiCtrl.isAnalyzing.value;
                final isLoadingContext = aiCtrl.isLoadingContext.value;
                final error = aiCtrl.analysisError.value;
                final analysis = aiCtrl.currentAnalysis.value;
                final context = aiCtrl.currentContext.value;

                if (error.isNotEmpty) {
                  return _buildError(error, aiCtrl);
                }

                if (isLoadingContext || isAnalyzing) {
                  return _buildLoading(isLoadingContext);
                }

                if (analysis == null) {
                  return _buildEmptyState(aiCtrl);
                }

                return _buildAnalysisContent(analysis, context, aiCtrl);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AuthController authCtrl, AiController aiCtrl) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.accentGreen,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Context Analysis', style: AppTheme.titleMedium),
                Obx(() {
                  final role = authCtrl.currentUser.value?.role.name ?? 'student';
                  return Text(
                    'Role-aware reasoning · $role',
                    style: AppTheme.caption,
                  );
                }),
              ],
            ),
          ),
          Obx(() => aiCtrl.currentAnalysis.value != null
              ? IconButton(
                  onPressed: () => aiCtrl.refreshAnalysis(),
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh Analysis',
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AiController aiCtrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 40,
                color: AppTheme.accentGreen,
              ),
            ),
            const SizedBox(height: AppTheme.space24),
            const Text(
              'Context-Aware AI Analysis',
              style: AppTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space8),
            const Text(
              'AI will analyze your tasks, calendar, and responsibilities\nto discover relevant actions and priorities.',
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space32),
            ElevatedButton.icon(
              onPressed: () => aiCtrl.generateContextAwareAnalysis(),
              icon: const Icon(Icons.psychology_rounded, size: 20),
              label: const Text('Start Analysis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space24,
                  vertical: AppTheme.space12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(bool isLoadingContext) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.accentGreen),
          const SizedBox(height: AppTheme.space16),
          Text(
            isLoadingContext ? 'Retrieving context...' : 'Analyzing...',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error, AiController aiCtrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.accentRed,
            ),
            const SizedBox(height: AppTheme.space16),
            Text(
              error,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space24),
            TextButton.icon(
              onPressed: () => aiCtrl.refreshAnalysis(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisContent(
    AnalysisResult analysis,
    ContextSnapshot? context,
    AiController aiCtrl,
  ) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.space16),
      children: [
        // Context Summary
        if (context != null) _buildContextSummary(context),
        const SizedBox(height: AppTheme.space16),

        // Analysis Summary
        _buildAnalysisSummary(analysis),
        const SizedBox(height: AppTheme.space16),

        // Identified Issues
        if (analysis.identifiedIssues.isNotEmpty) ...[
          _buildIssuesSection(analysis.identifiedIssues),
          const SizedBox(height: AppTheme.space16),
        ],

        // Priorities
        if (analysis.priorities.isNotEmpty) ...[
          _buildPrioritiesSection(analysis.priorities),
          const SizedBox(height: AppTheme.space16),
        ],

        // Task Proposals
        if (analysis.hasProposals) ...[
          _buildProposalsSection(analysis.proposals),
          const SizedBox(height: AppTheme.space16),
        ],

        // Clarification Questions
        if (analysis.requiresClarification &&
            analysis.clarificationQuestions.isNotEmpty) ...[
          _buildClarificationSection(analysis.clarificationQuestions),
        ],

        // No Recommendations
        if (!analysis.hasProposals &&
            !analysis.requiresClarification &&
            analysis.identifiedIssues.isEmpty)
          _buildNoRecommendations(analysis.summary),
      ],
    );
  }

  Widget _buildContextSummary(ContextSnapshot context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: const BorderSide(color: AppTheme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.dataset_rounded,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.space8),
                const Text('Retrieved Context', style: AppTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppTheme.space12),
            _buildContextRow(
              'Tasks',
              '${context.tasks.length} total, ${context.pendingTasks.length} pending',
              Icons.task_alt_rounded,
            ),
            _buildContextRow(
              'Calendar',
              '${context.calendarEvents.length} events, ${context.urgentEvents.length} urgent',
              Icons.event_rounded,
            ),
            _buildContextRow(
              'Role',
              context.userRole.name,
              Icons.person_rounded,
            ),
            if (context.retrievalErrors.isNotEmpty) ...[
              const SizedBox(height: AppTheme.space8),
              Container(
                padding: const EdgeInsets.all(AppTheme.space8),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: AppTheme.accentOrange,
                    ),
                    const SizedBox(width: AppTheme.space8),
                    Expanded(
                      child: Text(
                        'Partial retrieval: ${context.retrievalErrors.length} warnings',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.accentOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContextRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textTertiary),
          const SizedBox(width: AppTheme.space8),
          Text('$label: ', style: AppTheme.bodySmall),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSummary(AnalysisResult analysis) {
    return Card(
      elevation: 0,
      color: AppTheme.accentGreen.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: AppTheme.accentGreen,
                ),
                const SizedBox(width: AppTheme.space8),
                const Text('AI Analysis', style: AppTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppTheme.space12),
            Text(
              analysis.summary,
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssuesSection(List<String> issues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.warning_rounded, size: 18, color: AppTheme.accentOrange),
            SizedBox(width: AppTheme.space8),
            Text('Identified Issues', style: AppTheme.titleSmall),
          ],
        ),
        const SizedBox(height: AppTheme.space12),
        ...issues.map((issue) => _buildListItem(issue, AppTheme.accentOrange)),
      ],
    );
  }

  Widget _buildPrioritiesSection(List<String> priorities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.flag_rounded, size: 18, color: AppTheme.accentGreen),
            SizedBox(width: AppTheme.space8),
            Text('Priorities', style: AppTheme.titleSmall),
          ],
        ),
        const SizedBox(height: AppTheme.space12),
        ...priorities.map((priority) => _buildListItem(priority, AppTheme.accentGreen)),
      ],
    );
  }

  Widget _buildListItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: Text(text, style: AppTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalsSection(List<TaskProposal> proposals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lightbulb_rounded, size: 18, color: AppTheme.accentGreen),
            SizedBox(width: AppTheme.space8),
            Text('Task Proposals', style: AppTheme.titleSmall),
          ],
        ),
        const SizedBox(height: AppTheme.space12),
        ...proposals.map((proposal) => _buildProposalCard(proposal)),
      ],
    );
  }

  Widget _buildProposalCard(TaskProposal proposal) {
    final priorityColor = _getPriorityColor(proposal.priority);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppTheme.space12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: BorderSide(color: priorityColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Priority
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    proposal.title,
                    style: AppTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: AppTheme.space8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    proposal.priority.toUpperCase(),
                    style: AppTheme.caption.copyWith(
                      color: priorityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Description
            const SizedBox(height: AppTheme.space8),
            Text(
              proposal.description,
              style: AppTheme.bodyMedium,
            ),

            // Reason
            const SizedBox(height: AppTheme.space12),
            Container(
              padding: const EdgeInsets.all(AppTheme.space8),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.space8),
                  Expanded(
                    child: Text(
                      proposal.reason,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Evidence
            if (proposal.evidence.isNotEmpty) ...[
              const SizedBox(height: AppTheme.space12),
              const Text('Evidence:', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              const SizedBox(height: AppTheme.space4),
              ...proposal.evidence.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: AppTheme.bodySmall),
                        Expanded(
                          child: Text(e, style: AppTheme.bodySmall),
                        ),
                      ],
                    ),
                  )),
            ],

            // Subtasks
            if (proposal.subtasks.isNotEmpty) ...[
              const SizedBox(height: AppTheme.space12),
              const Text('Subtasks:', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              const SizedBox(height: AppTheme.space4),
              ...proposal.subtasks.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key + 1}. ',
                          style: AppTheme.bodySmall,
                        ),
                        Expanded(
                          child: Text(entry.value, style: AppTheme.bodySmall),
                        ),
                      ],
                    ),
                  )),
            ],

            // Related items
            if (proposal.relatedTaskIds.isNotEmpty ||
                proposal.relatedEventIds.isNotEmpty) ...[
              const SizedBox(height: AppTheme.space12),
              Container(
                padding: const EdgeInsets.all(AppTheme.space8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      size: 14,
                      color: AppTheme.accentGreen,
                    ),
                    const SizedBox(width: AppTheme.space4),
                    Expanded(
                      child: Text(
                        'Related: ${proposal.relatedTaskIds.length} tasks, ${proposal.relatedEventIds.length} events',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.accentGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Timing suggestion
            if (proposal.suggestedTiming != null) ...[
              const SizedBox(height: AppTheme.space8),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(width: AppTheme.space4),
                  Expanded(
                    child: Text(
                      proposal.suggestedTiming!,
                      style: AppTheme.caption.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Assumptions (if any)
            if (proposal.assumptions.isNotEmpty) ...[
              const SizedBox(height: AppTheme.space8),
              Text(
                'Assumptions: ${proposal.assumptions.join(", ")}',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClarificationSection(List<String> questions) {
    return Card(
      elevation: 0,
      color: AppTheme.accentOrange.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  size: 20,
                  color: AppTheme.accentOrange,
                ),
                SizedBox(width: AppTheme.space8),
                Text('Clarification Needed', style: AppTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppTheme.space12),
            ...questions.map((q) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.space8),
                  child: Text('• $q', style: AppTheme.bodyMedium),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildNoRecommendations(String summary) {
    return Card(
      elevation: 0,
      color: AppTheme.accentGreen.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppTheme.accentGreen,
              size: 24,
            ),
            const SizedBox(width: AppTheme.space12),
            Expanded(
              child: Text(
                summary.isNotEmpty ? summary : 'No actions needed at this time.',
                style: AppTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.accentRed;
      case 'medium':
        return AppTheme.accentOrange;
      case 'low':
        return AppTheme.accentGreen;
      default:
        return AppTheme.textSecondary;
    }
  }
}
