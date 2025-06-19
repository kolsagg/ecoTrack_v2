import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../models/review/review_models.dart';
import '../../providers/review_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/reviews/review_card.dart';
import '../../widgets/reviews/create_review_dialog.dart';

class MyReviewsScreen extends ConsumerStatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  ConsumerState<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends ConsumerState<MyReviewsScreen> {
  final ScrollController _scrollController = ScrollController();
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    print('🔍 Loading user reviews');
    // Şimdilik mock data ile test edelim
    ref
        .read(userReviewsProvider.notifier)
        .loadUserReviews(sortBy: _sortBy, sortOrder: _sortOrder);
  }

  @override
  Widget build(BuildContext context) {
    final reviewsState = ref.watch(userReviewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showSortOptions,
            icon: const Icon(Icons.sort),
            tooltip: 'Sort Reviews',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: reviewsState.isLoading,
        loadingText: 'Loading reviews...',
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Error State
              if (reviewsState.error != null)
                SliverToBoxAdapter(child: _buildErrorCard(reviewsState.error!)),

              // Reviews List
              if (reviewsState.reviews.isNotEmpty)
                _buildReviewsList(reviewsState.reviews)
              else if (!reviewsState.isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No reviews yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start reviewing merchants to see them here!',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsList(List<Review> reviews) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final review = reviews[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ReviewCard(
            review: review,
            showMerchantName: true,
          ),
        );
      }, childCount: reviews.length),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      margin: const EdgeInsets.all(16),
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

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort Reviews',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Newest First'),
              leading: Radio<String>(
                value: 'created_at_desc',
                groupValue: '${_sortBy}_$_sortOrder',
                onChanged: (value) => _updateSort('created_at', 'desc'),
              ),
              onTap: () => _updateSort('created_at', 'desc'),
            ),
            ListTile(
              title: const Text('Oldest First'),
              leading: Radio<String>(
                value: 'created_at_asc',
                groupValue: '${_sortBy}_$_sortOrder',
                onChanged: (value) => _updateSort('created_at', 'asc'),
              ),
              onTap: () => _updateSort('created_at', 'asc'),
            ),
            ListTile(
              title: const Text('Highest Rating'),
              leading: Radio<String>(
                value: 'rating_desc',
                groupValue: '${_sortBy}_$_sortOrder',
                onChanged: (value) => _updateSort('rating', 'desc'),
              ),
              onTap: () => _updateSort('rating', 'desc'),
            ),
            ListTile(
              title: const Text('Lowest Rating'),
              leading: Radio<String>(
                value: 'rating_asc',
                groupValue: '${_sortBy}_$_sortOrder',
                onChanged: (value) => _updateSort('rating', 'asc'),
              ),
              onTap: () => _updateSort('rating', 'asc'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateSort(String sortBy, String sortOrder) {
    setState(() {
      _sortBy = sortBy;
      _sortOrder = sortOrder;
    });
    Navigator.of(context).pop();
    _loadData();
  }

  void _showEditReviewDialog(Review review) {
    showDialog(
      context: context,
      builder: (context) => CreateReviewDialog(
        initialRating: review.rating,
        initialComment: review.comment,
        isEdit: true,
        onSubmit: (rating, comment, _) {
          final request = MerchantReviewUpdateRequest(
            rating: rating,
            comment: comment,
          );
          ref
              .read(userReviewsProvider.notifier)
              .updateReview(review.id, request);
        },
      ),
    );
  }

  void _showDeleteConfirmation(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text(
          'Are you sure you want to delete this review? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(userReviewsProvider.notifier).deleteReview(review.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
