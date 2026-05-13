class HabitModel {
  final String id;
  final String title;
  final bool completed;
  final int streak;

  HabitModel({
    required this.id,
    required this.title,
    required this.completed,
    required this.streak,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'streak': streak,
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'],
      title: map['title'],
      completed: map['completed'],
      streak: map['streak'],
    );
  }
}