import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';

class MyCustAppBar extends StatelessWidget {
  final Color color;
  final Color textColor;
  final VoidCallback? backButton;
  final Color? backButtonColor;
  final List<Widget>? actionButtons;
  final String title;

  const MyCustAppBar({
    super.key,
    this.title = "",
    this.color = const Color.fromARGB(200, 255, 255, 255),
    this.backButton,
    this.backButtonColor,
    this.actionButtons,
    this.textColor = MyColorPalette.titleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MyDimensionAdapter.getWidth(context),
      height: kToolbarHeight,
      decoration: BoxDecoration(color: color),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 5,
            child: (backButton != null)
                ? IconButton(
                    onPressed: backButton,
                    highlightColor: (backButtonColor == null)
                        ? Colors.blue.shade100
                        : Colors.white70,
                    splashRadius: 10,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: backButtonColor ?? Colors.blue.shade400,
                    ),
                  )
                : SizedBox(),
          ),
          MyTextFormatter.h1(
            text: title,
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
          Positioned(right: 5, child: Row(children: actionButtons ?? [])),
        ],
      ),
    );
  }
}
