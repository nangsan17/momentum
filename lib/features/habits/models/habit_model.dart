class HabitModel {
  final String id;
  final String title;
  final bool completed;
  final int streak;
  final String emoji;
  final String category;
  final List<String> completedDates;

  HabitModel({
    required this.id,
    required this.title,
    required this.completed,
    required this.streak,
    required this.emoji,
    required this.category,
    required this.completedDates,
  });

  HabitModel copyWith({
    String? id,
    String? title,
    bool? completed,
    int? streak,
    String? emoji,
    String? category,
    List<String>? completedDates,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      streak: streak ?? this.streak,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'streak': streak,
      'emoji': emoji,
      'category': category,
      'completedDates': completedDates,
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      completed: map['completed'] ?? false,
      streak: map['streak'] ?? 0,
      emoji: map['emoji'] ?? '🔥',
      category: map['category'] ?? 'General',
      completedDates: List<String>.from(
        (map['completedDates'] as List? ?? []).map((e) => e.toString()),
      ),
    );
  }
}
