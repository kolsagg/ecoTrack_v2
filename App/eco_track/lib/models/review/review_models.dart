import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_models.g.dart';

// Merchant Review Create Request
@JsonSerializable()
class MerchantReviewCreateRequest extends Equatable {
  final int rating;
  final String comment;
  @JsonKey(name: 'is_anonymous')
  final bool isAnonymous;

  const MerchantReviewCreateRequest({
    required this.rating,
    required this.comment,
    this.isAnonymous = false,
  });

  factory MerchantReviewCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$MerchantReviewCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$MerchantReviewCreateRequestToJson(this);

  @override
  List<Object?> get props => [rating, comment, isAnonymous];
}

// Merchant Review Update Request
@JsonSerializable()
class MerchantReviewUpdateRequest extends Equatable {
  final int rating;
  final String comment;

  const MerchantReviewUpdateRequest({
    required this.rating,
    required this.comment,
  });

  factory MerchantReviewUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$MerchantReviewUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$MerchantReviewUpdateRequestToJson(this);

  @override
  List<Object?> get props => [rating, comment];
}

// Receipt Review Create Request (Authenticated)
@JsonSerializable()
class ReceiptReviewCreateRequest extends Equatable {
  final int rating;
  final String comment;
  @JsonKey(name: 'review_categories')
  final List<String>? reviewCategories;

  const ReceiptReviewCreateRequest({
    required this.rating,
    required this.comment,
    this.reviewCategories,
  });

  factory ReceiptReviewCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ReceiptReviewCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ReceiptReviewCreateRequestToJson(this);

  @override
  List<Object?> get props => [rating, comment, reviewCategories];
}

// Receipt Review Create Request (Anonymous)
@JsonSerializable()
class AnonymousReceiptReviewCreateRequest extends Equatable {
  final int rating;
  final String comment;
  @JsonKey(name: 'reviewer_name')
  final String? reviewerName;
  @JsonKey(name: 'review_categories')
  final List<String>? reviewCategories;

  const AnonymousReceiptReviewCreateRequest({
    required this.rating,
    required this.comment,
    this.reviewerName,
    this.reviewCategories,
  });

  factory AnonymousReceiptReviewCreateRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$AnonymousReceiptReviewCreateRequestFromJson(json);
  Map<String, dynamic> toJson() =>
      _$AnonymousReceiptReviewCreateRequestToJson(this);

  @override
  List<Object?> get props => [rating, comment, reviewerName, reviewCategories];
}

