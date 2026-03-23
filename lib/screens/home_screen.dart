import 'package:bean_byte/components/category_chip.dart';
import 'package:bean_byte/components/product_card.dart';
import 'package:bean_byte/database/supabase_db.dart';
import 'package:bean_byte/models/product_model.dart';
import 'package:bean_byte/models/user_model.dart';
import 'package:bean_byte/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  HomeScreen({super.key, required this.user});
  final TextEditingController searchController = TextEditingController();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ProductCategory> categories = [
    ProductCategory.coffee,
    ProductCategory.pastry,
  ];
  late ProductCategory selectedCategory;

  void addToCart(String productId) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Map<String, dynamic> cartProducts = widget.user.cartProducts;
    if (cartProducts.containsKey(productId)) {
      cartProducts[productId] = cartProducts[productId]! + 1;
    } else {
      cartProducts[productId] = 1;
    }

    SupabaseDb().updateCartProducts(widget.user, cartProducts);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Item added to cart",
          style: TextStyle(
            color: isDark ? Colors.white : Theme.of(context).primaryColor,
          ),
        ),
        backgroundColor: isDark ? AppTheme.fieldDark : AppTheme.backgroundLight,
      ),
    );
  }

  void onFavClick(String prodId, bool isFav) {
    if (isFav) {
      widget.user.favouriteProducts.add(prodId);
    } else {
      widget.user.favouriteProducts.remove(prodId);
    }
    SupabaseDb().updateFavProducts(widget.user, widget.user.favouriteProducts);
  }

  @override
  void initState() {
    super.initState();
    selectedCategory = ProductCategory.coffee;
  }

  Future<List<dynamic>> getProducts() async {
    List<dynamic> products = await SupabaseDb().getProducts(selectedCategory);
    if (widget.searchController.text.isNotEmpty) {
      products = products.where((product) {
        return product['name'].toLowerCase().contains(
          widget.searchController.text.toLowerCase().trim(),
        );
      }).toList();
    }
    return products;
  }

  Future<Widget> getUserImage() async {
    return Image.network(
      await SupabaseDb().getUserImg(widget.user.profilePicture),
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryColor.withAlpha(51),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: FutureBuilder(
                          future: getUserImage(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data!;
                            }
                            if (snapshot.hasError || snapshot.data == null) {
                              return Image.asset("assets/users/user.png");
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Hi, ${widget.user.name}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.fieldDark,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_none,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.fieldDark
                                    : Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: TextField(
                  controller: widget.searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search for your favorite coffee...',
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  "Categories",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = categories[index];
                        });
                      },
                      child: CategoryChip(
                        icon: Icons.local_cafe,
                        label: categories[index].name,
                        isSelected: categories[index] == selectedCategory,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Products grid
            FutureBuilder(
              future: getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Lottie.asset(
                        'assets/lotties/loader.json',
                        height: 100,
                        width: 100,
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      ProductModel product = ProductModel.fromJson(
                        snapshot.data![index],
                      );
                      return ProductCard(
                        product: product,
                        favouriteProducts: widget.user.favouriteProducts,
                        addToCart: () => addToCart(product.productId),
                        onFavClick: (bool isFav) =>
                            onFavClick(product.productId, isFav),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
