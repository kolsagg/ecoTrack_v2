import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../models/admin/admin_models.dart';
import '../models/merchant/merchant_models.dart';
import '../services/admin_service.dart';
import '../services/merchant_service.dart';
import '../services/auth_service.dart';
import '../core/utils/dependency_injection.dart';

// Admin Dashboard State
class AdminDashboardState extends Equatable {
  final AdminDashboardData? dashboardData;
  final SystemMetrics? systemMetrics;
  final SystemHealth? systemHealth;
  final List<UserActivity> userActivities;
  final bool isLoading;
  final String? error;
  final bool isAdmin;

  const AdminDashboardState({
    this.dashboardData,
    this.systemMetrics,
    this.systemHealth,
    this.userActivities = const [],
    this.isLoading = false,
    this.error,
    this.isAdmin = false,
  });

  AdminDashboardState copyWith({
    AdminDashboardData? dashboardData,
    SystemMetrics? systemMetrics,
    SystemHealth? systemHealth,
    List<UserActivity>? userActivities,
    bool? isLoading,
    String? error,
    bool? isAdmin,
  }) {
    return AdminDashboardState(
      dashboardData: dashboardData ?? this.dashboardData,
      systemMetrics: systemMetrics ?? this.systemMetrics,
      systemHealth: systemHealth ?? this.systemHealth,
      userActivities: userActivities ?? this.userActivities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  @override
  List<Object?> get props => [
    dashboardData,
    systemMetrics,
    systemHealth,
    userActivities,
    isLoading,
    error,
    isAdmin,
  ];
}

// Admin Dashboard Notifier
class AdminDashboardNotifier extends StateNotifier<AdminDashboardState> {
  final AdminService _adminService;
  final AuthService _authService = getIt<AuthService>();

  AdminDashboardNotifier(this._adminService)
    : super(const AdminDashboardState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // AuthService'den admin durumunu al (sadece okuma)
    final isAdmin = _authService.isAdmin;
    state = state.copyWith(isAdmin: isAdmin);

    if (isAdmin) {
      await loadDashboardData();
    }
  }

  // Admin permissions kontrolü artık AuthService'de yapılıyor
  // Bu metod sadece geriye uyumluluk için bırakıldı
  Future<void> checkAdminPermissions() async {
    final isAdmin = _authService.isAdmin;
    state = state.copyWith(isAdmin: isAdmin);
  }

  // Load dashboard data
  Future<void> loadDashboardData() async {
    if (!state.isAdmin) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      // Load all dashboard data in parallel
      final futures = await Future.wait([
        _adminService.getSystemMetrics(),
        _adminService.getSystemHealth(),
        _adminService.getUserActivities(limit: 10),
      ]);

      final systemMetrics = futures[0] as SystemMetrics;
      final systemHealth = futures[1] as SystemHealth;
      final userActivities = futures[2] as List<UserActivity>;

      state = state.copyWith(
        systemMetrics: systemMetrics,
        systemHealth: systemHealth,
        userActivities: userActivities,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Cannot load dashboard data: $e',
        isLoading: false,
      );
    }
  }

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  // Load system statistics
  Future<Map<String, dynamic>?> loadSystemStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!state.isAdmin) return null;

