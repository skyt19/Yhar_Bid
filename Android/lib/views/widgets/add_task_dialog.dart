library;

/// lib/views/widgets/add_task_dialog.dart
/// Dialog สำหรับเพิ่มงานใหม่ พร้อม Google Calendar Integration
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/calendar_controller.dart';
import '../../services/auth_service.dart';
import '../theme/app_theme.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _priority = 'Medium';
  bool _syncToCalendar = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _pickStartTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _startTime = time;
        // Auto-set end time to 1 hour after start time
        if (_endTime == null) {
          final now = DateTime.now();
          final start = DateTime(now.year, now.month, now.day, time.hour, time.minute);
          final end = start.add(const Duration(hours: 1));
          _endTime = TimeOfDay(hour: end.hour, minute: end.minute);
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _endTime ?? (_startTime ?? TimeOfDay.now()),
    );
    if (time != null) setState(() => _endTime = time);
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'กรุณากรอกชื่องาน', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final TaskController taskCtrl = Get.find<TaskController>();
    DateTime? dueDate;
    
    if (_selectedDate != null) {
      if (_selectedTime != null) {
        dueDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
      } else {
        dueDate = _selectedDate;
      }
    }

    final bool taskSuccess = await taskCtrl.addTask(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: dueDate,
      category: _priority,
    );

    if (!taskSuccess) {
      Get.snackbar('Error', 'ไม่สามารถบันทึกงานได้', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Sync to Google Calendar if checkbox enabled
    if (_syncToCalendar && _selectedDate != null) {
      // Validate time inputs
      if (_startTime == null || _endTime == null) {
        Get.snackbar('คำเตือน', 'กรุณาระบุเวลาเริ่มต้นและสิ้นสุดสำหรับ Calendar Event', 
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
        return;
      }
      
      final CalendarController calCtrl = Get.find<CalendarController>();
      
      // Debug: Check if user has calendar scope
      final AuthService authService = AuthService();
      final String? token = await authService.getAccessToken();
      
      if (token == null || token.isEmpty) {
        Get.snackbar('คำเตือน', 'ไม่สามารถดึง Access Token ได้ กรุณาเข้าสู่ระบบใหม่', 
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
        Get.back();
        return;
      }

      // Request Calendar Scope if not granted
      final bool hasScope = await authService.hasCalendarScope();
      if (!hasScope) {
        Get.snackbar('ต้องการสิทธิ์', 'กำลังขอสิทธิ์เข้าถึง Google Calendar...', 
            snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
        final bool granted = await authService.requestCalendarScope();
        if (!granted) {
          Get.snackbar('ไม่สำเร็จ', 'กรุณาอนุญาตให้แอปเข้าถึง Google Calendar', 
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
          Get.back();
          return;
        }
      }
      
      // Create DateTime from date + start/end times
      final DateTime startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      
      final DateTime endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );
      
      // Validate: end time must be after start time
      if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
        Get.snackbar('คำเตือน', 'เวลาสิ้นสุดต้องมากกว่าเวลาเริ่มต้น', 
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
        return;
      }
      
      final bool calendarSuccess = await calCtrl.createEvent(
        title: _titleController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        description: _descriptionController.text.trim(),
      );

      if (calendarSuccess) {
        // Force refresh calendar events
        await calCtrl.fetchEvents();
        Get.snackbar('สำเร็จ', 'บันทึกงาน "${_titleController.text}" และซิงค์ลง Google Calendar แล้ว', 
            snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
      } else {
        // Show detailed error from CalendarController
        Get.snackbar('คำเตือน', 'บันทึกงานสำเร็จ แต่ไม่สามารถซิงค์ลง Calendar ได้\n${calCtrl.errorMessage.value}', 
            snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5), backgroundColor: Colors.orange);
      }
    } else {
      Get.snackbar('สำเร็จ', 'บันทึกงาน "${_titleController.text}" แล้ว', 
          snackPosition: SnackPosition.BOTTOM);
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
      child: Container(width: 450, padding: const EdgeInsets.all(24), child: SingleChildScrollView(child: _buildContent())),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Add New Task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
          ],
        ),
        const SizedBox(height: 20),
        TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Task Title *', hintText: 'Enter task name')),
        const SizedBox(height: 16),
        TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', hintText: 'What needs to be done?')),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(child: OutlinedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.calendar_today), label: Text(_selectedDate == null ? 'Pick Date' : '${_selectedDate!.day}/${_selectedDate!.month}'))),
            const SizedBox(width: 12),
            if (!_syncToCalendar)
              Expanded(child: OutlinedButton.icon(onPressed: _pickTime, icon: const Icon(Icons.access_time), label: Text(_selectedTime == null ? 'Due Time' : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'))),
          ],
        ),
        const SizedBox(height: 16),
        // Show Start/End Time pickers when Calendar Sync is enabled
        if (_syncToCalendar) ...[
          const Text('Event Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickStartTime,
                  icon: const Icon(Icons.access_time),
                  label: Text(_startTime == null ? 'Start Time *' : '${_startTime!.hour}:${_startTime!.minute.toString().padLeft(2, '0')}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _startTime == null ? Colors.red : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickEndTime,
                  icon: const Icon(Icons.access_time),
                  label: Text(_endTime == null ? 'End Time *' : '${_endTime!.hour}:${_endTime!.minute.toString().padLeft(2, '0')}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _endTime == null ? Colors.red : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        const Text('Priority', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: <String>['High', 'Medium', 'Low']
              .map((String p) {
                final bool isSelected = _priority == p;
                return ChoiceChip(
                  label: Text(p),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    if (selected) setState(() => _priority = p);
                  },
                  selectedColor: AppTheme.accentPrimary,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textPrimary),
                );
              })
              .toList(),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(title: const Text('Add to Google Calendar'), value: _syncToCalendar, onChanged: (bool? value) => setState(() => _syncToCalendar = value ?? false), controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveTask, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Save Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
      ],
    );
  }
}

