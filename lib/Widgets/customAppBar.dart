import 'package:ShopAndBuy/Config/config.dart';
import 'package:ShopAndBuy/Store/cart.dart';
import 'package:ShopAndBuy/Counters/cartitemcounter.dart';
import 'package:ShopAndBuy/Store/storehome.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  final PreferredSizeWidget bottom;
  MyAppBar({this.bottom});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
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
      title: InkWell(
        onTap: () {
          Route route = MaterialPageRoute(builder: (_) => StoreHome());
          Navigator.pushReplacement(context, route);
        },
        child: Text(
          "Shop&Buy",
          style: mystyle(30, Colors.white),
        ),
      ),
      centerTitle: true,
      bottom: bottom,
      actions: [
        Stack(
          children: [
            IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.green,
                ),
                onPressed: () {
                  Route route = MaterialPageRoute(builder: (_) => CartPage());
                  Navigator.pushReplacement(context, route);
                }),
            Positioned(
                child: Stack(
              children: [
                Icon(
                  Icons.brightness_1,
                  size: 19.0,
                  color: Colors.green,
                ),
                Positioned(
                  top: 3.0,
                  bottom: 4.0,
                  left: 4.0,
                  child: Consumer<CartItemCounter>(
                    builder: (context, counter, _) {
                      return Text(
                        (EcommerceApp.sharedPreferences
                                    .getStringList(EcommerceApp.userCartList)
                                    .length -
                                1)
                            .toString(),
                        style: mystyle(12.0, Colors.white),
                      );
                    },
                  ),
                ),
              ],
            ))
          ],
        )
      ],
    );
  }

  Size get preferredSize => bottom == null
      ? Size(56, AppBar().preferredSize.height)
      : Size(56, 80 + AppBar().preferredSize.height);
}
