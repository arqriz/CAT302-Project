import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../models/reward_model.dart';

class RewardsTab extends StatelessWidget {
  const RewardsTab({super.key});

  static const Color mossGreen = Color(0xFF5B6739);
  static const Color gold = Color(0xFFDAA520);

  @override
  Widget build(BuildContext context) {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text('Impact Rewards', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));
            
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final int points = userData['points'] ?? 0;

            return ListView(
              padding: const EdgeInsets.only(top: 100, bottom: 40), 
              children: [
                // 1. Points Card
                _buildProgressCard(points),
                
                const SizedBox(height: 25),

                // 2. Rewards Section
                _buildSectionHeader("Redeem Rewards", Colors.black87),
                _buildRewardsList(points, context), 
                
                const SizedBox(height: 20),

                // 3. Badges Section
                _buildSectionHeader("Achievements", Colors.black87),
                _buildBadgeGrid(points),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildProgressCard(int points) {
    double progress = (points % 500) / 500;
    int level = (points ~/ 500) + 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Current Balance", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text("$points", style: const TextStyle(color: mossGreen, fontSize: 36, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: gold.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.emoji_events, color: gold, size: 30),
              )
            ],
          ),
          const SizedBox(height: 20),
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Level $level", style: const TextStyle(fontWeight: FontWeight.bold, color: mossGreen)),
                  Text("${500 - (points % 500)} pts to next level", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  color: gold,
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsList(int userPoints, BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rewards').orderBy('pointCost').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text("No rewards available.", style: TextStyle(color: Colors.grey)),
          );
        }

        return SizedBox(
          height: 200, // Increased height to prevent overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final reward = Reward.fromFirestore(snapshot.data!.docs[index]);
              final bool canAfford = userPoints >= reward.pointCost;

              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: canAfford ? mossGreen : Colors.grey.shade300, 
                    width: canAfford ? 2 : 1
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: canAfford ? mossGreen.withOpacity(0.1) : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.card_giftcard, size: 30, color: canAfford ? mossGreen : Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      reward.title, 
                      textAlign: TextAlign.center, 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
                    ),
                    Text(
                      "${reward.pointCost} pts", 
                      style: TextStyle(fontWeight: FontWeight.bold, color: canAfford ? Colors.orange : Colors.grey, fontSize: 12)
                    ),
                    const Spacer(),
                    
                    // --- FIXED BUTTON ---
                    SizedBox(
                      height: 36, // Slightly taller
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canAfford ? () => _redeemReward(context, reward) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mossGreen, 
                          foregroundColor: Colors.white,
                          // FIX: Explicitly set DISABLED colors so text is visible
                          disabledBackgroundColor: Colors.grey.shade200,
                          disabledForegroundColor: Colors.grey.shade500,
                          elevation: 0,
                          padding: EdgeInsets.zero, // Ensures text fits
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        child: Text(
                          canAfford ? "Redeem" : "Locked", // Text changes if locked
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                        ),
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

  Widget _buildBadgeGrid(int userPoints) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.2,
        children: [
          _badgeItem("Eco Sprout", 100, Icons.eco, userPoints),
          _badgeItem("Recycle Rookie", 300, Icons.auto_awesome, userPoints),
          _badgeItem("Plastic Hero", 600, Icons.water_drop, userPoints),
          _badgeItem("Carbon Master", 1000, Icons.cloud_done, userPoints),
        ],
      ),
    );
  }

  Widget _badgeItem(String name, int required, IconData icon, int userPoints) {
    bool isUnlocked = userPoints >= required;
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: isUnlocked ? Border.all(color: gold, width: 2) : null,
        boxShadow: isUnlocked ? [BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 35, color: isUnlocked ? mossGreen : Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: isUnlocked ? Colors.black87 : Colors.grey, fontSize: 13)),
          Text("$required pts", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          if (isUnlocked)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(Icons.check_circle, size: 14, color: gold),
            )
        ],
      ),
    );
  }

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
                await FirebaseFirestore.instance.collection('users').doc(uid).collection('redeemed').add({
                  'title': reward.title,
                  'pointCost': reward.pointCost,
                  'timestamp': FieldValue.serverTimestamp(),
                  'status': 'Active'
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Redeemed Successfully!"), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    );
  }
}