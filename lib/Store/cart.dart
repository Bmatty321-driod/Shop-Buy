import 'package:ShopAndBuy/Widgets/customAppBar.dart';
import 'package:ShopAndBuy/Widgets/myDrawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ShopAndBuy/Config/config.dart';
import 'package:ShopAndBuy/Address/address.dart';
import 'package:ShopAndBuy/Widgets/loadingWidget.dart';
import 'package:ShopAndBuy/Models/item.dart';
import 'package:ShopAndBuy/Counters/cartitemcounter.dart';
import 'package:ShopAndBuy/Counters/totalMoney.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ShopAndBuy/Store/storehome.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double totalAmount;
  @override
  void initState() {
    super.initState();
    totalAmount = 0;
    Provider.of<TotalAmount>(context, listen: false).display(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (EcommerceApp.sharedPreferences
                  .getStringList(EcommerceApp.userCartList)
                  .length ==
              1) {
            Fluttertoast.showToast(msg: "Your Cart is empty.");
          } else {
            Route route = MaterialPageRoute(
                builder: (_) => Address(totalAmount: totalAmount));
            Navigator.pushReplacement(context, route);
          }
        },
        label: Text("Checkout"),
        backgroundColor: Colors.pink,
        icon: Icon(Icons.navigate_next),
      ),
      appBar: MyAppBar(),
      drawer: MyDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Consumer2<TotalAmount, CartItemCounter>(
                builder: (context, amountProvider, cartProvider, c) {
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: cartProvider.count == 0
                      ? Container()
                      : Text(
                          "Total Amount: ＄ ${amountProvider.totalAmount.toString()}",
                          style: mystyle(
                            15.0,
                            Colors.black,
                            TextDecoration.none,
                            FontWeight.w500,
                          ),
                        ),
                ),
              );
            }),
          ),
          StreamBuilder(
              stream: EcommerceApp.firestore
                  .collection("Items")
                  .where("shortInfo",
                      whereIn: EcommerceApp.sharedPreferences
                          .getStringList(EcommerceApp.userCartList))
                  .snapshots(),
              builder: (c, snapshot) {
                return !snapshot.hasData
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: circularProgress(),
                        ),
                      )
                    : snapshot.data.documents.length == 0
                        ? beginBuidlingCart()
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                ItemModel model = ItemModel.fromJson(
                                    snapshot.data.documents[index].data);
                                if (index == 0) {
                                  totalAmount = 0;
                                  totalAmount = model.price + totalAmount;
                                } else {
                                  totalAmount = model.price + totalAmount;
                                }

                                if (snapshot.data.documents.length - 1 ==
                                    index) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((timeStamp) {
                                    Provider.of<TotalAmount>(context,
                                            listen: false)
                                        .display(totalAmount);
                                  });
                                }
                                return sourceInfo(model, context,
                                    removeCartFunction: () =>
                                        removeItemFromCart(model.shortInfo));
                              },
                              childCount: snapshot.hasData
                                  ? snapshot.data.documents.length
                                  : 0,
                            ),
                          );
              }),
        ],
      ),
    );
  }

  beginBuidlingCart() {
    return SliverToBoxAdapter(
      child: Card(
        color: Theme.of(context).primaryColor.withOpacity(0.5),
        child: Container(
          height: 100.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insert_emoticon, color: Colors.white),
              Text("Cart is empty"),
              Text("Add new Item to your Cart"),
            ],
          ),
        ),
      ),
    );
  }

  removeItemFromCart(String shortInfoAsId) {
    List itemCartList =
        EcommerceApp.sharedPreferences.getStringList(EcommerceApp.userCartList);
    itemCartList.remove(shortInfoAsId);
    EcommerceApp.firestore
        .collection(EcommerceApp.collectionUser)
        .document(
            EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
        .updateData({
      EcommerceApp.userCartList: itemCartList,
    }).then((m) {
      Fluttertoast.showToast(msg: "Item Removed Successfully.");
      EcommerceApp.sharedPreferences
          .setStringList(EcommerceApp.userCartList, itemCartList);
      Provider.of<CartItemCounter>(context, listen: false).displayResult();

      totalAmount = 0;
    });
  }
}
