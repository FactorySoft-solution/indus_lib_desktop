import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final double? height;
  final double? width;
  final String label;
  final String hint;
  final Icon? prefixIcon;
  final String? value;
  final List<dynamic> items; // Accept List<dynamic>
  final TextEditingController controller;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.hint,
    required this.items,
    this.height,
    this.width,
    this.prefixIcon,
    this.value,
    required this.controller,
  }) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  List<String> convertedItems = []; // Initialize as an empty list

  @override
  void initState() {
    super.initState();
    convertedItems = widget.items.map((item) => item.toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: widget.width ?? screenWidth * 0.9,
        height: widget.height,
        child: InputDecorator(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            prefixIcon: widget.prefixIcon,
          ),
          isEmpty: widget.value == null || widget.value!.isEmpty,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.value,
              hint: Text(widget.hint),
              isExpanded: true,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  widget.controller.text =
                      newValue; // Update the controller value
                }
              },
              items: convertedItems.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
