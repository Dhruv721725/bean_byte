import 'package:bean_byte/components/alert_comp.dart';
import 'package:bean_byte/components/cart_item.dart';
import 'package:bean_byte/components/check_out_card.dart';
import 'package:bean_byte/database/supabase_db.dart';
import 'package:bean_byte/models/order_model.dart';
import 'package:bean_byte/models/user_model.dart';
import 'package:bean_byte/payment/payment_gate.dart';
import 'package:flutter/material.dart';
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
    setState(() {});
    Provider.of<CartProvider>(context, listen: false).refreshCheckOut();
  }

  Future<void> onOrder() async {
    OrderModel order = OrderModel(
      orderId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: widget.user.uid,
      paymentId: "",
      products: widget.user.cartProducts,
      price: await getSubTotal(),
      status: OrderStatus.processing,
      createdAt: DateTime.now(),
    );

    await PaymentGate(
      context: context,
      user: widget.user,
      onSuccess: (String? payId) {
        setState(() {
          order.products = widget.user.cartProducts;
          order.paymentId = payId;
          order.status = OrderStatus.processing;
          widget.user.cartProducts = {};
        });
        showDialog(
          context: context,
          builder: (context) {
            return AlertComp(
              title: "Order Placed",
              message: "Your order has been placed successfully!",
            );
          },
        );
        SupabaseDb().createOrder(widget.user, order);
      },
    ).initiatePayment(order.price);
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
            CheckOutCard(
              getSubTotal: getSubTotal,
              user: widget.user,
              onOrder: onOrder,
            ),
          ],
        ),
      ),
    );
  }
}

class CartProvider extends ChangeNotifier {
  void refreshCheckOut() {
    notifyListeners();
  }
}
