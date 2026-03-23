import 'dart:io';

enum UserRole { admin, customer, delivery }

class UserModel {
  String uid;
  String email;
  String name;
  String? profilePicture;
  DateTime createdAt;
  UserRole role = UserRole.customer;
  int? phone;
  String? address;
  String? image;  
  List<dynamic> favouriteProducts;
  List<dynamic> currentOrders;
  List<dynamic> pastOrders;
  Map<String, dynamic> cartProducts;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.phone,
    this.address,
    required this.profilePicture,
    required this.createdAt,
    required this.role,
    this.favouriteProducts = const [],
    this.currentOrders = const [],
    this.pastOrders = const [],
    this.cartProducts = const {},
  });

  /// Convert Object → Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "phone": phone,
      "address": address,
      "profilePicture": profilePicture,
      "createdAt": createdAt.toIso8601String(),
      "role": role.name,
    };
  }

  /// Convert Map → Object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["id"],
      email: map["email"],
      name: map["name"],
      phone: map["phone"],
      address: map["address"],
      profilePicture: map["profilepicture"] ?? "",
      createdAt: DateTime.parse(map["createdate"]),
      role: UserRole.values.firstWhere((e) => e.name == map["role"]),
      favouriteProducts: map["favprods"],
      currentOrders: map["currentorders"],
      pastOrders: map["pastorders"],
      cartProducts: map["cartprods"],
    );
  }

  /// CopyWith (for updates)
  UserModel updateUser({
    String? name,
    String? phone,
    String? address,
    String? profilePicture,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      phone: this.phone,
      address: address ?? this.address,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt,
      role: role,
    );
  }
}
