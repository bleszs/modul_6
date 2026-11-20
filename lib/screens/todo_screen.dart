import 'package:flutter/material.dart';
import 'package:modul_6/services/firestore_service.dart';
import 'package:modul_6/widgets/todo_dialog.dart';

class TodoScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo List')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) =>
                TodoDialog(firestoreService: _firestoreService),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
