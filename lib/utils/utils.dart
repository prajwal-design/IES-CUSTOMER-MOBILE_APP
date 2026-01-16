import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
class Utils{

  static void fieldFocusChange(BuildContext context , FocusNode current , FocusNode nextFocus){
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }


  Widget isLoading(baseColor,highlightColor){

    return Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            mainLoadObject(),
            mainLoadObject(),
            mainLoadObject(),
          ],
        )
    );
  }

  Widget mainLoadObject() {
    return Container(
      width: 15,
      height: 15,
      margin: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
          color: const Color(0xff0c1147), borderRadius: BorderRadius.circular(120)),
    );
  }

}