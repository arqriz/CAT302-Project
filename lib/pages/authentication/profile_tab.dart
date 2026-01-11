import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../services/auth_service.dart';
import '../admin/admin_panel.dart';
import 'package:intl/intl.dart'; // Added for date formatting

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  static const Color mossGreen = Color(0xFF5B6739);
  static const Color goldColor = Color(0xFFDAA520);

  // USM Data
  static const List<String> usmFaculties = [
    'School of Computer Sciences', 'School of Housing, Building and Planning',
    'School of Industrial Technology', 'School of Pharmaceutical Sciences',
    'School of Management', 'School of Educational Studies', 'School of Arts',
    'School of Communication', 'School of Civil Engineering', 'School of Aerospace Engineering',
    'School of Mechanical Engineering', 'School of Electrical & Electronic Engineering',
    'School of Materials & Mineral Resources', 'School of Chemical Engineering',
    'School of Biological Sciences', 'School of Chemical Sciences',
    'School of Mathematical Sciences', 'School of Physics', 'School of Social Sciences',
    'School of Humanities', 'School of Languages, Literacies and Translation', 'Other'
  ];

  static const List<String> usmColleges = [
    'Aman Damai', 'Bakti Permai', 'Cahaya Gemilang', 'Fajar Harapan',
    'Indah Kembara', 'Restu', 'Saujana', 'Tekun', 'Lembaran',
    'Jaya', 'Utama', 'Murni', 'Nurani', 'Off-Campus'
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator(color: mossGreen));
    }

    bool isPasswordUser = false;
    final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      for (final provider in fbUser.providerData) {
        if (provider.providerId == 'password') isPasswordUser = true;
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF556B2F), Color(0xFFFDFCF5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.45],
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.id).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final String name = userData['name'] ?? user.name;
            final String email = userData['email'] ?? user.email;
            final String faculty = userData['faculty'] ?? user.faculty;
            final String college = userData['residentialCollege'] ?? user.residentialCollege;
            final String matricNo = userData['matricNo'] ?? user.matricNo;
            final bool isAdmin = userData['isAdmin'] ?? user.isAdmin;

            return Column(
              children: [
                const SizedBox(height: 70), 
                
                // --- PROFILE CARD ---
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: goldColor,
                        child: const Icon(Icons.person, size: 45, color: Colors.white),
                      ),
                      const SizedBox(height: 15),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22, 
                                fontWeight: FontWeight.w800, 
                                color: Colors.white, 
                                letterSpacing: 0.5,
                                shadows: [Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black26)],
                              ),
                            ),
                          ),
                          if (isAdmin) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: Colors.lightBlueAccent, size: 20),
                          ],
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _showEditProfileDialog(context, user.id, userData),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.edit, size: 20, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        email, 
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14, 
                          fontWeight: FontWeight.w500,
                          shadows: [Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black12)],
                        )
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),

                // --- BOTTOM PANEL ---
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        children: [
                          _buildInfoSection(faculty, college, matricNo),
                          const SizedBox(height: 25),
                          _buildRedeemedRewards(context, user.id), 
                          const SizedBox(height: 25),
                          if (isPasswordUser)
                            _buildActionTile(Icons.lock_outline, "Change Password", mossGreen, () => _showChangePasswordDialog(context)),
                          if (isAdmin)
                            _buildActionTile(Icons.admin_panel_settings, "Admin Dashboard", Colors.red, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanel())), isRed: true),
                          const SizedBox(height: 35),
                          _buildLogoutButton(context, authService),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- WIDGETS ---
  
  Widget _buildRedeemedRewards(BuildContext context, String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('redeemed').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text("My Rewards History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mossGreen)),
            ),
            ...snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              
              // Check Status
              bool isUsed = data['status'] == 'Used';
              
              // Formatting Timestamp
              String dateStr = "";
              if (data['timestamp'] != null) {
                dateStr = DateFormat('dd/MM/yy').format((data['timestamp'] as Timestamp).toDate());
              }

              return GestureDetector(
                // Only allow tap if NOT used
                onTap: isUsed ? null : () => _showUseRewardDialog(context, uid, doc.id, data['title'] ?? 'Reward'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10), 
                  padding: const EdgeInsets.all(16), 
                  decoration: BoxDecoration(
                    color: isUsed ? Colors.grey.shade50 : Colors.white, // Grey if used
                    borderRadius: BorderRadius.circular(16), 
                    border: Border.all(color: Colors.grey.shade200), 
                    boxShadow: isUsed ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]
                  ), 
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isUsed ? Colors.grey.shade200 : mossGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Icon(Icons.card_giftcard, color: isUsed ? Colors.grey : mossGreen, size: 22),
                      ), 
                      const SizedBox(width: 12), 
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? '', 
                              style: TextStyle(
                                fontSize: 15, 
                                fontWeight: FontWeight.bold, 
                                color: isUsed ? Colors.grey : mossGreen
                              )
                            ),
                            if (isUsed)
                              Text("Used on $dateStr", style: const TextStyle(fontSize: 11, color: Colors.grey))
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isUsed ? Colors.grey.shade200 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isUsed ? Colors.grey.shade300 : Colors.green.shade100)
                        ),
                        child: Text(
                          isUsed ? "Used" : "Active",
                          style: TextStyle(
                            fontSize: 11, 
                            fontWeight: FontWeight.bold, 
                            color: isUsed ? Colors.grey.shade600 : Colors.green
                          ),
                        ),
                      )
                    ],
                  )
                ),
              );
            }).toList()
          ],
        );
      },
    );
  }

  // --- REWARD DIALOG (UPDATED LOGIC) ---
  void _showUseRewardDialog(BuildContext context, String uid, String docId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Use $title?", style: const TextStyle(color: mossGreen, fontWeight: FontWeight.bold)),
        content: const Text("Staff will verify this. Once used, it will be marked in your history."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // UPDATE instead of DELETE
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('redeemed')
                    .doc(docId)
                    .update({
                      'status': 'Used',
                      'usedAt': FieldValue.serverTimestamp(), // Optional: track when it was used
                    });
                
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Reward marked as Used!"),
                      backgroundColor: mossGreen,
                    )
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
                  );
                }
              }
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: mossGreen, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            child: const Text("Confirm Use")
          ),
        ],
      ),
    );
  }

  // --- DIALOGS & HELPERS (Unchanged) ---
  
  void _showEditProfileDialog(BuildContext context, String uid, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['name']);
    final matricController = TextEditingController(text: data['matricNo']);
    String? selectedFaculty = data['faculty'];
    if (!usmFaculties.contains(selectedFaculty)) selectedFaculty = null;
    String? selectedCollege = data['residentialCollege'];
    if (!usmColleges.contains(selectedCollege)) selectedCollege = null;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: const Text("Edit Profile", style: TextStyle(color: mossGreen, fontWeight: FontWeight.bold, fontSize: 20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, "Full Name"),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: selectedFaculty, isExpanded: true, decoration: InputDecoration(labelText: "Faculty", labelStyle: const TextStyle(fontSize: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: usmFaculties.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(), onChanged: (val) => setState(() => selectedFaculty = val)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: selectedCollege, isExpanded: true, decoration: InputDecoration(labelText: "Residential College", labelStyle: const TextStyle(fontSize: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: usmColleges.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13)))).toList(), onChanged: (val) => setState(() => selectedCollege = val)),
              const SizedBox(height: 12),
              _buildTextField(matricController, "Matric No"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
          ElevatedButton(onPressed: () async { await FirebaseFirestore.instance.collection('users').doc(uid).update({'name': nameController.text, 'faculty': selectedFaculty ?? data['faculty'], 'residentialCollege': selectedCollege ?? data['residentialCollege'], 'matricNo': matricController.text}); if (context.mounted) Navigator.pop(ctx); }, style: ElevatedButton.styleFrom(backgroundColor: mossGreen, foregroundColor: Colors.white), child: const Text("Save", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
        ],
      );
    }));
  }

  void _showChangePasswordDialog(BuildContext context) {
      final currentPassController = TextEditingController();
      final newPassController = TextEditingController();
      showDialog(context: context, builder: (ctx) => AlertDialog(
        title: const Text("Change Password", style: TextStyle(color: mossGreen, fontWeight: FontWeight.bold, fontSize: 20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("Verify current password first.", style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 10),
          _buildTextField(currentPassController, "Current Password", obscure: true),
          const SizedBox(height: 10),
          _buildTextField(newPassController, "New Password", obscure: true),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
          ElevatedButton(onPressed: () async {
            final user = fb_auth.FirebaseAuth.instance.currentUser; if (user == null) return;
            try {
              await user.reauthenticateWithCredential(fb_auth.EmailAuthProvider.credential(email: user.email!, password: currentPassController.text));
              await user.updatePassword(newPassController.text);
              if (context.mounted) { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated!"), backgroundColor: Colors.green)); }
            } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error or Wrong Password"), backgroundColor: Colors.red)); }
          }, style: ElevatedButton.styleFrom(backgroundColor: mossGreen, foregroundColor: Colors.white), child: const Text("Update", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
        ],
      ));
  }

  Widget _buildTextField(TextEditingController c, String l, {bool obscure = false}) {
    return TextField(controller: c, obscureText: obscure, decoration: InputDecoration(labelText: l, labelStyle: const TextStyle(fontSize: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))));
  }

  Widget _buildInfoSection(String f, String c, String m) {
    return Column(children: [_infoTile(Icons.school_outlined, 'Faculty', f), _infoTile(Icons.apartment_outlined, 'College', c), _infoTile(Icons.badge_outlined, 'Matric No.', m)]);
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        Icon(icon, color: mossGreen, size: 24), 
        const SizedBox(width: 16), 
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), 
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87))
        ]))
      ]),
    );
  }

  Widget _buildActionTile(IconData i, String t, Color c, VoidCallback tap, {bool isRed = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), 
      decoration: BoxDecoration(color: isRed ? Colors.red.shade50 : Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: isRed ? Colors.red.shade100 : Colors.grey.shade200)), 
      child: ListTile(
        leading: Icon(i, color: c, size: 24), 
        title: Text(t, style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.bold)), 
        onTap: tap
      )
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthService authService) {
    return SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () { authService.logout(); Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.red))), child: const Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))));
  }
}