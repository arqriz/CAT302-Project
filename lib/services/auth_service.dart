import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock user data
    _currentUser = User(
      id: '123456',
      name: 'Ahmad Adib',
      email: email,
      matricNo: '22303906',
      faculty: 'School of Computer Sciences',
      residentialCollege: 'Desasiswa Tekun',
      points: 1250,
      level: 7,
      rank: '#12',
      totalRecycled: 45.0,
      co2Saved: 89.0,
      badges: ['Eco Warrior', 'Plastic Crusher', 'Weekly Champion'],
      joinDate: DateTime(2024, 1, 15),
    );
    
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  Future<bool> register(String name, String email, String password, 
                        String matricNo, String faculty, String college) async {
    await Future.delayed(const Duration(seconds: 2));
    
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      matricNo: matricNo,
      faculty: faculty,
      residentialCollege: college,
      points: 0,
      level: 1,
      rank: 'New Recycler',
      totalRecycled: 0.0,
      co2Saved: 0.0,
      badges: ['New Recruit'],
      joinDate: DateTime.now(),
    );
    
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}