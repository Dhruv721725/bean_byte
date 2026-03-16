class OrderModel {
  final String orderId;
  final String userId;
  final String productId;
  final int quantity;
  final double price;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime completedAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.completedAt,
  });
}
