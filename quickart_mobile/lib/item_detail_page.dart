import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:model_viewer_plus/model_viewer_plus.dart';

import 'session.dart';
import 'config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NOTE: For the 3D GLB viewer, add this dependency to pubspec.yaml:
//   model_viewer_plus: ^1.7.0
//
// Then replace _GlbViewerPlaceholder with:
//   import 'package:model_viewer_plus/model_viewer_plus.dart';
//   ModelViewer(src: item.glbAssetPath, autoRotate: true, ar: true)
// ─────────────────────────────────────────────────────────────────────────────

// ─── Model ────────────────────────────────────────────────────────────────────

class _ItemData {
  final String name;
  final String category;
  final String seller;
  final double price;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> highlights;
  final List<String> images;
  final String? glbAssetPath;
  final int stock;

  const _ItemData({
    required this.name,
    required this.category,
    required this.seller,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.highlights,
    required this.images,
    this.glbAssetPath,
    required this.stock,
  });

  bool get inStock => stock > 0;
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class ItemDetailPage extends StatefulWidget {
  final String productId;
  const ItemDetailPage({super.key, required this.productId});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage>
    with SingleTickerProviderStateMixin {
  int _activeImageIndex = 0;
  bool _show3D = false;
  bool _isWishlisted = false;
  int _quantity = 1;
  int _selectedNavIndex = 0;
  bool _isLoading = true;
  _ItemData? _item;

  late PageController _pageController;

  static const Color _black = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFE8720C);
  static const Color _bgColor = Color(0xFFF2F2F0);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _navIconColor = Color(0xFF999999);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchProduct();
  }

