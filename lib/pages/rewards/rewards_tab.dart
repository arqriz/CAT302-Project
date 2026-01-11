import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../models/reward_model.dart';

class RewardsTab extends StatelessWidget {
  const RewardsTab({super.key});

  static const Color mossGreen = Color(0xFF5B6739);
  static const Color lightSage = Color(0xFFDDE2C9);
  static const Color creamWhite = Color(0xFFF9F9F0);

  @override
  Widget build(BuildContext context) {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: lightSage,
      appBar: AppBar(
        title: const Text('Impact Rewards', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: mossGreen,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final int points = userData['points'] ?? 0;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              _buildProgressCard(points),
              const SizedBox(height: 20),
              _buildSectionHeader("Redeem Rewards"),
              _buildRewardsList(points, context), 
              _buildSectionHeader("Achievements"),
              _buildBadgeGrid(points),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  // --- REWARDS LIST SECTION ---
  Widget _buildRewardsList(int userPoints, BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rewards').orderBy('pointCost').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        if (snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text("No rewards available yet.", style: TextStyle(color: Colors.grey)),
          );
        }

        return SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 25),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final reward = Reward.fromFirestore(snapshot.data!.docs[index]);
              final bool canAfford = userPoints >= reward.pointCost;

              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: creamWhite, 
                  borderRadius: BorderRadius.circular(20),
                  border: canAfford ? Border.all(color: mossGreen, width: 2) : null,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_giftcard, size: 35, color: canAfford ? mossGreen : Colors.grey),
                    const SizedBox(height: 8),
                    Text(reward.title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: mossGreen, fontSize: 13)),
                    Text("${reward.pointCost} pts", style: TextStyle(fontWeight: FontWeight.bold, color: canAfford ? Colors.orange : Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 30,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canAfford ? () => _redeemReward(context, reward) : null,
                        style: ElevatedButton.styleFrom(backgroundColor: mossGreen, foregroundColor: Colors.white, padding: EdgeInsets.zero),
                        child: const Text("Redeem"),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // --- UPDATED: SAVES TO PROFILE HISTORY ---
  void _redeemReward(BuildContext context, Reward reward) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Redeem ${reward.title}?"),
        content: Text("This will cost ${reward.pointCost} points."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); 
              
              final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;

              try {
                // 1. Transaction to deduct points safely
                await FirebaseFirestore.instance.runTransaction((transaction) async {
                  final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
                  final userSnapshot = await transaction.get(userRef);

                  if (!userSnapshot.exists) throw Exception("User does not exist!");

                  final int currentPoints = (userSnapshot.data()?['points'] ?? 0);

                  if (currentPoints >= reward.pointCost) {
                    transaction.update(userRef, {'points': currentPoints - reward.pointCost});
                  } else {
                    throw Exception("Insufficient points!");
                  }
                });

                // 2. NEW: Save to 'redeemed' sub-collection for the Profile Page
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('redeemed')
                    .add({
                      'title': reward.title,
                      'pointCost': reward.pointCost,
                      'timestamp': FieldValue.serverTimestamp(),
                      'status': 'Active' // You can use this to show "Used" or "Active"
                    });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Redeemed ${reward.title}! Check your Profile."), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed: ${e.toString()}"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildSectionHeader(String title) {
    return Padding(padding: const EdgeInsets.fromLTRB(25, 10, 25, 15), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mossGreen)));
  }

  Widget _buildProgressCard(int points) {
    double progress = (points % 500) / 500;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25), padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: mossGreen, borderRadius: BorderRadius.circular(30)), 
      child: Column(children: [
        const Text("Points Balance", style: TextStyle(color: Colors.white70)), 
        Text("$points pts", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)), 
        const SizedBox(height: 20), 
        LinearProgressIndicator(value: progress, backgroundColor: Colors.white24, color: Colors.amber, minHeight: 8, borderRadius: BorderRadius.circular(10))
      ])
    );
  }

  Widget _buildBadgeGrid(int userPoints) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 25), child: GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 1.1, children: [_badgeItem("Eco Sprout", 100, Icons.eco, userPoints), _badgeItem("Recycle Rookie", 300, Icons.auto_awesome, userPoints), _badgeItem("Plastic Hero", 600, Icons.water_drop, userPoints), _badgeItem("Carbon Master", 1000, Icons.cloud_done, userPoints)]));
  }

  Widget _badgeItem(String name, int required, IconData icon, int userPoints) {
    bool isUnlocked = userPoints >= required;
    return Container(
      decoration: BoxDecoration(color: isUnlocked ? creamWhite : Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(25), border: isUnlocked ? Border.all(color: Colors.amber, width: 2) : null), 
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 40, color: isUnlocked ? mossGreen : Colors.grey), const SizedBox(height: 10), Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: isUnlocked ? mossGreen : Colors.grey, fontSize: 13)), Text("$required pts", style: const TextStyle(fontSize: 11, color: Colors.grey))])
    );
  }
}