import 'package:hive/hive.dart';

class WishlistService {
  final Box box = Hive.box('wishlist');

  void toggleWishlist(int productId) {
    if (box.containsKey(productId)) {
      box.delete(productId);
    } else {
      box.put(productId, true);
    }
  }

  bool isInWishlist(int productId) {
    return box.containsKey(productId);
  }

  List getWishlistIds() {
    return box.keys.toList();
  }
}
