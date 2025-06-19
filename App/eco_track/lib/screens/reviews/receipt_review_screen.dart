import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../models/review/review_models.dart';
import '../../providers/review_provider.dart';
import '../../widgets/common/loading_overlay.dart';

class ReceiptReviewScreen extends ConsumerStatefulWidget {
  final String receiptId;
  final String merchantName;
  final bool allowAnonymous;

  const ReceiptReviewScreen({
    super.key,
    required this.receiptId,
    required this.merchantName,
    this.allowAnonymous = true,
  });

  @override
  ConsumerState<ReceiptReviewScreen> createState() =>
      _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends ConsumerState<ReceiptReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _reviewerNameController = TextEditingController();

  int _rating = 0;
  bool _isAnonymous = false;
  final List<String> _selectedCategories = [];
  List<String> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviewCategories();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _reviewerNameController.dispose();
    super.dispose();
  }

  void _loadReviewCategories() {
    ref.read(reviewCategoriesProvider.notifier).loadReviewCategories();
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(receiptReviewProvider);
    final categoriesState = ref.watch(reviewCategoriesProvider);

    // Update available categories when loaded
    if (categoriesState.categories.isNotEmpty && _availableCategories.isEmpty) {
      _availableCategories = categoriesState.categories;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Review'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: LoadingOverlay(
        isLoading: reviewState.isLoading,
        loadingText: 'Submitting review...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Merchant info card
                _buildMerchantInfoCard(),

                const SizedBox(height: 24),

                // Rating section
                _buildRatingSection(),

                const SizedBox(height: 24),

                // Comment section
                _buildCommentSection(),

                const SizedBox(height: 24),

                // Categories section
                if (_availableCategories.isNotEmpty) _buildCategoriesSection(),

                const SizedBox(height: 24),

                // Anonymous option
                if (widget.allowAnonymous) _buildAnonymousSection(),

                const SizedBox(height: 32),

                // Submit button
                _buildSubmitButton(),

                // Error display
                if (reviewState.error != null)
                  _buildErrorCard(reviewState.error!),

                // Success display
                if (reviewState.successMessage != null)
                  _buildSuccessCard(reviewState.successMessage!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMerchantInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.store,
                color: AppConstants.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.merchantName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Share your experience with this merchant',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Rating *',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
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
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    _rating >= starValue ? Icons.star : Icons.star_border,
                    size: 40,
                    color: _rating >= starValue
                        ? Colors.amber
                        : Colors.grey[400],
                  ),
                ),
              );
            }),
            const SizedBox(width: 16),
            if (_rating > 0)
              Text(
                _getRatingText(_rating),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        if (_rating == 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select a rating',
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Review',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _commentController,
          maxLines: 5,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Tell others about your experience...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppConstants.primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please write a review';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Categories (Optional)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Select categories that best describe your experience',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableCategories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
              selectedColor: AppConstants.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppConstants.primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppConstants.primaryColor
                    : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAnonymousSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        // Anonymous reviewer name field
        if (_isAnonymous) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _reviewerNameController,
            decoration: InputDecoration(
              labelText: 'Display Name (Optional)',
              hintText: 'How would you like to be shown?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppConstants.primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _rating > 0 ? _submitReview : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Submit Review',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard(String message) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.green[700], fontSize: 14),
            ),
          ),
        ],
      ),
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
    if (!_formKey.currentState!.validate() || _rating == 0) {
      return;
    }

    if (_isAnonymous) {
      final request = AnonymousReceiptReviewCreateRequest(
        rating: _rating,
        comment: _commentController.text.trim(),
        reviewerName: _reviewerNameController.text.trim().isEmpty
            ? null
            : _reviewerNameController.text.trim(),
        reviewCategories: _selectedCategories.isEmpty
            ? null
            : _selectedCategories,
      );

      await ref
          .read(receiptReviewProvider.notifier)
          .createAnonymousReceiptReview(widget.receiptId, request);
    } else {
      final request = ReceiptReviewCreateRequest(
        rating: _rating,
        comment: _commentController.text.trim(),
        reviewCategories: _selectedCategories.isEmpty
            ? null
            : _selectedCategories,
      );

      await ref
          .read(receiptReviewProvider.notifier)
          .createReceiptReview(widget.receiptId, request);
    }

    // Navigate back on success
    final state = ref.read(receiptReviewProvider);
    if (state.successMessage != null && mounted) {
      Navigator.of(context).pop(true); // Return true to indicate success
    }
  }
}
