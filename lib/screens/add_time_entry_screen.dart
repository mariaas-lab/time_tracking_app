import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../providers/time_entry_provider.dart';
import '../utils/constants.dart';
import '../models/time_entry.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  String? _selectedProjectId;
  String? _selectedTaskId;
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<TimeEntryProvider>(context, listen: false);

    final rawTime = double.tryParse(_timeController.text.trim()) ?? 0.0;
    final cleanTime = rawTime % 1 == 0 ? rawTime.truncateToDouble() : rawTime;

    final newEntry = TimeEntry(
      id: _uuid.v4(),
      projectId: _selectedProjectId ?? 'Unassigned',
      taskId: _selectedTaskId ?? 'Unassigned',
      totalTime: cleanTime,
      date: _selectedDate,
      notes: _notesController.text.trim(),
    );

    provider.addEntry(newEntry);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Time entry saved')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add Time Entry',
          style: TextStyle(color: Colors.white),
        ),

        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Project'),
                items: provider.projects
                    .map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                    )
                    .toList(),
                value: _selectedProjectId,
                onChanged: (v) => setState(() => _selectedProjectId = v),
                validator: (v) => v == null ? 'Choose project' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Task'),
                items: provider.tasks
                    .map(
                      (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
                    )
                    .toList(),
                value: _selectedTaskId,
                onChanged: (v) => setState(() => _selectedTaskId = v),
                validator: (v) => v == null ? 'Choose task' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Total time (hours)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final value = double.tryParse(v ?? '');
                  if (value == null || value <= 0) {
                    return 'Enter valid time';
                  }
                  return null;
                },
                onChanged: (v) {
                  final value = double.tryParse(v);
                  if (value != null && value % 1 == 0) {
                    final cleaned = value.toInt().toString();
                    _timeController.value = TextEditingValue(
                      text: cleaned,
                      selection: TextSelection.collapsed(
                        offset: cleaned.length,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Note'),
                maxLines: 1,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 164, 205, 199),
                ),
                child: const Text('Save the Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
