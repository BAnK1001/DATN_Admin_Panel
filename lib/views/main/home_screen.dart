import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop_admin/constants/color.dart';
import '../../models/app_data.dart';
import '../../models/chart_sample.dart';
import '../components/app_data_graph.dart';
import '../components/category_pie_data.dart';
import '../widgets/build_dashboard_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchText = TextEditingController();

  int orders = 0;
  int cashOuts = 0;
  int users = 0;
  int categories = 0;
  int vendors = 0;
  int products = 0;

  List<ChartSampleData> chartSampleData = [];

  Future<void> fetchCategoriesWithData() async {
    final List<String> categories = [];

    final categorySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    for (var doc in categorySnapshot.docs) {
      categories.add(doc['category']);
    }

    for (var category in categories) {
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: category)
          .get();
      final int number = productSnapshot.docs.length;

      setState(() {
        chartSampleData.add(
          ChartSampleData(
            x: category,
            y: number == 0 ? 0.1 : number,
            text: category,
          ),
        );
      });
    }
  }

  Future<void> fetchData() async {
    final collectionNames = {
      'orders': (int value) => orders = value,
      'products': (int value) => products = value,
      'customers': (int value) => users = value,
      'categories': (int value) => categories = value,
      'cash_outs': (int value) => cashOuts = value,
      'vendors': (int value) => vendors = value,
    };

    for (var entry in collectionNames.entries) {
      final dataSnapshot =
          await FirebaseFirestore.instance.collection(entry.key).get();
      setState(() {
        entry.value(dataSnapshot.docs.length);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchCategoriesWithData();
  }

  @override
  Widget build(BuildContext context) {
    final data = [
      AppData(
          title: 'Orders',
          number: orders,
          color: dashBlue,
          icon: Icons.shopping_cart_checkout,
          index: 2),
      AppData(
          title: 'Cash Outs',
          number: cashOuts,
          color: dashGrey,
          icon: Icons.monetization_on,
          index: 6),
      AppData(
          title: 'Products',
          number: products,
          color: dashOrange,
          icon: Icons.shopping_bag,
          index: 1),
      AppData(
          title: 'Vendors',
          number: vendors,
          color: dashPurple,
          icon: Icons.group,
          index: 3),
      AppData(
          title: 'Categories',
          number: categories,
          color: dashRed,
          icon: Icons.category_outlined,
          index: 5),
      AppData(
          title: 'Users',
          number: users,
          color: dashTeal,
          icon: Icons.group,
          index: 7),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black12, bgColor],
              begin: Alignment.topCenter,
              end: Alignment.center,
              stops: [1, 30],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final screenWidth = constraints.maxWidth;
                    const desiredItemWidth = 180.0;
                    final crossAxisCount =
                        (screenWidth / desiredItemWidth).floor();

                    return GridView.builder(
                      itemCount: data.length,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                      ),
                      itemBuilder: (context, index) => BuildDashboardContainer(
                        title: data[index].title,
                        value: data[index].number,
                        color: data[index].color,
                        icon: data[index].icon,
                        index: data[index].index,
                        // Thêm animation và các thành phần trang trí khác tại đây
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool isWideScreen = constraints.maxWidth > 600;
                    final children = [
                      Expanded(flex: 3, child: AppDataGraph(data: data)),
                      const SizedBox(width: 30),
                      Expanded(
                        child: chartSampleData.isNotEmpty
                            ? CategoryDataPie(chartSampleData: chartSampleData)
                            : const SizedBox.shrink(),
                      ),
                    ];

                    return isWideScreen
                        ? Row(children: children)
                        : Column(children: children);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
