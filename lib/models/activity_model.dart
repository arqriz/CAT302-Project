class RecyclingActivity {
  final String id;
  final String userId;
  final String type; // plastic, paper, metal, glass, e-waste
  final double weight;
  final int pointsEarned;
  final String location;
  final DateTime timestamp;
  final String? qrCode;
  final String? eventId;

  RecyclingActivity({
    required this.id,
    required this.userId,
    required this.type,
    required this.weight,
    required this.pointsEarned,
    required this.location,
    required this.timestamp,
    this.qrCode,
    this.eventId,
  });
}

class SustainabilityEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String organizer;
  final int pointsReward;
  final String qrCode;
  final int maxParticipants;
  final int currentParticipants;

  SustainabilityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.organizer,
    required this.pointsReward,
    required this.qrCode,
    required this.maxParticipants,
    this.currentParticipants = 0,
  });
}