  void _fetchProduct() async {
    try {
      final db = await mongo.Db.create(Config.mongoUrl);
      await db.open();
      final collection = db.collection('products');

      final data = await collection.findOne(mongo.where.eq('_id', widget.productId));

      await db.close();

      if (!mounted) return;

      if (data != null) {
        setState(() {
          _item = _ItemData(
            name: data['name']?.toString() ?? 'Unknown Product',
            category: data['category']?.toString() ?? 'GENERAL',
            seller: 'QuickArt',
            price: (data['price'] as num?)?.toDouble() ?? 0.0,
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            reviewCount: 120,
            description: data['description']?.toString() ?? '',
            highlights: ['Fast delivery', 'Premium quality', 'Authentic design'],
            images: [data['imageUrl']?.toString() ?? ''],
            glbAssetPath: data['model3dUrl']?.toString(),
            stock: (data['stock'] as num?)?.toInt() ?? 0,
          );
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  void _switchToImage(int index) {
    setState(() {
      _activeImageIndex = index;
      _show3D = false;
    });
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 280), curve: Curves.easeInOut);
  }

  void _toggle3D() => setState(() => _show3D = !_show3D);

  void _toggleWishlist() async {
    setState(() => _isWishlisted = !_isWishlisted);
    
    try {
      final db = await mongo.Db.create(Config.mongoUrl);
      await db.open();

      final prefCollection = db.collection('preferences');
      final pref = await prefCollection.findOne(mongo.where.eq('userId', Session.userId));
      if (pref != null) {
        List<dynamic> wishlist = pref['wishlist'] ?? [];
        if (_isWishlisted) {
          if (!wishlist.contains(widget.productId)) wishlist.add(widget.productId);
        } else {
          wishlist.remove(widget.productId);
        }
        await prefCollection.updateOne(
          mongo.where.eq('userId', Session.userId),
          mongo.modify.set('wishlist', wishlist),
        );
      }
      await db.close();
    } catch (e) {
      debugPrint('Error updating wishlist: $e');
    }
  }

  void _addToCart() async {
    final item = _item;
    if (item == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} (×$_quantity) added to cart'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: _black,
      ),
    );

    try {
      final db = await mongo.Db.create(Config.mongoUrl);
      await db.open();

      final prefCollection = db.collection('preferences');
      final pref = await prefCollection.findOne(mongo.where.eq('userId', Session.userId));
      if (pref != null) {
        List<dynamic> cart = pref['cart'] ?? [];
        bool found = false;
        for (var c in cart) {
          if (c['productId'] == widget.productId) {
            c['quantity'] = (c['quantity'] as num).toInt() + _quantity;
            found = true;
            break;
          }
        }
        if (!found) {
          cart.add({'productId': widget.productId, 'quantity': _quantity});
        }
        await prefCollection.updateOne(
          mongo.where.eq('userId', Session.userId),
          mongo.modify.set('cart', cart),
        );
      }
      await db.close();
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ───────────────────────────────────────────────────
            _AppBar(
              black: _black,
              isWishlisted: _isWishlisted,
              onWishlist: _toggleWishlist,
              onBack: () => Navigator.maybePop(context),
            ),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _orange))
                  : _item == null
                      ? Center(
                          child: Text(
                            'Product not found',
                            style: TextStyle(
                                fontSize: 16, color: _black.withOpacity(0.5)),
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            final item = _item!;
                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                    // ── Item Name & Category ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: _orange,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: _black,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _StarRow(
                                  rating: item.rating, orange: _orange),
                              const SizedBox(width: 8),
                              Text(
                                '${item.reviewCount} reviews',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _black.withOpacity(0.4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'by ${item.seller}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _black.withOpacity(0.4),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Image Viewer ──────────────────────────────────────
                    _ImageViewer(
                      item: item,
                      activeIndex: _activeImageIndex,
                      show3D: _show3D,
                      pageController: _pageController,
                      onPageChanged: (i) =>
                          setState(() => _activeImageIndex = i),
                      onThumbnailTap: _switchToImage,
                      onToggle3D: _toggle3D,
                      black: _black,
                      orange: _orange,
                    ),

                    const SizedBox(height: 24),

                    // ── Price & Quantity ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PRICE',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.8,
                                    color: _black.withOpacity(0.38),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'LKR ${_fmt(item.price)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: _black,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: item.inStock
                                        ? const Color(0xFFE8F5E9)
                                        : const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    item.inStock ? 'In Stock' : 'Out of Stock',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: item.inStock
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFC62828),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Quantity
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'QTY',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.8,
                                    color: _black.withOpacity(0.38),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: _black.withOpacity(0.15),
                                        width: 1.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _QtyBtn(
                                        icon: Icons.remove_rounded,
                                        onTap: () {
                                          if (_quantity > 1) {
                                            setState(() => _quantity--);
                                          }
                                        },
                                        black: _black,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text(
                                          _quantity
                                              .toString()
                                              .padLeft(2, '0'),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _black,
                                          ),
                                        ),
                                      ),
                                      _QtyBtn(
                                        icon: Icons.add_rounded,
                                        onTap: () =>
                                            setState(() => _quantity++),
                                        black: _black,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Description ───────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SectionCard(
                        title: 'Description',
                        black: _black,
                        cardColor: _cardColor,
                        child: Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.7,
                            color: _black.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Highlights ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SectionCard(
                        title: 'Highlights',
                        black: _black,
                        cardColor: _cardColor,
                        child: Column(
                          children: item.highlights
                              .map((h) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          margin: const EdgeInsets.only(
                                              top: 6, right: 12),
                                          decoration: BoxDecoration(
                                            color: _orange,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            h,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              color: _black.withOpacity(0.65),
                                              fontWeight: FontWeight.w400,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Action Buttons ────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // Wishlist
                          GestureDetector(
                            onTap: _toggleWishlist,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: _cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: _isWishlisted
                                        ? Colors.red.withOpacity(0.4)
                                        : _black.withOpacity(0.12),
                                    width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isWishlisted
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: _isWishlisted
                                    ? Colors.red
                                    : _black.withOpacity(0.5),
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Add to Cart
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _addToCart,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 18),
                                    SizedBox(width: 10),
                                    Text(
                                      'Add to Cart',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              );
                        }
                      ),
            ),

            // ── Bottom Nav ────────────────────────────────────────────────
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

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final Color black;
  final bool isWishlisted;
  final VoidCallback onWishlist;
  final VoidCallback onBack;

  const _AppBar({
    required this.black,
    required this.isWishlisted,
    required this.onWishlist,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: black, size: 20),
          ),
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Quick',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: black,
                    letterSpacing: -0.5,
                  ),
                ),
                const TextSpan(
                  text: 'Art',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE8720C),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onWishlist,
            child: Icon(
              isWishlisted
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isWishlisted ? Colors.red : black.withOpacity(0.5),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Icon(Icons.share_outlined,
              color: black.withOpacity(0.5), size: 22),
        ],
      ),
    );
  }
}

