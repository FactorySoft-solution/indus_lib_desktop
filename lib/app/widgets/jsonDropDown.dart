import 'package:code_g/app/widgets/DropdownButtonWidget.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class JsonDropDown extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Future<List<dynamic>> future;
  final String Function(dynamic) keyExtractor;
  final double width;
  final double height;

  final ValueChanged<String>? onChanged; // Optional onChanged callback
  final bool disabled; // Optional disabled flag
  const JsonDropDown({
    required this.label,
    required this.hint,
    required this.controller,
    required this.future,
    required this.keyExtractor,
    required this.width,
    required this.height,
    this.onChanged, // Optional
    this.disabled = false, // Default is false (enabled)
    super.key,
  });

  @override
  State<JsonDropDown> createState() => _JsonDropDownState();
}

class _JsonDropDownState extends State<JsonDropDown> {
  final Logger logger = Logger();
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      logger.e(
          "onChanged: ${widget.onChanged?.toString() ?? 'onChanged is null'}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No data available');
        }

        final value = widget.controller.text;
        final items = snapshot.data!.map(widget.keyExtractor).toList();

        return CustomDropdown(
          controller: widget.controller,
          value: value.isEmpty ? null : value,
          items: items,
          label: widget.label,
          hint: value.isEmpty ? widget.hint : value,
          width: widget.width,
          height: widget.height,
          onChanged: widget.onChanged, // Pass the onChanged callback
          disabled: widget.disabled, // Pass the disabled flag
        );
      },
    );
  }
}
