class User {
  final String id;
  final String name;
  final String email;
  final String matricNo;
  final String faculty;
  final String residentialCollege;
  final int points;
  final int level;
  final String rank;
  final double totalRecycled;
  final double co2Saved;
  final List<String> badges;
  final DateTime joinDate;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.matricNo,
    required this.faculty,
    required this.residentialCollege,
    this.points = 0,
    this.level = 1,
    this.rank = 'Novice Recycler',
    this.totalRecycled = 0.0,
    this.co2Saved = 0.0,
    this.badges = const [],
    required this.joinDate,
  });
}