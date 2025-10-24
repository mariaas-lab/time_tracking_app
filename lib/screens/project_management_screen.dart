import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';
import '../utils/constants.dart';

class ProjectManagementScreen extends StatefulWidget {
  const ProjectManagementScreen({super.key});
  @override
  State<ProjectManagementScreen> createState() =>
      _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Project'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Project name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                Provider.of<TimeEntryProvider>(
                  context,
                  listen: false,
                ).addProject(_controller.text.trim());
                _controller.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Manage Projects',
          style: TextStyle(color: Colors.white),
        ),

        backgroundColor: const Color.fromARGB(255, 187, 88, 244),
      ),
      body: provider.projects.isEmpty
          ? const Center(child: Text('No projects yet'))
          : ListView.builder(
              itemCount: provider.projects.length,
              itemBuilder: (context, i) {
                final p = provider.projects[i];
                return ListTile(
                  leading: const Icon(Icons.folder, color: kPrimaryColor),
                  title: Text(p.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => provider.deleteProject(p.id),
                  ),
                );
              },
            ),

      // ✅ Single yellow "+" button to add project
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 239, 188, 4),
        onPressed: _showAddProjectDialog,
        child: const Icon(Icons.add, color: Color.fromARGB(255, 248, 246, 246)),
      ),
    );
  }
}
