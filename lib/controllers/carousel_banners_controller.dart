import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class CarouselBannersController {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  Future<Uint8List?> selectImage() async {
    // Implement image selection logic if needed.
    return null;
  }

  Future<void> uploadImg(Uint8List fileBytes, String fileName) async {
    try {
      final Reference ref = _firebaseStorage.ref('banners/$fileName');
      await ref.putData(fileBytes);
      String downloadLink = await ref.getDownloadURL();

      await _firebase.collection('banners').doc(fileName).set({
        'img_url': downloadLink,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> deleteCarousel(String id) async {
    try {
      await _firebase.collection('banners').doc(id).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting banner: $e');
      }
    }
  }
}
