import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../models/review/review_models.dart';
import 'rating_display.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final bool showActions;
  final bool showMerchantName;

  const ReviewCard({
    super.key,
    required this.review,
    this.showActions = true,
    this.showMerchantName = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with rating and date
            Row(
              children: [
                RatingDisplay(rating: review.rating.toDouble(), size: 18),
                const Spacer(),
                Text(
                  _formatDate(review.createdAt),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Reviewer info
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    review.isAnonymous ? Icons.person_outline : Icons.person,
                    size: 18,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.isAnonymous
                            ? (review.reviewerName ?? 'Anonymous')
                            : (review.reviewerName ?? 'User'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (review.isAnonymous)
                        Text(
                          'Anonymous Review',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      // Merchant name (for user's reviews)
                      if (showMerchantName && review.merchantId != null)
                        Text(
                          'Merchant ID: ${review.merchantId}', // TODO: Merchant name'i göster
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Review comment
            if (review.comment.isNotEmpty)
              Text(
                review.comment,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

            // Review categories
            if (review.reviewCategories.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: review.reviewCategories.map((category) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppConstants.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Updated indicator
            if (review.updatedAt != null &&
                review.updatedAt!.isAfter(
                  review.createdAt.add(const Duration(minutes: 1)),
                ))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Updated ${_formatDate(review.updatedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }
}
