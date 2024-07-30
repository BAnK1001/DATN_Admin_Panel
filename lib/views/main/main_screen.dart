import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop_admin/views/main/refunds/refunds.dart';
import 'package:shoes_shop_admin/views/main/shipper/shipper.dart';
import 'package:shoes_shop_admin/views/main/users/users_screen.dart';
import '../../controllers/route_manager.dart';
import 'products/products.dart';
import 'vendors/vendors.dart';
import '../../resources/assets_manager.dart';
import '../../resources/styles_manager.dart';
import '../widgets/are_you_sure_dialog.dart';
import 'carousel_banners/carousel_banners.dart';
import 'cash_outs/cash_outs.dart';
import 'categories/categories.dart';
import 'orders/orders.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.index = 0});

  final int index;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _pageIndex = 0;
  bool isLoading = true;
  bool isDarkMode = false;

  final user = FirebaseAuth.instance.currentUser!;

  final List<Widget> _pages = const [
    HomeScreen(),
    ProductScreen(),
    OrdersScreen(),
    VendorsScreen(),
    CarouselBanners(),
    CategoriesScreen(),
    CashOutScreen(),
    UsersScreen(),
    ShipperScreen(),
    RefundScreen(),
  ];

  void setNewPage(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  void initState() {
    if (widget.index != 0) {
      setNewPage(widget.index);
    }

    super.initState();
  }

  // logout
  logout() async {
    await FirebaseAuth.instance.signOut();
    Timer(
      const Duration(seconds: 1),
      () => Navigator.of(context).pushNamedAndRemoveUntil(
        RouteManager.entryScreen,
        (route) => false,
      ),
    );
  }

  // logout dialog
  logoutDialog() {
    areYouSureDialog(
      title: 'Logout',
      content: 'Are you sure you want to logout',
      context: context,
      action: logout,
    );
  }

  // Toggle Dark Mode
  toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = isDarkMode ? ThemeData.dark() : ThemeData.light();

    return MaterialApp(
      theme: theme,
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AssetManager.logoTransparent, width: 30),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  text: 'SHOES',
                  children: [
                    TextSpan(
                      text: 'SHOP',
                      style: getMediumStyle(
                        color: Colors.blue,
                      ),
                      children: const [
                        TextSpan(text: ' ADMIN'),
                      ],
                    )
                  ],
                  style: getMediumStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => toggleDarkMode(),
              icon: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Colors.black,
              ),
            ),
            IconButton(
              onPressed: () => logoutDialog(),
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
              ),
            ),
          ],
        ),
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: Colors.white,
              selectedLabelTextStyle: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12, // Smaller font size for selected label
              ),
              unselectedIconTheme: const IconThemeData(
                color: Colors.grey,
                size: 18, // Smaller size for unselected icons
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 10, // Smaller font size for unselected label
              ),
              selectedIconTheme: const IconThemeData(
                color: Colors.grey,
                size: 20, // Smaller size for selected icons
              ),
              onDestinationSelected: (index) => setState(() {
                _pageIndex = index;
              }),
              labelType: NavigationRailLabelType.all,
              leading: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  child: Column(
                    children: [
                      user.photoURL != null
                          ? Hero(
                              tag: user.email!,
                              child: CircleAvatar(
                                radius: 20, // Smaller Avatar
                                backgroundColor: Colors.transparent,
                                backgroundImage: NetworkImage(
                                  user.photoURL!,
                                ),
                              ),
                            )
                          : Hero(
                              tag: user.email!,
                              child: const CircleAvatar(
                                radius: 20, // Smaller Avatar
                                backgroundColor: Colors.transparent,
                                backgroundImage: AssetImage(
                                  AssetManager.avatar,
                                ),
                              ),
                            ),
                      const SizedBox(height: 8),
                      Text(
                        user.displayName ?? 'Shop Admin',
                        style: getMediumStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ),
              minWidth: 56, // Smaller width
              groupAlignment: 0.0, // Align items in the center
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shopping_bag_outlined),
                  selectedIcon: Icon(Icons.shopping_bag),
                  label: Text('Products'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shopping_cart_checkout),
                  selectedIcon: Icon(Icons.shopping_cart),
                  label: Text('Orders'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.group_outlined),
                  selectedIcon: Icon(Icons.group),
                  label: Text('Vendors'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.view_carousel),
                  selectedIcon: Icon(Icons.view_carousel),
                  label: Text('Carousels'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.category_outlined),
                  selectedIcon: Icon(Icons.category),
                  label: Text('Categories'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.monetization_on_outlined),
                  selectedIcon: Icon(Icons.monetization_on),
                  label: Text('Cash outs'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.group),
                  selectedIcon: Icon(Icons.group),
                  label: Text('Users'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.local_shipping_outlined),
                  selectedIcon: Icon(Icons.local_shipping),
                  label: Text('Shippers'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_outlined),
                  selectedIcon: Icon(Icons.receipt),
                  label: Text('Refunds'),
                ),
              ],
              selectedIndex: _pageIndex,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
                child: _pages[_pageIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
