library;

/// lib/views/widgets/add_task_dialog.dart
/// Dialog สำหรับเพิ่มงานใหม่ พร้อม Google Calendar Integration
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/calendar_controller.dart';
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

    final bool success = await taskCtrl.addTask(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: dueDate,
      category: _priority,
    );

    if (success && _syncToCalendar && dueDate != null) {
      final CalendarController calCtrl = Get.find<CalendarController>();
      await calCtrl.createEvent(
        title: _titleController.text.trim(),
        startTime: dueDate,
        endTime: dueDate.add(const Duration(hours: 1)),
        description: _descriptionController.text.trim(),
      );
    }

    if (success) Get.back();
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
            Expanded(child: OutlinedButton.icon(onPressed: _pickTime, icon: const Icon(Icons.access_time), label: Text(_selectedTime == null ? 'Pick Time' : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'))),
          ],
        ),
        const SizedBox(height: 16),
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

