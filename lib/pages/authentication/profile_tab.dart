import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../services/auth_service.dart';
import '../admin/admin_panel.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  static const Color mossGreen = Color(0xFF5B6739);
  static const Color goldColor = Color(0xFFDAA520);

  // --- USM DATA LISTS ---
  static const List<String> usmFaculties = [
    'School of Computer Sciences',
    'School of Housing, Building and Planning',
    'School of Industrial Technology',
    'School of Pharmaceutical Sciences',
    'School of Management',
    'School of Educational Studies',
    'School of Arts',
    'School of Communication',
    'School of Civil Engineering',
    'School of Aerospace Engineering',
    'School of Mechanical Engineering',
    'School of Electrical & Electronic Engineering',
    'School of Materials & Mineral Resources',
    'School of Chemical Engineering',
    'School of Biological Sciences',
    'School of Chemical Sciences',
    'School of Mathematical Sciences',
    'School of Physics',
    'School of Social Sciences',
    'School of Humanities',
    'School of Languages, Literacies and Translation',
    'Other'
  ];

  static const List<String> usmColleges = [
    'Aman Damai',
    'Bakti Permai',
    'Cahaya Gemilang',
    'Fajar Harapan',
    'Indah Kembara',
    'Restu',
    'Saujana',
    'Tekun',
    'Lembaran',
    'Jaya',
    'Utama',
    'Murni',
    'Nurani',
    'Off-Campus'
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator(color: mossGreen));
    }

    // CHECK LOGIN METHOD
    bool isPasswordUser = false;
    final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      for (final provider in fbUser.providerData) {
        if (provider.providerId == 'password') {
          isPasswordUser = true;
        }
      }
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF556B2F), Color(0xFFFDFCF5)], 
          begin: Alignment.topCenter,
          end: Alignment.center,
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Profile Picture
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: goldColor,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                
                const SizedBox(height: 16),
                
                // Name & Edit Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white 
                        ),
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.lightBlueAccent, size: 20),
                    ],
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20, color: Colors.white70),
                      onPressed: () => _showEditProfileDialog(context, user.id, userData),
                    ),
                  ],
                ),
                
                Text(email, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 32),
                
                // Info Cards
                _buildInfoSection(faculty, college, matricNo),

                const SizedBox(height: 20),

                // Redeemed Rewards
                _buildRedeemedRewards(user.id),
                
                const SizedBox(height: 20),

                // Change Password (Only if email/password login)
                if (isPasswordUser)
                  _buildActionTile(
                    icon: Icons.lock_outline,
                    title: "Change Password",
                    color: mossGreen,
                    onTap: () => _showChangePasswordDialog(context),
                  ),

                // Admin Panel
                if (isAdmin)
                  _buildActionTile(
                    icon: Icons.admin_panel_settings,
                    title: "Admin Dashboard",
                    color: Colors.red,
                    isRed: true,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanel())),
                  ),

                const SizedBox(height: 40),
                
                // Logout Button
                _buildLogoutButton(context, authService),
                
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- UPDATED: EDIT PROFILE DIALOG WITH DROPDOWNS ---
  void _showEditProfileDialog(BuildContext context, String uid, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['name']);
    final matricController = TextEditingController(text: data['matricNo']);
    
    // Ensure initial values match the list, or default to null if not found
    String? selectedFaculty = data['faculty'];
    if (!usmFaculties.contains(selectedFaculty)) selectedFaculty = null;

    String? selectedCollege = data['residentialCollege'];
    if (!usmColleges.contains(selectedCollege)) selectedCollege = null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Edit Profile", style: TextStyle(color: mossGreen, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(nameController, "Full Name"),
                  
                  const SizedBox(height: 10),
                  
                  // FACULTY DROPDOWN
                  DropdownButtonFormField<String>(
                    value: selectedFaculty,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Faculty",
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: mossGreen, width: 2)),
                    ),
                    items: usmFaculties.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedFaculty = val),
                  ),

                  const SizedBox(height: 15),

                  // COLLEGE DROPDOWN
                  DropdownButtonFormField<String>(
                    value: selectedCollege,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Residential College",
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: mossGreen, width: 2)),
                    ),
                    items: usmColleges.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedCollege = val),
                  ),

                  const SizedBox(height: 15),

                  _buildTextField(matricController, "Matric No"),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseFirestore.instance.collection('users').doc(uid).update({
                      'name': nameController.text,
                      'faculty': selectedFaculty ?? data['faculty'], // Keep old if null
                      'residentialCollege': selectedCollege ?? data['residentialCollege'],
                      'matricNo': matricController.text,
                    });
                    if (context.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update: $e")));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: mossGreen, foregroundColor: Colors.white),
                child: const Text("Save"),
              ),
            ],
          );
        }
      ),
    );
  }

  // --- CHANGE PASSWORD DIALOG ---
  void _showChangePasswordDialog(BuildContext context) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Password", style: TextStyle(color: mossGreen, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("To secure your account, please enter your current password first.", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 15),
            TextField(
              controller: currentPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Current Password",
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: mossGreen, width: 2)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password", 
                hintText: "Min. 6 characters",
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: mossGreen, width: 2)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (newPassController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("New password must be at least 6 characters")));
                return;
              }

              final user = fb_auth.FirebaseAuth.instance.currentUser;
              if (user == null) return;

              try {
                final cred = fb_auth.EmailAuthProvider.credential(
                  email: user.email!, 
                  password: currentPassController.text
                );
                await user.reauthenticateWithCredential(cred);
                await user.updatePassword(newPassController.text);
                
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Password updated successfully!"),
                    backgroundColor: Colors.green,
                  ));
                }
              } on fb_auth.FirebaseAuthException catch (e) {
                String msg = "Error: ${e.message}";
                if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                  msg = "Incorrect current password.";
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: mossGreen, foregroundColor: Colors.white),
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: mossGreen, width: 2)),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String faculty, String college, String matric) {
    return Column(
      children: [
        _infoTile(Icons.school_outlined, 'Faculty', faculty),
        _infoTile(Icons.apartment_outlined, 'College', college),
        _infoTile(Icons.badge_outlined, 'Matric No.', matric),
      ],
    );
  }

  Widget _buildRedeemedRewards(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('redeemed').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink(); 
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Text("My Rewards", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mossGreen)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: mossGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.card_giftcard, color: mossGreen, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Text(data['title'] ?? 'Reward', style: const TextStyle(fontWeight: FontWeight.bold, color: mossGreen))),
                      const Text("Active", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: mossGreen),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: mossGreen)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, required Color color, required VoidCallback onTap, bool isRed = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRed ? Colors.red.shade50 : Colors.white, 
        borderRadius: BorderRadius.circular(20),
        border: isRed ? Border.all(color: Colors.red.shade100) : null,
        boxShadow: isRed ? null : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthService authService) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          authService.logout();
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
          elevation: 0,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text('Logout'),
      ),
    );
  }
}