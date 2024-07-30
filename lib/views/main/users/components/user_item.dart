import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoes_shop_admin/controllers/user_controller.dart';
import 'package:shoes_shop_admin/resources/assets_manager.dart';
import 'package:shoes_shop_admin/resources/font_manager.dart';
import 'package:shoes_shop_admin/resources/styles_manager.dart';
import 'package:shoes_shop_admin/views/widgets/are_you_sure_dialog.dart';
import 'package:shoes_shop_admin/views/widgets/loading_widget.dart'; // Import dialog function

class UserItems extends StatelessWidget {
  final Stream<QuerySnapshot> usersStream;
  final UserController userController;
  final ScrollController scrollController;

  const UserItems({
    super.key,
    required this.usersStream,
    required this.userController,
    required this.scrollController,
  });

  void _showDeleteDialog(BuildContext context, String id) {
    areYouSureDialog(
      title: 'Delete Customer',
      content: 'Are you sure you want to delete this customer?',
      context: context,
      action: () async {
        await userController.deleteCustomer(id);
      },
      isIdInvolved: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: usersStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error occurred!'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingWidget());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Image.asset(AssetManager.noImagePlaceholderImg));
        }

        List<DocumentSnapshot> sortedDocs = snapshot.data!.docs;

        return ListView.builder(
          controller: scrollController,
          itemCount: sortedDocs.length,
          itemBuilder: (context, index) {
            var item = sortedDocs[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  item['fullname'],
                  style: getMediumStyle(
                      color: Colors.black, fontSize: FontSize.s16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone: ${item['phone']}',
                      style: getMediumStyle(
                          color: Colors.black, fontSize: FontSize.s14),
                    ),
                    Text(
                      'Email: ${item['email']}',
                      style: getRegularStyle(
                          color: Colors.black54, fontSize: FontSize.s12),
                    ),
                    Text(
                      'Address: ${item['address']}',
                      style: getRegularStyle(
                          color: Colors.black54, fontSize: FontSize.s12),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, item.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
