import 'package:flutter/material.dart';

void main() {
  runApp(const QuickArtApp());
}

class QuickArtApp extends StatelessWidget {
  const QuickArtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickArt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ),
      home: const HomePage(),
    );
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

class _Product {
  final String name;
  final String seller;
  final double rating;
  final int reviewCount;
  final double price;
  final String currency;
  final Color imageBg;
  final IconData imageIcon;
  bool isWishlisted;

  _Product({
    required this.name,
    required this.seller,
    required this.rating,
    required this.reviewCount,
    required this.price,
    this.currency = 'LKR',
    required this.imageBg,
    required this.imageIcon,
    this.isWishlisted = false,
  });
}

// ─── Sample Data ──────────────────────────────────────────────────────────────

final List<_Product> _products = [
  _Product(
    name: "Men's Casual Shirt",
    seller: 'Ome witurer',
    rating: 4.5,
    reviewCount: 120,
    price: 4500,
    imageBg: const Color(0xFFDDE4EC),
    imageIcon: Icons.checkroom_outlined,
  ),
  _Product(
    name: 'Latest Smartphone Pro',
    seller: 'Ome nhituer',
    rating: 4.0,
    reviewCount: 340,
    price: 215000,
    imageBg: const Color(0xFFDDE3F0),
    imageIcon: Icons.smartphone_outlined,
  ),
  _Product(
    name: "Men's Casual Shirt",
    seller: 'Ome witurer',
    rating: 4.0,
    reviewCount: 98,
    price: 4500,
    imageBg: const Color(0xFFE8DDD0),
    imageIcon: Icons.checkroom_outlined,
  ),
  _Product(
    name: 'Latest Smartphone Pro',
    seller: 'Ome nhitvsr',
    rating: 4.5,
    reviewCount: 210,
    price: 4500,
    imageBg: const Color(0xFFD8D0C8),
    imageIcon: Icons.smartphone_outlined,
  ),
  _Product(
    name: "Men's Casual Shirt",
    seller: 'Droe now',
    rating: 4.5,
    reviewCount: 75,
    price: 4500,
    imageBg: const Color(0xFFCCCCCC),
    imageIcon: Icons.checkroom_outlined,
  ),
  _Product(
    name: 'Latest Smartphone Pro',
    seller: 'Droe now',
    rating: 4.0,
    reviewCount: 180,
    price: 215000,
    imageBg: const Color(0xFFD0D8E8),
    imageIcon: Icons.smartphone_outlined,
  ),
  _Product(
    name: "Men's Casual Shirt",
    seller: 'Droe now',
    rating: 3.5,
    reviewCount: 55,
    price: 4500,
    imageBg: const Color(0xFFCCCCCC),
    imageIcon: Icons.checkroom_outlined,
  ),
  _Product(
    name: 'Latest Smartphone Pro',
    seller: 'Droe now',
    rating: 4.5,
    reviewCount: 290,
    price: 215000,
    imageBg: const Color(0xFFD0D8E8),
    imageIcon: Icons.smartphone_outlined,
  ),
  _Product(
    name: "Men's Casual Shirt",
    seller: 'Droe now',
    rating: 4.5,
    reviewCount: 88,
    price: 4500,
    imageBg: const Color(0xFFCCCCCC),
    imageIcon: Icons.checkroom_outlined,
  ),
  _Product(
    name: 'Latest Smartphone Pro',
    seller: 'Droe now',
    rating: 4.0,
    reviewCount: 143,
    price: 215000,
    imageBg: const Color(0xFFD0D8E8),
    imageIcon: Icons.smartphone_outlined,
  ),
  _Product(
    name: "Men's Casual Shirt",
    seller: 'Droe now',
    rating: 4.0,
    reviewCount: 61,
    price: 4500,
    imageBg: const Color(0xFFCCCCCC),
    imageIcon: Icons.checkroom_outlined,
  ),
  _Product(
    name: 'Latest Smartphone Pro',
    seller: 'Droe now',
    rating: 4.5,
    reviewCount: 320,
    price: 215000,
    imageBg: const Color(0xFFD0D8E8),
    imageIcon: Icons.smartphone_outlined,
  ),
];

const List<String> _brands = [
  'NEXUS AI',
  'AURA',
  'QuantumLeap',
  'Stellar',
  'Nova',
  'Orion',
  'CyberCore',
];

// ─── HomePage ─────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedBrand = 0;
  int _selectedNavIndex = 0;
  int _cartCount = 1;

  static const Color _black = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFE8720C);
  static const Color _navIconColor = Color(0xFF888888);

  void _toggleWishlist(int index) {
    setState(() {
      _products[index].isWishlisted = !_products[index].isWishlisted;
    });
  }

  void _addToCart(int index) {
    setState(() => _cartCount++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_products[index].name} added to cart'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(Icons.search_rounded,
                              color: _black.withOpacity(0.4), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              style:
                                  const TextStyle(fontSize: 14, color: _black),
                              decoration: InputDecoration(
                                hintText: 'Search products...',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: _black.withOpacity(0.38),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Icon(Icons.shopping_cart_outlined,
                            color: _black, size: 22),
                      ),
                      if (_cartCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: _black,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                '$_cartCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Scrollable content ────────────────────────────────────────
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Top Brands
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: const Text(
                        'Top Brands',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _black,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 42,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _brands.length,
                        itemBuilder: (context, index) {
                          final isSelected = index == _selectedBrand;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedBrand = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? _black : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? _black
                                      : Colors.black.withOpacity(0.2),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                _brands[index],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : _black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // Featured Products header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Featured Products',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _black,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: _black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  'View All',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.chevron_right_rounded,
                                    color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // Product Grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _ProductCard(
                          product: _products[index],
                          onWishlistTap: () => _toggleWishlist(index),
                          onAddToCart: () => _addToCart(index),
                          orange: _orange,
                          black: _black,
                        ),
                        childCount: _products.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            ),

            // ── Bottom Nav Bar ────────────────────────────────────────────
            _BottomNavBar(
              selectedIndex: _selectedNavIndex,
              onTap: (i) => setState(() => _selectedNavIndex = i),
              navIconColor: _navIconColor,
              black: _black,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final _Product product;
  final VoidCallback onWishlistTap;
  final VoidCallback onAddToCart;
  final Color orange;
  final Color black;

  const _ProductCard({
    required this.product,
    required this.onWishlistTap,
    required this.onAddToCart,
    required this.orange,
    required this.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: product.imageBg,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(13)),
                  ),
                  width: double.infinity,
                  child: Center(
                    child: Icon(
                      product.imageIcon,
                      size: 56,
                      color: Colors.black.withOpacity(0.25),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onWishlistTap,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        product.isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 16,
                        color: product.isWishlisted ? Colors.red : black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info area
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: black,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Seller
                  Text(
                    product.seller,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: black.withOpacity(0.4),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Stars
                  _StarRating(rating: product.rating, orange: orange),
                  const Spacer(),

                  // Price + Add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.currency} ${_formatPrice(product.price)}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: black,
                        ),
                      ),
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
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
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price
          .toStringAsFixed(0)
          .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    }
    return price.toStringAsFixed(0);
  }
}

// ─── Star Rating ──────────────────────────────────────────────────────────────

class _StarRating extends StatelessWidget {
  final double rating;
  final Color orange;

  const _StarRating({required this.rating, required this.orange});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          half
              ? Icons.star_half_rounded
              : filled
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
          color: orange,
          size: 13,
        );
      }),
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
