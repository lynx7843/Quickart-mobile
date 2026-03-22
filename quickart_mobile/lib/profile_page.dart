import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import 'home_page.dart';
import 'categories_page.dart';
import 'cart_page.dart';
import 'wishlist_page.dart';
import 'session.dart';
import 'login_page.dart';
import 'config.dart';

// ─── Page ─────────────────────────────────────────────────────────────────────

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedNavIndex = 4;
  
  String _name = 'Loading...';
  String _email = 'Loading...';
  String _role = '...';

  static const Color _black = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFE8720C);
  static const Color _bgColor = Color(0xFFF2F2F2);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _navIconColor = Color(0xFF999999);
  static const Color _red = Color(0xFFD32F2F);

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    try {
      final db = await mongo.Db.create(Config.mongoUrl);
      await db.open();
      final collection = db.collection('users');

      final user = await collection.findOne(mongo.where.eq('_id', Session.userId));

      if (user != null && mounted) {
        setState(() {
          _name = user['name']?.toString() ?? 'Unknown';
          _email = user['email']?.toString() ?? '';
          _role = user['role']?.toString() ?? 'CUSTOMER';
        });
      }
      await db.close();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  void _onMenuTap(String label) {
    if (label == 'Logout') {
      _showLogoutDialog();
      return;
    }
    if (label == 'Settings' || label == 'Help') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('This feature is not available'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: _black,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label tapped'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: _black,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () {
              Session.userId = ''; // Clear the session
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Logout',
                style: TextStyle(
                    color: Color(0xFFD32F2F), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ───────────────────────────────────────────────────
            _AppBar(black: _black),

            // ── Scrollable Body ───────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 24),

                  // ── Avatar ─────────────────────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/profile.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Name & Email ───────────────────────────────────────
                  Text(
                    _name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: _black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: _black.withOpacity(0.45),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Premium Badge ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: _black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _role.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Preferences Section ────────────────────────────────
                  _SectionLabel(label: 'PREFERENCES', black: _black),
                  const SizedBox(height: 10),

                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.edit_outlined,
                        label: 'Edit Account',
                      ),
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                      ),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help',
                      ),
                      _MenuItem(
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        isDestructive: true,
                        destructiveColor: _red,
                      ),
                    ],
                    onTap: _onMenuTap,
                    black: _black,
                    cardColor: _cardColor,
                  ),

                  const SizedBox(height: 36),

                  // ── Version ────────────────────────────────────────────
                  Center(
                    child: Text(
                      'QUICKART V2.4.0 • 2024',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.8,
                        color: _black.withOpacity(0.28),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Bottom Nav Bar ────────────────────────────────────────────
            _BottomNavBar(
              selectedIndex: _selectedNavIndex,
              onTap: (i) {
                if (i == _selectedNavIndex) return;
                Widget page;
                switch (i) {
                  case 0: page = const HomePage(); break;
                  case 1: page = const CategoriesPage(); break;
                  case 2: page = const CartPage(); break;
                  case 3: page = const WishlistPage(); break;
                  default: return;
                }
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(pageBuilder: (_, __, ___) => page, transitionDuration: Duration.zero),
                );
              },
              navIconColor: _navIconColor,
              black: _black,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final Color black;
  const _AppBar({required this.black});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          Icon(Icons.menu_rounded, color: black, size: 22),
          const Expanded(
            child: Center(
              child: Text(
                'QuickArt',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/profile.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color black;
  const _SectionLabel({required this.label, required this.black});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        color: black.withOpacity(0.38),
      ),
    );
  }
}

// ─── Menu Item Model ──────────────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final Color? destructiveColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.destructiveColor,
  });
}

// ─── Menu Card ────────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  final void Function(String) onTap;
  final Color black;
  final Color cardColor;

  const _MenuCard({
    required this.items,
    required this.onTap,
    required this.black,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == items.length - 1;

        return GestureDetector(
          onTap: () => onTap(item.label),
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon box
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: item.isDestructive
                        ? const Color(0xFFFFF0F0)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    size: 18,
                    color: item.isDestructive
                        ? item.destructiveColor
                        : black,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: item.isDestructive
                          ? item.destructiveColor
                          : black,
                    ),
                  ),
                ),
                if (!item.isDestructive)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: black.withOpacity(0.3),
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Bottom Nav Bar ───────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

const _navItems = [
  _NavItem(icon: Icons.home_outlined, label: 'HOME'),
  _NavItem(icon: Icons.grid_view_rounded, label: 'CATEGORIES'),
  _NavItem(icon: Icons.shopping_cart_outlined, label: 'CART'),
  _NavItem(icon: Icons.favorite_border_rounded, label: 'WISHLIST'),
  _NavItem(icon: Icons.person_rounded, label: 'PROFILE'),
];

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Color navIconColor;
  final Color black;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
    required this.navIconColor,
    required this.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.08), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final isActive = index == selectedIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 58,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 22,
                    color: isActive ? black : navIconColor,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                          isActive ? FontWeight.w800 : FontWeight.w500,
                      letterSpacing: 0.5,
                      color: isActive ? black : navIconColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}