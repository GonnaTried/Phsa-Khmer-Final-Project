import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/app_constants.dart';
// Assuming AppColors is available

enum InputState { normal, error, success, focused }

class CustomInputBox extends StatefulWidget {
  // Appearance and Structure
  final String title;
  final String placeholder;
  final String description;
  final Icon? suffixIcon;

  // Validation and Behavior
  final bool obscureText;
  final TextInputType keyboardType;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  // Customization
  final Color baseBorderColor;
  final Color errorColor;
  final Color successColor;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final TextStyle errorTextStyle;

  const CustomInputBox({
    super.key,
    required this.title,
    this.placeholder = '',
    this.description = '',
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.baseBorderColor = AppColors.dividerColor,
    this.errorColor = AppColors.danger,
    this.successColor = AppColors.success,
    this.titleStyle = const TextStyle(
      fontSize: AppConstants.kTitleTextSize,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryLight,
    ),
    this.descriptionStyle = const TextStyle(
      fontSize: AppConstants.kSmallTextSize,
      color: AppColors.textSecondary,
    ),
    this.errorTextStyle = const TextStyle(
      fontSize: AppConstants.kSmallTextSize,
      color: AppColors.danger,
    ),
  });

  @override
  State<CustomInputBox> createState() => _CustomInputBoxState();
}

class _CustomInputBoxState extends State<CustomInputBox> {
  InputState _state = InputState.normal;
  String? _errorMessage;
  late final TextEditingController _internalController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _internalController =
        widget.controller ?? TextEditingController(text: widget.initialValue);

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      if (_focusNode.hasFocus && _state != InputState.error) {
        _state = InputState.focused;
      } else if (!_focusNode.hasFocus && _state == InputState.focused) {
        _state = InputState.normal;
      }
    });
  }

  Color _getBorderColor() {
    switch (_state) {
      case InputState.error:
        return widget.errorColor;
      case InputState.success:
        return widget.successColor;
      case InputState.focused:
        return AppColors.primaryColor;
      case InputState.normal:
      default:
        return widget.baseBorderColor;
    }
  }

  // Handles input validation and state update
  void _validateInput(String? value) {
    if (widget.validator != null) {
      final error = widget.validator!(value);
      setState(() {
        _errorMessage = error;
        if (error != null) {
          _state = InputState.error;
        } else if (value != null && value.isNotEmpty) {
          _state = InputState.success;
        } else {
          _state = InputState.normal;
        }
      });
    }
    widget.onChanged?.call(value ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor();

    Widget descriptionWidget;
    if (_errorMessage != null) {
      descriptionWidget = Text(_errorMessage!, style: widget.errorTextStyle);
    } else if (widget.description.isNotEmpty) {
      descriptionWidget = Text(
        widget.description,
        style: widget.descriptionStyle,
      );
    } else {
      descriptionWidget = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: widget.titleStyle),
          const SizedBox(height: 8.0),

          TextFormField(
            controller: _internalController,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            onChanged: _validateInput,
            onFieldSubmitted: widget.onSubmitted,
            autovalidateMode: AutovalidateMode.disabled,

            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),

            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: widget.descriptionStyle,

              suffixIcon: widget.suffixIcon,

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: _getBorderColor(), width: 2.0),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: widget.errorColor, width: 2.0),
              ),

              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: widget.errorColor, width: 2.0),
              ),
            ),
          ),

          if (widget.description.isNotEmpty || _errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: descriptionWidget,
            ),
        ],
      ),
    );
  }
}
