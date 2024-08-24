import 'package:flutter/material.dart';
import 'package:flutter/src/services/text_formatter.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.obscureText = false,
      this.enabled = true,
      this.suffixIcon,
        this.focusNode,
      this.padding,
        this.keyboardType,
        this.readOnly = false,
        this.onChanged,
      this.maxLines, this.inputFormatters});

  final TextEditingController controller;
  final String hintText;
  final bool obscureText, enabled;
  final EdgeInsets? padding;
  final int? maxLines;
  final bool readOnly;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines ?? 1,
      readOnly: readOnly,
      keyboardType: keyboardType,
      focusNode: focusNode,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: padding ??
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: suffixIcon),
    );
  }
}
