import '../models/project.dart';
import '../models/task.dart';
import '../models/time_entry.dart';

class LocalDB {
  // Temporary in-memory DB (you can replace with real local storage later)
  List<Project> _projects = [];
  List<Task> _tasks = [];
  List<TimeEntry> _entries = [];

  Future<List<Project>> loadProjects() async => _projects;
  Future<List<Task>> loadTasks() async => _tasks;
  Future<List<TimeEntry>> loadEntries() async => _entries;

  Future<void> saveProjects(List<Project> list) async => _projects = list;
  Future<void> saveTasks(List<Task> list) async => _tasks = list;
  Future<void> saveEntries(List<TimeEntry> list) async => _entries = list;
}
