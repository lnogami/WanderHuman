import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';

class MyCustButton extends StatefulWidget {
  final double widthPercentage;
  final double height;
  final Color color;
  final String buttonText;
  final FontWeight buttonTextFontWeight;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color buttonTextColor;
  final double buttonTextSpacing;
  final String buttonTextFontFamily;
  final VoidCallback onTap;
  final bool enableShadow;
  final Color buttonShadowColor;

  const MyCustButton({
    super.key,
    this.widthPercentage = 0.50,
    this.height = 50,
    this.color = Colors.blue,
    required this.buttonText,
    this.buttonTextFontWeight = FontWeight.w400,
    this.borderRadius = 30,
    this.borderWidth = 1.5,
    this.borderColor = const Color.fromARGB(254, 209, 232, 253),
    this.buttonTextColor = Colors.black,
    this.buttonTextSpacing = 2.5,
    this.buttonTextFontFamily = "Poppins",
    required this.onTap,
    this.enableShadow = true,
    this.buttonShadowColor = Colors.blue,
  });

  @override
  State<MyCustButton> createState() => _MyCustButtonState();
}

class _MyCustButtonState extends State<MyCustButton> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MyDimensionAdapter.getWidth(context) * widget.widthPercentage,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.color,
        border: BoxBorder.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [boxShadow(Offset(1, 2)), boxShadow(Offset(-1, 2))],
      ),
      // Material will act as the canvas of Inkwell's ripple effect
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          splashColor: Colors.purple[200],
          onTap: () {
            widget.onTap();
          },
          child: Center(
            child: Text(
              widget.buttonText,
              style: TextStyle(
                fontWeight: widget.buttonTextFontWeight,
                color: widget.buttonTextColor,
                letterSpacing: widget.buttonTextSpacing,
                fontFamily: widget.buttonTextFontFamily,
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxShadow boxShadow(Offset offset) {
    return BoxShadow(
      // color: const Color.fromARGB(50, 33, 149, 243),
      color: (widget.enableShadow)
          ? widget.buttonShadowColor.withAlpha(50)
          : Colors.transparent,
      offset: offset,
      blurRadius: 2,
      blurStyle: BlurStyle.normal,
    );
  }
}
