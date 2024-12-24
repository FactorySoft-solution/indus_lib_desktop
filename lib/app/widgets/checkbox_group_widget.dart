import 'package:flutter/material.dart';

class CheckboxGroupWidget extends StatefulWidget {
  final List<String> items; // List of checkbox items
  final TextEditingController controller; // Controller for selected items
  final double spacing; // Spacing between checkboxes

  const CheckboxGroupWidget({
    Key? key,
    required this.items,
    required this.controller,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  _CheckboxGroupWidgetState createState() => _CheckboxGroupWidgetState();
}

class _CheckboxGroupWidgetState extends State<CheckboxGroupWidget> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.controller.text.isNotEmpty
        ? widget.controller.text.split(', ')
        : [];
  }

  void _onItemChanged(bool? isSelected, String item) {
    setState(() {
      if (isSelected == true) {
        _selectedItems.add(item);
      } else {
        _selectedItems.remove(item);
      }
      widget.controller.text = _selectedItems.join(', ');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      spacing: widget.spacing,
      children: widget.items.map((item) {
        final bool isSelected = _selectedItems.contains(item);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (bool? isSelected) {
                _onItemChanged(isSelected, item);
              },
            ),
            Text(item),
          ],
        );
      }).toList(),
    );
  }
}
