/// lib/controllers/navigation_controller.dart
/// Navigation State Management — จัดการการสลับหน้าจอหลัก
import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;
  
  void changePage(int index) {
    currentIndex.value = index;
  }
  
  String getCurrentPageTitle() {
    switch (currentIndex.value) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Calendar & Schedule';
      case 2:
        return 'AI Workspace';
      case 3:
        return 'Tasks & Projects';
      case 4:
        return 'Settings';
      default:
        return 'Yharbid';
    }
  }
}
