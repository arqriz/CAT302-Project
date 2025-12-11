class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final String criteria;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.criteria,
  });
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final String type; // daily, weekly, monthly
  final int target;
  final int pointsReward;
  final DateTime startDate;
  final DateTime endDate;
  final int currentProgress;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.pointsReward,
    required this.startDate,
    required this.endDate,
    this.currentProgress = 0,
  });
}