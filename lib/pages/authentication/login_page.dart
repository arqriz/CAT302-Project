import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  static const Color primaryDark = Color(0xFF2D3B2D);
  static const Color accentGold = Color(0xFFC5A358);
  static const Color softChampagne = Color(0xFFF5F5ED);
  static const Color deepOlive = Color(0xFF4A5D23);

  Future<void> _performLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final success = await authService.login(
          _emailController.text.trim(), _passwordController.text.trim());
      if (mounted && !success) {
        _showErrorSnackBar("Login failed. Check credentials.");
      }
    } catch (e) {
      _showErrorSnackBar("An unexpected error occurred.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    setState(() => _isGoogleLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final user = await authService.signInWithGoogle();
      if (user == null && mounted) {
        _showErrorSnackBar("Google Sign-In canceled.");
      }
    } catch (e) {
      _showErrorSnackBar("Google Sign-In failed.");
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [softChampagne, Color(0xFFE2E8D5), Color(0xFFD0D7BD)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 50),
                    _buildLoginCard(),
                    const SizedBox(height: 40),
                    _buildRegisterLink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(35),
            border:
                Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text("Welcome Back",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: primaryDark)),
                const SizedBox(height: 35),
                _buildTextField(
                    controller: _emailController,
                    label: "Email",
                    icon: Icons.email),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock,
                  isPassword: true,
                  obscure: _obscurePassword,
                  onToggleVisibility: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 40),
                _buildAnimatedButton(context),
                const SizedBox(height: 20),
                _buildDivider(),
                const SizedBox(height: 20),
                _buildGoogleButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton(
      onPressed: _isGoogleLoading ? null : () => _handleGoogleSignIn(context),
      style: OutlinedButton.styleFrom(
        fixedSize: const Size(double.maxFinite, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: primaryDark.withOpacity(0.1)),
        backgroundColor: Colors.white.withOpacity(0.4),
      ),
      child: _isGoogleLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child:
                  CircularProgressIndicator(strokeWidth: 2, color: primaryDark))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Prevents overflow
              children: [
                // Replaced broken network image with an Icon
                const Icon(Icons.g_mobiledata_rounded,
                    size: 35, color: primaryDark),
                const SizedBox(width: 8),
                const Flexible(
                  // Ensures text stays inside button boundaries
                  child: Text(
                    "Continue with Google",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: primaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLogo() => Hero(
      tag: 'app_logo',
      child: Image.asset('assets/images/first.png', height: 200));

  Widget _buildDivider() => Row(children: [
        const Expanded(child: Divider()),
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OR")),
        const Expanded(child: Divider())
      ]);

  Widget _buildRegisterLink() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text("New here? "),
        GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/register'),
            child: const Text("Create Account",
                style:
                    TextStyle(color: deepOlive, fontWeight: FontWeight.bold)))
      ]);

  Widget _buildAnimatedButton(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _performLogin(context),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(colors: [primaryDark, deepOlive])),
        child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("SIGN IN",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      bool isPassword = false,
      bool obscure = false,
      VoidCallback? onToggleVisibility}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (value) =>
          (value == null || value.isEmpty) ? "Field required" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: onToggleVisibility)
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
