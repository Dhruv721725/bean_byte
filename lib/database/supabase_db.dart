import 'dart:io';
import 'dart:js_interop';
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
    final response = await supabase.storage
        .from('products')
        .getPublicUrl(imagePath);
    return response.toString();
  }

  Future<ProductModel> getProduct(String prodId) async {
    final response = await supabase.from('products').select().eq('uid', prodId);
    ProductModel prod = await ProductModel.fromJson(response[0]);
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
          "uid": user.uid,
          "email": user.email,
          "name": user.name,
          "profilepicture": user.profilePicture,
          "favprods": user.favouriteProducts,
          "currentorders": user.currentOrders,
          "pastorders": user.pastOrders,
          "cartprods": user.cartProducts,
        })
        .eq("uid", user.uid);
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

  Future<void> updateCurrentOrders(
    UserModel user,
    List<dynamic> currentOrders,
  ) async {
    await supabase
        .from("users")
        .update({"currentorders": currentOrders})
        .eq("id", user.uid);
  }

  Future<void> updatePastOrders(
    UserModel user,
    List<dynamic> pastOrders,
  ) async {
    await supabase
        .from("users")
        .update({"pastorders": pastOrders})
        .eq("id", user.uid);
  }
}
