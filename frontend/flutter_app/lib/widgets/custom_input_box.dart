import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/app_constants.dart';
// Assuming AppColors is available

enum InputState { normal, error, success, focused, disabled }

class CustomInputBox extends StatefulWidget {
  // Appearance and Structure
  final String title;
  final String placeholder;
  final String description;
  final Icon? suffixIcon;

  // Behavior and State
  final bool obscureText;
  final TextInputType keyboardType;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled; // New property for disabling the input

  // Customization
  final Color baseBorderColor;
  final Color errorColor;
  final Color successColor;
  final Color disabledFillColor; // New property for disabled state
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final TextStyle errorTextStyle;

  const CustomInputBox({
    super.key,
    this.title = '',
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
    this.enabled = true,
    this.baseBorderColor = AppColors.dividerColor,
    this.errorColor = AppColors.danger,
    this.successColor = AppColors.success,
    this.disabledFillColor = AppColors.dividerColor,
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
    _updateStateBasedOnEnabled();
  }

  @override
  void didUpdateWidget(covariant CustomInputBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _updateStateBasedOnEnabled();
    }
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

  void _updateStateBasedOnEnabled() {
    if (!widget.enabled) {
      setState(() {
        _state = InputState.disabled;
        // Ensure focus is removed when disabled
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      });
    } else if (_state == InputState.disabled) {
      // Revert to normal if enabled again
      setState(() {
        _state = InputState.normal;
      });
    }
  }

  void _onFocusChange() {
    if (!widget.enabled) return;

    setState(() {
      if (_focusNode.hasFocus && _state != InputState.error) {
        _state = InputState.focused;
      } else if (!_focusNode.hasFocus && _state == InputState.focused) {
        // Only revert to normal if there is no current error
        if (_errorMessage == null) {
          _state = InputState.normal;
        } else {
          // If there's an error, stay in error state
          _state = InputState.error;
        }
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
      case InputState.disabled:
        // Use a less prominent border for disabled state
        return AppColors.dividerColor.withOpacity(0.5);
      case InputState.normal:
      default:
        return widget.baseBorderColor;
    }
  }

  Color? _getFillColor() {
    return _state == InputState.disabled ? widget.disabledFillColor : null;
  }

  // Handles input validation and state update
  void _validateInput(String? value) {
    if (!widget.enabled) return;

    if (widget.validator != null) {
      final error = widget.validator!(value);
      setState(() {
        _errorMessage = error;
        if (error != null) {
          _state = InputState.error;
        } else if (value != null && value.isNotEmpty) {
          _state = InputState.success;
        } else {
          // If empty, revert to normal (unless focused)
          _state = _focusNode.hasFocus ? InputState.focused : InputState.normal;
        }
      });
    }
    widget.onChanged?.call(value ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor();
    final isError = _errorMessage != null && _state == InputState.error;

    Widget descriptionWidget;
    if (isError) {
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
          widget.title.isEmpty
              ? const SizedBox.shrink()
              : Text(widget.title, style: widget.titleStyle),
          const SizedBox(height: 8.0),

          TextFormField(
            controller: _internalController,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            onChanged: widget.enabled ? _validateInput : null,
            onFieldSubmitted: widget.enabled ? widget.onSubmitted : null,
            autovalidateMode: AutovalidateMode.disabled,
            enabled: widget.enabled, // Set enabled state

            style: TextStyle(
              fontSize: 16,
              color: widget.enabled
                  ? AppColors.textPrimary
                  : AppColors.textSecondary.withOpacity(0.7),
            ),

            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: widget.descriptionStyle,
              suffixIcon: widget.suffixIcon,
              filled: _getFillColor() != null,
              fillColor: _getFillColor(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),

              // Standard Enabled Border
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),

              // Focused Border
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: _getBorderColor(), width: 2.0),
              ),

              // Disabled Border
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                // Disabled border uses base border color (or custom disabled color)
                borderSide: BorderSide(
                  color: _getBorderColor(),
                  width: _state == InputState.disabled ? 1.0 : 1.5,
                ),
              ),

              // Error Borders (only triggered if TextFormField's validation was used,
              // but we manage error state manually. We include them for completeness
              // in case the internal error handling is later enabled, or for visual consistency).
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: widget.errorColor, width: 2.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: widget.errorColor, width: 2.0),
              ),
              // We explicitly set helperText/errorText to null because we display the message externally
              helperText: null,
              errorText: null,
            ),
          ),

          if (widget.description.isNotEmpty || isError)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: descriptionWidget,
            ),
        ],
      ),
    );
  }
}
