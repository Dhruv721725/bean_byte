import 'dart:io';
import 'package:bean_byte/components/detail_comp.dart';
import 'package:bean_byte/components/stat_badge_comp.dart';
import 'package:bean_byte/auth/auth_services.dart';
import 'package:bean_byte/database/supabase_db.dart';
import 'package:bean_byte/models/user_model.dart';
import 'package:bean_byte/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  UserModel user;
  ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FileImage? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    print("picking image");
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile == null) {
      print("no image selected");
      return;
    }

    File imgFile = File(pickedFile.path);

    await SupabaseDb().updateUserImg(widget.user, imgFile);
    _image = FileImage(imgFile);
    setState(() {});
  }

  FutureBuilder getUserImg() {
    return FutureBuilder(
      future: SupabaseDb().getUserImg(widget.user.profilePicture),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Lottie.asset("assets/lotties/loader.json");
        }
        if (snapshot.hasError || !snapshot.hasData) {
          print(snapshot.error);
          return Image.asset("assets/users/user.png");
        }
        return ClipOval(
          child: Image.network(
            "${snapshot.data}?t=${DateTime.now().millisecondsSinceEpoch}",
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Profile",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: GoogleFonts.orbitron().fontFamily,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16),
              Column(
                children: [
                  Stack(
                    children: [
                      // SizedBox(
                      //   width: 120,
                      //   height: 120,
                      //   child: Image.asset("assets/users/user.png"),
                      // ),
                      Container(
                        width: 120,
                        height: 120,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppTheme.fieldDark : Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              offset: Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: getUserImg(),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => pickImage(),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.fieldDark
                                    : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer<UserUpdate>(
                    builder: (context, value, child) {
                      return Text(
                        widget.user.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.user.email,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
              const SizedBox(height: 24),
              // Stats
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.fieldDark.withAlpha(150)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black.withAlpha(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StatBadgeComp(
                      value: widget.user.pastOrders.length.toString(),
                      label: "ORDERS",
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(25),
                    ),
                    StatBadgeComp(
                      value: widget.user.favouriteProducts.length.toString(),
                      label: "FAVOURITES",
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(25),
                    ),
                    StatBadgeComp(value: 'GOLD', label: "TIER"),
                  ],
                ),
              ),

              SizedBox(height: 32),
              // Users Details
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.only(left: 4, bottom: 12),
                      child: Text(
                        "GENERAL",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    DetailComp(
                      icon: Icons.person,
                      title: "Name",
                      value: widget.user.name,
                      onEdit: (value) {
                        widget.user.name = value;
                        SupabaseDb().updateUser(widget.user);
                        Provider.of<UserUpdate>(
                          context,
                          listen: false,
                        ).nameChanged();
                      },
                    ),
                    DetailComp(
                      icon: Icons.phone,
                      title: "Contact",
                      value: widget.user.phone,
                      onEdit: (value) {
                        widget.user.phone = int.parse(value);
                        SupabaseDb().updateUser(widget.user);
                      },
                    ),
                    DetailComp(
                      icon: Icons.pin_drop,
                      title: "Address",
                      value: widget.user.address,
                      onEdit: (value) {
                        widget.user.address = value;
                        SupabaseDb().updateUser(widget.user);
                      },
                    ),

                    const SizedBox(height: 32),

                    // Sign Out
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.red.withAlpha(75)),
                          backgroundColor: Colors.red.withAlpha(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 56),
                        ),
                        onPressed: () => AuthServices().logout(),
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'APP VERSION 1.0.0',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserUpdate extends ChangeNotifier {
  void nameChanged() {
    notifyListeners();
  }
}