// Review Response
@JsonSerializable()
class Review extends Equatable {
  final String id;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'merchant_id')
  final String? merchantId;
  @JsonKey(name: 'receipt_id')
  final String? receiptId;
  final int rating;
  final String comment;
  @JsonKey(name: 'reviewer_name')
  final String? reviewerName;
  @JsonKey(name: 'is_anonymous')
  final bool isAnonymous;
  @JsonKey(name: 'review_categories')
  final List<String> reviewCategories;
  @JsonKey(name: 'helpful_count')
  final int helpfulCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const Review({
    required this.id,
    this.userId,
    this.merchantId,
    this.receiptId,
    required this.rating,
    required this.comment,
    this.reviewerName,
    this.isAnonymous = false,
    this.reviewCategories = const [],
    this.helpfulCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    try {
      return Review(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String?,
        merchantId: json['merchant_id'] as String?,
        receiptId: json['receipt_id'] as String?,
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        comment: json['comment'] as String? ?? '',
        reviewerName: json['reviewer_name'] as String?,
        isAnonymous: json['is_anonymous'] as bool? ?? false,
        reviewCategories:
            (json['review_categories'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            [],
        helpfulCount: (json['helpful_count'] as num?)?.toInt() ?? 0,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );
    } catch (e) {
      print('❌ Error parsing Review: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  @override
  List<Object?> get props => [
    id,
    userId,
    merchantId,
    receiptId,
    rating,
    comment,
    reviewerName,
    isAnonymous,
    reviewCategories,
    helpfulCount,
    createdAt,
    updatedAt,
  ];
}

// Merchant Reviews Response
@JsonSerializable()
class MerchantReviewsResponse extends Equatable {
  @JsonKey(name: 'merchant_rating')
  final MerchantRatingResponse merchantRating;
  @JsonKey(name: 'recent_reviews')
  final List<Review> recentReviews;
  @JsonKey(name: 'user_review')
  final Review? userReview;

  const MerchantReviewsResponse({
    required this.merchantRating,
    this.recentReviews = const [],
    this.userReview,
  });

  // Backward compatibility için reviews getter'ı
  List<Review> get reviews => recentReviews;
  int get totalCount => merchantRating.totalReviews;
  double get averageRating => merchantRating.averageRating;
  Map<String, int> get ratingDistribution => merchantRating.ratingDistribution;

  factory MerchantReviewsResponse.fromJson(Map<String, dynamic> json) {
    try {
      return MerchantReviewsResponse(
        merchantRating: MerchantRatingResponse.fromJson(
          json['merchant_rating'] as Map<String, dynamic>? ?? {},
        ),
        recentReviews:
            (json['recent_reviews'] as List<dynamic>?)
                ?.map((item) => Review.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [],
        userReview: json['user_review'] != null
            ? Review.fromJson(json['user_review'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('❌ Error parsing MerchantReviewsResponse: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$MerchantReviewsResponseToJson(this);

  @override
  List<Object?> get props => [merchantRating, recentReviews, userReview];
}

// Merchant Rating Response
@JsonSerializable()
class MerchantRatingResponse extends Equatable {
  @JsonKey(name: 'merchant_id')
  final String merchantId;
  @JsonKey(name: 'merchant_name')
  final String merchantName;
  @JsonKey(name: 'average_rating')
  final double averageRating;
  @JsonKey(name: 'total_reviews')
  final int totalReviews;
  @JsonKey(name: 'rating_distribution')
  final Map<String, int> ratingDistribution;

  const MerchantRatingResponse({
    this.merchantId = '',
    this.merchantName = '',
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.ratingDistribution = const {},
  });

  factory MerchantRatingResponse.fromJson(Map<String, dynamic> json) {
    try {
      return MerchantRatingResponse(
        merchantId: json['merchant_id'] as String? ?? '',
        merchantName: json['merchant_name'] as String? ?? '',
        averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
        ratingDistribution:
            (json['rating_distribution'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, (value as num).toInt()),
            ) ??
            {},
      );
    } catch (e) {
      print('❌ Error parsing MerchantRatingResponse: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$MerchantRatingResponseToJson(this);

  @override
  List<Object?> get props => [
    merchantId,
    merchantName,
    averageRating,
    totalReviews,
    ratingDistribution,
  ];
}

// Review Categories Response
@JsonSerializable()
class ReviewCategoriesResponse extends Equatable {
  final List<String> categories;

  const ReviewCategoriesResponse({this.categories = const []});

  factory ReviewCategoriesResponse.fromJson(Map<String, dynamic> json) {
    try {
      return ReviewCategoriesResponse(
        categories:
            (json['categories'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            [],
      );
    } catch (e) {
      print('❌ Error parsing ReviewCategoriesResponse: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$ReviewCategoriesResponseToJson(this);

  @override
  List<Object?> get props => [categories];
}

// Review Success Response
@JsonSerializable()
class ReviewSuccessResponse extends Equatable {
  final String message;
  final Review? review;

  const ReviewSuccessResponse({this.message = '', this.review});

  factory ReviewSuccessResponse.fromJson(Map<String, dynamic> json) {
    try {
      return ReviewSuccessResponse(
        message: json['message'] as String? ?? '',
        review: json['review'] != null
            ? Review.fromJson(json['review'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('❌ Error parsing ReviewSuccessResponse: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$ReviewSuccessResponseToJson(this);

  @override
  List<Object?> get props => [message, review];
}
