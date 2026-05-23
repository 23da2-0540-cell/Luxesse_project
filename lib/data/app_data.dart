// ─────────────────────────────────────────────────────────────
// Central data file for Luxesse app.
// All dummy / local data lives here.
// Every screen imports from this file — no hardcoded data anywhere else.
// ─────────────────────────────────────────────────────────────

class AppData {
  // ─── BANNERS ─────────────────────────────────────────────────
  static const List<Map<String, String>> banners = [
    {
      'image':    'assets/images/home/image 1.jpeg',
      'title':    'Signature\nCollection',
      'category': 'Dresses',
    },
    {
      'image':    'assets/images/home/image2.jpeg',
      'title':    'New\nArrivals',
      'category': 'Dresses',
    },
    {
      'image':    'assets/images/home/image6.jpeg',
      'title':    'Exclusive\nDeals',
      'category': 'Dresses',
    },
  ];

  // ─── CATEGORIES ──────────────────────────────────────────────
  static const List<Map<String, String>> categories = [
    {'label': 'Dresses', 'image': 'assets/images/home/image5.jpeg'},
    {'label': 'Shoes',   'image': 'assets/images/home/image4.jpeg'},
    {'label': 'Bags',    'image': 'assets/images/home/image7.jpeg'},
    {'label': 'Jewellery', 'image': 'assets/images/home/image 8.jpeg'},
  ];

  // ─── DETAIL IMAGES (carousel on product detail page) ─────────
  static const List<String> detailImages = [
    'assets/images/product details/frock1.jpeg',
    'assets/images/product details/frock2.jpeg',
    'assets/images/product details/frock 3.jpeg',
  ];

  // ─── FEATURED PRODUCTS (home page grid) ──────────────────────
  // imageUrl is blank — filled in by Firestore after migration.
  static const List<Map<String, String>> featuredProducts = [
    {
      'id': 'prod_1',
      'name': 'Noir Luxe Diamond\nNecklace',
      'price': '\$800',
      'priceValue': '800',
      'category': 'Jewellery',
      'localImage': 'assets/images/product listing/image2 (1).jpeg',
      'detailLocalImage': 'assets/images/product details/frock1.jpeg',
      'imageUrl': '',
    },
    {
      'id': 'prod_2',
      'name': 'Crystal Shine Luxe\nClutch',
      'price': '\$1,700',
      'priceValue': '1700',
      'category': 'Bags',
      'localImage': 'assets/images/product listing/image2 (2).jpeg',
      'detailLocalImage': 'assets/images/product details/frock2.jpeg',
      'imageUrl': '',
    },
    {
      'id': 'prod_3',
      'name': 'Velvet Rose\nGown',
      'price': '\$2,400',
      'priceValue': '2400',
      'category': 'Dresses',
      'localImage': 'assets/images/product listing/image2 (3).jpeg',
      'detailLocalImage': 'assets/images/product details/frock 3.jpeg',
      'imageUrl': '',
    },
    {
      'id': 'prod_4',
      'name': 'Gold Leaf\nEarrings',
      'price': '\$450',
      'priceValue': '450',
      'category': 'Jewellery',
      'localImage': 'assets/images/product listing/image2 (4).jpeg',
      'detailLocalImage': 'assets/images/product details/frock1.jpeg',
      'imageUrl': '',
    },
  ];

  // ─── DRESS PRODUCTS (product listing page) ───────────────────
  static const List<Map<String, String>> dressProducts = [
    {
      'id': 'dress_1',
      'name': 'Champagne Mist Glam\nGown',
      'price': '\$400',
      'priceValue': '400',
      'category': 'Dresses',
      'localImage': 'assets/images/product listing/image2 (1).jpeg',
      'detailLocalImage': 'assets/images/product details/frock1.jpeg',
      'imageUrl': '',
    },
    {
      'id': 'dress_2',
      'name': 'Aurora Glam Luxe\nGown',
      'price': '\$599',
      'priceValue': '599',
      'category': 'Dresses',
      'localImage': 'assets/images/product listing/image2 (2).jpeg',
      'detailLocalImage': 'assets/images/product details/frock2.jpeg',
      'imageUrl': '',
    },
    {
      'id': 'dress_3',
      'name': 'Midnight Noir Elegance\nGown',
      'price': '\$750',
      'priceValue': '750',
      'category': 'Dresses',
      'localImage': 'assets/images/product listing/image2 (3).jpeg',
      'detailLocalImage': 'assets/images/product details/frock 3.jpeg',
      'imageUrl': '',
    },
    {
      'id': 'dress_4',
      'name': 'Blush Rose Royal\nGown',
      'price': '\$890',
      'priceValue': '890',
      'category': 'Dresses',
      'localImage': 'assets/images/product listing/image2 (4).jpeg',
      'detailLocalImage': 'assets/images/product details/frock1.jpeg',
      'imageUrl': '',
    },
  ];

  // ─── HELPERS ─────────────────────────────────────────────────

  /// All products combined, deduplicated by id.
  static List<Map<String, String>> getAllProducts() {
    final all  = [...featuredProducts, ...dressProducts];
    final seen = <String>{};
    return all.where((p) => seen.add(p['id']!)).toList();
  }

  /// Products filtered by category.
  /// Pass 'All' to get every product.
  static List<Map<String, String>> getProductsByCategory(String category) {
    if (category == 'All') return getAllProducts();
    return getAllProducts()
        .where((p) => p['category'] == category)
        .toList();
  }

  // ─── DEFAULT CART ITEMS (bag page seed / migration reference) ─
  static List<Map<String, dynamic>> defaultCartItems() => [
    {
      'name': 'Blush Rose Royal Gown - Black',
      'subtitle': 'Size-L',
      'price': 1599.00,
      'localImage': 'assets/images/product details/frock1.jpeg',
      'imageUrl': '',
      'quantity': 1,
    },
    {
      'name': 'Slingback Heels with Crystal Buckle - Gold',
      'subtitle': 'Size-8',
      'price': 799.00,
      'localImage': 'assets/images/home/image4.jpeg',
      'imageUrl': '',
      'quantity': 1,
    },
    {
      'name': 'Moonlight Silver Glam Clutch Bag',
      'subtitle': '',
      'price': 699.00,
      'localImage': 'assets/images/bag/bag 3.jpeg',
      'imageUrl': '',
      'quantity': 1,
    },
  ];
}
