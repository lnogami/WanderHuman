import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';

class MyDropdownMenuButton extends StatefulWidget {
  /// The first in the list should be a default or no value yet (e.g. "No Role")
  /// Because I program this dropdown to display the items[0] to look like NO VALUE YET
  final List<String> items;
  final Icon icon;
  final String hintText;
  final String initialValue;
  final Function(String?) onChanged;

  const MyDropdownMenuButton({
    super.key,
    required this.items,
    required this.initialValue,
    required this.hintText,
    required this.onChanged,
    this.icon = const Icon(Icons.info_outline_rounded, size: 32),
  });

  @override
  State<MyDropdownMenuButton> createState() => _MyDropdownMenuButtonState();
}

class _MyDropdownMenuButtonState extends State<MyDropdownMenuButton> {
  // List<String> items = ["No Role", "Admin", "Social Service", "Home Life"];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MyDimensionAdapter.getWidth(context) * 0.80,
      height: MyDimensionAdapter.getHeight(context) * 0.07,
      // width: MyDimensionAdapter.getWidth(context)
      // height: MyDimensionAdapter.getHeight(context) * 0.2,
      child: DropdownButtonFormField<String>(
        initialValue: widget.initialValue,
        menuMaxHeight: MyDimensionAdapter.getHeight(context) * 0.55,
        padding: EdgeInsets.all(0),
        dropdownColor: Colors.blue[50],
        hint: Text(widget.hintText),
        decoration: InputDecoration(
          icon: widget.icon,
          iconColor: Colors.blue.shade200,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(width: 2.5, color: Colors.blue.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(width: 1.5, color: Colors.blue.shade200),
          ),
        ),
        items: widget.items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    // this ensures that the first item should means no value
                    fontStyle:
                        // (item == widget.initialValue && item == "No Role")
                        (item == widget.items[0])
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color:
                        // (item == widget.initialValue && item == "No Role")
                        (item == widget.items[0])
                        ? Colors.blueGrey
                        : Colors.black,
                  ),
                ),
              ),
            )
            .toList(),
        // onChanged: (item) => setState(() {
        //   _selectedItem = item!;
        // }),
        onChanged: widget.onChanged,
      ),
    );
  }
}
