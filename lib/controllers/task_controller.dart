/// lib/controllers/task_controller.dart
/// Task Management Controller — จัดการงานและ Projects
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../controllers/auth_controller.dart';

class TaskController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  

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
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถอัปเดตสถานะได้: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  /// ลบงาน
  Future<void> deleteTask(TaskModel task) async {
    final AuthController authCtrl = Get.find<AuthController>();
    final user = authCtrl.currentUser.value;
    if (user == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(task.id)
          .delete();
      
      tasks.removeWhere((t) => t.id == task.id);
      Get.snackbar('สำเร็จ', 'ลบงานแล้ว', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถลบงานได้: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
