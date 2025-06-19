import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/device_provider.dart';
import '../../models/device/device_models.dart';
import '../../widgets/common/loading_overlay.dart';

class DeviceManagementScreen extends ConsumerStatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  ConsumerState<DeviceManagementScreen> createState() =>
      _DeviceManagementScreenState();
}

class _DeviceManagementScreenState
    extends ConsumerState<DeviceManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deviceProvider.notifier).loadUserDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(deviceProvider.notifier).loadUserDevices();
            },
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: deviceState.isLoading,
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(deviceProvider.notifier).loadUserDevices();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Device Card
                _buildCurrentDeviceCard(deviceState),
                const SizedBox(height: 24),

                // Registration Status Card
                _buildRegistrationStatusCard(deviceState),
                const SizedBox(height: 24),

                // Registered Devices Section
                _buildRegisteredDevicesSection(deviceState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentDeviceCard(DeviceState state) {
    final currentDevice = state.currentDevice;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getDeviceIcon(currentDevice?.deviceType),
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Current Device',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (currentDevice != null) ...[
              _buildDeviceInfoRow(
                'Device Name',
                currentDevice.deviceName ?? 'Unknown',
              ),
              _buildDeviceInfoRow(
                'Device Type',
                _getDeviceTypeDisplayName(currentDevice.deviceType),
              ),
              _buildDeviceInfoRow(
                'App Version',
                currentDevice.appVersion ?? 'Unknown',
              ),
              _buildDeviceInfoRow(
                'Operating System',
                currentDevice.osVersion ?? 'Unknown',
              ),
              _buildDeviceInfoRow('Device ID', currentDevice.deviceId),
            ] else ...[
              const Center(
                child: Text(
                  'Device information could not be loaded',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationStatusCard(DeviceState state) {
    final isRegistered = state.isRegistered;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isRegistered ? Icons.check_circle : Icons.warning,
                  color: isRegistered ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Registration Status',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isRegistered
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isRegistered ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRegistered ? 'Device Registered' : 'Device Not Registered',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isRegistered ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isRegistered
                        ? 'This device can receive push notifications and take advantage of security features.'
                        : 'To receive push notifications and take advantage of security features, please register your device.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (!isRegistered) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _registerCurrentDevice(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Save Device'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRegisteredDevicesSection(DeviceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registered Devices',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        if (state.error != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Column(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    ref.read(deviceProvider.notifier).clearError();
                    ref.read(deviceProvider.notifier).loadUserDevices();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ] else if (state.devices.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            child: const Column(
              children: [
                Icon(Icons.devices, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Registered Devices',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'You do not have any registered devices. Please register your device using the button above.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ] else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.devices.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final device = state.devices[index];
              return _buildDeviceCard(device);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDeviceCard(DeviceResponse device) {
    final isCurrentDevice =
        device.deviceId == ref.read(deviceProvider).currentDevice?.deviceId;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getDeviceIcon(device.deviceType),
                  color: device.isActive
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    device.deviceName ?? 'Unknown Device',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isCurrentDevice) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    child: Text(
                      'This Device',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: device.isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    device.isActive ? 'Active' : 'Inactive',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: device.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDeviceInfoRow(
              'Device Type',
              _getDeviceTypeDisplayName(device.deviceType),
            ),
            _buildDeviceInfoRow('Last Used', _formatDate(device.lastUsedAt)),
            _buildDeviceInfoRow('Registration Date', _formatDate(device.createdAt)),
            if (!isCurrentDevice) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (device.isActive) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deactivateDevice(device),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                        icon: const Icon(Icons.pause_circle, size: 16),
                        label: const Text('Deactivate'),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _deleteDevice(device),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String? deviceType) {
    switch (deviceType?.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'web':
        return Icons.web;
      default:
        return Icons.device_unknown;
    }
  }

  String _getDeviceTypeDisplayName(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'android':
        return 'Android';
      case 'ios':
        return 'iOS';
      case 'web':
        return 'Web';
      default:
        return 'Bilinmiyor';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Future<void> _registerCurrentDevice() async {
    final success = await ref.read(deviceProvider.notifier).registerDevice();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deactivateDevice(DeviceResponse device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Device'),
        content: Text(
          '${device.deviceName ?? 'This device'} will be deactivated. This action cannot be undone. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(deviceProvider.notifier)
          .deactivateDevice(device.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device deactivated successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _deleteDevice(DeviceResponse device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Device'),
        content: Text(
          '${device.deviceName ?? 'This device'} will be permanently deleted. This action cannot be undone. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(deviceProvider.notifier)
          .deleteDevice(device.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device deleted successfully!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
