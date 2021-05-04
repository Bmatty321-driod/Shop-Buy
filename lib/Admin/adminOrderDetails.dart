import 'package:ShopAndBuy/Address/address.dart';
import 'package:ShopAndBuy/Admin/uploadItems.dart';
import 'package:ShopAndBuy/Config/config.dart';
import 'package:ShopAndBuy/Models/address.dart';
import 'package:ShopAndBuy/Widgets/customAppBar.dart';
import 'package:ShopAndBuy/Widgets/loadingWidget.dart';
import 'package:ShopAndBuy/Widgets/orderCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

String getOrderId = "";

class AdminOrderDetails extends StatelessWidget {
  final String orderID;
  final String addressID;
  final String orderBy;
  AdminOrderDetails({Key key, this.addressID, this.orderBy, this.orderID})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    getOrderId = orderID;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: FutureBuilder<DocumentSnapshot>(
              future: EcommerceApp.firestore
                  .collection(EcommerceApp.collectionOrders)
                  .document(getOrderId)
                  .get(),
              builder: (c, snapshot) {
                Map dataMap;
                if (snapshot.hasData) {
                  dataMap = snapshot.data.data;
                }
                return snapshot.hasData
                    ? Container(
                        child: Column(
                          children: [
                            AdminStatusBanner(
                              status: dataMap[EcommerceApp.isSuccess],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    "＄ " +
                                        dataMap[EcommerceApp.totalAmount]
                                            .toString(),
                                    style: mystyle(20.0, Colors.black,
                                        TextDecoration.none, FontWeight.bold)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text("Order ID:" + getOrderId),
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                "Order at:" +
                                    DateFormat("dd MMMM, YYYY - hh:mm aa")
                                        .format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(dataMap["orderTime"])),
                                    ),
                                style: mystyle(16.0, Colors.grey),
                              ),
                            ),
                            Divider(
                              height: 2.0,
                            ),
                            FutureBuilder<QuerySnapshot>(
                                future: EcommerceApp.firestore
                                    .collection("Items")
                                    .where("shortInfo",
                                        whereIn:
                                            dataMap[EcommerceApp.productID])
                                    .getDocuments(),
                                builder: (c, dataSnapshot) {
                                  return dataSnapshot.hasData
                                      ? OrderCard(
                                          itemCount: dataSnapshot
                                              .data.documents.length,
                                          data: dataSnapshot.data.documents,
                                        )
                                      : Center(
                                          child: circularProgress(),
                                        );
                                }),
                            Divider(
                              height: 2.0,
                            ),
                            FutureBuilder<DocumentSnapshot>(
                                future: EcommerceApp.firestore
                                    .collection(EcommerceApp.collectionUser)
                                    .document(orderBy)
                                    .collection(
                                        EcommerceApp.subCollectionAddress)
                                    .document(addressID)
                                    .get(),
                                builder: (c, snap) {
                                  return snap.hasData
                                      ? AdminShippingDetails(
                                          model: AddressModel.fromJson(
                                              snap.data.data),
                                        )
                                      : Center(
                                          child: circularProgress(),
                                        );
                                })
                          ],
                        ),
                      )
                    : Center(
                        child: circularProgress(),
                      );
              }),
        ),
        // appBar: MyAppBar(),
      ),
    );
  }
}

class AdminStatusBanner extends StatelessWidget {
  final bool status;
  AdminStatusBanner({Key key, this.status}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String msg;
    IconData iconData;

    status ? iconData = Icons.done : iconData = Icons.cancel;
    status ? msg = "Successful" : msg = "UnSuccessful";

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
      height: 40.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              SystemNavigator.pop();
            },
            child: Container(
              child: Icon(
                Icons.arrow_drop_down_circle,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          Text(
            "Order Shipped" + msg,
            style: mystyle(
              20.0,
              Colors.white,
            ),
          ),
          SizedBox(
            width: 5.0,
          ),
          CircleAvatar(
            radius: 8.0,
            backgroundColor: Colors.grey,
            child: Center(
              child: Icon(
                iconData,
                color: Colors.white,
                size: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminShippingDetails extends StatelessWidget {
  final AddressModel model;
  AdminShippingDetails({Key key, this.model}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: Text(
            "Shipment Detail:",
            style: mystyle(
              20.0,
              Colors.black,
              TextDecoration.none,
              FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          width: screenwidth,
          child: Table(
            children: [
              TableRow(
                children: [
                  KeyText(
                    msg: "Name",
                  ),
                  Text(model.name),
                ],
              ),
              TableRow(
                children: [
                  KeyText(
                    msg: "Phone Number",
                  ),
                  Text(model.phoneNumber),
                ],
              ),
              TableRow(
                children: [
                  KeyText(
                    msg: "Flat Number",
                  ),
                  Text(model.flatNumber),
                ],
              ),
              TableRow(
                children: [
                  KeyText(
                    msg: "City",
                  ),
                  Text(model.city),
                ],
              ),
              TableRow(
                children: [
                  KeyText(
                    msg: "State",
                  ),
                  Text(model.state),
                ],
              ),
              TableRow(
                children: [
                  KeyText(
                    msg: "Zip Code",
                  ),
                  Text(model.pincode),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: InkWell(
              onTap: () {
                confirmedOrderShifted(context, getOrderId);
              },
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
                width: MediaQuery.of(context).size.width - 40.0,
                height: 50.0,
                child: Center(
                  child: Text(
                    "Order Shifted",
                    style: mystyle(15.0, Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  confirmedOrderShifted(BuildContext context, String mOrderId) {
    EcommerceApp.firestore
        .collection(EcommerceApp.collectionOrders)
        .document(mOrderId)
        .delete();
    getOrderId = "";

    Route route = MaterialPageRoute(builder: (_) => UploadPage());
    Navigator.pushReplacement(context, route);

    Fluttertoast.showToast(msg: "Order has been Shifted");
  }
}
