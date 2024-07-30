import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoes_shop_admin/controllers/user_controller.dart';
import 'package:shoes_shop_admin/views/main/users/components/user_item.dart';
import '../../../resources/font_manager.dart';
import '../../../resources/styles_manager.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> _usersStream;
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _usersStream = _userController.getUsersStream('');
  }

  void _onSearchChanged(String value) {
    setState(() {
      _usersStream = _userController.getUsersStream(value);
    });
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
              const Icon(Icons.group),
              const SizedBox(width: 10),
              Text(
                'Users',
                style:
                    getMediumStyle(color: Colors.black, fontSize: FontSize.s16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: UserItems(
              usersStream: _usersStream,
              userController: _userController,
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
    );
  }
}
