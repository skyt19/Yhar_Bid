/// lib/models/task_model.dart
/// Task Data Model — โครงสร้างข้อมูลงาน
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? category;
  
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
    required this.createdAt,
    this.dueDate,
    this.category,
  });
  
  factory TaskModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TaskModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isDone: data['isDone'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      category: data['category'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'createdAt': Timestamp.fromDate(createdAt),
      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),
      if (category != null) 'category': category,
    };
  }
  
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? createdAt,
    DateTime? dueDate,
    String? category,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
    );
  }
}
