class Task {
  final String id;
  final String projectId;
  final String name;

  Task({required this.id, required this.projectId, required this.name});

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'name': name,
  };

  factory Task.fromJson(Map<String, dynamic> json) =>
      Task(id: json['id'], projectId: json['projectId'], name: json['name']);
}
