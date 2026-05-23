import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Display name falls back to email prefix if displayName is not set
    final displayName = (user?.displayName?.isNotEmpty == true)
        ? user!.displayName!
        : (user?.email?.split('@').first ?? 'User');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Color(0xFFD4B06A),
              Color(0xFFAC8A2E),
            ],
            stops: [0.0, 0.4, 0.5, 1.0],
          ),
        ),
        child: Column(
          children: [
            // ── Top Header Section ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 40,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.black, size: 22),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'My Account',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'serif',
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFD4B06A), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/profile/image.jpeg'),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Real user name from FirebaseAuth
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Menu Section ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 30),
                child: Column(
                  children: [
                    _buildMenuItem(
                        context, Icons.shopping_cart_outlined, 'My Orders'),
                    _buildMenuItem(
                        context, Icons.bookmark_outline, 'Wishlist'),
                    _buildMenuItem(
                        context, Icons.location_on_outlined, 'Address Book'),
                    _buildMenuItem(
                        context, Icons.payments_outlined, 'Payment'),
                    _buildMenuItem(
                        context, Icons.settings_outlined, 'Settings'),
                    // Log Out — wired to AuthService
                    _buildMenuItem(
                        context, Icons.logout, 'Log Out',
                        isLogout: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title, {
    bool isLogout = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            if (isLogout) {
              await AuthService().signOut();
              // StreamBuilder in main.dart will navigate back to OnboardPage
            }
          },
          splashColor: const Color(0xFFD4B06A).withOpacity(0.1),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: [
                Icon(icon, color: Colors.black87, size: 26),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.black45, size: 16),
              ],
            ),
          ),
        ),
        const Divider(color: Colors.black12, thickness: 0.8),
      ],
    );
  }
}
