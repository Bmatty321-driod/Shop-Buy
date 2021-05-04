import 'dart:io';

import 'package:ShopAndBuy/Admin/adminShiftOrders.dart';
import 'package:ShopAndBuy/Authentication/authenication.dart';
import 'package:ShopAndBuy/Authentication/login.dart';
import 'package:ShopAndBuy/Config/config.dart';
import 'package:ShopAndBuy/Widgets/loadingWidget.dart';
import 'package:ShopAndBuy/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with AutomaticKeepAliveClientMixin<UploadPage> {
  bool get wantKeepAlive => true;
  TextEditingController _descripController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _shortController = TextEditingController();
  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  bool uploading = false;

  File file;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return file == null
        ? displayAdminHomeScreen()
        : displayAdminUploadFormScreen();
  }

  displayAdminUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.green, Colors.pink],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => clearFormInfo(),
        ),
        title: Text(
          "New Product",
          style: mystyle(15.0, Colors.white),
        ),
        actions: [
          FlatButton(
              onPressed: uploading ? null : () => uploadImageSaveInfo(),
              child: Text(
                "Add",
                style: mystyle(15.0, Colors.green),
              ))
        ],
      ),
      body: ListView(
        children: [
          uploading ? linearProgress() : Text(""),
          Container(
            height: 230.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(file), fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.0),
          ),
          ListTile(
            leading: Icon(
              Icons.perm_device_information,
              color: Colors.pink,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: mystyle(10.0, Colors.deepPurpleAccent),
                controller: _shortController,
                decoration: InputDecoration(
                  hintText: "Short Info",
                  hintStyle: mystyle(10.0, Colors.deepPurpleAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.pink,
          ),
          ListTile(
            leading: Icon(
              Icons.perm_device_information,
              color: Colors.pink,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: mystyle(10.0, Colors.deepPurpleAccent),
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Title",
                  hintStyle: mystyle(10.0, Colors.deepPurpleAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.pink,
          ),
          ListTile(
            leading: Icon(
              Icons.perm_device_information,
              color: Colors.pink,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: mystyle(10.0, Colors.deepPurpleAccent),
                controller: _descripController,
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: mystyle(10.0, Colors.deepPurpleAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.pink,
          ),
          ListTile(
            leading: Icon(
              Icons.perm_device_information,
              color: Colors.pink,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                keyboardType: TextInputType.number,
                style: mystyle(10.0, Colors.deepPurpleAccent),
                controller: _priceController,
                decoration: InputDecoration(
                  hintText: "Price",
                  hintStyle: mystyle(10.0, Colors.deepPurpleAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.pink,
          ),
        ],
      ),
    );
  }

  uploadImageSaveInfo() async {
    setState(() {
      uploading = true;
    });
    String imageDownloadUrl = await uploadItemImage(file);

    saveItemInfo(imageDownloadUrl);
  }

  Future<String> uploadItemImage(nfileImage) async {
    final StorageReference storageReference =
        FirebaseStorage.instance.ref().child("Items");
    StorageUploadTask uploadTask =
        storageReference.child("product_$productId.jpg").putFile(nfileImage);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  saveItemInfo(String downloadUrl) {
    final itemsRef = Firestore.instance.collection("Items");
    itemsRef.document(productId).setData({
      "shortInfo": _shortController.text.trim(),
      "title": _titleController.text.trim(),
      "price": int.parse(_priceController.text),
      "longDescription": _descripController.text.trim(),
      "publishedDate": DateTime.now(),
      "status": "available",
      "thumbnailUrl": downloadUrl
    });

    setState(() {
      file = null;
      uploading = false;
      productId = DateTime.now().millisecondsSinceEpoch.toString();
      _priceController.clear();
      _descripController.clear();
      _shortController.clear();
      _titleController.clear();
    });
  }

  clearFormInfo() {
    setState(() {
      file = null;
      _priceController.clear();
      _descripController.clear();
      _shortController.clear();
      _titleController.clear();
    });
  }

  displayAdminHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.green, Colors.pink],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.border_color,
            color: Colors.white,
          ),
          onPressed: () {
            Route route = MaterialPageRoute(builder: (_) => AdminShiftOrders());
            Navigator.pushReplacement(context, route);
          },
        ),
        actions: [
          FlatButton(
            onPressed: () {
              Route route =
                  MaterialPageRoute(builder: (_) => AuthenticScreen());
              Navigator.pushReplacement(context, route);
            },
            child: Text(
              "Logout",
              style: mystyle(20.0, Colors.green),
            ),
          ),
        ],
      ),
      body: getAdminHomeScreenBody(),
    );
  }

  getAdminHomeScreenBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.pink],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shop_two,
              color: Colors.white,
              size: 200.0,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.0),
                ),
                child: Text(
                  "Add New Items",
                  style: mystyle(15.0, Colors.white),
                ),
                color: Colors.green,
                onPressed: () => showDialogBuilder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showDialogBuilder() {
    return showDialog(
        context: context,
        builder: (cont) {
          return SimpleDialog(
            title: Text(
              "Item Image",
              style: mystyle(15.0, Colors.green),
            ),
            children: [
              SimpleDialogOption(
                child: Text(
                  "Capture with camera",
                  style: mystyle(15.0, Colors.green),
                ),
                onPressed: () => captureWithCamera(),
              ),
              SimpleDialogOption(
                child: Text(
                  "Select from gallery",
                  style: mystyle(15.0, Colors.green),
                ),
                onPressed: () => pinkWithGallery(),
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: mystyle(15.0, Colors.green),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  captureWithCamera() async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 680.0, maxWidth: 950.0);
    setState(() {
      file = imageFile;
    });
  }

  pinkWithGallery() async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      file = imageFile;
    });
  }
}
