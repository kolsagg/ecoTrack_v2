import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class CreateReviewDialog extends StatefulWidget {
  final Function(int rating, String comment, bool isAnonymous) onSubmit;
  final int? initialRating;
  final String? initialComment;
  final bool isEdit;
  final bool showAnonymousOption;

  const CreateReviewDialog({
    super.key,
    required this.onSubmit,
    this.initialRating,
    this.initialComment,
    this.isEdit = false,
    this.showAnonymousOption = true,
  });

  @override
  State<CreateReviewDialog> createState() => _CreateReviewDialogState();
}

class _CreateReviewDialogState extends State<CreateReviewDialog> {
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 0;
    _commentController.text = widget.initialComment ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'Edit Review' : 'Write a Review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating section
            Text(
              'Rating',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (index) {
                  final starValue = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = starValue;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        _rating >= starValue ? Icons.star : Icons.star_border,
                        size: 32,
                        color: _rating >= starValue ? Colors.amber : Colors.grey[400],
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                if (_rating > 0)
                  Text(
                    _getRatingText(_rating),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Comment section
            Text(
              'Comment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppConstants.primaryColor),
                ),
              ),
            ),
            
            // Anonymous option
            if (widget.showAnonymousOption && !widget.isEdit) ...[
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value ?? false;
                  });
                },
                title: const Text('Post anonymously'),
                subtitle: const Text('Your name will not be shown with this review'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppConstants.primaryColor,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || _rating == 0 ? null : _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(widget.isEdit ? 'Update' : 'Submit'),
        ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  void _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      widget.onSubmit(_rating, _commentController.text.trim(), _isAnonymous);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEdit ? 'Review updated successfully!' : 'Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 