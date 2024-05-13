import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shoes_shop_admin/views/main/products/product_detail.dart';
import 'package:shoes_shop_admin/views/widgets/are_you_sure_dialog.dart';
import 'package:shoes_shop_admin/views/widgets/kcool_alert.dart';
import '../../components/scroll_component.dart';
import '../../widgets/loading_widget.dart';
import '../../../constants/color.dart';
import '../../../resources/assets_manager.dart';
import '../../../resources/font_manager.dart';
import '../../../resources/styles_manager.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _verticalScrollController = ScrollController();
  final _horizontalScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> _productStream;

  @override
  void initState() {
    super.initState();
    _productStream =
        FirebaseFirestore.instance.collection('products').snapshots();
  }

  // toggle Product Approval
  Future<void> toggleApproval(String id, bool status) async {
    await FirebaseFirestore.instance.collection('products').doc(id).update(
      {
        'isApproved': !status,
      },
    );
  }

  // called after alert for dismissal
  doneWithAction() {
    Navigator.of(context).pop();
  }

  void navigaterToProductDetail(String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: productId),
      ),
    );
  }

  // return context
  get cxt => context;

  // delete Product
  Future<void> deleteProduct(String id) async {
    //pop out
    doneWithAction();

    await FirebaseFirestore.instance
        .collection('products')
        .doc(id)
        .delete()
        .whenComplete(() {
      kCoolAlert(
        message: 'You have successfully set the deleted product',
        context: cxt,
        alert: CoolAlertType.success,
        action: doneWithAction,
      );
    });
  }

  // delete dialog
  void deleteDialog(String id) {
    areYouSureDialog(
      title: 'Delete product',
      content: 'Are you sure you want to delete product?',
      context: context,
      action: deleteProduct,
      isIdInvolved: true,
      id: id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(Icons.shopping_bag),
              const SizedBox(width: 10),
              Text(
                'Products',
                style: getMediumStyle(
                  color: Colors.black,
                  fontSize: FontSize.s16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _productStream = FirebaseFirestore.instance
                      .collection('products')
                      .where('productName', isGreaterThanOrEqualTo: value)
                      .where('productName', isLessThan: value + 'z')
                      .snapshots();
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _productStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error occurred!'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: LoadingWidget(),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: LoadingWidget(),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Image.asset(AssetManager.noImagePlaceholderImg),
                  );
                }

                // Sort the documents by the latest date
                List<DocumentSnapshot> sortedDocs = snapshot.data!.docs;
                sortedDocs
                    .sort((a, b) => b['uploadDate'].compareTo(a['uploadDate']));

                return ScrollComponent(
                  verticalScrollController: _verticalScrollController,
                  horizontalScrollController: _horizontalScrollController,
                  child: DataTable(
                    showBottomBorder: true,
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => primaryColor),
                    headingTextStyle: const TextStyle(color: Colors.white),
                    dataRowMinHeight: 60,
                    dataRowMaxHeight: 60,
                    columns: const [
                      DataColumn(label: Text('Product Name')),
                      DataColumn(label: Text('Product Image')),
                      DataColumn(label: Text('Product Price')),
                      DataColumn(label: Text('Product Quantity')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Action')),
                      DataColumn(label: Text('Action')),
                      DataColumn(label: Text('Action'))
                    ],
                    rows: sortedDocs
                        .map(
                          (item) => DataRow(
                            cells: [
                              DataCell(Text(item['productName'])),
                              DataCell(
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    item['imgUrls'][0],
                                    width: 50,
                                  ),
                                ),
                              ),
                              DataCell(Text('\$${item['price']}')),
                              DataCell(
                                Text(
                                  item['quantity'].toString(),
                                ),
                              ),
                              DataCell(
                                Text(
                                  intl.DateFormat.yMMMEd().format(
                                    item['uploadDate'].toDate(),
                                  ),
                                ),
                              ),
                              DataCell(
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: item['isApproved']
                                        ? primaryColor
                                        : accentColor,
                                  ),
                                  onPressed: () => toggleApproval(
                                    item['prodId'],
                                    item['isApproved'],
                                  ),
                                  child: Text(
                                    item['isApproved'] ? 'Reject' : 'Approve',
                                  ),
                                ),
                              ),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () => deleteDialog(item['prodId']),
                                  child: const Text('Delete'),
                                ),
                              ),
                              DataCell(ElevatedButton(
                                onPressed: () {
                                  // Navigate to the product detail page here
                                  navigaterToProductDetail(item['prodId']);
                                },
                                child: const Text('View Details'),
                              ))
                            ],
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
