import 'package:cloud_firestore/cloud_firestore.dart';

class CarouselBannerRepository {
  static Future<void> createBanner(
      {required String? fileName, required downloadLink}) async {
    try {
      await FirebaseFirestore.instance.collection('banners').doc(fileName).set(
        {
          'img_url': downloadLink,
        },
      );
    } on FirebaseException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
