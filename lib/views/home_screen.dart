import 'dart:async';
import 'package:flutter/material.dart';
import 'package:products_app/views/wishlist_screen.dart';
import 'package:provider/provider.dart';
import '../viewmodels/product_viewmodel.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    final vm = Provider.of<ProductViewModel>(context, listen: false);
    vm.fetchProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        vm.fetchProducts();
      }
    });
  }

  void _onSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      Provider.of<ProductViewModel>(context, listen: false).search(query);
    });
  }

  // 🔽 FILTER BOTTOM SHEET
  void _openFilterSheet(BuildContext context) {
    final vm = Provider.of<ProductViewModel>(context, listen: false);

    String tempCategory = vm.selectedCategory;
    RangeValues tempRange = vm.priceRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔘 DRAG HANDLE
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const Text(
                    "Filters",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  // 📂 CATEGORY
                  DropdownButtonFormField<String>(
                    value: vm.categories.contains(tempCategory)
                        ? tempCategory
                        : "All",
                    items: vm.categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          tempCategory = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 💰 PRICE RANGE
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Price Range"),
                      RangeSlider(
                        values: tempRange,
                        min: 0,
                        max: 2000,
                        divisions: 20,
                        labels: RangeLabels(
                          tempRange.start.round().toString(),
                          tempRange.end.round().toString(),
                        ),
                        onChanged: (range) {
                          setState(() {
                            tempRange = range;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // 🔘 BUTTONS
                  Row(
                    children: [
                      // RESET
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              tempCategory = "All";
                              tempRange = const RangeValues(0, 2000);
                            });
                          },
                          child: const Text("Reset"),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // APPLY
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            vm.setCategory(tempCategory);
                            vm.setPriceRange(tempRange);

                            Navigator.pop(context);
                          },
                          child: const Text("Apply"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProductViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _openFilterSheet(context);
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // 📦 PRODUCT LIST
          Expanded(
            child: vm.products.isEmpty && vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.products.isEmpty
                ? const Center(child: Text("No products found 😕"))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: vm.products.length,
                    itemBuilder: (context, index) {
                      final product = vm.products[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: Image.network(
                            product.image,
                            width: 50,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const SizedBox(
                                width: 50,
                                height: 50,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                          title: Text(
                            product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            "₹${product.price}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () {
                              vm.toggleWishlist(product.id);
                            },
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 1.0,
                                end: vm.isWishlisted(product.id) ? 1.3 : 1.0,
                              ),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.elasticOut,
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: child,
                                );
                              },
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                                child: Icon(
                                  vm.isWishlisted(product.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  key: ValueKey(vm.isWishlisted(product.id)),
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailScreen(product: product),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),

          // 🔄 LOADING MORE
          if (vm.isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
