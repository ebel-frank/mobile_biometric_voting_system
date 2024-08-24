import 'package:flutter/material.dart';

class CustomDropDown extends StatefulWidget {
  final List menuEntries;
  final bool enabled, isExpanded;
  final Function(String) onSelected;

  const CustomDropDown(
      {super.key,
      this.enabled = true,
      this.isExpanded = true,
      required this.menuEntries,
      required this.onSelected});

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  String value = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // Adjust border radius to get the desired roundness
        border: Border.all(
          color: Colors.grey, // Adjust the color of the border
          width: 1.5, // Adjust the width of the border
        ),
      ),
      child: DropdownButtonHideUnderline(
          child: DropdownButton(
        isExpanded: widget.isExpanded,
        value: value.isNotEmpty
            ? value
            : widget.menuEntries.isNotEmpty
                ? widget.menuEntries[0]
                : "",
        items: widget.menuEntries
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: theme.bodyMedium,
                  ),
                ))
            .toList(),
        onChanged: widget.enabled
            ? (value) {
                setState(() {
                  this.value = value.toString();
                });
                widget.onSelected(value.toString());
              }
            : null,
      )),
    );
  }
}
