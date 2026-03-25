import 'package:bean_byte/models/order_model.dart';
import 'package:bean_byte/models/product_model.dart';
import 'package:bean_byte/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderManageScreen extends StatelessWidget {
  OrderManageScreen({super.key});

  SupabaseClient supabase = Supabase.instance.client;

  void showInfo(BuildContext context, String title, Map<String, dynamic> info) {
    showDialog(
      context: context,
      builder: (context) {
        String data = "";
        info.forEach((key, value) {
          data += "$key : $value\n";
        });
        return AlertDialog(
          title: Text(title),
          content: Text(data),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<List<OrderModel>> getOrders() async {
    List<Map<String, dynamic>> orders = await supabase
        .from('orders')
        .select('*');
    return orders.map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await supabase
        .from('orders')
        .update({'status': status})
        .eq('order_id', orderId);
  }

  Future<UserModel> getUser(String userId) async {
    List<Map<String, dynamic>> users = await supabase
        .from('users')
        .select()
        .eq('id', userId);
    return UserModel.fromMap(users[0]);
  }

  Future<ProductModel> getProduct(String productId) async {
    List<Map<String, dynamic>> products = await supabase
        .from('products')
        .select()
        .eq('uid', productId);
    return ProductModel.fromJson(products[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: FutureBuilder(
        future: getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              OrderModel order = snapshot.data![index];
              return Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(25),
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(order.orderId),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          var user = await getUser(order.userId);
                          showInfo(context, "User Info", user.toMap());
                        },
                        child: Text(order.userId),
                      ),
                      ...order.products.entries.map(
                        (e) => FutureBuilder(
                          future: getProduct(e.key),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data!.name +
                                    "\t x " +
                                    e.value.toString(),
                              );
                            }
                            return Text("Loading...");
                          },
                        ),
                      ),
                    ],
                  ),
                  trailing: DropdownButton<OrderStatus>(
                    value: order.status,
                    items: OrderStatus.values
                        .map(
                          (e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)),
                        )
                        .toList(),
                    onChanged: (value) =>
                        updateOrderStatus(order.orderId, value!.name),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
