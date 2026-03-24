import 'dart:io';
import 'package:bean_byte/models/order_model.dart';
import 'package:bean_byte/models/product_model.dart';
import 'package:bean_byte/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ProductCategory { coffee, tea, pastry, juices, shakes, smoothies }

class SupabaseDb {
  final supabase = Supabase.instance.client;
  // Products functionalities
  Future<List<dynamic>> getProducts(ProductCategory category) async {
    final response = await supabase
        .from('products')
        .select()
        .eq('category', category.name);
    return response;
  }

  Future<String> getProductImage(String imagePath) async {
    final response = supabase.storage.from('products').getPublicUrl(imagePath);
    return response.toString();
  }

  Future<ProductModel> getProduct(String prodId) async {
    final response = await supabase.from('products').select().eq('uid', prodId);
    ProductModel prod = ProductModel.fromJson(response[0]);
    prod.imageUrl = await getProductImage(response[0]['image']);
    return prod;
  }

  Future<void> insertProduct(
    String name,
    String category,
    double price,
    File file,
  ) async {
    final response = await supabase.from('products').insert({
      'name': name,
      'category': category,
      'price': price,
    });
    await supabase.storage.from('product').upload('$category/$name.png', file);
    return response;
  }

  // User functionalities
  Future<dynamic> createUser(String uid, String name, String email) async {
    final response = await supabase.from("users").insert({
      "id": uid,
      "email": email,
      "name": name,
      "cartprods": {},
    });
    return response;
  }

  Future<UserModel> getUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final response = (await supabase.from("users").select().eq("id", uid))[0];
    return UserModel.fromMap(Map<String, dynamic>.from(response));
  }

  Future<void> updateUser(UserModel user) async {
    await supabase
        .from("users")
        .update({
          "name": user.name,
          "profilepicture": user.profilePicture,
          "phone": user.phone,
          "address": user.address,
          "role": user.role.name,
        })
        .eq("id", user.uid);
  }

  Future<void> updateUserImg(UserModel user, File img) async {
    try {
      await supabase.storage
          .from("users")
          .upload(
            "${user.uid}.png",
            img,
            fileOptions: const FileOptions(upsert: true),
          );
      await supabase
          .from("users")
          .update({"profilepicture": "${user.uid}.png"})
          .eq("id", user.uid);
    } catch (e) {
      print("Upload Failed: $e");
    }
  }

  Future<String> getUserImg(imagePath) async {
    final response = supabase.storage.from('users').getPublicUrl(imagePath);
    return response.toString();
  }

  // cart products
  Future<void> updateCartProducts(
    UserModel user,
    Map<String, dynamic> cartProducts,
  ) async {
    await supabase
        .from("users")
        .update({"cartprods": cartProducts})
        .eq("id", user.uid);
  }

  Future<void> updateFavProducts(
    UserModel user,
    List<dynamic> favProducts,
  ) async {
    await supabase
        .from("users")
        .update({"favprods": favProducts})
        .eq("id", user.uid);
  }

  Future<void> updateOrders(UserModel user) async {
    await supabase
        .from("users")
        .update({"orders": user.orders})
        .eq("id", user.uid);
  }

  // Order functionalities
  Future<void> createOrder(UserModel user, OrderModel order) async {
    await supabase.from("orders").insert({
      "order_id": order.orderId,
      "user_id": order.userId,
      "products": order.products,
      "price": order.price,
      "status": order.status.name,
      "created_at": order.createdAt?.toIso8601String(),
      "payment_id": order.paymentId,
    });
    await updateCartProducts(user, {});
    user.orders.add(order.orderId);
    await updateOrders(user);
  }

  Future<List<OrderModel>> getOrders(String userId) async {
    final response = (await supabase
        .from("orders")
        .select()
        .eq("user_id", userId));
    return response.map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await supabase
        .from("orders")
        .update({
          "status": status.name,
          if (status == OrderStatus.completed ||
              status == OrderStatus.cancelled)
            "completed_at": DateTime.now().toIso8601String(),
        })
        .eq("order_id", orderId);
  }
}
