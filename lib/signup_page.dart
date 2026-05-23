import 'package:flutter/material.dart';
import 'services/auth_service.dart';
// Navigation to HomePage is handled automatically by the StreamBuilder in main.dart

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController            = TextEditingController();
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService               = AuthService();

  bool _isAgreed          = false;
  bool _isLoading         = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible  = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── SIGN UP ─────────────────────────────────────────────────
  Future<void> _handleSignUp() async {
    final name     = _nameController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm  = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnackBar('Please fill in all fields.');
      return;
    }
    if (password != confirm) {
      _showSnackBar('Passwords do not match.');
      return;
    }
    if (!_isAgreed) {
      _showSnackBar('Please agree to the Terms & Conditions.');
      return;
    }

    setState(() => _isLoading = true);

    final error = await _authService.signUp(
      email: email,
      password: password,
      fullName: name,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      _showSnackBar(error);
    }
    // On success, StreamBuilder in main.dart navigates to HomePage automatically.
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFAC8A2E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section with Gradient
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFAC8A2E),
                    Color(0xFFE5CC84),
                  ],
                ),
              ),
              child: const SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LUXESSE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 6,
                        fontFamily: 'serif',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Create Your Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // White Card Section
            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    // Input Fields
                    _buildInputField(
                      hintText: 'Full Name',
                      icon: Icons.person,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      hintText: 'Email',
                      icon: Icons.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      hintText: 'Create Password',
                      icon: Icons.lock,
                      controller: _passwordController,
                      isPassword: !_isPasswordVisible,
                      suffixIcon: Icons.visibility_off_outlined,
                      onSuffixTap: () =>
                          setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      hintText: 'Confirm Password',
                      icon: Icons.lock,
                      controller: _confirmPasswordController,
                      isPassword: !_isConfirmVisible,
                      suffixIcon: Icons.visibility_off_outlined,
                      onSuffixTap: () =>
                          setState(() => _isConfirmVisible = !_isConfirmVisible),
                    ),

                    const SizedBox(height: 20),

                    // Terms & Conditions Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _isAgreed,
                          onChanged: (value) =>
                              setState(() => _isAgreed = value ?? false),
                          activeColor: const Color(0xFFAC8A2E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Text('Agree to '),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Terms & Condition',
                            style: TextStyle(
                              color: Color(0xFFAC8A2E),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAC8A2E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Log In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              color: Color(0xFFAC8A2E),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFAC8A2E), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black26),
          prefixIcon: Icon(icon, color: Colors.black),
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(suffixIcon, color: Colors.black54),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}
