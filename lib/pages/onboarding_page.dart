import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7DCC3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF556B2F),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // App Title
                  const Text(
                    "REGEN",
                    style: TextStyle(
                      fontSize: 48,
                      letterSpacing: 4.0,
                      color: Color(0xFFF6F2DD),
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Gamified Recycling System",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFF6F2DD),
                    ),
                  ),

                  const Spacer(),

                  // Planet Image (Using Icon instead of Image.asset)
                  Container(
                    height: 230,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF7A8F5A),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.recycling,
                        size: 120,
                        color: Colors.white.withOpacity(0.8), // Fixed here
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Hero Text
                  Column(
                    children: const [
                      Text(
                        "SAVE",
                        style: TextStyle(
                          fontSize: 58,
                          color: Color(0xFFF6F2DD),
                          fontWeight: FontWeight.w900,
                          height: 0.9,
                        ),
                      ),
                      Text(
                        "THE",
                        style: TextStyle(
                          fontSize: 58,
                          color: Color(0xFFF6F2DD),
                          fontWeight: FontWeight.w900,
                          height: 0.9,
                        ),
                      ),
                      Text(
                        "PLANET",
                        style: TextStyle(
                          fontSize: 58,
                          color: Color(0xFFF6F2DD),
                          fontWeight: FontWeight.w900,
                          height: 0.9,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Subtitle
                  const Text(
                    "Recycle. Compete. Earn Rewards.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFF6F2DD),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // USM Tagline
                  Text(
                    "Universiti Sains Malaysia",
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFFF6F2DD).withOpacity(0.8), // Fixed here
                    ),
                  ),

                  const Spacer(),

                  // Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF6F2DD),
                        foregroundColor: const Color(0xFF556B2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.2),
                      ),
                      child: const Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Don't have account link
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                        color: Color(0xFFF6F2DD),
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Footer
                  Text(
                    "Supporting USM's Green Campus Initiative",
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFFF6F2DD).withOpacity(0.6), // Fixed here
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}