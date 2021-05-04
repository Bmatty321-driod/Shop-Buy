import 'package:flutter/foundation.dart';

class ItemQuantity with ChangeNotifier {
  int _numOfItems = 0;

  int get numOfItem => _numOfItems;

  display(int no) {
    _numOfItems = no;
    notifyListeners();
  }
}
