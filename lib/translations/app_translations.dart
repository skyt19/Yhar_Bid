/// lib/translations/app_translations.dart
/// ระบบแปลภาษา TH/EN สำหรับแอป Yharbid
import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'th_TH': {
          // Navigation & Common
          'app_title': 'Yharbid',
          'dashboard': 'หน้าหลัก',
          'ai_chatbot': 'AI จาร์วิส',
          'calendar': 'ปฏิทิน',
          'tasks': 'จัดการงาน',
          'settings': 'ตั้งค่า',
          'back': 'กลับ',
          'save': 'บันทึก',
          'cancel': 'ยกเลิก',
          'confirm': 'ยืนยัน',
          'delete': 'ลบ',
          'edit': 'แก้ไข',
          'add': 'เพิ่ม',
          'loading': 'กำลังโหลด...',
          'success': 'สำเร็จ',
          'error': 'เกิดข้อผิดพลาด',
          
          // Login & Auth
          'please_login': 'โปรดล็อกอินหรือสมัคร',
          'sign_in_google': 'Google',
          'sign_out': 'ออกจากระบบ',
          'welcome_back': 'ยินดีต้อนรับกลับ',
          
          // Dashboard
          'incoming_work': 'Incoming Work',
          'work_in_week': 'Work in week',
          'calendar_api': 'Calendar API',
          'add_appointment': '+ เพิ่มนัดหมาย',
          'sync_calendar': '🔄 Sync Calendar',
          'no_tasks': 'ไม่มีงานในขณะนี้',
          'tasks_today': 'งานวันนี้',
          'tasks_this_week': 'งานสัปดาห์นี้',
          
          // Calendar
          'sync_with_google': 'ซิงค์กับ Google Calendar',
          'create_event': 'สร้างกิจกรรม',
          'event_title': 'ชื่อกิจกรรม',
          'event_description': 'รายละเอียด',
          'start_time': 'เวลาเริ่มต้น',
          'end_time': 'เวลาสิ้นสุด',
          'no_events': 'ไม่มีกิจกรรม',
          
          // Settings
          'advanced_settings': 'การตั้งค่าขั้นสูง',
          'language': 'ภาษา',
          'ai_style': 'สไตล์ AI',
          'notifications': 'การแจ้งเตือน',
          'account': 'บัญชี',
          'clear_cache': 'ล้างข้อมูลแคชชั่วคราว',
          'reset_calendar': 'รีเซ็ตการเชื่อมต่อ Calendar',
          'ai_memory': 'เปิดใช้งาน Contextual Memory',
          'ai_behavior': 'สไตล์การตอบของ AI',
          'current_email': 'อีเมลที่ล็อกอินอยู่',
          
          // AI Personalities
          'polite_jarvis': 'สุภาพ (Polite Jarvis)',
          'friendly': 'เป็นกันเอง (Friendly)',
          'aggressive_motivator': 'กระตุ้นแรง (Aggressive)',
          
          // Roles
          'student': 'นักศึกษา',
          'employee': 'บุคลากร',
          'educator': 'อาจารย์',
          'select_role': 'เลือกบทบาท',
          
          // Messages
          'calendar_synced': 'ซิงค์ปฏิทินสำเร็จ',
          'event_created': 'สร้างกิจกรรมสำเร็จ',
          'cache_cleared': 'ล้างแคชสำเร็จ',
          'sign_out_confirm': 'คุณต้องการออกจากระบบใช่หรือไม่?',
        },
        'en_US': {
          // Navigation & Common
          'app_title': 'Yharbid',
          'dashboard': 'Dashboard',
          'ai_chatbot': 'AI Jarvis',
          'calendar': 'Calendar',
          'tasks': 'Tasks',
          'settings': 'Settings',
          'back': 'Back',
          'save': 'Save',
          'cancel': 'Cancel',
          'confirm': 'Confirm',
          'delete': 'Delete',
          'edit': 'Edit',
          'add': 'Add',
          'loading': 'Loading...',
          'success': 'Success',
          'error': 'Error',
          
          // Login & Auth
          'please_login': 'Please Login or Sign Up',
          'sign_in_google': 'Google',
          'sign_out': 'Sign Out',
          'welcome_back': 'Welcome Back',
          
          // Dashboard
          'incoming_work': 'Incoming Work',
          'work_in_week': 'Work in week',
          'calendar_api': 'Calendar API',
          'add_appointment': '+ Add Appointment',
          'sync_calendar': '🔄 Sync Calendar',
          'no_tasks': 'No tasks at the moment',
          'tasks_today': 'Tasks Today',
          'tasks_this_week': 'Tasks This Week',
          
          // Calendar
          'sync_with_google': 'Sync with Google Calendar',
          'create_event': 'Create Event',
          'event_title': 'Event Title',
          'event_description': 'Description',
          'start_time': 'Start Time',
          'end_time': 'End Time',
          'no_events': 'No events',
          
          // Settings
          'advanced_settings': 'Advanced Settings',
          'language': 'Language',
          'ai_style': 'AI Style',
          'notifications': 'Notifications',
          'account': 'Account',
          'clear_cache': 'Clear Temporary Cache',
          'reset_calendar': 'Reset Calendar Connection',
          'ai_memory': 'Enable Contextual Memory',
          'ai_behavior': 'AI Response Style',
          'current_email': 'Current Email',
          
          // AI Personalities
          'polite_jarvis': 'Polite (Jarvis)',
          'friendly': 'Friendly',
          'aggressive_motivator': 'Aggressive Motivator',
          
          // Roles
          'student': 'Student',
          'employee': 'Employee',
          'educator': 'Educator',
          'select_role': 'Select Role',
          
          // Messages
          'calendar_synced': 'Calendar synced successfully',
          'event_created': 'Event created successfully',
          'cache_cleared': 'Cache cleared successfully',
          'sign_out_confirm': 'Do you want to sign out?',
        },
      };
}
