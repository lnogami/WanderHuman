import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';

class MyDropdownMenuButton extends StatefulWidget {
  final List<String> items;
  final Icon icon;
  final String hintText;

  const MyDropdownMenuButton({
    super.key,
    required this.items,
    required this.hintText,
    this.icon = const Icon(Icons.info_outline_rounded, size: 32),
  });

  @override
  State<MyDropdownMenuButton> createState() => _MyDropdownMenuButtonState();
}

class _MyDropdownMenuButtonState extends State<MyDropdownMenuButton> {
  // List<String> items = ["No Role", "Admin", "Social Service", "Home Life"];
  String _selectedItem = "No Role";

  String get selectedItem => _selectedItem;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MyDimensionAdapter.getWidth(context) * 0.70,
      // height: MyDimensionAdapter.getHeight(context) * 0.2,
      child: DropdownButtonFormField<String>(
        dropdownColor: Colors.blue[50],
        hint: Text(widget.hintText),
        decoration: InputDecoration(
          icon: widget.icon,
          iconColor: Colors.blue.shade200,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              width: 2.5,
              color: const Color.fromARGB(255, 86, 168, 235),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              width: 1.5,
              color: const Color.fromARGB(255, 117, 182, 235),
            ),
          ),
        ),
        items: widget.items
            .map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            )
            .toList(),
        onChanged: (item) => setState(() {
          _selectedItem = item!;
        }),
      ),
    );
  }
}
