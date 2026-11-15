/// lib/core/localization/app_translations.dart
/// Complete Thai/English localization for Yhar Bid
/// Phase 12: Comprehensive localization support

import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          // Navigation
          'dashboard': 'Dashboard',
          'tasks': 'Tasks',
          'calendar': 'Calendar',
          'ai_assistance': 'AI Assistance',
          'settings': 'Settings',
          'profile': 'Profile',
          'logout': 'Logout',

          // Common Actions
          'add': 'Add',
          'edit': 'Edit',
          'delete': 'Delete',
          'save': 'Save',
          'cancel': 'Cancel',
          'confirm': 'Confirm',
          'close': 'Close',
          'ok': 'OK',
          'yes': 'Yes',
          'no': 'No',
          'search': 'Search',
          'filter': 'Filter',
          'refresh': 'Refresh',
          'sync': 'Sync',
          'loading': 'Loading...',
          'error': 'Error',
          'success': 'Success',

          // Task Management
          'add_task': 'Add Task',
          'all_tasks': 'All Tasks',
          'pending_tasks': 'Pending Tasks',
          'completed_tasks': 'Completed Tasks',
          'no_tasks': 'No tasks yet',
          'task_details': 'Task Details',
          'task_title': 'Task Title',
          'task_description': 'Description',
          'task_priority': 'Priority',
          'task_status': 'Status',
          'task_category': 'Category',
          'due_date': 'Due Date',
          'created_date': 'Created',
          'mark_complete': 'Mark as Completed',
          'mark_pending': 'Mark as Pending',
          'delete_task': 'Delete Task',
          'delete_task_confirm': 'Are you sure you want to delete this task?',
          'delete_all_tasks': 'Delete All Tasks',
          'delete_all_confirm': 'Are you sure you want to delete all {count} tasks? This action cannot be undone.',
          'task_deleted': 'Task deleted',
          'tasks_deleted': 'Deleted {count} tasks',
          'no_tasks_to_delete': 'No tasks to delete',
          'priority_high': 'High',
          'priority_medium': 'Medium',
          'priority_low': 'Low',
          'status_pending': 'Pending',
          'status_completed': 'Completed',
          'total': 'Total',
          'pending': 'Pending',
          'done': 'Done',

          // Calendar
          'calendar_synced': 'Calendar synced',
          'events_found': 'events found',
          'no_events': 'No events',
          'event_details': 'Event Details',

          // AI Assistance
          'ai_chat': 'AI Chat',
          'new_conversation': 'New Conversation',
          'conversations': 'Conversations',
          'delete_conversation': 'Delete Conversation',
          'delete_conversation_confirm': 'Are you sure you want to delete this conversation? This action cannot be undone.',
          'conversation_deleted': 'Conversation deleted',
          'no_conversations': 'No conversations yet',
          'type_message': 'Type your message...',
          'send': 'Send',
          'ai_thinking': 'AI is thinking...',
          'ai_error': 'An error occurred',

          // Personality Levels
          'personality_standard': 'Standard',
          'personality_advanced': 'Advanced',
          'personality_executive': 'Executive',

          // Authentication
          'sign_in': 'Sign In',
          'sign_in_google': 'Sign in with Google',
          'sign_out': 'Sign Out',
          'welcome': 'Welcome',
          'login_successful': 'Login successful',
          'login_failed': 'Login failed',

          // Settings
          'language': 'Language',
          'thai': 'ภาษาไทย',
          'english': 'English',
          'appearance': 'Appearance',
          'theme': 'Theme',
          'notifications': 'Notifications',

          // Errors
          'error_occurred': 'An error occurred',
          'network_error': 'Network error',
          'authentication_error': 'Authentication error',
          'permission_denied': 'Permission denied',
          'not_found': 'Not found',
          'try_again': 'Try again',

          // Empty States
          'no_data': 'No data available',
          'no_results': 'No results found',
          'empty_state_message': 'Nothing to show here yet',

          // Time & Date
          'today': 'Today',
          'tomorrow': 'Tomorrow',
          'yesterday': 'Yesterday',
          'this_week': 'This Week',
          'this_month': 'This Month',
          'last_updated': 'Last updated',
        },
        'th_TH': {
          // Navigation
          'dashboard': 'แดชบอร์ด',
          'tasks': 'งาน',
          'calendar': 'ปฏิทิน',
          'ai_assistance': 'ผู้ช่วย AI',
          'settings': 'ตั้งค่า',
          'profile': 'โปรไฟล์',
          'logout': 'ออกจากระบบ',

          // Common Actions
          'add': 'เพิ่ม',
          'edit': 'แก้ไข',
          'delete': 'ลบ',
          'save': 'บันทึก',
          'cancel': 'ยกเลิก',
          'confirm': 'ยืนยัน',
          'close': 'ปิด',
          'ok': 'ตกลง',
          'yes': 'ใช่',
          'no': 'ไม่',
          'search': 'ค้นหา',
          'filter': 'กรอง',
          'refresh': 'รีเฟรช',
          'sync': 'ซิงค์',
          'loading': 'กำลังโหลด...',
          'error': 'ข้อผิดพลาด',
          'success': 'สำเร็จ',

          // Task Management
          'add_task': 'เพิ่มงาน',
          'all_tasks': 'งานทั้งหมด',
          'pending_tasks': 'งานที่รอดำเนินการ',
          'completed_tasks': 'งานที่เสร็จแล้ว',
          'no_tasks': 'ยังไม่มีงาน',
          'task_details': 'รายละเอียดงาน',
          'task_title': 'ชื่องาน',
          'task_description': 'คำอธิบาย',
          'task_priority': 'ความสำคัญ',
          'task_status': 'สถานะ',
          'task_category': 'หมวดหมู่',
          'due_date': 'กำหนดส่ง',
          'created_date': 'สร้างเมื่อ',
          'mark_complete': 'ทำเครื่องหมายว่าเสร็จแล้ว',
          'mark_pending': 'ทำเครื่องหมายว่ารอดำเนินการ',
          'delete_task': 'ลบงาน',
          'delete_task_confirm': 'คุณแน่ใจหรือไม่ว่าต้องการลบงานนี้',
          'delete_all_tasks': 'ลบงานทั้งหมด',
          'delete_all_confirm': 'คุณแน่ใจหรือไม่ว่าต้องการลบงานทั้งหมด {count} งาน การกระทำนี้ไม่สามารถยกเลิกได้',
          'task_deleted': 'ลบงานแล้ว',
          'tasks_deleted': 'ลบงาน {count} งานแล้ว',
          'no_tasks_to_delete': 'ไม่มีงานที่จะลบ',
          'priority_high': 'สูง',
          'priority_medium': 'ปานกลาง',
          'priority_low': 'ต่ำ',
          'status_pending': 'รอดำเนินการ',
          'status_completed': 'เสร็จแล้ว',
          'total': 'ทั้งหมด',
          'pending': 'รอดำเนินการ',
          'done': 'เสร็จแล้ว',

          // Calendar
          'calendar_synced': 'ซิงค์ปฏิทินแล้ว',
          'events_found': 'กิจกรรมที่พบ',
          'no_events': 'ไม่มีกิจกรรม',
          'event_details': 'รายละเอียดกิจกรรม',

          // AI Assistance
          'ai_chat': 'แชทกับ AI',
          'new_conversation': 'การสนทนาใหม่',
          'conversations': 'การสนทนา',
          'delete_conversation': 'ลบการสนทนา',
          'delete_conversation_confirm': 'คุณแน่ใจหรือไม่ว่าต้องการลบการสนทนานี้ การกระทำนี้ไม่สามารถยกเลิกได้',
          'conversation_deleted': 'ลบการสนทนาแล้ว',
          'no_conversations': 'ยังไม่มีการสนทนา',
          'type_message': 'พิมพ์ข้อความของคุณ...',
          'send': 'ส่ง',
          'ai_thinking': 'AI กำลังคิด...',
          'ai_error': 'เกิดข้อผิดพลาด',

          // Personality Levels
          'personality_standard': 'มาตรฐาน',
          'personality_advanced': 'ขั้นสูง',
          'personality_executive': 'ผู้บริหาร',

          // Authentication
          'sign_in': 'เข้าสู่ระบบ',
          'sign_in_google': 'เข้าสู่ระบบด้วย Google',
          'sign_out': 'ออกจากระบบ',
          'welcome': 'ยินดีต้อนรับ',
          'login_successful': 'เข้าสู่ระบบสำเร็จ',
          'login_failed': 'เข้าสู่ระบบไม่สำเร็จ',

          // Settings
          'language': 'ภาษา',
          'thai': 'ภาษาไทย',
          'english': 'English',
          'appearance': 'รูปลักษณ์',
          'theme': 'ธีม',
          'notifications': 'การแจ้งเตือน',

          // Errors
          'error_occurred': 'เกิดข้อผิดพลาด',
          'network_error': 'ข้อผิดพลาดเครือข่าย',
          'authentication_error': 'ข้อผิดพลาดการยืนยันตัวตน',
          'permission_denied': 'ไม่ได้รับอนุญาต',
          'not_found': 'ไม่พบ',
          'try_again': 'ลองอีกครั้ง',

          // Empty States
          'no_data': 'ไม่มีข้อมูล',
          'no_results': 'ไม่พบผลลัพธ์',
          'empty_state_message': 'ยังไม่มีอะไรที่นี่',

          // Time & Date
          'today': 'วันนี้',
          'tomorrow': 'พรุ่งนี้',
          'yesterday': 'เมื่อวาน',
          'this_week': 'สัปดาห์นี้',
          'this_month': 'เดือนนี้',
          'last_updated': 'อัปเดตล่าสุด',
        },
      };
}
