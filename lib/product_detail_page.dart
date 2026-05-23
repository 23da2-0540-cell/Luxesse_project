import 'package:flutter/material.dart';
import 'data/app_data.dart';
import 'services/firestore_service.dart';
import 'bag_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String productName;
  final String price;
  final String mainImage;
  final String imageUrl;         // Step 5: Cloudinary / network URL
  final String detailLocalImage; // local asset for carousel

  const ProductDetailPage({
    super.key,
    this.productName      = 'Cherry Blossom Luxe Gown',
    this.price            = '\$1,200',
    this.mainImage        = 'assets/images/product details/frock1.jpeg',
    this.imageUrl         = '',
    this.detailLocalImage = 'assets/images/product details/frock1.jpeg',
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int    _currentImageIndex  = 0;
  String _selectedSize       = 'XL';
  int    _selectedColorIndex = 0;
  bool   _isAddingToBag      = false;
  bool   _isWishlisted       = false;

  final _firestoreService = FirestoreService();

  final List<String> _sizes = ['XL', 'L', 'M', 'S'];
  final List<Color>  _colors = [
    const Color(0xFF8B1A1A),
    const Color(0xFF1A5C5C),
    const Color(0xFFD4A96A),
  ];

  // Carousel uses detailLocalImage first, then the rest from AppData
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    final others = AppData.detailImages
        .where((img) => img != widget.detailLocalImage)
        .toList();
    _images = [widget.detailLocalImage, ...others];
    // Check if this product is already wishlisted
    _firestoreService
        .isInWishlist(widget.productName)
        .then((value) {
      if (mounted) setState(() => _isWishlisted = value);
    });
  }

  // ─── ADD TO BAG ──────────────────────────────────────────────
  Future<void> _handleAddToBag() async {
    setState(() => _isAddingToBag = true);

    await _firestoreService.addToCart({
      'name':       '${widget.productName} - $_selectedSize',
      'subtitle':   'Size-$_selectedSize',
      'price':      _parsePriceValue(widget.price),
      'imageUrl':   widget.imageUrl,
      'localImage': widget.mainImage,
    });

    if (!mounted) return;
    setState(() => _isAddingToBag = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.productName} added to bag!'),
        backgroundColor: const Color(0xFFAC8A2E),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View Bag',
          textColor: Colors.white,
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const BagPage())),
        ),
      ),
    );
  }

  /// Strips "$" and commas and returns a double (e.g. "$1,200" → 1200.0)
  double _parsePriceValue(String price) {
    final cleaned = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  // ─── WISHLIST TOGGLE ─────────────────────────────────────────
  Future<void> _handleWishlistToggle() async {
    if (_isWishlisted) {
      // Remove from wishlist
      final docId = widget.productName
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
          .toLowerCase();
      await _firestoreService.removeFromWishlist(docId);
      if (!mounted) return;
      setState(() => _isWishlisted = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from wishlist'),
          backgroundColor: Color(0xFFAC8A2E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Add to wishlist
      await _firestoreService.addToWishlist({
        'name':             widget.productName,
        'price':            widget.price,
        'imageUrl':         widget.imageUrl,
        'localImage':       widget.mainImage,
        'detailLocalImage': widget.detailLocalImage,
      });
      if (!mounted) return;
      setState(() => _isWishlisted = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to wishlist!'),
          backgroundColor: Color(0xFFAC8A2E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageCarousel(),
                  const SizedBox(height: 10),
                  _buildDotIndicators(),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNameAndPrice(),
                        const SizedBox(height: 4),
                        const Text(
                          'Satin Velvet',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black45,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSizeSection(),
                        const SizedBox(height: 20),
                        _buildColorSection(),
                        const SizedBox(height: 28),
                        _buildAddToBagRow(),
                        const SizedBox(height: 24),
                        _buildDescription(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BagPage())),
            child: const Icon(Icons.shopping_bag_outlined,
                color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // IMAGE CAROUSEL  (Step 5: first slide uses imageUrl if available)
  // ──────────────────────────────────────────
  Widget _buildImageCarousel() {
    return SizedBox(
      height: 320,
      child: PageView.builder(
        itemCount: _images.length,
        onPageChanged: (i) => setState(() => _currentImageIndex = i),
        itemBuilder: (context, index) {
          // First slide: prefer network imageUrl; rest always use local asset
          final useNetwork =
              index == 0 && widget.imageUrl.isNotEmpty;
          if (useNetwork) {
            return Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, _, _) => _assetImage(_images[index]),
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : _localPlaceholder(),
            );
          }
          return _assetImage(_images[index]);
        },
      ),
    );
  }

  Widget _assetImage(String path) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, _, _) => _localPlaceholder(),
    );
  }

  Widget _localPlaceholder() {
    return Container(
      color: const Color(0xFFE8DCC8),
      child: Icon(Icons.image_not_supported,
          color: Colors.grey.shade400, size: 60),
    );
  }

  // ──────────────────────────────────────────
  // DOT INDICATORS
  // ──────────────────────────────────────────
  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_images.length, (index) {
        final isActive = index == _currentImageIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFAC8A2E)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ──────────────────────────────────────────
  // NAME & PRICE
  // ──────────────────────────────────────────
  Widget _buildNameAndPrice() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.productName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          widget.price,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // SIZE SECTION
  // ──────────────────────────────────────────
  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Size',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 10),
        Row(
          children: _sizes.map((size) {
            final isSelected = size == _selectedSize;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFAC8A2E)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFAC8A2E)
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFFAC8A2E).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // COLOR SECTION
  // ──────────────────────────────────────────
  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 10),
        Row(
          children: List.generate(_colors.length, (index) {
            final isSelected = index == _selectedColorIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedColorIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 12),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _colors[index],
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFAC8A2E)
                        : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // ADD TO BAG + WISHLIST
  // ──────────────────────────────────────────
  Widget _buildAddToBagRow() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isAddingToBag ? null : _handleAddToBag,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAC8A2E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isAddingToBag
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Text(
                      'Add to Bag',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _handleWishlistToggle,
            icon: Icon(
              _isWishlisted
                  ? Icons.bookmark_rounded         // filled = saved
                  : Icons.bookmark_border_rounded, // outline = not saved
              color: const Color(0xFFAC8A2E),
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // DESCRIPTION
  // ──────────────────────────────────────────
  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 10),
        const Text(
          'A luxurious satin gown in three shades, designed for elegance and '
          'grace. Its smooth texture and flowing silhouette create a soft, '
          'glamorous look perfect for evening occasions and special events.',
          style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.6),
        ),
      ],
    );
  }
}
