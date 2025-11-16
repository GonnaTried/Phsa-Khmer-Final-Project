import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  final TextInputType inputType;
  final int maxLines;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.validator,
    required this.onSaved,
    this.inputType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: AppColors.blueGrey, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
        keyboardType: inputType,
        maxLines: maxLines,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
