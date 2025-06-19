import 'package:flutter/material.dart';

class RatingDisplay extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final bool showRatingText;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
    this.showRatingText = false,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Colors.amber;
    final greyColor = Colors.grey[300]!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stars
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            
            if (rating >= starValue) {
              // Full star
              return Icon(
                Icons.star,
                size: size,
                color: starColor,
              );
            } else if (rating >= starValue - 0.5) {
              // Half star
              return Icon(
                Icons.star_half,
                size: size,
                color: starColor,
              );
            } else {
              // Empty star
              return Icon(
                Icons.star_border,
                size: size,
                color: greyColor,
              );
            }
          }),
        ),
        
        // Rating text
        if (showRatingText) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ],
    );
  }
} 