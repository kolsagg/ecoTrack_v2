import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? 
        (isOutlined ? Colors.transparent : AppConstants.primaryColor);
    final effectiveTextColor = textColor ?? 
        (isOutlined ? AppConstants.primaryColor : AppConstants.textOnPrimaryColor);
    final effectiveHeight = height ?? AppConstants.buttonHeightLarge;

    return SizedBox(
      width: width,
      height: effectiveHeight,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppConstants.primaryColor,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                ),
              ),
              child: _buildButtonContent(effectiveTextColor),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: effectiveBackgroundColor,
                foregroundColor: effectiveTextColor,
                elevation: AppConstants.elevationMedium,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                ),
              ),
              child: _buildButtonContent(effectiveTextColor),
            ),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppConstants.iconSizeMedium,
            color: textColor,
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize ?? AppConstants.fontSizeRegular,
              fontWeight: fontWeight ?? AppConstants.fontWeightSemiBold,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize ?? AppConstants.fontSizeRegular,
        fontWeight: fontWeight ?? AppConstants.fontWeightSemiBold,
      ),
    );
  }
} 