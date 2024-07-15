import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop_admin/helpers/screen_size.dart';
import 'package:shoes_shop_admin/views/widgets/loading_widget.dart';
import '../../../constants/color.dart';
import '../../../constants/enums/status.dart';
import '../../../resources/assets_manager.dart';
import '../../../resources/font_manager.dart';
import '../../../resources/styles_manager.dart';
import 'package:file_picker/file_picker.dart';
import '../../components/grid_categories.dart';
import '../../widgets/are_you_sure_dialog.dart';
import '../../widgets/kcool_alert.dart';
import '../../widgets/msg_snackbar.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool isImgSelected = false;
  Uint8List? fileBytes;
  String? fileName;
  bool isProcessing = false;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final TextEditingController categoryName = TextEditingController();

  Future<void> selectImage() async {
    FilePickerResult? pickedImage = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );

    if (pickedImage != null) {
      setState(() {
        isImgSelected = true;
        fileBytes = pickedImage.files.first.bytes;
        fileName = pickedImage.files.first.name;
      });
    }
  }

  void resetIsImagePicked() {
    setState(() {
      isImgSelected = false;
    });
  }

  void uploadDone() {
    setState(() {
      isProcessing = false;
      isImgSelected = false;
      categoryName.clear();
    });
  }

  Future<void> uploadCategory() async {
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

    setState(() {
      isProcessing = true;
    });

    try {
      final Reference ref = _firebaseStorage.ref('categories/$fileName');
      await ref.putData(fileBytes!).whenComplete(() async {
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

  void doneDeleting() {
    Navigator.of(context).pop();
  }

  Future<void> deleteCategory(String id) async {
    EasyLoading.show(status: 'loading...');

    try {
      await _firebase.collection('categories').doc(id).delete();
      EasyLoading.dismiss();
    } catch (e) {}
  }

  void deleteDialog({required String id}) {
    areYouSureDialog(
      title: 'Delete Category',
      content: 'Are you sure you want to delete this category?',
      context: context,
      action: deleteCategory,
      isIdInvolved: true,
      id: id,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(Icons.category),
              const SizedBox(width: 10),
              Text(
                'Categories',
                style:
                    getMediumStyle(color: Colors.black, fontSize: FontSize.s16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Stack(
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
                          ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 10,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: selectImage,
                        child: CircleAvatar(
                          backgroundColor: gridBg,
                          child: !isProcessing
                              ? const Icon(Icons.photo, color: accentColor)
                              : const LoadingWidget(size: 30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: size.width / 3,
                    child: TextFormField(
                      autofocus: true,
                      controller: categoryName,
                      decoration: InputDecoration(
                        hintText: 'Enter category name',
                        prefixIcon: const Icon(
                          Icons.category_outlined,
                          color: accentColor,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  isImgSelected
                      ? ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: !isProcessing ? uploadCategory : null,
                          icon: const Icon(Icons.save),
                          label: Text(
                            !isProcessing ? 'Upload Category' : 'Uploading...',
                            style: getMediumStyle(
                              color: Colors.white,
                              fontSize: FontSize.s16,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: boxBg, thickness: 1.5),
          const SizedBox(height: 10),
          Text(
            'Product Categories',
            style: getBoldStyle(
              color: Colors.black,
              fontSize: FontSize.s18,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: context.screenSize ? size.height / 2.5 : size.height / 2,
            child: CategoryGrid(
              deleteDialog: deleteDialog,
              cxt: context,
            ),
          ),
        ],
      ),
    );
  }
}
