import '../models/activity_model.dart';

class ActivityService {
  final List<RecyclingActivity> _activities = [
    RecyclingActivity(
      id: '1',
      userId: '123456',
      type: 'plastic',
      weight: 2.5,
      pointsEarned: 50,
      location: 'Library Recycling Center',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RecyclingActivity(
      id: '2',
      userId: '123456',
      type: 'mixed',
      weight: 5.0,
      pointsEarned: 100,
      location: 'Campus Clean-up Event',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      eventId: 'event1',
    ),
    RecyclingActivity(
      id: '3',
      userId: '123456',
      type: 'paper',
      weight: 3.0,
      pointsEarned: 30,
      location: 'Faculty of Computer Sciences',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final List<SustainabilityEvent> _events = [
    SustainabilityEvent(
      id: 'event1',
      title: 'Campus Clean-up Day',
      description: 'Join us for a campus-wide clean-up event',
      date: DateTime.now().add(const Duration(days: 3)),
      location: 'USM Main Campus',
      organizer: 'Kampus Sejahtera',
      pointsReward: 100,
      qrCode: 'EVENT123456',
      maxParticipants: 100,
      currentParticipants: 45,
    ),
    SustainabilityEvent(
      id: 'event2',
      title: 'E-Waste Collection Drive',
      description: 'Proper disposal of electronic waste',
      date: DateTime.now().add(const Duration(days: 7)),
      location: 'DKP Lobby',
      organizer: 'School of Computer Sciences',
      pointsReward: 150,
      qrCode: 'EVENT789012',
      maxParticipants: 50,
      currentParticipants: 22,
    ),
  ];

  List<RecyclingActivity> getUserActivities(String userId) {
    return _activities.where((activity) => activity.userId == userId).toList();
  }

  List<SustainabilityEvent> getUpcomingEvents() {
    return _events.where((event) => event.date.isAfter(DateTime.now())).toList();
  }

  Future<RecyclingActivity> logActivity({
    required String userId,
    required String type,
    required double weight,
    required String location,
    String? qrCode,
    String? eventId,
  }) async {
    // Calculate points based on weight and type
    int points = calculatePoints(type, weight);
    
    final activity = RecyclingActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: type,
      weight: weight,
      pointsEarned: points,
      location: location,
      timestamp: DateTime.now(),
      qrCode: qrCode,
      eventId: eventId,
    );
    
    _activities.add(activity);
    return activity;
  }

  int calculatePoints(String type, double weight) {
    const Map<String, int> pointMultipliers = {
      'plastic': 20,
      'paper': 10,
      'metal': 15,
      'glass': 12,
      'e-waste': 30,
      'mixed': 8,
    };
    
    final multiplier = pointMultipliers[type] ?? 10;
    return (weight * multiplier).toInt();
  }
}