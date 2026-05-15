class Task {
  final String id;
  String title;
  bool isDone;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.createdAt,
  });

  Task copyWith({String? title, bool? isDone}) {
    return Task(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
