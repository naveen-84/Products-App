import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/product_viewmodel.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProductViewModel>(context);

    final wishlistItems = vm.products
        .where((p) => vm.isWishlisted(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Wishlist")),
      body: wishlistItems.isEmpty
          ? const Center(child: Text("No items in wishlist ❤️"))
          : ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final product = wishlistItems[index];

                return ListTile(
                  leading: Image.network(product.image, width: 50),
                  title: Text(product.title),
                  subtitle: Text("₹${product.price}"),
                );
              },
            ),
    );
  }
}
