import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  final List<Map<String, dynamic>> topUsers = const [
    {'rank': 1, 'name': 'Ali Rahman', 'points': 3245, 'faculty': 'Computer Sciences'},
    {'rank': 2, 'name': 'Siti Aisyah', 'points': 2980, 'faculty': 'Biological Sciences'},
    {'rank': 3, 'name': 'Raj Kumar', 'points': 2750, 'faculty': 'Chemical Sciences'},
    {'rank': 4, 'name': 'Mei Ling', 'points': 2540, 'faculty': 'Physics'},
    {'rank': 5, 'name': 'Ahmad Adib', 'points': 1250, 'faculty': 'Computer Sciences'},
    {'rank': 6, 'name': 'Fatimah Zahra', 'points': 1150, 'faculty': 'Mathematics'},
    {'rank': 7, 'name': 'John Lim', 'points': 980, 'faculty': 'HBP'},
    {'rank': 8, 'name': 'Sarah Tan', 'points': 870, 'faculty': 'Computer Sciences'},
    {'rank': 9, 'name': 'David Chen', 'points': 750, 'faculty': 'Biological Sciences'},
    {'rank': 10, 'name': 'Nurul Iman', 'points': 620, 'faculty': 'Chemical Sciences'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF556B2F),
        title: const Text(
          "Leaderboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle filter selection
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'overall', child: Text('Overall')),
              const PopupMenuItem(value: 'faculty', child: Text('By Faculty')),
              const PopupMenuItem(value: 'college', child: Text('By College')),
              const PopupMenuItem(value: 'monthly', child: Text('This Month')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Podium section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 2nd place
                  Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC0C0C0),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 3),
                        ),
                        child: const Center(
                          child: Text(
                            "2",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Siti Aisyah",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "2,980 pts",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  
                  // 1st place
                  Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber, width: 4),
                        ),
                        child: const Center(
                          child: Text(
                            "1",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Ali Rahman",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "3,245 pts",
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                  
                  // 3rd place
                  Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCD7F32),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.brown, width: 3),
                        ),
                        child: const Center(
                          child: Text(
                            "3",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Raj Kumar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "2,750 pts",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Leaderboard list
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Current user highlight
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF556B2F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF556B2F), width: 2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDAA520),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              "5",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Ahmad Adib (You)",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF556B2F),
                                ),
                              ),
                              Text(
                                "Computer Sciences • 1,250 pts",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.emoji_events, color: Color(0xFFDAA520)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // List of all users
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topUsers.length,
                    itemBuilder: (context, index) {
                      final user = topUsers[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: user['rank'] <= 3 
                                    ? const Color(0xFF556B2F) 
                                    : Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  user['rank'].toString(),
                                  style: TextStyle(
                                    color: user['rank'] <= 3 
                                        ? Colors.white 
                                        : Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['name'],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${user['faculty']}",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${user['points']} pts",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF556B2F),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}