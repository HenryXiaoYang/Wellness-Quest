class QuestBasic {
  final String type;
  final String name;
  final String description;
  final String quest_id;

  QuestBasic({
    required this.type,
    required this.name,
    required this.description,
    required this.quest_id,
  });

  // Factory method to create a Quest from JSON
  factory QuestBasic.fromJson(Map<String, dynamic> json) {
    return QuestBasic(
      type: json['type'],
      name: json['name'],
      description: json['description'],
      quest_id: json['quest_id']
    );
  }
}
class ProfileBasic {
  final String full_name;
  final int completed_quests; // Changed to int
  final int level;            // Changed to int
  final int points;           // Changed to int

  ProfileBasic({
    required this.full_name,
    required this.completed_quests,
    required this.level,
    required this.points,
  });

  // Factory method to create a ProfileBasic from JSON
  factory ProfileBasic.fromJson(Map<String, dynamic> json) {
    return ProfileBasic(
      full_name: json['username'],
      completed_quests: json['completed_quests'],
      level: json['level'],
      points: json['points'], // Ensure this matches the API response
    );
  }
}
