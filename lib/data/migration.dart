import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_data.dart';

class DataMigration {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Uploads every product from AppData into the 'products' Firestore collection.
  /// Uses the product 'id' as the Firestore document ID so re-running is safe.
  /// Call once from main.dart, then comment out that call.
  static Future<void> uploadProducts() async {
    // Merge featured + dress products, deduplicate by id
    final all = [
      ...AppData.featuredProducts,
      ...AppData.dressProducts,
    ];
    final seen = <String>{};
    final unique = all.where((p) => seen.add(p['id']!)).toList();

    for (final p in unique) {
      await _db.collection('products').doc(p['id']).set({
        'name': p['name']!.replaceAll('\n', ' '),
        'price': p['price'],
        'priceValue': double.tryParse(p['priceValue'] ?? '0') ?? 0.0,
        'category': p['category'],
        'imageUrl': p['imageUrl'] ?? '',          // blank — add Cloudinary URL later
        'localImage': p['localImage'],
        'detailLocalImage': p['detailLocalImage'] ?? p['localImage'],
        'description':
            'A luxurious piece designed for elegance and grace. '
            'Its smooth texture and flowing silhouette create a soft, '
            'glamorous look perfect for evening occasions and special events.',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // ignore: avoid_print
    print('Migration complete');
  }
}
