import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modul_6/models/todo.dart';
import 'package:modul_6/screens/todo_screen.dart';
import 'package:modul_6/services/firestore_service.dart';

void main() {
  testWidgets('adds, completes, and deletes tasks from the live list', (
    tester,
  ) async {
    final service = _FakeFirestoreService();
    addTearDown(service.close);
    await tester.pumpWidget(
      MaterialApp(home: TodoScreen(firestoreService: service)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Belum ada tugas.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan nama tugas.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '  Belajar Firestore  ');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Belajar Firestore'), findsOneWidget);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isTrue,
    );

    await tester.drag(find.byType(CheckboxListTile), const Offset(-480, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Belajar Firestore'), findsOneWidget);

    await tester.tap(find.byTooltip('Hapus tugas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada tugas.'), findsOneWidget);
  });

  testWidgets('keeps the task name when Firestore rejects a save', (
    tester,
  ) async {
    final service = _FakeFirestoreService()..rejectNextAdd = true;
    addTearDown(service.close);
    await tester.pumpWidget(
      MaterialApp(home: TodoScreen(firestoreService: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Baca Modul 7');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Gagal menyimpan tugas. Coba lagi.'), findsOneWidget);
    expect(find.text('Baca Modul 7'), findsOneWidget);

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Baca Modul 7'), findsOneWidget);
  });
}

class _FakeFirestoreService implements FirestoreService {
  final _changes = StreamController<List<Todo>>.broadcast();
  final _items = <Todo>[];
  int _nextId = 0;
  bool rejectNextAdd = false;

  @override
  Stream<List<Todo>> getTodos() async* {
    yield List.of(_items);
    yield* _changes.stream;
  }

  @override
  Future<void> addTodo(String taskName) async {
    if (rejectNextAdd) {
      rejectNextAdd = false;
      throw StateError('Write rejected');
    }
    _items.insert(0, Todo(id: '${_nextId++}', task: taskName, isDone: false));
    _changes.add(List.of(_items));
  }

  @override
  Future<void> updateTodoStatus(String id, bool currentStatus) async {
    final index = _items.indexWhere((todo) => todo.id == id);
    final todo = _items[index];
    _items[index] = Todo(id: todo.id, task: todo.task, isDone: !currentStatus);
    _changes.add(List.of(_items));
  }

  @override
  Future<void> deleteTodoStatus(String id) async {
    _items.removeWhere((todo) => todo.id == id);
    _changes.add(List.of(_items));
  }

  Future<void> close() => _changes.close();
}
