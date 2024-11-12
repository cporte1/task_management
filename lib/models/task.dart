import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  String name;
  bool isCompleted;
  Map<String, dynamic> subTasks;

  Task({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.subTasks = const {},
  });

  // Converts Task object to a map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'subTasks': subTasks,
    };
  }

  // Converts a Firebase document to a Task object
  factory Task.fromDocument(DocumentSnapshot doc) {
    return Task(
      id: doc.id,
      name: doc['name'] ?? '',
      isCompleted: doc['isCompleted'] ?? false,
      subTasks: Map<String, dynamic>.from(doc['subTasks'] ?? {}),
    );
  }
}
