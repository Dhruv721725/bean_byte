import 'package:bean_byte/database/supabase_db.dart';
import 'package:bean_byte/models/product_model.dart';
import 'package:flutter/material.dart';

class CartItem extends StatefulWidget {
  String prodId;
  int quantity;
  void Function() onDel;
  void Function(String, int) onUpdate;
  CartItem({
    super.key,
    required this.prodId,
    required this.onDel,
    required this.quantity,
    required this.onUpdate,
  });

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  Future<ProductModel> getProduct() async {
    ProductModel prod = await SupabaseDb().getProduct(widget.prodId);
    return prod;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withAlpha(125) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withAlpha(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FutureBuilder(
        future: getProduct(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data == null) {
            return SizedBox.shrink();
          }
          ProductModel prod = snapshot.data!;
          return Row(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(prod.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prod.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      prod.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        overflow: TextOverflow.ellipsis,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : Colors.black12,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            iconSize: 14,
                            onPressed: () {
                              if (widget.quantity > 1) {
                                setState(() {
                                  widget.quantity--;
                                  widget.onUpdate(
                                    widget.prodId,
                                    widget.quantity,
                                  );
                                });
                              }
                            },
                            color: Theme.of(context).primaryColor,
                          ),
                          Text(widget.quantity.toString()),
                          IconButton(
                            icon: Icon(Icons.add),
                            iconSize: 14,
                            onPressed: () {
                              if (widget.quantity < 10) {
                                setState(() {
                                  widget.quantity++;
                                  widget.onUpdate(
                                    widget.prodId,
                                    widget.quantity,
                                  );
                                });
                              }
                            },
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "₹${prod.price * widget.quantity}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: widget.onDel,
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
