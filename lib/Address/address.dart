import 'package:ShopAndBuy/Address/addAddress.dart';
import 'package:ShopAndBuy/Config/config.dart';
import 'package:ShopAndBuy/Counters/changeAddresss.dart';

import 'package:ShopAndBuy/Models/address.dart';
import 'package:ShopAndBuy/Orders/placeOrder.dart';
import 'package:ShopAndBuy/Widgets/customAppBar.dart';
import 'package:ShopAndBuy/Widgets/loadingWidget.dart';
import 'package:ShopAndBuy/Widgets/wideButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Address extends StatefulWidget {
  final double totalAmount;

  Address({Key key, this.totalAmount}) : super(key: key);
  @override
  _AddressState createState() => _AddressState();
}

class _AddressState extends State<Address> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: MyAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Select Address",
                style: mystyle(
                    15.0, Colors.black, TextDecoration.none, FontWeight.bold),
              ),
            ),
          ),
          Consumer<AddressChanger>(builder: (context, address, c) {
            return Flexible(
                child: StreamBuilder<QuerySnapshot>(
                    stream: EcommerceApp.firestore
                        .collection(EcommerceApp.collectionUser)
                        .document(EcommerceApp.sharedPreferences
                            .getString(EcommerceApp.userUID))
                        .collection(EcommerceApp.subCollectionAddress)
                        .snapshots(),
                    builder: (c, snapshot) {
                      return !snapshot.hasData
                          ? Center(
                              child: circularProgress(),
                            )
                          : snapshot.data.documents.length == 0
                              ? noAddressCard()
                              : ListView.builder(
                                  itemCount: snapshot.data.documents.length,
                                  shrinkWrap: true,
                                  itemBuilder: (c, index) {
                                    return AddressCard(
                                      currentIdex: address.count,
                                      values: index,
                                      addressId: snapshot
                                          .data.documents[index].documentID,
                                      totalAmount: widget.totalAmount,
                                      model: AddressModel.fromJson(
                                          snapshot.data.documents[index].data),
                                    );
                                  });
                    }));
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Route route = MaterialPageRoute(builder: (_) => AddAddress());
          Navigator.pushReplacement(context, route);
        },
        label: Text("Add New Address"),
      ),
    ));
  }

  noAddressCard() {
    return Card(
      color: Colors.pink.withOpacity(0.5),
      child: Container(
        height: 100.0,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_location,
              color: Colors.white,
            ),
            Text("No shipment address has been saved."),
            Text("Please add your shipment address to ease Product delivery."),
          ],
        ),
      ),
    );
  }
}

class AddressCard extends StatefulWidget {
  final AddressModel model;
  final String addressId;
  final double totalAmount;
  final int currentIdex;
  final int values;
  AddressCard(
      {Key key,
      this.addressId,
      this.currentIdex,
      this.model,
      this.totalAmount,
      this.values})
      : super(key: key);
  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    // _screenHeight = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: () {
        Provider.of<AddressChanger>(context, listen: false)
            .display(widget.values);
      },
      child: Card(
        // margin: EdgeInsets.all(8.0),
        color: Colors.pinkAccent.withOpacity(0.4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio(
                    value: widget.values,
                    groupValue: widget.currentIdex,
                    activeColor: Colors.pink,
                    onChanged: (val) {
                      Provider.of<AddressChanger>(context, listen: false)
                          .display(val);
                    }),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      width: _screenWidth * 0.8,
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              KeyText(
                                msg: "Name",
                              ),
                              Text(widget.model.name),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(
                                msg: "Phone Number",
                              ),
                              Text(widget.model.phoneNumber),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(
                                msg: "Flat Number",
                              ),
                              Text(widget.model.flatNumber),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(
                                msg: "City",
                              ),
                              Text(widget.model.city),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(
                                msg: "State",
                              ),
                              Text(widget.model.state),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(
                                msg: "Zip Code",
                              ),
                              Text(widget.model.pincode),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
            widget.values == Provider.of<AddressChanger>(context).count
                ? WideButton(
                    msg: "Proceed",
                    onPressed: () {
                      Route route = MaterialPageRoute(
                          builder: (_) => PaymentPage(
                              addressId: widget.addressId,
                              totalAmount: widget.totalAmount));
                      Navigator.pushReplacement(context, route);
                    },
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class KeyText extends StatelessWidget {
  final String msg;
  KeyText({Key key, this.msg}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(msg,
        style: mystyle(10, Colors.black, TextDecoration.none, FontWeight.bold));
  }
}
