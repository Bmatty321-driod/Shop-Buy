import 'dart:io';

import 'package:ShopAndBuy/Config/config.dart';
import 'package:ShopAndBuy/DialogBox/errorDialog.dart';
import 'package:ShopAndBuy/DialogBox/loadingDialog.dart';
import 'package:ShopAndBuy/Store/storehome.dart';
import 'package:ShopAndBuy/Widgets/customTextField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userImage = "";
  File fileImage;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 10.0,
            ),
            InkWell(
                onTap: () => _selectImage(),
                child: CircleAvatar(
                  radius: _screenWidth * 0.15,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      fileImage == null ? null : FileImage(fileImage),
                  child: fileImage == null
                      ? Icon(
                          Icons.add_a_photo,
                          size: _screenWidth * 0.15,
                          color: Colors.grey,
                        )
                      : null,
                )),
            SizedBox(
              height: 8.0,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nameController,
                    hintText: "Name",
                    data: Icons.person,
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _emailController,
                    hintText: "Email",
                    data: Icons.email,
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    data: Icons.lock,
                    isObsecure: true,
                  ),
                  CustomTextField(
                    controller: _cPasswordController,
                    hintText: "Confirm Password",
                    data: Icons.lock,
                    isObsecure: true,
                  ),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () {
                uploadImageAndSave();
              },
              color: Colors.green,
              child: Text(
                "Sign Up",
                style: mystyle(15.0, Colors.white),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              height: 4.0,
              width: _screenWidth * 0.8,
              color: Colors.green,
            ),
            SizedBox(
              height: 15.0,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage() async {
    // ignore: deprecated_member_use
    fileImage = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<void> uploadImageAndSave() async {
    if (fileImage == null) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(
              message: "Please select an image",
            );
          });
    } else {
      _passwordController.text == _cPasswordController.text
          ? _emailController.text.isNotEmpty &&
                  _passwordController.text.isNotEmpty &&
                  _cPasswordController.text.isNotEmpty &&
                  _nameController.text.isNotEmpty
              ? uploadToStorage()
              : displayDialog("Please the fill up the form ")
          : displayDialog("Password do not matches");
    }
  }

  displayDialog(String msg) {
    showDialog(
        context: context,
        builder: (c) {
          return ErrorAlertDialog(
            message: "Please select an image",
          );
        });
  }

  Future<void> uploadToStorage() async {
    showDialog(
        context: context,
        builder: (c) {
          return LoadingAlertDialog(
            message: "Registering, Please wait.....",
          );
        });
    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(imageFileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(fileImage);
    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;
    await taskSnapshot.ref.getDownloadURL().then((imageUrl) {
      userImage = imageUrl;

      registerUser();
    });
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  void registerUser() async {
    FirebaseUser firebaseUser;
    await _auth
        .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim())
        .then((auth) {
      firebaseUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(
              message: error.message.toString(),
            );
          });
    });

    if (firebaseUser != null) {
      savUserInfoToFirestore(firebaseUser).then((value) {
        Navigator.pop(context);
        Route route = MaterialPageRoute(builder: (_) => StoreHome());
        Navigator.pushReplacement(context, route);
      });
    }
  }

  Future savUserInfoToFirestore(FirebaseUser fUser) async {
    Firestore.instance.collection("users").document(fUser.uid).setData({
      "uid": fUser.uid,
      "email": fUser.email,
      "name": _nameController.text.trim(),
      "url": userImage,
      EcommerceApp.userCartList: ["garbageValue"],
    });

    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userUID, fUser.uid);
    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userEmail, fUser.email);
    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userName, _nameController.text);
    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userAvatarUrl, userImage);
    await EcommerceApp.sharedPreferences
        .setStringList(EcommerceApp.userCartList, ["garbageValue"]);
  }
}
