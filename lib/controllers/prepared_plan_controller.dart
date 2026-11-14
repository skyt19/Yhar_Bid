/// lib/controllers/prepared_plan_controller.dart
/// Controller for interactive preparation plans with per-step completion tracking
/// Handles Firestore persistence, optimistic updates, and state management

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prepared_plan_model.dart';
import '../controllers/proactive_controller.dart';
import '../utils/ai_content_parser.dart';
import 'auth_controller.dart';

class PreparedPlanController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<PreparedPlanModel> plans = <PreparedPlanModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Track which plans exist to prevent duplicates
  final _existingProposalIds = <String>{}.obs;

  // Track per-step sync state for error visibility
  final RxMap<String, bool> stepSyncInProgress = <String, bool>{}.obs;
  final RxMap<String, String> stepSyncErrors = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  // Getters
  List<PreparedPlanModel> get activePlans => plans
      .where((p) => !p.isCompleted && !p.hasEventPassed)
      .toList()
    ..sort((a, b) => a.eventDateTime.compareTo(b.eventDateTime));

  List<PreparedPlanModel> get completedPlans =>
      plans.where((p) => p.isCompleted).toList();

  List<PreparedPlanModel> get allPlans => plans.toList()
    ..sort((a, b) => a.eventDateTime.compareTo(b.eventDateTime));

  bool isPlanCreatedForProposal(String proposalId) {
    return _existingProposalIds.contains(proposalId);
  }

  PreparedPlanModel? getPlanByProposalId(String proposalId) {
    try {
      return plans.firstWhere((p) => p.proposalId == proposalId);
    } catch (e) {
      return null;
    }
  }

  /// Fetch all plans for current user
  Future<void> fetchPlans() async {
    final authCtrl = Get.find<AuthController>();
    final userId = authCtrl.currentUser.value?.uid;

    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final snapshot = await _firestore
          .collection('preparedPlans')
          .doc(userId)
          .collection('plans')
          .orderBy('eventDateTime', descending: false)
          .get();

      plans.value = snapshot.docs
          .map((doc) => PreparedPlanModel.fromFirestore(doc))
          .toList();

      // Track existing proposal IDs
      _existingProposalIds.clear();
      _existingProposalIds.addAll(plans.map((p) => p.proposalId));
    } catch (e) {
      error.value = 'ไม่สามารถโหลดแผนเตรียมงานได้: $e';
      print('Error fetching prepared plans: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create prepared plan from approved proposal
  /// Prevents duplicate creation for same proposal
  Future<bool> createPlanFromProposal(PreparationProposal proposal) async {
    final authCtrl = Get.find<AuthController>();
    final userId = authCtrl.currentUser.value?.uid;

    if (userId == null || userId.isEmpty) {
      Get.snackbar('ข้อผิดพลาด', 'กรุณาเข้าสู่ระบบก่อนใช้งาน');
      return false;
    }

    // Prevent duplicate creation
    if (isPlanCreatedForProposal(proposal.id)) {
      print('Plan already exists for proposal ${proposal.id}');
      return true; // Already exists, not an error
    }

    try {
      // Parse AI content into structured plan
      final parsedSections = AiContentParser.parse(proposal.aiContent);

      final plan = PreparedPlanModel(
        id: '', // Will be set by Firestore
        userId: userId,
        proposalId: proposal.id,
        eventId: proposal.event.id,
        eventTitle: proposal.event.title,
        eventDateTime: proposal.event.startTime,
        eventLocation: proposal.event.location ?? 'ไม่ระบุสถานที่',
        objective: parsedSections['objective'] as String,
        steps: parsedSections['steps'] as List<PreparationStep>,
        resources: parsedSections['resources'] as List<String>,
        timeline: parsedSections['timeline'] as String,
        rawAiContent: proposal.aiContent,
        createdAt: DateTime.now(),
        completedAt: null,
      );

      // Create unique plan ID
      final planId = 'plan_${proposal.id}';

      // Persist to Firestore
      await _firestore
          .collection('preparedPlans')
          .doc(userId)
          .collection('plans')
          .doc(planId)
          .set(plan.toFirestore());

      // Add to local state with correct ID
      final savedPlan = plan.copyWith(id: planId);
      plans.add(savedPlan);
      _existingProposalIds.add(proposal.id);

      return true;
    } catch (e) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'ไม่สามารถบันทึกแผนเตรียมงานได้: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error creating prepared plan: $e');
      return false;
    }
  }

  /// Toggle step completion with optimistic update and rollback on failure
  Future<void> toggleStep(String planId, String stepId) async {
    final authCtrl = Get.find<AuthController>();
    final userId = authCtrl.currentUser.value?.uid;

    if (userId == null || userId.isEmpty) {
      return;
    }

    // Find plan and step
    final planIndex = plans.indexWhere((p) => p.id == planId);
    if (planIndex == -1) {
      print('Plan not found: $planId');
      return;
    }

    final plan = plans[planIndex];
    final stepIndex = plan.steps.indexWhere((s) => s.id == stepId);
    if (stepIndex == -1) {
      print('Step not found: $stepId');
      return;
    }

    final step = plan.steps[stepIndex];
    final stepKey = '${planId}_$stepId';

    // Backup for rollback
    final oldStepState = step;
    final oldCompletedAt = plan.completedAt;

    // Mark sync in progress
    stepSyncInProgress[stepKey] = true;
    stepSyncErrors.remove(stepKey);

    // Optimistic update - toggle step
    final newStepState = step.copyWith(
      isCompleted: !step.isCompleted,
      completedAt: !step.isCompleted ? DateTime.now() : null,
    );

    final updatedSteps = List<PreparationStep>.from(plan.steps);
    updatedSteps[stepIndex] = newStepState;

    // Check if all steps now complete
    final allComplete = updatedSteps.every((s) => s.isCompleted);
    final newCompletedAt = allComplete && plan.completedAt == null
        ? DateTime.now()
        : (allComplete ? plan.completedAt : null);

    final updatedPlan = plan.copyWith(
      steps: updatedSteps,
      completedAt: newCompletedAt,
    );

    plans[planIndex] = updatedPlan;
    plans.refresh();

    // Trigger completion animation if just completed
    if (allComplete && oldCompletedAt == null) {
      _triggerCompletionCelebration(planId);
    }

    // Persist to Firestore
    try {
      await _firestore
          .collection('preparedPlans')
          .doc(userId)
          .collection('plans')
          .doc(planId)
          .update({
        'steps': updatedSteps.map((s) => s.toMap()).toList(),
        'completedAt': newCompletedAt != null
            ? Timestamp.fromDate(newCompletedAt)
            : null,
      });

      // Clear sync state on success
      stepSyncInProgress.remove(stepKey);
    } catch (e) {
      // Rollback on failure
      final rollbackSteps = List<PreparationStep>.from(plan.steps);
      rollbackSteps[stepIndex] = oldStepState;

      plans[planIndex] = plan.copyWith(
        steps: rollbackSteps,
        completedAt: oldCompletedAt,
      );
      plans.refresh();

      // Mark sync error with specific message
      stepSyncInProgress.remove(stepKey);
      stepSyncErrors[stepKey] = 'ไม่สามารถบันทึกขั้นตอนนี้ได้ — กดอีกครั้งเพื่อลองใหม่';

      Get.snackbar(
        'ข้อผิดพลาด',
        'ไม่สามารถบันทึกได้ กรุณาลองใหม่',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      print('Error toggling step: $e');
    }
  }

  void _triggerCompletionCelebration(String planId) {
    // Show completion snackbar with celebration
    Get.snackbar(
      'เตรียมงานเสร็จสมบูรณ์!',
      '🎉 ขั้นตอนทั้งหมดเสร็จแล้ว',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 3),
    );
  }

  /// Delete a prepared plan
  Future<void> deletePlan(String planId) async {
    final authCtrl = Get.find<AuthController>();
    final userId = authCtrl.currentUser.value?.uid;

    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      // Remove from local state
      final plan = plans.firstWhere((p) => p.id == planId);
      plans.removeWhere((p) => p.id == planId);
      _existingProposalIds.remove(plan.proposalId);

      // Delete from Firestore
      await _firestore
          .collection('preparedPlans')
          .doc(userId)
          .collection('plans')
          .doc(planId)
          .delete();
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถลบแผนได้');
      print('Error deleting plan: $e');
      // Refetch to restore state
      await fetchPlans();
    }
  }
}
