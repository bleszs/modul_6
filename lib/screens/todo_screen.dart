import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../services/firestore_service.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/todo_dialog.dart';
import '../widgets/todo_item.dart';
import 'profile_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key, this.firestoreService});

  final FirestoreService? firestoreService;

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late final _firestoreService = widget.firestoreService ?? FirestoreService();
  late Stream<List<Todo>> _todos = _firestoreService.getTodos();
  final _pending = <String>{};

  Future<void> _runTodoAction(
    String id,
    Future<void> Function() action,
    String errorMessage,
  ) async {
    if (_pending.contains(id)) return;

    setState(() => _pending.add(id));
    try {
      await action();
    } catch (_) {
      if (mounted) SnackBarHelper.show(context, errorMessage);
    } finally {
      if (mounted) setState(() => _pending.remove(id));
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Hapus tugas?'),
        content: Text('“${todo.task}” akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    await _runTodoAction(
      todo.id,
      () => _firestoreService.deleteTodoStatus(todo.id),
      'Gagal menghapus tugas. Coba lagi.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar tugas'),
        actions: [
          IconButton(
            tooltip: 'Profil',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Todo>>(
          stream: _todos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Gagal memuat tugas.'),
                    TextButton(
                      onPressed: () => setState(() {
                        _todos = _firestoreService.getTodos();
                      }),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              );
            }

            final todos = snapshot.data ?? const <Todo>[];
            if (todos.isEmpty) {
              return const Center(child: Text('Belum ada tugas.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return TodoItem(
                  key: ValueKey(todo.id),
                  todo: todo,
                  isBusy: _pending.contains(todo.id),
                  onToggle: () => _runTodoAction(
                    todo.id,
                    () => _firestoreService.updateTodoStatus(
                      todo.id,
                      todo.isDone,
                    ),
                    'Gagal mengubah status tugas. Coba lagi.',
                  ),
                  onDelete: () => _deleteTodo(todo),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (context) =>
                TodoDialog(firestoreService: _firestoreService),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah tugas'),
      ),
    );
  }
}
