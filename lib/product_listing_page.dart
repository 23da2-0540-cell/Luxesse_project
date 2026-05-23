import 'package:flutter/material.dart';
import 'data/app_data.dart';
import 'services/firestore_service.dart';
import 'product_detail_page.dart';
import 'bag_page.dart';
import 'wishlist_page.dart';
import 'profile_page.dart';

class ProductListingPage extends StatefulWidget {
  final String category;
  const ProductListingPage({super.key, this.category = 'Dresses'});

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  String _selectedSort   = 'Sorting';
  String _selectedFilter = 'Filter';

  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    Text(
                      widget.category == 'All'
                          ? 'All Products'
                          : widget.category,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildFilterRow(),
                    const SizedBox(height: 16),
                    _buildProductGrid(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ──────────────────────────────────────────
  // APP BAR
  // ──────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: const Color(0xFFD4B06A),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 20,
        bottom: 14,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios,
                color: Colors.white, size: 20),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'LUXESSE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 5,
                  fontFamily: 'serif',
                ),
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.search,
                      color: Colors.white, size: 24)),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BagPage())),
                child: const Icon(Icons.shopping_bag_outlined,
                    color: Colors.white, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // FILTER ROW
  // ──────────────────────────────────────────
  Widget _buildFilterRow() {
    return Row(
      children: [
        _filterChip(label: 'Filter', icon: Icons.filter_list, onTap: () {}),
        const SizedBox(width: 10),
        _dropdownChip(
          label: _selectedFilter,
          items: ['All', 'New', 'Sale', 'Limited'],
          onSelected: (val) => setState(() => _selectedFilter = val),
        ),
        const SizedBox(width: 10),
        _dropdownChip(
          label: _selectedSort,
          items: ['Price: Low to High', 'Price: High to Low', 'Newest'],
          onSelected: (val) => setState(() => _selectedSort = val),
        ),
      ],
    );
  }

  Widget _filterChip(
      {required String label,
      required IconData icon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.black54),
            const SizedBox(width: 6),
            Text(label,
                style:
                    const TextStyle(fontSize: 13, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _dropdownChip({
    required String label,
    required List<String> items,
    required ValueChanged<String> onSelected,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => items
          .map((item) => PopupMenuItem(value: item, child: Text(item)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // PRODUCT GRID — Firestore StreamBuilder
  // ──────────────────────────────────────────
  Widget _buildProductGrid() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getProductsByCategory(widget.category),
      builder: (context, snapshot) {
        // Fallback to AppData while Firestore loads.
        // Respects the selected category (including 'All').
        final products = snapshot.hasData && snapshot.data!.isNotEmpty
            ? snapshot.data!
            : AppData.getProductsByCategory(widget.category)
                .map((p) => Map<String, dynamic>.from(p))
                .toList();

        if (products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'No products found.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.62,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) =>
              _buildProductCard(products[index]),
        );
      },
    );
  }

  // ──────────────────────────────────────────
  // PRODUCT CARD  (Step 5: imageUrl support)
  // ──────────────────────────────────────────
  Widget _buildProductCard(Map<String, dynamic> product) {
    final imageUrl        = (product['imageUrl'] ?? '').toString();
    final localImage      = (product['localImage'] ?? product['image'] ?? '').toString();
    final detailLocalImage =
        (product['detailLocalImage'] ?? product['detailImage'] ?? localImage).toString();
    final name  = (product['name'] ?? '').toString();
    final price = (product['price'] ?? '').toString();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              productName: name.replaceAll('\n', ' '),
              price: price,
              mainImage: localImage,
              imageUrl: imageUrl,
              detailLocalImage: detailLocalImage,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: _productImage(
                  imageUrl: imageUrl,
                  localImage: localImage,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await _firestoreService.addToCart({
                            'name':       name.replaceAll('\n', ' '),
                            'subtitle':   '',
                            'price':      double.tryParse(
                                            price.replaceAll(
                                              RegExp(r'[^\d.]'), '')) ?? 0.0,
                            'imageUrl':   imageUrl,
                            'localImage': localImage,
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${name.replaceAll('\n', ' ')} added to bag!'),
                                backgroundColor: const Color(0xFFAC8A2E),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFAC8A2E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // IMAGE HELPER (Step 5)
  // ──────────────────────────────────────────
  Widget _productImage({
    required String imageUrl,
    required String localImage,
    required double width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(width, height),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _placeholder(width, height),
      );
    }
    if (localImage.isNotEmpty) {
      return Image.asset(
        localImage,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(width, height),
      );
    }
    return _placeholder(width, height);
  }

  Widget _placeholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Icon(Icons.image_not_supported,
          color: Colors.grey.shade400, size: 40),
    );
  }

  // ──────────────────────────────────────────
  // BOTTOM NAV BAR
  // ──────────────────────────────────────────
  Widget _buildBottomNavBar() {
    const items = [
      Icons.home_rounded,
      Icons.grid_view_rounded,
      Icons.bookmark_border_rounded,
      Icons.person_outline,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              // Highlight the Products icon when we are on a category listing,
              // otherwise highlight Home.
              final isActive = widget.category != 'All'
                  ? index == 0   // came from category tap → Home active
                  : index == 1;  // came from Products nav → Products active
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    Navigator.pop(context); // back to Home
                  } else if (index == 1) {
                    // Already on products; if current category isn't 'All',
                    // replace with the all-products view.
                    if (widget.category != 'All') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ProductListingPage(category: 'All'),
                        ),
                      );
                    }
                  } else if (index == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const WishlistPage()),
                    );
                  } else if (index == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProfilePage()),
                    );
                  }
                },
                child: Icon(
                  items[index],
                  color: isActive
                      ? const Color(0xFFAC8A2E)
                      : Colors.grey.shade400,
                  size: 26,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
