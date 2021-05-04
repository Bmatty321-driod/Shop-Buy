import 'package:ShopAndBuy/Admin/uploadItems.dart';
import 'package:ShopAndBuy/Authentication/authenication.dart';
import 'package:ShopAndBuy/Config/config.dart';
import 'package:ShopAndBuy/DialogBox/errorDialog.dart';
import 'package:ShopAndBuy/Widgets/customTextField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        title: Text(
          "Shop&Buy",
          style: mystyle(30, Colors.white),
        ),
        centerTitle: true,
      ),
      body: AdminSignInScreen(),
    );
  }
}

class AdminSignInScreen extends StatefulWidget {
  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen> {
  final TextEditingController _adminController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.pink],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset("images/admin.png"),
              height: 240.0,
              width: 240.0,
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Admin",
                style: mystyle(20.0, Colors.white),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _adminController,
                    hintText: "id",
                    data: Icons.person,
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    data: Icons.lock,
                    isObsecure: true,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            RaisedButton(
              onPressed: () {
                _adminController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty
                    ? loginAdmin()
                    : showDialog(
                        context: context,
                        builder: (c) {
                          return ErrorAlertDialog(
                            message: "Please enter your email and password",
                          );
                        });
              },
              color: Colors.green,
              child: Text(
                "Login",
                style: mystyle(15.0, Colors.white),
              ),
            ),
            SizedBox(
              height: 40.0,
            ),
            Container(
              height: 4.0,
              width: _screenWidth * 0.8,
              color: Colors.green,
            ),
            SizedBox(
              height: 25.0,
            ),
            FlatButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AuthenticScreen())),
              icon: Icon(
                Icons.satellite,
                color: Colors.green,
              ),
              label: Text(
                "I'm not Admin",
                style: mystyle(15.0, Colors.green),
              ),
            ),
            SizedBox(
              height: 150.0,
            ),
          ],
        ),
      ),
    );
  }

  void loginAdmin() async {
    Firestore.instance.collection("admins").getDocuments().then((snapshot) {
      snapshot.documents.forEach((result) {
        if (result.data["id"] != _adminController.text.trim()) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text("Please enter your correct id")));
        } else if (result.data["password"] != _passwordController.text.trim()) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text("Please enter your correct password")));
        } else {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Welcome Dear Admin," + result.data["name"]),
          ));
          setState(() {
            _adminController.text = "";
            _passwordController.text = "";
          });
          Route route = MaterialPageRoute(builder: (_) => UploadPage());
          Navigator.pushReplacement(context, route);
        }
      });
    });
  }
}
