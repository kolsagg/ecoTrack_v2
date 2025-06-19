import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/merchant/merchant_models.dart';
import '../services/merchant_service.dart';
import '../core/utils/dependency_injection.dart';

// Merchant Search State
class MerchantSearchState {
  final List<Merchant> merchants;
  final bool isLoading;
  final String? error;
  final String? searchQuery;

  const MerchantSearchState({
    this.merchants = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
  });

  MerchantSearchState copyWith({
    List<Merchant>? merchants,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return MerchantSearchState(
      merchants: merchants ?? this.merchants,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Merchant Search Notifier
class MerchantSearchNotifier extends StateNotifier<MerchantSearchState> {
  final MerchantService _merchantService;

  MerchantSearchNotifier(this._merchantService)
    : super(const MerchantSearchState());

  // Search merchants for autocomplete
  Future<void> searchMerchants(String query) async {
    if (query.trim().isEmpty) {
      state = const MerchantSearchState();
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null, searchQuery: query);

      final response = await _merchantService.getMerchants(
        search: query,
        isActive: true, // Only active merchants
        perPage: 10, // Limit results for autocomplete
      );

      state = state.copyWith(merchants: response.merchants, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Clear search results
  void clearSearch() {
    state = const MerchantSearchState();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Popular Merchants State
class PopularMerchantsState {
  final List<Merchant> merchants;
  final bool isLoading;
  final String? error;

  const PopularMerchantsState({
    this.merchants = const [],
    this.isLoading = false,
    this.error,
  });

  PopularMerchantsState copyWith({
    List<Merchant>? merchants,
    bool? isLoading,
    String? error,
  }) {
    return PopularMerchantsState(
      merchants: merchants ?? this.merchants,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Popular Merchants Notifier
class PopularMerchantsNotifier extends StateNotifier<PopularMerchantsState> {
  final MerchantService _merchantService;

  PopularMerchantsNotifier(this._merchantService)
    : super(const PopularMerchantsState());

  // Load popular merchants
  Future<void> loadPopularMerchants() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _merchantService.getMerchants(
        isActive: true,
        perPage: 20, // Get top 20 popular merchants
      );

      state = state.copyWith(merchants: response.merchants, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset state
  void reset() {
    state = const PopularMerchantsState();
  }
}

// Providers
final merchantSearchProvider =
    StateNotifierProvider<MerchantSearchNotifier, MerchantSearchState>((ref) {
      final merchantService = getIt<MerchantService>();
      return MerchantSearchNotifier(merchantService);
    });

final popularMerchantsProvider =
    StateNotifierProvider<PopularMerchantsNotifier, PopularMerchantsState>((
      ref,
    ) {
      final merchantService = getIt<MerchantService>();
      return PopularMerchantsNotifier(merchantService);
    });
