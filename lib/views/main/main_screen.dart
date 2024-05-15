import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop_admin/views/main/users/users.dart';
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
  bool isExtended = false;
  bool isLoading = true;

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

  // for navigation rail
  toggleIsExtended() {
    setState(() {
      isExtended = !isExtended;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white, // Thay đổi màu AppBar
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AssetManager.logoTransparent, width: 40),
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
            onPressed: () => logoutDialog(),
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
        leading: IconButton(
          onPressed: () => setState(() {
            isExtended = !isExtended;
          }),
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
      ),
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: Colors.white, // Thay đổi màu nền NavigationRail
            selectedLabelTextStyle: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.bold),
            unselectedIconTheme:
                const IconThemeData(color: Colors.grey, size: 24),
            unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
            onDestinationSelected: (index) => setState(() {
              _pageIndex = index;
            }),
            labelType: NavigationRailLabelType.all, // Hiển thị tất cả nhãn
            leading: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                child: Column(
                  children: [
                    user.photoURL != null
                        ? Hero(
                            tag: user.email!,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              backgroundImage: NetworkImage(
                                user.photoURL!,
                              ),
                            ),
                          )
                        : Hero(
                            tag: user.email!,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              backgroundImage: const AssetImage(
                                AssetManager.avatar,
                              ),
                            ),
                          ),
                    const SizedBox(height: 10),
                    Text(
                      user.displayName ?? 'Shop Admin',
                      style: getMediumStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
            ),
            extended: isExtended,
            selectedIconTheme: const IconThemeData(
              color: Colors.grey,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(
                  Icons.dashboard_outlined,
                ),
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
          )
        ],
      ),
    );
  }
}
