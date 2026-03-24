import 'package:bean_byte/components/order_card.dart';
import 'package:bean_byte/database/supabase_db.dart';
import 'package:bean_byte/models/order_model.dart';
import 'package:bean_byte/models/user_model.dart';
import 'package:bean_byte/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OrdersScreen extends StatefulWidget {
  final UserModel user;
  OrdersScreen({super.key, required this.user});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedTabIndex = 0;

  Future<List<OrderModel>> _fetchOrders() async {
    List<OrderModel> orders = await SupabaseDb().getOrders(widget.user.uid);
    return orders;
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Order History"),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Control
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.fieldDark.withAlpha(125)
                      : Colors.black.withAlpha(125),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 0),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 0
                                ? (isDark ? AppTheme.fieldDark : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Active',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedTabIndex == 0
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withAlpha(125),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 1),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 1
                                ? (isDark ? AppTheme.fieldDark : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Past Orders',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedTabIndex == 1
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withAlpha(125),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder(
                future: _fetchOrders(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    snapshot.data!.sort(
                      (a, b) => b.createdAt!.compareTo(a.createdAt!),
                    );
                    List<OrderModel> orders = _selectedTabIndex == 0
                        ? snapshot.data!
                              .where(
                                (order) =>
                                    order.status == OrderStatus.processing,
                              )
                              .toList()
                        : snapshot.data!
                              .where(
                                (order) =>
                                    order.status != OrderStatus.processing,
                              )
                              .toList();
                    if (orders.isEmpty) {
                      return Center(child: Text("No Active Orders"));
                    }

                    return Container(
                      height: double.maxFinite,
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          return OrderCard(
                            order: orders[index],
                            pickUp: widget.user.address!,
                            onCancel: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Cancel Order'),
                                    content: Text(
                                      'Are you sure you want to cancel this order?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          SupabaseDb().updateOrderStatus(
                                            orders[index].orderId,
                                            OrderStatus.cancelled,
                                          );
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Order Cancelled'),
                                            ),
                                          );
                                          setState(() {
                                            _fetchOrders();
                                          });
                                        },
                                        child: Text('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// return ListView.builder(
  // itemCount: snapshot.data!.length,
  // itemBuilder: (context, index) {
    // return ActiveOrderCard(
      // order: snapshot.data![index],
      // pickUp: widget.user.address!,
    // );
  // },
// );