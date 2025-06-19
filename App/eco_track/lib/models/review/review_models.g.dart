// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MerchantReviewCreateRequest _$MerchantReviewCreateRequestFromJson(
  Map<String, dynamic> json,
) => MerchantReviewCreateRequest(
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String,
  isAnonymous: json['is_anonymous'] as bool? ?? false,
);

Map<String, dynamic> _$MerchantReviewCreateRequestToJson(
  MerchantReviewCreateRequest instance,
) => <String, dynamic>{
  'rating': instance.rating,
  'comment': instance.comment,
  'is_anonymous': instance.isAnonymous,
};

MerchantReviewUpdateRequest _$MerchantReviewUpdateRequestFromJson(
  Map<String, dynamic> json,
) => MerchantReviewUpdateRequest(
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String,
);

Map<String, dynamic> _$MerchantReviewUpdateRequestToJson(
  MerchantReviewUpdateRequest instance,
) => <String, dynamic>{'rating': instance.rating, 'comment': instance.comment};

ReceiptReviewCreateRequest _$ReceiptReviewCreateRequestFromJson(
  Map<String, dynamic> json,
) => ReceiptReviewCreateRequest(
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String,
  reviewCategories: (json['review_categories'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ReceiptReviewCreateRequestToJson(
  ReceiptReviewCreateRequest instance,
) => <String, dynamic>{
  'rating': instance.rating,
  'comment': instance.comment,
  'review_categories': instance.reviewCategories,
};

AnonymousReceiptReviewCreateRequest
_$AnonymousReceiptReviewCreateRequestFromJson(Map<String, dynamic> json) =>
    AnonymousReceiptReviewCreateRequest(
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String,
      reviewerName: json['reviewer_name'] as String?,
      reviewCategories: (json['review_categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AnonymousReceiptReviewCreateRequestToJson(
  AnonymousReceiptReviewCreateRequest instance,
) => <String, dynamic>{
  'rating': instance.rating,
  'comment': instance.comment,
  'reviewer_name': instance.reviewerName,
  'review_categories': instance.reviewCategories,
};

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: json['id'] as String,
  userId: json['user_id'] as String?,
  merchantId: json['merchant_id'] as String?,
  receiptId: json['receipt_id'] as String?,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String,
  reviewerName: json['reviewer_name'] as String?,
  isAnonymous: json['is_anonymous'] as bool? ?? false,
  reviewCategories:
      (json['review_categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  helpfulCount: (json['helpful_count'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'merchant_id': instance.merchantId,
  'receipt_id': instance.receiptId,
  'rating': instance.rating,
  'comment': instance.comment,
  'reviewer_name': instance.reviewerName,
  'is_anonymous': instance.isAnonymous,
  'review_categories': instance.reviewCategories,
  'helpful_count': instance.helpfulCount,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

MerchantReviewsResponse _$MerchantReviewsResponseFromJson(
  Map<String, dynamic> json,
) => MerchantReviewsResponse(
  merchantRating: MerchantRatingResponse.fromJson(
    json['merchant_rating'] as Map<String, dynamic>,
  ),
  recentReviews:
      (json['recent_reviews'] as List<dynamic>?)
          ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  userReview: json['user_review'] == null
      ? null
      : Review.fromJson(json['user_review'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MerchantReviewsResponseToJson(
  MerchantReviewsResponse instance,
) => <String, dynamic>{
  'merchant_rating': instance.merchantRating,
  'recent_reviews': instance.recentReviews,
  'user_review': instance.userReview,
};

MerchantRatingResponse _$MerchantRatingResponseFromJson(
  Map<String, dynamic> json,
) => MerchantRatingResponse(
  merchantId: json['merchant_id'] as String? ?? '',
  merchantName: json['merchant_name'] as String? ?? '',
  averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
  totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
  ratingDistribution:
      (json['rating_distribution'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$MerchantRatingResponseToJson(
  MerchantRatingResponse instance,
) => <String, dynamic>{
  'merchant_id': instance.merchantId,
  'merchant_name': instance.merchantName,
  'average_rating': instance.averageRating,
  'total_reviews': instance.totalReviews,
  'rating_distribution': instance.ratingDistribution,
};

ReviewCategoriesResponse _$ReviewCategoriesResponseFromJson(
  Map<String, dynamic> json,
) => ReviewCategoriesResponse(
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$ReviewCategoriesResponseToJson(
  ReviewCategoriesResponse instance,
) => <String, dynamic>{'categories': instance.categories};

ReviewSuccessResponse _$ReviewSuccessResponseFromJson(
  Map<String, dynamic> json,
) => ReviewSuccessResponse(
  message: json['message'] as String? ?? '',
  review: json['review'] == null
      ? null
      : Review.fromJson(json['review'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReviewSuccessResponseToJson(
  ReviewSuccessResponse instance,
) => <String, dynamic>{'message': instance.message, 'review': instance.review};
