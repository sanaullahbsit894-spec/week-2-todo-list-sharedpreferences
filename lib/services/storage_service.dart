import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const String _tasksKey = 'tasks';
  static const String _counterKey = 'counter';

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_tasksKey) ?? [];
    return raw.map((e) => Task.fromMap(jsonDecode(e))).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = tasks.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList(_tasksKey, encoded);
  }

  Future<int> loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_counterKey) ?? 0;
  }

  Future<void> saveCounter(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, value);
  }
}
