enum OrderStatus { pending, completed, cancelled, processing }

class OrderModel {
  final String orderId;
  final String userId;
  String? paymentId;
  Map<String, dynamic> products;
  final double price;
  OrderStatus status;
  DateTime? createdAt;
  DateTime? completedAt; //for both completion and cancellation

  OrderModel({
    required this.orderId,
    required this.userId,
    this.paymentId,
    required this.products,
    required this.price,
    required this.status,
    this.completedAt,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    orderId: json["order_id"],
    userId: json["user_id"],
    paymentId: json["payment_id"],
    products: json["products"],
    price: json["price"],
    status: OrderStatus.values.firstWhere((e) => e.name == json["status"]),
    createdAt: json["created_at"] == null
        ? DateTime.now()
        : DateTime.parse(json["created_at"]),
    completedAt: json["completed_at"] == null
        ? null
        : DateTime.parse(json["completed_at"]),
  );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "user_id": userId,
    "payment_id": paymentId,
    "products": products,
    "price": price,
    "status": status.name, // 🔥 store as string
    "created_at": createdAt?.toIso8601String(),
    "completed_at": completedAt?.toIso8601String(),
  };
}
