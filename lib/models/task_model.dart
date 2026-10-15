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
  final String priority;
  final DateTime? firstDownloadedAt;
  final String? fileUrl;
  
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
    required this.createdAt,
    this.dueDate,
    this.category,
    this.priority = 'Medium',
    this.firstDownloadedAt,
    this.fileUrl,
  });
  
  DateTime get expiresAt {
    if (firstDownloadedAt != null) {
      return firstDownloadedAt!.add(const Duration(hours: 48));
    }
    return createdAt.add(const Duration(days: 7));
  }
  
  bool get isFileExpired => DateTime.now().isAfter(expiresAt);
  
  factory TaskModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TaskModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isDone: data['isDone'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      category: data['category'],
      priority: data['priority'] ?? 'Medium',
      firstDownloadedAt: (data['firstDownloadedAt'] as Timestamp?)?.toDate(),
      fileUrl: data['fileUrl'],
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
      'priority': priority,
      if (firstDownloadedAt != null) 'firstDownloadedAt': Timestamp.fromDate(firstDownloadedAt!),
      if (fileUrl != null) 'fileUrl': fileUrl,
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
    String? priority,
    DateTime? firstDownloadedAt,
    String? fileUrl,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      firstDownloadedAt: firstDownloadedAt ?? this.firstDownloadedAt,
      fileUrl: fileUrl ?? this.fileUrl,
    );
  }
}
