import 'package:flutter/material.dart';

import 'home_page.dart';
import 'cart_page.dart';
import 'wishlist_page.dart';
import 'profile_page.dart';

// ─── Data ─────────────────────────────────────────────────────────────────────

class _Category {
  final String label;
  final IconData icon;
  const _Category({required this.label, required this.icon});
}

const _categories = [
  _Category(label: 'Fashion', icon: Icons.checkroom_outlined),
  _Category(label: 'Electronics', icon: Icons.memory_outlined),
  _Category(label: 'Home & Living', icon: Icons.home_outlined),
  _Category(label: 'Beauty & Personal Care', icon: Icons.face_outlined),
  _Category(label: 'Groceries', icon: Icons.shopping_basket_outlined),
  _Category(label: 'Sports & Fitness', icon: Icons.fitness_center_outlined),
  _Category(label: 'Automotive', icon: Icons.directions_car_outlined),
  _Category(label: 'Books & Education', icon: Icons.menu_book_outlined),
  _Category(label: 'Pets', icon: Icons.pets_outlined),
  _Category(label: 'Gaming', icon: Icons.sports_esports_outlined),
  _Category(label: 'Travel & Lifestyle', icon: Icons.luggage_outlined),
  _Category(label: 'Health & Medical', icon: Icons.medical_services_outlined),
  _Category(label: 'Gifts & Special Items', icon: Icons.card_giftcard_outlined),
  _Category(label: 'Top Brands', icon: Icons.emoji_events_outlined),
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  int _selectedCategory = 0;
  int _selectedNavIndex = 1; // Categories tab

  static const Color _black = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFE8720C);
  static const Color _sidebarBg = Color(0xFFF2F2F2);
  static const Color _activeItemBg = Color(0xFFFFFFFF);
  static const Color _navIconColor = Color(0xFF888888);
  static const Color _searchBg = Color(0xFFEEEEEE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top App Bar ───────────────────────────────────────────────
            _AppBar(),

            // ── Body ──────────────────────────────────────────────────────
            Expanded(
              child: Row(
                children: [
                  // ── Left Sidebar ─────────────────────────────────────
                  _Sidebar(
                    categories: _categories,
                    selectedIndex: _selectedCategory,
                    onSelect: (i) => setState(() => _selectedCategory = i),
                    sidebarBg: _sidebarBg,
                    activeItemBg: _activeItemBg,
                    orange: _orange,
                    black: _black,
                  ),

                  // ── Right Content Area ────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Page title
                              const Text(
                                'Categories',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: _black,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Search bar
                              Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _searchBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: TextField(
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: _black,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Search sub-categories...',
                                          hintStyle: TextStyle(
                                            fontSize: 13.5,
                                            color:
                                                _black.withOpacity(0.38),
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Icon(
                                        Icons.search_rounded,
                                        color: _black.withOpacity(0.4),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Empty content area
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.grid_view_rounded,
                                  size: 52,
                                  color: _black.withOpacity(0.12),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Select a category',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: _black.withOpacity(0.3),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Navigation Bar ─────────────────────────────────────
            _BottomNavBar(
              selectedIndex: _selectedNavIndex,
              onTap: (i) {
                if (i == _selectedNavIndex) return;
                Widget page;
                switch (i) {
                  case 0: page = const HomePage(); break;
                  case 2: page = const CartPage(); break;
                  case 3: page = const WishlistPage(); break;
                  case 4: page = const ProfilePage(); break;
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
  static const Color _black = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFE8720C);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.07), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo icon circle
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.bolt_rounded,
                color: _orange,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Quick',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _black,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Art',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _orange,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Icon(Icons.notifications_none_rounded,
              color: _black.withOpacity(0.6), size: 24),
          const SizedBox(width: 14),
          Icon(Icons.person_outline_rounded,
              color: _black.withOpacity(0.6), size: 24),
        ],
      ),
    );
  }
}

// ─── Sidebar ──────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final List<_Category> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Color sidebarBg;
  final Color activeItemBg;
  final Color orange;
  final Color black;

  const _Sidebar({
    required this.categories,
    required this.selectedIndex,
    required this.onSelect,
    required this.sidebarBg,
    required this.activeItemBg,
    required this.orange,
    required this.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      color: sidebarBg,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? activeItemBg : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 26,
                    color: isSelected ? orange : black.withOpacity(0.55),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? black : black.withOpacity(0.55),
                      height: 1.25,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color: orange,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
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
  _NavItem(icon: Icons.home_outlined, label: 'Home'),
  _NavItem(icon: Icons.grid_view_rounded, label: 'Categories'),
  _NavItem(icon: Icons.shopping_cart_outlined, label: 'Cart'),
  _NavItem(icon: Icons.favorite_border_rounded, label: 'Wishlist'),
  _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
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
      height: 64,
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
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 24,
                    color: isActive ? black : navIconColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w400,
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