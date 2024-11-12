import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get tasksCollection =>
      FirebaseFirestore.instance.collection('tasks');

  Future<void> _addTask() async {
    final String taskName = _taskController.text.trim();
    if (taskName.isNotEmpty) {
      try {
        await tasksCollection.add({
          'name': taskName,
          'isCompleted': false,
          'subTasks': {
            'Monday': {
              '9am-10am': ['HW1', 'Essay2'],
              '12pm-2pm': ['HW3'],
            },
            'Tuesday': {
              '10am-12pm': ['Meeting'],
            }
          },
        });
        _taskController.clear();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add task: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a task name')),
      );
    }
  }

  void _toggleComplete(Task task) {
    tasksCollection.doc(task.id).update({'isCompleted': !task.isCompleted});
  }

  void _deleteTask(Task task) {
    tasksCollection.doc(task.id).delete();
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Manager',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(labelText: 'Enter task name'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tasksCollection.snapshots(),
              builder: (ctx, taskSnapshot) {
                if (taskSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (taskSnapshot.hasError) {
                  return Center(child: Text('An error occurred! ${taskSnapshot.error}'));
                }
                final taskDocs = taskSnapshot.data?.docs ?? [];
                if (taskDocs.isEmpty) {
                  return Center(child: Text('No tasks available.'));
                }
                return ListView.builder(
                  itemCount: taskDocs.length,
                  itemBuilder: (ctx, index) {
                    final task = Task.fromDocument(taskDocs[index]);
                    // Alternate background color for tasks
                    final backgroundColor = index % 2 == 0
                        ? Colors.white
                        : Colors.yellow[100];
                    return Container(
                      color: backgroundColor,
                      child: TaskItem(
                        task: task,
                        onToggleComplete: _toggleComplete,
                        onDelete: _deleteTask,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
