import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class TodoDialog extends StatefulWidget {
  final FirestoreService firestoreService;
  const TodoDialog({super.key, required this.firestoreService});

  @override
  State<TodoDialog> createState() => _TodoDialogState();
}

class _TodoDialogState extends State<TodoDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskController = TextEditingController();
  bool _isSaving = false;
  String? _saveError;

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    try {
      await widget.firestoreService.addTodo(_taskController.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = 'Gagal menyimpan tugas. Coba lagi.';
        });
      }
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Tambah tugas'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _taskController,
          autofocus: true,
          readOnly: _isSaving,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Nama tugas',
            errorText: _saveError,
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Masukkan nama tugas.'
              : null,
          onFieldSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isSaving ? 'Menyimpan…' : 'Simpan'),
        ),
      ],
    );
  }
}
