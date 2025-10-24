import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';

class TimeEntryProvider extends ChangeNotifier {
  final LocalStorage storage = LocalStorage('time_tracker_data.json');

  List<TimeEntry> _entries = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];

  List<TimeEntry> get entries => _entries;
  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  Map<Project, Map<Task, List<TimeEntry>>> get groupedByProjectAndTask {
    final Map<Project, Map<Task, List<TimeEntry>>> result = {};

    for (final entry in _entries) {
      final project = _projects.firstWhere(
        (p) => p.id == entry.projectId,
        orElse: () => Project(id: 'unknown', name: 'Unknown Project'),
      );

      final task = _tasks.firstWhere(
        (t) => t.id == entry.taskId,
        orElse: () =>
            Task(id: 'unknown', projectId: project.id, name: 'Unknown Task'),
      );

      result.putIfAbsent(project, () => {});
      result[project]!.putIfAbsent(task, () => []);
      result[project]![task]!.add(entry);
    }

    return result;
  }

  Future<void> loadEntries() async {
    await storage.ready;

    final storedData = storage.getItem('time_tracker_data.json');

    if (storedData != null) {
      _projects = List<Map<String, dynamic>>.from(
        storedData['projects'] ?? [],
      ).map((e) => Project.fromJson(e)).toList();
      _tasks = List<Map<String, dynamic>>.from(
        storedData['tasks'] ?? [],
      ).map((e) => Task.fromJson(e)).toList();
      _entries = List<Map<String, dynamic>>.from(
        storedData['timeEntries'] ?? [],
      ).map((e) => TimeEntry.fromJson(e)).toList();
    }

    // If empty, add a default project & task
    if (_projects.isEmpty) {
      final defaultProject = Project(
        id: DateTime.now().toIso8601String(),
        name: 'Default Project',
      );
      _projects.add(defaultProject);

      final defaultTask = Task(
        id: DateTime.now().toIso8601String(),
        projectId: defaultProject.id,
        name: 'Default Task',
      );
      _tasks.add(defaultTask);

      await saveAll();
    }

    notifyListeners();
  }

  Future<void> saveAll() async {
    await storage.ready;

    await storage.setItem('time_tracker_data.json', {
      'projects': _projects.map((e) => e.toJson()).toList(),
      'tasks': _tasks.map((e) => e.toJson()).toList(),
      'timeEntries': _entries.map((e) => e.toJson()).toList(),
    });
  }

  Future<void> addEntry(TimeEntry entry) async {
    _entries.add(entry);
    await saveAll();
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    await saveAll();
    notifyListeners();
  }

  Future<void> addProject(String name) async {
    final project = Project(id: DateTime.now().toIso8601String(), name: name);
    _projects.add(project);
    await saveAll();
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    _projects.removeWhere((p) => p.id == id);
    _tasks.removeWhere((t) => t.projectId == id);
    _entries.removeWhere((e) => e.projectId == id);
    await saveAll();
    notifyListeners();
  }

  Future<void> addTask(String projectId, String name) async {
    final task = Task(
      id: DateTime.now().toIso8601String(),
      projectId: projectId,
      name: name,
    );
    _tasks.add(task);
    await saveAll();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    _entries.removeWhere((e) => e.taskId == id);
    await saveAll();
    notifyListeners();
  }

  List<Task> getTasksByProject(String projectId) {
    return _tasks.where((t) => t.projectId == projectId).toList();
  }

  Map<String, double> getTotalTimeByProject() {
    final Map<String, double> grouped = {};
    for (var e in _entries) {
      grouped[e.projectId] = (grouped[e.projectId] ?? 0) + e.totalTime;
    }
    return grouped;
  }
}
