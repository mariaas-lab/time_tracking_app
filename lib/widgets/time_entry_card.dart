import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/time_entry.dart';

class TimeEntryItem extends StatelessWidget {
  final TimeEntry entry;
  final VoidCallback onDelete;

  const TimeEntryItem({Key? key, required this.entry, required this.onDelete})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.timer, color: Color(0xFF4B9086)),
        title: Text('${entry.projectId} - ${entry.taskId}'),
        subtitle: Text(
          '${entry.totalTime} hrs • ${DateFormat.yMMMd().format(entry.date)}\n${entry.notes}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
