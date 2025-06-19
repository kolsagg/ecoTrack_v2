// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemMetrics _$SystemMetricsFromJson(Map<String, dynamic> json) =>
    SystemMetrics(
      totalUsers: (json['total_users'] as num).toInt(),
      activeUsers: (json['active_users'] as num).toInt(),
      totalMerchants: (json['total_merchants'] as num).toInt(),
      activeMerchants: (json['active_merchants'] as num).toInt(),
      totalExpenses: (json['total_expenses'] as num).toInt(),
      totalReceipts: (json['total_receipts'] as num).toInt(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      avgExpenseAmount: (json['avg_expense_amount'] as num).toDouble(),
      last24hUsers: (json['last_24h_users'] as num).toInt(),
      last24hExpenses: (json['last_24h_expenses'] as num).toInt(),
      last24hAmount: (json['last_24h_amount'] as num).toDouble(),
      systemUptime: json['system_uptime'] as String,
      databaseStatus: json['database_status'] as String,
      apiResponseTime: (json['api_response_time'] as num).toDouble(),
    );

Map<String, dynamic> _$SystemMetricsToJson(SystemMetrics instance) =>
    <String, dynamic>{
      'total_users': instance.totalUsers,
      'active_users': instance.activeUsers,
      'total_merchants': instance.totalMerchants,
      'active_merchants': instance.activeMerchants,
      'total_expenses': instance.totalExpenses,
      'total_receipts': instance.totalReceipts,
      'total_amount': instance.totalAmount,
      'avg_expense_amount': instance.avgExpenseAmount,
      'last_24h_users': instance.last24hUsers,
      'last_24h_expenses': instance.last24hExpenses,
      'last_24h_amount': instance.last24hAmount,
      'system_uptime': instance.systemUptime,
      'database_status': instance.databaseStatus,
      'api_response_time': instance.apiResponseTime,
    };

UserActivity _$UserActivityFromJson(Map<String, dynamic> json) => UserActivity(
  userId: json['user_id'] as String,
  userEmail: json['user_email'] as String,
  lastLogin: DateTime.parse(json['last_login'] as String),
  totalExpenses: (json['total_expenses'] as num).toInt(),
  totalAmount: (json['total_amount'] as num).toDouble(),
  isActive: json['is_active'] as bool,
);

Map<String, dynamic> _$UserActivityToJson(UserActivity instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'user_email': instance.userEmail,
      'last_login': instance.lastLogin.toIso8601String(),
      'total_expenses': instance.totalExpenses,
      'total_amount': instance.totalAmount,
      'is_active': instance.isActive,
    };

SystemHealth _$SystemHealthFromJson(Map<String, dynamic> json) => SystemHealth(
  status: json['status'] as String,
  databaseStatus: json['database_status'] as String,
  redisStatus: json['redis_status'] as String?,
  apiStatus: json['api_status'] as String,
  responseTime: (json['response_time'] as num).toDouble(),
  memoryUsage: (json['memory_usage'] as num).toDouble(),
  cpuUsage: (json['cpu_usage'] as num).toDouble(),
  diskUsage: (json['disk_usage'] as num).toDouble(),
  lastCheck: DateTime.parse(json['last_check'] as String),
);

Map<String, dynamic> _$SystemHealthToJson(SystemHealth instance) =>
    <String, dynamic>{
      'status': instance.status,
      'database_status': instance.databaseStatus,
      'redis_status': instance.redisStatus,
      'api_status': instance.apiStatus,
      'response_time': instance.responseTime,
      'memory_usage': instance.memoryUsage,
      'cpu_usage': instance.cpuUsage,
      'disk_usage': instance.diskUsage,
      'last_check': instance.lastCheck.toIso8601String(),
    };

AdminDashboardData _$AdminDashboardDataFromJson(Map<String, dynamic> json) =>
    AdminDashboardData(
      systemMetrics: SystemMetrics.fromJson(
        json['system_metrics'] as Map<String, dynamic>,
      ),
      systemHealth: SystemHealth.fromJson(
        json['system_health'] as Map<String, dynamic>,
      ),
      recentUsers: (json['recent_users'] as List<dynamic>)
          .map((e) => UserActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
      topMerchants: (json['top_merchants'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      dailyStats: (json['daily_stats'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$AdminDashboardDataToJson(AdminDashboardData instance) =>
    <String, dynamic>{
      'system_metrics': instance.systemMetrics,
      'system_health': instance.systemHealth,
      'recent_users': instance.recentUsers,
      'top_merchants': instance.topMerchants,
      'daily_stats': instance.dailyStats,
    };
