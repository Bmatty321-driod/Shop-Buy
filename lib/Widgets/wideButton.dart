import 'package:ShopAndBuy/Config/config.dart';
import 'package:flutter/material.dart';

class WideButton extends StatelessWidget {
  final String msg;
  final Function onPressed;
  WideButton({Key key, this.msg, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
      child: Center(
        child: InkWell(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.pink,
            ),
            width: MediaQuery.of(context).size.width * 0.80,
            height: 50.0,
            child: Center(
              child: Text(
                msg,
                style: mystyle(10.0, Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