    try {
      return await _adminService.getSystemStatistics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      state = state.copyWith(error: 'Cannot load system statistics: $e');
      return null;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Merchant Management State
class MerchantManagementState extends Equatable {
  final List<Merchant> merchants;
  final Merchant? selectedMerchant;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int total;
  final String? searchQuery;
  final bool? activeFilter;

  const MerchantManagementState({
    this.merchants = const [],
    this.selectedMerchant,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.total = 0,
    this.searchQuery,
    this.activeFilter,
  });

  MerchantManagementState copyWith({
    List<Merchant>? merchants,
    Merchant? selectedMerchant,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? total,
    String? searchQuery,
    bool? activeFilter,
  }) {
    return MerchantManagementState(
      merchants: merchants ?? this.merchants,
      selectedMerchant: selectedMerchant ?? this.selectedMerchant,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props => [
    merchants,
    selectedMerchant,
    isLoading,
    error,
    currentPage,
    totalPages,
    total,
    searchQuery,
    activeFilter,
  ];
}

// Merchant Management Notifier
class MerchantManagementNotifier
    extends StateNotifier<MerchantManagementState> {
  final MerchantService _merchantService;

  MerchantManagementNotifier(this._merchantService)
    : super(const MerchantManagementState()) {
    loadMerchants();
  }

  // Load merchants with pagination and filters
  Future<void> loadMerchants({
    int page = 1,
    String? search,
    bool? isActive,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _merchantService.getMerchants(
        page: page,
        search: search,
        isActive: isActive,
      );

      state = state.copyWith(
        merchants: response.merchants,
        currentPage: response.page,
        totalPages: response.hasNext ? response.page + 1 : response.page,
        total: response.total,
        searchQuery: search,
        activeFilter: isActive,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Cannot load merchant list: $e',
        isLoading: false,
      );
    }
  }

  // Load merchant details
  Future<void> loadMerchantDetails(String merchantId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final merchant = await _merchantService.getMerchant(merchantId);
      state = state.copyWith(selectedMerchant: merchant, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Cannot load merchant details: $e',
        isLoading: false,
      );
    }
  }

  // Create new merchant
  Future<bool> createMerchant(MerchantCreateRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _merchantService.createMerchant(request);
      await loadMerchants(
        page: state.currentPage,
        search: state.searchQuery,
        isActive: state.activeFilter,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Cannot create merchant: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Update merchant
  Future<bool> updateMerchant(
    String merchantId,
    MerchantUpdateRequest request,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final updatedMerchant = await _merchantService.updateMerchant(
        merchantId,
        request,
      );

      // Update merchant in list
      final updatedMerchants = state.merchants.map((merchant) {
        return merchant.id == merchantId ? updatedMerchant : merchant;
      }).toList();

      state = state.copyWith(
        merchants: updatedMerchants,
        selectedMerchant: state.selectedMerchant?.id == merchantId
            ? updatedMerchant
            : state.selectedMerchant,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Cannot update merchant: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Delete merchant
  Future<bool> deleteMerchant(String merchantId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _merchantService.deleteMerchant(merchantId);

      // Remove merchant from list
      final updatedMerchants = state.merchants
          .where((merchant) => merchant.id != merchantId)
          .toList();

      state = state.copyWith(
        merchants: updatedMerchants,
        selectedMerchant: state.selectedMerchant?.id == merchantId
            ? null
            : state.selectedMerchant,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Cannot delete merchant: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Toggle merchant status
  Future<bool> toggleMerchantStatus(String merchantId, bool isActive) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final updatedMerchant = await _merchantService.toggleMerchantStatus(
        merchantId,
        isActive,
      );

      // Update merchant in list
      final updatedMerchants = state.merchants.map((merchant) {
        return merchant.id == merchantId ? updatedMerchant : merchant;
      }).toList();

      state = state.copyWith(
        merchants: updatedMerchants,
        selectedMerchant: state.selectedMerchant?.id == merchantId
            ? updatedMerchant
            : state.selectedMerchant,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Cannot change merchant status: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Regenerate API key
  Future<String?> regenerateApiKey(String merchantId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await _merchantService.regenerateApiKey(merchantId);

      // Update merchant with new API key
      if (state.selectedMerchant?.id == merchantId) {
        state = state.copyWith(
          selectedMerchant: state.selectedMerchant!.copyWith(
            apiKey: response.apiKey,
          ),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

      return response.apiKey;
    } catch (e) {
      state = state.copyWith(
        error: 'Cannot regenerate API key: $e',
        isLoading: false,
      );
      return null;
    }
  }

  // Search merchants
  Future<void> searchMerchants(String query) async {
    await loadMerchants(page: 1, search: query, isActive: state.activeFilter);
  }

  // Filter by active status
  Future<void> filterByActiveStatus(bool? isActive) async {
    await loadMerchants(page: 1, search: state.searchQuery, isActive: isActive);
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (state.currentPage < state.totalPages) {
      await loadMerchants(
        page: state.currentPage + 1,
        search: state.searchQuery,
        isActive: state.activeFilter,
      );
    }
  }

  // Load previous page
  Future<void> loadPreviousPage() async {
    if (state.currentPage > 1) {
      await loadMerchants(
        page: state.currentPage - 1,
        search: state.searchQuery,
        isActive: state.activeFilter,
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear selected merchant
  void clearSelectedMerchant() {
    state = state.copyWith(selectedMerchant: null);
  }
}

// Providers
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

final merchantServiceProvider = Provider<MerchantService>((ref) {
  return MerchantService();
});

final adminDashboardProvider =
    StateNotifierProvider<AdminDashboardNotifier, AdminDashboardState>((ref) {
      final adminService = ref.read(adminServiceProvider);
      return AdminDashboardNotifier(adminService);
    });

final merchantManagementProvider =
    StateNotifierProvider<MerchantManagementNotifier, MerchantManagementState>((
      ref,
    ) {
      final merchantService = ref.read(merchantServiceProvider);
      return MerchantManagementNotifier(merchantService);
    });
