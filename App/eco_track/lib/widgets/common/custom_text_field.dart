import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? initialValue;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onSubmitted;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final String? errorText;
  final bool autofocus;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.initialValue,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.focusNode,
    this.errorText,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppConstants.textPrimaryColor,
              fontWeight: AppConstants.fontWeightMedium,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXSmall),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          onFieldSubmitted: onSubmitted,
          readOnly: readOnly,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          autofocus: autofocus,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppConstants.textPrimaryColor,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppConstants.textHintColor,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: AppConstants.textSecondaryColor,
                    size: AppConstants.iconSizeMedium,
                  )
                : null,
            suffixIcon: suffixIcon,
            errorText: errorText,
            filled: true,
            fillColor: AppConstants.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              borderSide: BorderSide(
                color: AppConstants.dividerColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              borderSide: BorderSide(
                color: AppConstants.dividerColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              borderSide: BorderSide(
                color: AppConstants.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              borderSide: BorderSide(
                color: AppConstants.errorColor,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              borderSide: BorderSide(
                color: AppConstants.errorColor,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              borderSide: BorderSide(
                color: AppConstants.disabledColor,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMedium,
              vertical: AppConstants.spacingMedium,
            ),
          ),
        ),
      ],
    );
  }
} 