import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class CustomDropdown extends StatefulWidget {
  final double? height;
  final double? width;
  final String label;
  final String hint;
  final Icon? prefixIcon;
  final String? value;
  final List<dynamic> items; // Accept List<dynamic>
  final TextEditingController controller;
  final ValueChanged<String>? onChanged; // Optional onChanged callback
  final bool disabled; // Optional disabled flag

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.hint,
    required this.items,
    this.height,
    this.width,
    this.prefixIcon,
    this.value,
    this.onChanged, // Optional
    this.disabled = false, // Default is false (enabled)
    required this.controller,
  }) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late String? selectedValue;
  List<String> convertedItems = [];
  final Logger logger = new Logger();

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
        child: IgnorePointer(
          ignoring:
              widget.disabled, // Disable interaction if widget.disabled is true
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              border: const OutlineInputBorder(),
              prefixIcon: widget.prefixIcon,
            ),
            value: selectedValue,
            isExpanded: true,
            onChanged: widget.disabled
                ? null // Ensure no action when disabled
                : (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedValue = newValue;
                      });
                      widget.controller.text = newValue;
                      if (widget.onChanged != null) {
                        widget.onChanged!(newValue);
                      }
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
    );
  }
}
