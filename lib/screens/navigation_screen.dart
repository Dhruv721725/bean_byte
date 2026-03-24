import 'package:bean_byte/database/supabase_db.dart';
import 'package:bean_byte/models/user_model.dart';
import 'package:bean_byte/screens/cart_screen.dart';
import 'package:bean_byte/screens/home_screen.dart';
import 'package:bean_byte/screens/orders_screen.dart';
import 'package:bean_byte/screens/profile_screen.dart';
import 'package:bean_byte/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Future<UserModel> user = SupabaseDb().getUser();

    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
          future: user,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Lottie.asset(
                  "assets/lotties/loader.json",
                  width: 100,
                  height: 100,
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            final List<Widget> screens = [
              HomeScreen(
                user: snapshot.data!,
                onSwitchTap: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              OrdersScreen(user: snapshot.data!),
              ChangeNotifierProvider(
                create: (_) => CartProvider(),
                child: CartScreen(user: snapshot.data!),
              ),
              ChangeNotifierProvider(
                create: (_) => UserUpdate(),
                child: ProfileScreen(user: snapshot.data!),
              ),
            ];
            return screens[_currentIndex];
          },
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.backgroundDark : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12,
                width: 1,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: AppTheme.primaryColor.withAlpha(50),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppTheme.primaryColor),
                label: "Home",
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_outlined),
                selectedIcon: Icon(Icons.receipt, color: AppTheme.primaryColor),
                label: "Orders",
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(
                  Icons.shopping_cart,
                  color: AppTheme.primaryColor,
                ),
                label: "Cart",
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                selectedIcon: Icon(Icons.person, color: AppTheme.primaryColor),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
