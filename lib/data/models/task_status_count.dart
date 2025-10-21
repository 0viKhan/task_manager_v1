class TaskStatusCountModel {
  final String id;
  final int count;

  TaskStatusCountModel({
    required this.id,
    required this.count,
  });

  factory TaskStatusCountModel.fromJson(Map<String, dynamic> json) {
    return TaskStatusCountModel(
      id: json['_id']?.toString() ?? 'Unknown',
      count: (json['sum'] ?? 0).toInt(),
    );
  }
}
