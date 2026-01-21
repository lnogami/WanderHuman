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
  final FontWeight fontWeight;
  final double fontSize;
  final double actionButtonsRightMargin;
  // newly added, subject to change
  final Color shadowColor;

  const MyCustAppBar({
    super.key,
    this.title = "",
    this.color = const Color.fromARGB(200, 255, 255, 255),
    this.backButton,
    this.backButtonColor,
    this.actionButtons,
    this.actionButtonsRightMargin = 5,
    this.textColor = MyColorPalette.titleTextColor,
    this.fontSize = (kDefaultFontSize + 7),
    this.fontWeight = FontWeight.w700,
    this.shadowColor = const Color.fromARGB(20, 33, 149, 243), // newly added
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MyDimensionAdapter.getWidth(context),
      height: kToolbarHeight,
      decoration: BoxDecoration(
        color: color,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
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
          Container(
            width: MyDimensionAdapter.getWidth(context) * 0.67,
            alignment: Alignment.center,
            child: MyTextFormatter.h1(
              text: title,
              color: textColor,
              fontWeight: fontWeight,
              fontsize: fontSize,
              overflow: TextOverflow.fade,
            ),
          ),
          Positioned(
            right: actionButtonsRightMargin,
            child: Row(children: actionButtons ?? []),
          ),
        ],
      ),
    );
  }
}
