/// lib/controllers/task_controller.dart
/// Task Management Controller — จัดการงานและ Projects
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html; // For Flutter Web file download
import '../models/task_model.dart';
import '../controllers/auth_controller.dart';
import '../controllers/analytics_controller.dart';
import '../views/theme/app_theme.dart';

class TaskController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Task Filtering State (FR-4 Task Management)
  final RxString selectedFilter = 'all'.obs; // 'all', 'pending', 'completed'
  
  /// Computed filtered tasks based on selectedFilter
  List<TaskModel> get filteredTasks {
    switch (selectedFilter.value) {
      case 'pending':
        return tasks.where((TaskModel t) => !t.isDone).toList();
      case 'completed':
        return tasks.where((TaskModel t) => t.isDone).toList();
      case 'all':
      default:
        return tasks.toList();
    }
  }

  /// ดึงรายการงานจาก Firestore
  Future<void> fetchTasks() async {
    final AuthController authCtrl = Get.find<AuthController>();
    final user = authCtrl.currentUser.value;
    if (user == null) {
      errorMessage.value = 'กรุณาเข้าสู่ระบบก่อนดูรายการงาน';
      return;
    }
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .get();
      
      tasks.value = snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      errorMessage.value = 'เกิดข้อผิดพลาด: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  /// เพิ่มงานใหม่
  Future<bool> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    String? category,
    String? priority,
  }) async {
    final AuthController authCtrl = Get.find<AuthController>();
    final user = authCtrl.currentUser.value;
    if (user == null) {
      Get.snackbar('ข้อผิดพลาด', 'กรุณาเข้าสู่ระบบก่อนเพิ่มงาน',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    
    try {
      isLoading.value = true;
      
      final task = TaskModel(
        id: '',
        title: title,
        description: description ?? '',
        isDone: false,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        category: category,
        priority: priority ?? 'Medium',
      );
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .add(task.toFirestore());
      
      Get.snackbar('สำเร็จ', 'เพิ่มงาน "$title" แล้ว',
          snackPosition: SnackPosition.BOTTOM);
      
      await fetchTasks();
      return true;
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถเพิ่มงานได้: $e',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// สลับสถานะงานเสร็จ/ยังไม่เสร็จ
  Future<void> toggleTaskStatus(TaskModel task) async {
    final AuthController authCtrl = Get.find<AuthController>();
    final user = authCtrl.currentUser.value;
    if (user == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(task.id)
          .update({'isDone': !task.isDone});
      
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = task.copyWith(isDone: !task.isDone);
        tasks.refresh();
      }
      
      // FR-6: Trigger analytics recalculation when task status changes
      try {
        final analyticsCtrl = Get.find<AnalyticsController>();
        await analyticsCtrl.recalculateMetrics();
      } catch (_) {
        // AnalyticsController may not be initialized yet
      }
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถอัปเดตสถานะได้: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  /// ดาวน์โหลดโครงร่างงานเป็นไฟล์ .md (Markdown File Download)
  /// Starts 48-hour countdown timer by setting firstDownloadedAt
  /// Flutter Web implementation using dart:html Blob and URL download
  Future<void> downloadTaskOutline(TaskModel task) async {
    final AuthController authCtrl = Get.find<AuthController>();
    final user = authCtrl.currentUser.value;
    if (user == null) return;
    
    try {
      // Generate markdown content with full outline
      final String markdownContent = '''# ${task.title}

## รายละเอียดงาน
${task.description}

---
สร้างเมื่อ: ${task.createdAt.toString().substring(0, 16)}
${task.dueDate != null ? 'กำหนดส่ง: ${task.dueDate.toString().substring(0, 16)}' : ''}
ลำดับความสำคัญ: ${task.priority}
''';

      // Flutter Web: Create Blob and trigger download
      // ignore: avoid_web_libraries_in_flutter
      final html.Blob blob = html.Blob([markdownContent], 'text/markdown;charset=utf-8');
      final String url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', '${task.title.replaceAll(RegExp(r'[^\w\s-]'), '_')}_outline.md')
        ..click();
      html.Url.revokeObjectUrl(url);
      
      // Update firstDownloadedAt to start 48-hour countdown
      if (task.firstDownloadedAt == null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .doc(task.id)
            .update({'firstDownloadedAt': Timestamp.fromDate(DateTime.now())});
        
        final int index = tasks.indexWhere((TaskModel t) => t.id == task.id);
        if (index != -1) {
          tasks[index] = task.copyWith(firstDownloadedAt: DateTime.now());
          tasks.refresh();
        }
        
        Get.snackbar(
          'ดาวน์โหลดสำเร็จ',
          'ไฟล์โครงร่างถูกดาวน์โหลดแล้ว • เริ่มนับถอยหลัง 48 ชั่วโมง',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppTheme.accentGreen,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'ดาวน์โหลดสำเร็จ',
          'ไฟล์โครงร่างถูกดาวน์โหลดแล้ว',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppTheme.accentGreen,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถดาวน์โหลดได้: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  /// ลบงาน (overload สำหรับ String id และ TaskModel)
  Future<void> deleteTask(dynamic taskOrId) async {
    final AuthController authCtrl = Get.find<AuthController>();
    final user = authCtrl.currentUser.value;
    if (user == null) return;
    
    String taskId;
    if (taskOrId is String) {
      taskId = taskOrId;
    } else if (taskOrId is TaskModel) {
      taskId = taskOrId.id;
    } else {
      return;
    }
    
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId)
          .delete();
      
      tasks.removeWhere((TaskModel t) => t.id == taskId);
      Get.snackbar('สำเร็จ', 'ลบงานแล้ว', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถลบงานได้: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
