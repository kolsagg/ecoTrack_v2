import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/dependency_injection.dart';
import '../models/review/review_models.dart';
import '../services/review_service.dart';

// Merchant Reviews State
class MerchantReviewsState {
  final MerchantReviewsResponse? reviewsResponse;
  final bool isLoading;
  final String? error;

  const MerchantReviewsState({
    this.reviewsResponse,
    this.isLoading = false,
    this.error,
  });

  MerchantReviewsState copyWith({
    MerchantReviewsResponse? reviewsResponse,
    bool? isLoading,
    String? error,
  }) {
    return MerchantReviewsState(
      reviewsResponse: reviewsResponse ?? this.reviewsResponse,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Merchant Reviews Notifier
class MerchantReviewsNotifier extends StateNotifier<MerchantReviewsState> {
  final ReviewService _reviewService;

  MerchantReviewsNotifier(this._reviewService)
    : super(const MerchantReviewsState());

  Future<void> loadMerchantReviews(
    String merchantId, {
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final reviewsResponse = await _reviewService.getMerchantReviews(
        merchantId,
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      state = state.copyWith(
        reviewsResponse: reviewsResponse,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createMerchantReview(
    String merchantId,
    MerchantReviewCreateRequest request,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _reviewService.createMerchantReview(merchantId, request);

      // Reload reviews after creating
      await loadMerchantReviews(merchantId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateReview(
    String reviewId,
    MerchantReviewUpdateRequest request,
    String merchantId,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _reviewService.updateReview(reviewId, request);

      // Reload reviews after updating
      await loadMerchantReviews(merchantId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteReview(String reviewId, String merchantId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _reviewService.deleteReview(reviewId);

      // Reload reviews after deleting
      await loadMerchantReviews(merchantId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markReviewAsHelpful(String reviewId, String merchantId) async {
    try {
      await _reviewService.markReviewAsHelpful(reviewId);

      // Reload reviews to update helpful count
      await loadMerchantReviews(merchantId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const MerchantReviewsState();
  }
}

// Merchant Rating State
class MerchantRatingState {
  final MerchantRatingResponse? rating;
  final bool isLoading;
  final String? error;

  const MerchantRatingState({this.rating, this.isLoading = false, this.error});

  MerchantRatingState copyWith({
    MerchantRatingResponse? rating,
    bool? isLoading,
    String? error,
  }) {
    return MerchantRatingState(
      rating: rating ?? this.rating,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Merchant Rating Notifier
class MerchantRatingNotifier extends StateNotifier<MerchantRatingState> {
  final ReviewService _reviewService;

  MerchantRatingNotifier(this._reviewService)
    : super(const MerchantRatingState());

  Future<void> loadMerchantRating(String merchantId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final rating = await _reviewService.getMerchantRating(merchantId);

      state = state.copyWith(rating: rating, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const MerchantRatingState();
  }
}

// Receipt Review State
class ReceiptReviewState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const ReceiptReviewState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  ReceiptReviewState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return ReceiptReviewState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

// Receipt Review Notifier
class ReceiptReviewNotifier extends StateNotifier<ReceiptReviewState> {
  final ReviewService _reviewService;

  ReceiptReviewNotifier(this._reviewService)
    : super(const ReceiptReviewState());

  Future<void> createReceiptReview(
    String receiptId,
    ReceiptReviewCreateRequest request,
  ) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        successMessage: null,
      );

      final response = await _reviewService.createReceiptReview(
        receiptId,
        request,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: response.message,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createAnonymousReceiptReview(
    String receiptId,
    AnonymousReceiptReviewCreateRequest request,
  ) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        successMessage: null,
      );

      final response = await _reviewService.createAnonymousReceiptReview(
        receiptId,
        request,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: response.message,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  void reset() {
    state = const ReceiptReviewState();
  }
}

// Review Categories State
class ReviewCategoriesState {
  final List<String> categories;
  final bool isLoading;
  final String? error;

  const ReviewCategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  ReviewCategoriesState copyWith({
    List<String>? categories,
    bool? isLoading,
    String? error,
  }) {
    return ReviewCategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Review Categories Notifier
class ReviewCategoriesNotifier extends StateNotifier<ReviewCategoriesState> {
  final ReviewService _reviewService;

  ReviewCategoriesNotifier(this._reviewService)
    : super(const ReviewCategoriesState());

  Future<void> loadReviewCategories() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _reviewService.getReviewCategories();

      state = state.copyWith(categories: response.categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const ReviewCategoriesState();
  }
}

// User Reviews State
class UserReviewsState {
  final List<Review> reviews;
  final bool isLoading;
  final String? error;

  const UserReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
  });

  UserReviewsState copyWith({
    List<Review>? reviews,
    bool? isLoading,
    String? error,
  }) {
    return UserReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// User Reviews Notifier
class UserReviewsNotifier extends StateNotifier<UserReviewsState> {
  final ReviewService _reviewService;

  UserReviewsNotifier(this._reviewService) : super(const UserReviewsState());

  Future<void> loadUserReviews({
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final reviews = await _reviewService.getUserReviews(
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      state = state.copyWith(reviews: reviews, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateReview(
    String reviewId,
    MerchantReviewUpdateRequest request,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _reviewService.updateReview(reviewId, request);

      // Reload reviews after updating
      await loadUserReviews();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _reviewService.deleteReview(reviewId);

      // Reload reviews after deleting
      await loadUserReviews();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markReviewAsHelpful(String reviewId) async {
    try {
      await _reviewService.markReviewAsHelpful(reviewId);

      // Reload reviews to update helpful count
      await loadUserReviews();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const UserReviewsState();
  }
}

// Providers
final reviewServiceProvider = Provider<ReviewService>((ref) {
  return getIt<ReviewService>();
});

final merchantReviewsProvider =
    StateNotifierProvider<MerchantReviewsNotifier, MerchantReviewsState>((ref) {
      final reviewService = ref.watch(reviewServiceProvider);
      return MerchantReviewsNotifier(reviewService);
    });

final merchantRatingProvider =
    StateNotifierProvider<MerchantRatingNotifier, MerchantRatingState>((ref) {
      final reviewService = ref.watch(reviewServiceProvider);
      return MerchantRatingNotifier(reviewService);
    });

final receiptReviewProvider =
    StateNotifierProvider<ReceiptReviewNotifier, ReceiptReviewState>((ref) {
      final reviewService = ref.watch(reviewServiceProvider);
      return ReceiptReviewNotifier(reviewService);
    });

final reviewCategoriesProvider =
    StateNotifierProvider<ReviewCategoriesNotifier, ReviewCategoriesState>((
      ref,
    ) {
      final reviewService = ref.watch(reviewServiceProvider);
      return ReviewCategoriesNotifier(reviewService);
    });

final userReviewsProvider =
    StateNotifierProvider<UserReviewsNotifier, UserReviewsState>((ref) {
      final reviewService = ref.watch(reviewServiceProvider);
      return UserReviewsNotifier(reviewService);
    });
