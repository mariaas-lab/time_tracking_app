import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/time_entry_provider.dart';
import '../models/project.dart';
import 'add_time_entry_screen.dart';
import 'project_management_screen.dart';
import 'task_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // ✅ We no longer need to call loadEntries() manually,
    // because it's already done in provider's constructor (main.dart)
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _deleteEntry(BuildContext context, String id) {
    Provider.of<TimeEntryProvider>(context, listen: false).deleteEntry(id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Entry deleted successfully')));
  }

  Widget _buildEmptyState({required String title, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.hourglass_empty_rounded,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context);

    // ✅ Grouped by Project → Task → Entries
    final groupedData = <Project, Map<String, List<dynamic>>>{};

    for (var entry in provider.entries) {
      final project = provider.projects.firstWhere(
        (p) => p.id == entry.projectId,
        orElse: () => Project(id: 'unknown', name: 'Unknown Project'),
      );

      final taskName = provider.tasks
          .firstWhere(
            (t) => t.id == entry.taskId,
            orElse: () => provider.tasks.isNotEmpty
                ? provider.tasks.first
                : (throw Exception('Missing Task')),
          )
          .name;

      groupedData.putIfAbsent(project, () => {});
      groupedData[project]!.putIfAbsent(taskName, () => []);
      groupedData[project]![taskName]!.add(entry);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B9086),
        centerTitle: true,
        title: const Text(
          'Time Tracking',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black45,
          indicatorColor: const Color.fromARGB(255, 248, 211, 2),
          tabs: const [
            Tab(text: 'All Entries'),
            Tab(text: 'Grouped by Projects'),
          ],
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF4B9086)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Projects'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProjectManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Tasks'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaskManagementScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          // 🔹 TAB 1 — All Entries
          provider.entries.isEmpty
              ? _buildEmptyState(
                  title: 'No time entries yet!',
                  message: 'Tap the + button to add your first entry.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: provider.entries.length,
                  itemBuilder: (context, index) {
                    final entry = provider.entries[index];
                    final project = provider.projects.firstWhere(
                      (p) => p.id == entry.projectId,
                      orElse: () =>
                          Project(id: entry.projectId, name: 'Unknown Project'),
                    );

                    final taskName = provider.tasks
                        .firstWhere(
                          (t) => t.id == entry.taskId,
                          orElse: () => provider.tasks.isNotEmpty
                              ? provider.tasks.first
                              : (throw Exception('Missing Task')),
                        )
                        .name;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${project.name} - $taskName',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4B9086),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Total Time: ${entry.totalTime.toInt()} hours',
                                  ),
                                  Text(
                                    'Date: ${DateFormat.yMMMd().format(entry.date)}',
                                  ),
                                  Text('Note: ${entry.notes}'),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deleteEntry(context, entry.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

          // 🔹 TAB 2 — Grouped by Project
          provider.entries.isEmpty
              ? _buildEmptyState(
                  title: 'No time entries yet!',
                  message: 'Tap the + button to add your first entry.',
                )
              : ListView(
                  padding: const EdgeInsets.all(8),
                  children: groupedData.entries.map((projectEntry) {
                    final project = projectEntry.key;
                    final tasksMap = projectEntry.value;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4B9086),
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...tasksMap.entries.map((taskEntry) {
                              final taskName = taskEntry.key;
                              final entries = taskEntry.value;

                              final totalHours = entries.fold<double>(
                                0,
                                (sum, e) => sum + e.totalTime,
                              );

                              final latestDate = entries.isNotEmpty
                                  ? entries.last.date
                                  : null;

                              final formattedDate = latestDate != null
                                  ? ' (${DateFormat.yMMMd().format(latestDate)})'
                                  : '';

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  '- $taskName: ${totalHours.toInt()} hours$formattedDate',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 239, 188, 4),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTimeEntryScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