// ─── Image Viewer ─────────────────────────────────────────────────────────────

class _ImageViewer extends StatelessWidget {
  final _ItemData item;
  final int activeIndex;
  final bool show3D;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onThumbnailTap;
  final VoidCallback onToggle3D;
  final Color black;
  final Color orange;

  const _ImageViewer({
    required this.item,
    required this.activeIndex,
    required this.show3D,
    required this.pageController,
    required this.onPageChanged,
    required this.onThumbnailTap,
    required this.onToggle3D,
    required this.black,
    required this.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Main View ──────────────────────────────────────────────────
        Container(
          height: 300,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: show3D && item.glbAssetPath != null
                ? ModelViewer(
                    src: item.glbAssetPath!,
                    autoRotate: true,
                    ar: true,
                    cameraControls: true,
                  )
                : PageView.builder(
                    controller: pageController,
                    onPageChanged: onPageChanged,
                    itemCount: item.images.length,
                    itemBuilder: (context, index) {
                      final img = item.images[index];
                      if (img.isEmpty) {
                        return Container(
                          color: const Color(0xFFE8E8E6),
                          child: Center(
                            child: Icon(Icons.image_not_supported_outlined,
                                size: 100, color: black.withOpacity(0.2)),
                          ),
                        );
                      }
                      return Image.network(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFE8E8E6),
                          child: Center(
                            child: Icon(Icons.image_not_supported_outlined,
                                size: 100, color: black.withOpacity(0.2)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Thumbnail Strip ───────────────────────────────────────────
        SizedBox(
          height: 62,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // Image thumbnails
              ...item.images.asMap().entries.map((entry) {
                final i = entry.key;
                final img = entry.value;
                final isActive = !show3D && i == activeIndex;
                return GestureDetector(
                  onTap: () => onThumbnailTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 58,
                    height: 58,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? orange : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: img.isNotEmpty
                          ? Image.network(
                              img,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 20,
                                  color: black.withOpacity(0.3)),
                            )
                          : Icon(Icons.image_not_supported_outlined,
                              size: 20, color: black.withOpacity(0.3)),
                    ),
                  ),
                );
              }).toList(),

              // 3D View button
              if (item.glbAssetPath != null && item.glbAssetPath!.isNotEmpty)
              GestureDetector(
                onTap: onToggle3D,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: show3D ? black : const Color(0xFFE8E8E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: show3D ? orange : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.view_in_ar_rounded,
                        size: 22,
                        color: show3D
                            ? orange
                            : black.withOpacity(0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '3D',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: show3D
                              ? orange
                              : black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Dot Indicators (images only) ──────────────────────────────
        if (!show3D) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: item.images.asMap().entries.map((e) {
              final isActive = e.key == activeIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 18 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: isActive ? black : black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color black;
  final Color cardColor;

  const _SectionCard({
    required this.title,
    required this.child,
    required this.black,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: black,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─── Star Row ─────────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final double rating;
  final Color orange;
  const _StarRow({required this.rating, required this.orange});

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
          size: 14,
        );
      }),
    );
  }
}

// ─── Qty Button ───────────────────────────────────────────────────────────────

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color black;
  const _QtyBtn(
      {required this.icon, required this.onTap, required this.black});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 38,
        child: Icon(icon, size: 16, color: black),
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
  _NavItem(icon: Icons.home_outlined, label: 'HOME'),
  _NavItem(icon: Icons.grid_view_rounded, label: 'CATEGORIES'),
  _NavItem(icon: Icons.shopping_cart_outlined, label: 'CART'),
  _NavItem(icon: Icons.favorite_border_rounded, label: 'WISHLIST'),
  _NavItem(icon: Icons.person_outline_rounded, label: 'PROFILE'),
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
                  Icon(item.icon,
                      size: 22,
                      color: isActive ? black : navIconColor),
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
