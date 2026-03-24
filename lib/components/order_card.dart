import 'package:bean_byte/database/supabase_db.dart';
import 'package:bean_byte/models/order_model.dart';
import 'package:bean_byte/models/product_model.dart';
import 'package:bean_byte/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final String pickUp;
  final Function() onCancel;
  const OrderCard({
    super.key,
    required this.order,
    required this.pickUp,
    required this.onCancel,
  });

  Future<Map<ProductModel, int>> _fetchOrderProducts() async {
    Map<ProductModel, int> products = {};
    for (var pId in order.products.keys) {
      ProductModel prod = await SupabaseDb().getProduct(pId);
      products[prod] = order.products[pId];
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(125),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Order Id: #${order.orderId}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: order.status == OrderStatus.processing
                      ? Colors.green.withAlpha(50)
                      : order.status == OrderStatus.completed
                      ? AppTheme.primaryColor.withAlpha(50)
                      : Colors.red.withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.name,
                  style: TextStyle(
                    color: order.status == OrderStatus.processing
                        ? Colors.green
                        : order.status == OrderStatus.completed
                        ? AppTheme.primaryColor
                        : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder(
            future: _fetchOrderProducts(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Row> data = snapshot.data!.entries.map((e) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${e.key.name} x ${e.value}"),
                      Text("₹${e.key.price * e.value}"),
                    ],
                  );
                }).toList();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...data,

                      Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Subtotal:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "₹${order.price}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tax(5%):",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "₹${order.price * 0.05}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Delivery Charges:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "₹50",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Payable:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "₹${(order.price * 1.05 + 50).toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return Center(
                child: Lottie.asset(
                  'assets/lotties/loader.json',
                  height: 50,
                  width: 50,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.timer, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Estimated: 15-20 mins',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Pickup at: ${pickUp}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (order.status == OrderStatus.processing)
            GestureDetector(
              onTap: onCancel,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Cancel", style: TextStyle(color: Colors.red)),
                  Icon(Icons.delete_sweep_outlined, color: Colors.red),
                ],
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
