import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'admin_models.g.dart';

// System Metrics Model
@JsonSerializable()
class SystemMetrics extends Equatable {
  @JsonKey(name: 'total_users')
  final int totalUsers;
  @JsonKey(name: 'active_users')
  final int activeUsers;
  @JsonKey(name: 'total_merchants')
  final int totalMerchants;
  @JsonKey(name: 'active_merchants')
  final int activeMerchants;
  @JsonKey(name: 'total_expenses')
  final int totalExpenses;
  @JsonKey(name: 'total_receipts')
  final int totalReceipts;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  @JsonKey(name: 'avg_expense_amount')
  final double avgExpenseAmount;
  @JsonKey(name: 'last_24h_users')
  final int last24hUsers;
  @JsonKey(name: 'last_24h_expenses')
  final int last24hExpenses;
  @JsonKey(name: 'last_24h_amount')
  final double last24hAmount;
  @JsonKey(name: 'system_uptime')
  final String systemUptime;
  @JsonKey(name: 'database_status')
  final String databaseStatus;
  @JsonKey(name: 'api_response_time')
  final double apiResponseTime;

  const SystemMetrics({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalMerchants,
    required this.activeMerchants,
    required this.totalExpenses,
    required this.totalReceipts,
    required this.totalAmount,
    required this.avgExpenseAmount,
    required this.last24hUsers,
    required this.last24hExpenses,
    required this.last24hAmount,
    required this.systemUptime,
    required this.databaseStatus,
    required this.apiResponseTime,
  });

  factory SystemMetrics.fromJson(Map<String, dynamic> json) =>
      _$SystemMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$SystemMetricsToJson(this);

  @override
  List<Object?> get props => [
    totalUsers,
    activeUsers,
    totalMerchants,
    activeMerchants,
    totalExpenses,
    totalReceipts,
    totalAmount,
    avgExpenseAmount,
    last24hUsers,
    last24hExpenses,
    last24hAmount,
    systemUptime,
    databaseStatus,
    apiResponseTime,
  ];
}

// User Activity Model
@JsonSerializable()
class UserActivity extends Equatable {
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'user_email')
  final String userEmail;
  @JsonKey(name: 'last_login')
  final DateTime lastLogin;
  @JsonKey(name: 'total_expenses')
  final int totalExpenses;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const UserActivity({
    required this.userId,
    required this.userEmail,
    required this.lastLogin,
    required this.totalExpenses,
    required this.totalAmount,
    required this.isActive,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) =>
      _$UserActivityFromJson(json);

  Map<String, dynamic> toJson() => _$UserActivityToJson(this);

  @override
  List<Object?> get props => [
    userId,
    userEmail,
    lastLogin,
    totalExpenses,
    totalAmount,
    isActive,
  ];
}

// System Health Model
@JsonSerializable()
class SystemHealth extends Equatable {
  final String status;
  @JsonKey(name: 'database_status')
  final String databaseStatus;
  @JsonKey(name: 'redis_status')
  final String? redisStatus;
  @JsonKey(name: 'api_status')
  final String apiStatus;
  @JsonKey(name: 'response_time')
  final double responseTime;
  @JsonKey(name: 'memory_usage')
  final double memoryUsage;
  @JsonKey(name: 'cpu_usage')
  final double cpuUsage;
  @JsonKey(name: 'disk_usage')
  final double diskUsage;
  @JsonKey(name: 'last_check')
  final DateTime lastCheck;

  const SystemHealth({
    required this.status,
    required this.databaseStatus,
    this.redisStatus,
    required this.apiStatus,
    required this.responseTime,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.diskUsage,
    required this.lastCheck,
  });

  factory SystemHealth.fromJson(Map<String, dynamic> json) =>
      _$SystemHealthFromJson(json);

  Map<String, dynamic> toJson() => _$SystemHealthToJson(this);

  @override
  List<Object?> get props => [
    status,
    databaseStatus,
    redisStatus,
    apiStatus,
    responseTime,
    memoryUsage,
    cpuUsage,
    diskUsage,
    lastCheck,
  ];
}

// Admin Dashboard Data Model
@JsonSerializable()
class AdminDashboardData extends Equatable {
  @JsonKey(name: 'system_metrics')
  final SystemMetrics systemMetrics;
  @JsonKey(name: 'system_health')
  final SystemHealth systemHealth;
  @JsonKey(name: 'recent_users')
  final List<UserActivity> recentUsers;
  @JsonKey(name: 'top_merchants')
  final List<Map<String, dynamic>> topMerchants;
  @JsonKey(name: 'daily_stats')
  final List<Map<String, dynamic>> dailyStats;

  const AdminDashboardData({
    required this.systemMetrics,
    required this.systemHealth,
    required this.recentUsers,
    required this.topMerchants,
    required this.dailyStats,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) =>
      _$AdminDashboardDataFromJson(json);

  Map<String, dynamic> toJson() => _$AdminDashboardDataToJson(this);

  @override
  List<Object?> get props => [
    systemMetrics,
    systemHealth,
    recentUsers,
    topMerchants,
    dailyStats,
  ];
}
