import 'package:ShopAndBuy/Admin/adminOrderCard.dart';
import 'package:ShopAndBuy/Admin/uploadItems.dart';
import 'package:ShopAndBuy/Config/config.dart';
import 'package:ShopAndBuy/Widgets/loadingWidget.dart';
import 'package:ShopAndBuy/Widgets/myDrawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminShiftOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<AdminShiftOrders> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // drawer: MyDrawer(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
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
          centerTitle: true,
          title: InkWell(
            onTap: () {
              Route route = MaterialPageRoute(builder: (_) => UploadPage());
              Navigator.pushReplacement(context, route);
            },
            child: Text(
              "My Orders",
              style: mystyle(30, Colors.white),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.arrow_drop_down_circle),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection("orders").snapshots(),
            builder: (c, snapshot) {
              return snapshot.hasData
                  ? ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (c, index) {
                        return FutureBuilder<QuerySnapshot>(
                            future: EcommerceApp.firestore
                                .collection("Items")
                                .where("shortInfo",
                                    whereIn: snapshot.data.documents[index]
                                        .data[EcommerceApp.productID])
                                .getDocuments(),
                            builder: (c, snap) {
                              return snapshot.hasData
                                  ? AdminOrderCard(
                                      itemCount: snap.data.documents.length,
                                      data: snap.data.documents,
                                      orderID: snapshot
                                          .data.documents[index].documentID,
                                      orderBy: snapshot.data.documents[index]
                                          .data["orderID"],
                                      addressID: snapshot.data.documents[index]
                                          .data["addressID"],
                                    )
                                  : Center(child: circularProgress());
                            });
                      })
                  : Center(
                      child: circularProgress(),
                    );
            }),
      ),
    );
  }
}
