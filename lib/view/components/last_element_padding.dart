import 'package:flutter/material.dart';

/// This class is for padding a widget, specifically the last element in a List, to give them more space.
class MyElementPadding {
  /// This is for the first element in a list to have a visual space in a ListView/ListView.builder.
  static Container firstListElementPadding({
    required Widget widget,
    double padding = 50,
  }) {
    return Container(
      // color: Colors.amber,
      // margin: EdgeInsets.only(bottom: 50),
      padding: EdgeInsets.only(top: padding),
      child: widget,
    );
  }

  /// This is for the last element in a list to have a visual space in a ListView/ListView.builder.
  static Container lastListElementPadding({
    required Widget widget,
    double padding = 50,
  }) {
    return Container(
      // color: Colors.amber,
      // margin: EdgeInsets.only(bottom: 50),
      padding: EdgeInsets.only(bottom: padding),
      child: widget,
    );
  }
}
