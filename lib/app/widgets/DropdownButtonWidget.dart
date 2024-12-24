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
  late String? selectedValue;
  List<String> convertedItems = [];

  @override
  void initState() {
    super.initState();
    convertedItems = widget.items.map((item) => item.toString()).toList();
    selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: widget.width ?? screenWidth * 0.9,
        height: 4 + widget.height!,
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            border: const OutlineInputBorder(),
            prefixIcon: widget.prefixIcon,
          ),
          value: selectedValue,
          isExpanded: true,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedValue = newValue;
              });
              widget.controller.text = newValue;
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
    );
  }
}
