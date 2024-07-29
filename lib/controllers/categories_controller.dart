import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../constants/enums/status.dart';

class CategoriesController {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  Future<void> uploadCategory(
      {required Uint8List fileBytes,
      required String fileName,
      required TextEditingController categoryName,
      required BuildContext context,
      required Function uploadDone,
      required Function displaySnackBar}) async {
    if (categoryName.text.isEmpty || categoryName.text.length < 4) {
      displaySnackBar(
        status: Status.error,
        message: categoryName.text.isEmpty
            ? 'Category name is empty'
            : 'Category name is not valid',
        context: context,
      );
      return;
    }

    try {
      final Reference ref = _firebaseStorage.ref('categories/$fileName');
      await ref.putData(fileBytes).whenComplete(() async {
        String downloadLink = await ref.getDownloadURL();
        await _firebase.collection('categories').doc(fileName).set({
          'img_url': downloadLink,
          'category': categoryName.text.trim(),
        });
      });
      uploadDone();
    } catch (e) {
      uploadDone();
    }
  }

  Future<void> deleteCategory(String id, BuildContext context) async {
    EasyLoading.show(status: 'loading...');

    try {
      await _firebase.collection('categories').doc(id).delete();
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete category'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
