import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'log_activity_page.dart';

class ActivitiesTab extends StatelessWidget {
  const ActivitiesTab({super.key});

  static const Color mossGreen = Color(0xFF5B6739);
  static const Color gold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Activity History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF556B2F), Color(0xFFFDFCF5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogActivityPage())),
                          style: ElevatedButton.styleFrom(backgroundColor: mossGreen, foregroundColor: Colors.white, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit_note, size: 22),
                              SizedBox(width: 10),
                              Text("Add Activity Manually", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.fromLTRB(25, 28, 25, 12), child: Align(alignment: Alignment.centerLeft, child: Text("Recent Activity", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: mossGreen)))),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('activities').where('userId', isEqualTo: user?.uid).orderBy('timestamp', descending: true).snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No activities yet.", style: TextStyle(color: Colors.grey, fontSize: 16)));
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                              String dateStr = "";
                              if (data['timestamp'] != null) dateStr = DateFormat('MMM d, h:mm a').format((data['timestamp'] as Timestamp).toDate());
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                                child: Row(children: [
                                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: mossGreen.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.recycling, color: mossGreen, size: 24)),
                                  const SizedBox(width: 16),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text("${data['type']} (${data['quantity']} ${data['unit']})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                                    const SizedBox(height: 4),
                                    Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                                  ])),
                                  Text("+${data['pointsEarned']}", style: const TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 17)),
                                ]),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}