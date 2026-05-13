class HabitModel {
  final String id;
  final String title;
  final String emoji;
  final bool completed;
  final int streak;
  final DateTime? lastCompleted;

  HabitModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.completed,
    required this.streak,
    this.lastCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'completed': completed,
      'streak': streak,
      'lastCompleted':
          lastCompleted?.toIso8601String(),
    };
  }

  factory HabitModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return HabitModel(
      id: map['id'],
      title: map['title'],
      emoji: map['emoji'] ?? '🔥',
      completed: map['completed'],
      streak: map['streak'] ?? 0,

      lastCompleted:
          map['lastCompleted'] != null
              ? DateTime.parse(
                  map['lastCompleted'],
                )
              : null,
    );
  }
}