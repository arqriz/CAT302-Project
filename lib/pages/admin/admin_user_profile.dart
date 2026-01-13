import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class AdminUserProfile extends StatelessWidget {
  final User user;

  const AdminUserProfile({super.key, required this.user});

  static const Color mossGreen = Color(0xFF5B6739);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        backgroundColor: mossGreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profileHeader(data),
                const SizedBox(height: 24),
                _infoTile("Matric No", data['matricNo']),
                _infoTile("Email", data['email']),
                _infoTile("Points", data['points'].toString()),
                _infoTile("Role", data['isAdmin'] ? "Admin" : "User"),
                _infoTile("Status", data['status'] ?? "Active"),
                const SizedBox(height: 30),
                const Text(
                  "Recent Activities",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _recentActivities(user.id),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileHeader(Map<String, dynamic> data) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: mossGreen,
            child: Text(
              data['name'][0].toUpperCase(),
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data['name'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _recentActivities(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activities')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = snapshot.data!.docs;

        if (logs.isEmpty) {
          return const Text("No activities recorded.");
        }

        return Column(
          children: logs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.recycling),
              title: Text("${data['type']} (${data['quantity']}${data['unit']})"),
              subtitle: Text("Points: ${data['pointsEarned']}"),
            );
          }).toList(),
        );
      },
    );
  }
}