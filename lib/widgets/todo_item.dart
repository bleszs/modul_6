import 'package:flutter/material.dart';

import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.todo,
    required this.isBusy,
    required this.onToggle,
    required this.onDelete,
  });

  final Todo todo;
  final bool isBusy;
  final VoidCallback onToggle;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(todo.id),
      direction: isBusy ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 24),
        color: colors.errorContainer,
        child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
      ),
      confirmDismiss: (_) async {
        await onDelete();
        // The Firestore stream removes the row and restores it if a write fails.
        return false;
      },
      child: Row(
        children: [
          Expanded(
            child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                todo.task,
                style: TextStyle(
                  decoration: todo.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              value: todo.isDone,
              onChanged: isBusy ? null : (_) => onToggle(),
            ),
          ),
          IconButton(
            tooltip: 'Hapus tugas',
            onPressed: isBusy ? null : onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
