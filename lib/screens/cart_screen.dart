import 'package:bean_byte/components/button_comp.dart';
import 'package:bean_byte/components/cart_item.dart';
import 'package:bean_byte/database/cart_provider.dart';
import 'package:bean_byte/database/supabase_db.dart';
import 'package:bean_byte/models/user_model.dart';
import 'package:bean_byte/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  UserModel user;
  CartScreen({super.key, required this.user});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<void> deleteCartItem(String prodId) async {
    widget.user.cartProducts.remove(prodId);
    await SupabaseDb().updateCartProducts(
      widget.user,
      widget.user.cartProducts,
    );
    Provider.of<CartProvider>(context, listen: false).refreshCheckOut();
  }

  void updateCartItem(String prodId, int quantity) async {
    if (quantity == 0) {
      deleteCartItem(prodId);
      return;
    }
    widget.user.cartProducts[prodId] = quantity;
    await SupabaseDb().updateCartProducts(
      widget.user,
      widget.user.cartProducts,
    );
    Provider.of<CartProvider>(context, listen: false).refreshCheckOut();
  }

  Future<double> getSubTotal() async {
    double subTotal = 0;
    for (var prodId in widget.user.cartProducts.keys) {
      subTotal +=
          widget.user.cartProducts[prodId]! *
          (await SupabaseDb().getProduct(prodId)).price;
    }
    return subTotal;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Your Shopping Cart",
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Cart Products:
            Expanded(
              child: ListView.builder(
                itemCount: widget.user.cartProducts.keys.toList().length,
                itemBuilder: (context, index) {
                  return CartItem(
                    prodId: widget.user.cartProducts.keys.toList()[index],
                    quantity: widget.user.cartProducts.values.toList()[index],
                    onDel: () => deleteCartItem(
                      widget.user.cartProducts.keys.toList()[index],
                    ),
                    onUpdate: updateCartItem,
                  );
                },
              ),
            ),

            // CheckOut Section:
            CheckOutCard(getSubTotal: getSubTotal),
            // CheckOutCard(getSubTotal: getSubTotal),
          ],
        ),
      ),
    );
  }
}

class CheckOutCard extends StatefulWidget {
  final Future<double> Function() getSubTotal;
  const CheckOutCard({super.key, required this.getSubTotal});

  @override
  State<CheckOutCard> createState() => _CheckOutCardState();
}

class _CheckOutCardState extends State<CheckOutCard> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.fieldDark : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 80 : 15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return FutureBuilder(
              future: widget.getSubTotal(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: Lottie.asset("lotties/loader.json"));
                }
                double subTotal = asyncSnapshot.data!;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Subtotal",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹${subTotal}",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Delivery Fee",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹50",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tax (5%)",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹${subTotal * 5 / 100}",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹${subTotal + subTotal * 5 / 100 + 50}",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    ButtonComp(
                      label: "Checkout",
                      onTap: () {
                        print("placing order");
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
