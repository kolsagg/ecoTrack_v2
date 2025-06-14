import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final Color? overlayColor;
  final Color? indicatorColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.overlayColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? AppConstants.overlayColor,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      indicatorColor ?? AppConstants.primaryColor,
                    ),
                  ),
                  if (loadingText != null) ...[
                    const SizedBox(height: AppConstants.spacingMedium),
                    Text(
                      loadingText!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.textOnPrimaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
} 