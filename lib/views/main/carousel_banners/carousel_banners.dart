import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop_admin/helpers/screen_size.dart';
import 'package:shoes_shop_admin/views/widgets/are_you_sure_dialog.dart';
import 'package:shoes_shop_admin/views/widgets/loading_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shoes_shop_admin/resources/assets_manager.dart';
import 'package:shoes_shop_admin/resources/styles_manager.dart';
import 'package:shoes_shop_admin/constants/color.dart';
import 'package:shoes_shop_admin/resources/font_manager.dart';
import '../../components/grid_carousel_banners.dart';
import '../../widgets/kcool_alert.dart';

class CarouselBanners extends StatefulWidget {
  const CarouselBanners({Key? key}) : super(key: key);

  @override
  State<CarouselBanners> createState() => _CarouselBannersState();
}

class _CarouselBannersState extends State<CarouselBanners> {
  bool isImgSelected = false;
  Uint8List? fileBytes;
  String? fileName;
  bool isProcessing = false;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  // select image
  Future selectImage() async {
    FilePickerResult? pickedImage = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);

    if (pickedImage == null) {
      return;
    } else {
      setState(() {
        isImgSelected = true;
        fileBytes = pickedImage.files.first.bytes;
        fileName = pickedImage.files.first.name;
      });
    }
  }

  // reset picked image
  void resetIsImagePicked() {
    setState(() {
      isImgSelected = false;
    });
  }

  // action after uploading banner
  uploadDone() {
    Navigator.of(context).pop();
    setState(() {
      isProcessing = false;
      isImgSelected = false;
    });
  }

  // upload banner image
  Future<void> uploadImg() async {
    setState(() {
      isProcessing = true;
    });
    String? downloadLink;
    try {
      final Reference ref = _firebaseStorage.ref('banners/$fileName');
      await ref.putData(fileBytes!).whenComplete(() async {
        downloadLink = await ref.getDownloadURL();
      });

      await FirebaseFirestore.instance.collection('banners').doc(fileName).set(
        {
          'img_url': downloadLink,
        },
      ).whenComplete(() {
        kCoolAlert(
          message: 'Image uploaded successfully',
          context: context,
          alert: CoolAlertType.success,
          action: uploadDone,
        );
      });
    } catch (e) {
      kCoolAlert(
        message: 'Image not uploaded successfully',
        context: context,
        alert: CoolAlertType.error,
        action: uploadDone,
      );
    }
  }

  // action after deleting
  void doneDeleting() {
    Navigator.of(context).pop();
  }

  // delete carousel banners
  Future<void> deleteCarousel(String id) async {
    Navigator.of(context).pop();
    EasyLoading.show(status: 'loading...');

    try {
      await _firebase.collection('banners').doc(id).delete().whenComplete(() {
        EasyLoading.dismiss();
        kCoolAlert(
          message: 'Banner deleted successfully',
          context: context,
          alert: CoolAlertType.success,
          action: doneDeleting,
        );
      });
    } catch (e) {
      kCoolAlert(
        message: 'Banner not deleted successfully',
        context: context,
        alert: CoolAlertType.error,
        action: doneDeleting,
      );
    }
  }

  // delete dialog
  void deleteDialog({required String id}) {
    areYouSureDialog(
      title: 'Delete Banner',
      content: 'Are you sure you want to delete this banner?',
      context: context,
      action: deleteCarousel,
      isIdInvolved: true,
      id: id,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: isImgSelected
          ? FloatingActionButton.extended(
              backgroundColor: !isProcessing ? accentColor : Colors.grey,
              onPressed: () => !isProcessing ? uploadImg() : null,
              icon: const Icon(Icons.save),
              label: Text(
                !isProcessing ? 'Upload' : 'Uploading...',
                style: getMediumStyle(
                  color: Colors.white,
                  fontSize: FontSize.s16,
                ),
              ),
            )
          : FloatingActionButton(
              onPressed: selectImage,
              backgroundColor: primaryColor,
              child: const Icon(Icons.add_a_photo),
            ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(Icons.view_carousel,
                      color: Colors.black, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    'Carousel Banners',
                    style: getMediumStyle(
                        color: Colors.black, fontSize: FontSize.s16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: isImgSelected
                          ? Image.memory(
                              fileBytes!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              AssetManager.placeholderImg,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: InkWell(
                          onTap: () => selectImage(),
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: !isProcessing
                                ? const Icon(
                                    Icons.photo,
                                    color: Colors.white,
                                  )
                                : const LoadingWidget(size: 30),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: boxBg, thickness: 1.5),
              const SizedBox(height: 20),
              Text(
                'Carousel Banners',
                style: getMediumStyle(
                  color: Colors.black,
                  fontSize: FontSize.s18,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height:
                    context.screenSize ? size.height / 2.5 : size.height / 2,
                child: CarouselBannerGrid(
                  deleteDialog: deleteDialog,
                  cxt: context,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
