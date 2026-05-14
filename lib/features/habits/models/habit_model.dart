class HabitModel {
  final String id;
  final String title;
  final bool completed;
  final int streak;
  final String emoji;
  final String category;
  final List<String> completedDates;
  final bool reminderEnabled;
  final String? reminderTime; // stored as "HH:mm" e.g. "08:30"

  HabitModel({
    required this.id,
    required this.title,
    required this.completed,
    required this.streak,
    required this.emoji,
    required this.category,
    required this.completedDates,
    this.reminderEnabled = false,
    this.reminderTime,
  });

  HabitModel copyWith({
    String? id,
    String? title,
    bool? completed,
    int? streak,
    String? emoji,
    String? category,
    List<String>? completedDates,
    bool? reminderEnabled,
    String? reminderTime,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      streak: streak ?? this.streak,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      completedDates: completedDates ?? this.completedDates,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
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
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
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
      reminderEnabled: map['reminderEnabled'] ?? false,
      reminderTime: map['reminderTime'],
    );
  }
}