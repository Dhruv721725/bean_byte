import 'package:bean_byte/components/button_comp.dart';
import 'package:bean_byte/models/user_model.dart';
import 'package:bean_byte/payment/payment_gate.dart';
import 'package:bean_byte/screens/cart_screen.dart';
import 'package:bean_byte/themes/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CheckOutCard extends StatefulWidget {
  final Future<double> Function() getSubTotal;
  final UserModel user;
  final Function() onOrder;
  const CheckOutCard({
    super.key,
    required this.getSubTotal,
    required this.user,
    required this.onOrder,
  });

  @override
  State<CheckOutCard> createState() => _CheckOutCardState();
}

class _CheckOutCardState extends State<CheckOutCard> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    void showSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: isDark ? Colors.white : Theme.of(context).primaryColor,
            ),
          ),
          backgroundColor: isDark
              ? AppTheme.fieldDark
              : AppTheme.backgroundLight,
        ),
      );
    }

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
                  return Center(
                    child: Lottie.asset("assets/lotties/loader.json"),
                  );
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
                            ).colorScheme.onSurface.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹$subTotal",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
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
                            ).colorScheme.onSurface.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹50",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
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
                            ).colorScheme.onSurface.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹${subTotal * 5 / 100}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    Divider(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(150),
                      thickness: 1,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹${subTotal + subTotal * 5 / 100 + 50}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ButtonComp(
                      label: "Checkout",
                      onTap: () {
                        if (widget.user.cartProducts.isEmpty) {
                          showSnackBar("Your cart is empty");
                          return;
                        }
                        if (widget.user.address == null) {
                          showSnackBar("Please add your address");
                          return;
                        }
                        if (widget.user.phone == null) {
                          showSnackBar("Please add your phone");
                          return;
                        }
                        if (kIsWeb) {
                          showSnackBar("Payment not supported on web");
                          return;
                        }
                        widget.onOrder();
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
