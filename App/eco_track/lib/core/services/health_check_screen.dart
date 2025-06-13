import 'package:eco_track/core/services/health_service.dart';
import 'package:eco_track/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HealthCheckScreen extends ConsumerWidget {
  const HealthCheckScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistem Sağlık Durumu'),
      ),
      body: healthState.when(
        data: (results) => _buildResults(results),
        error: (error, stack) => Center(
          child: SelectableText.rich(
            TextSpan(
              text: 'Hata oluştu: ',
              style: const TextStyle(color: AppColors.error),
              children: [
                TextSpan(text: error.toString()),
              ],
            ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildResults(Map<String, HealthCheckResult> results) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHealthCard('Genel Sağlık', results['general']!),
        const SizedBox(height: 12),
        _buildHealthCard('Detaylı Sağlık', results['detailed']!),
        const SizedBox(height: 12),
        _buildHealthCard('Veritabanı Sağlığı', results['database']!),
        const SizedBox(height: 12),
        _buildHealthCard('AI Servisi Sağlığı', results['ai']!),
        const SizedBox(height: 12),
        _buildHealthCard('Hazır Durumu', results['ready']!),
      ],
    );
  }

  Widget _buildHealthCard(String title, HealthCheckResult result) {
    return Card(
      elevation: 2,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.isHealthy ? Icons.check_circle : Icons.error,
                  color: result.isHealthy ? AppColors.success : AppColors.error,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    title,
                    style: AppTextStyles.headline3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              result.message,
              style: AppTextStyles.body,
            ),
            if (result.details != null && result.details!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Detaylar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...result.details!.entries.map((entry) {
                if (entry.value is Map) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key}:',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(entry.value.toString()),
                      const SizedBox(height: 4),
                    ],
                  );
                }
                return Text('${entry.key}: ${entry.value}');
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
} 