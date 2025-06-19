import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_provider.dart';
import '../../models/merchant/merchant_models.dart';

class MerchantManagementScreen extends ConsumerStatefulWidget {
  const MerchantManagementScreen({super.key});

  @override
  ConsumerState<MerchantManagementScreen> createState() =>
      _MerchantManagementScreenState();
}

class _MerchantManagementScreenState
    extends ConsumerState<MerchantManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool? _activeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final merchantState = ref.watch(merchantManagementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant Management'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMerchantDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a merchant...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(merchantManagementProvider.notifier)
                                  .searchMerchants('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    ref
                        .read(merchantManagementProvider.notifier)
                        .searchMerchants(value);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Status: '),
                    DropdownButton<bool?>(
                      value: _activeFilter,
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All')),
                        DropdownMenuItem(value: true, child: Text('Active')),
                        DropdownMenuItem(value: false, child: Text('Inactive')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _activeFilter = value;
                        });
                        ref
                            .read(merchantManagementProvider.notifier)
                            .filterByActiveStatus(value);
                      },
                    ),
                    const Spacer(),
                    Text(
                      'Total: ${merchantState.total}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Error Message
          if (merchantState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      merchantState.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      ref
                          .read(merchantManagementProvider.notifier)
                          .clearError();
                    },
                  ),
                ],
              ),
            ),

          // Merchant List
          Expanded(
            child: merchantState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : merchantState.merchants.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Merchant not found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(merchantManagementProvider.notifier)
                          .loadMerchants();
                    },
                    child: ListView.builder(
                      itemCount: merchantState.merchants.length,
                      itemBuilder: (context, index) {
                        final merchant = merchantState.merchants[index];
                        return _buildMerchantCard(merchant);
                      },
                    ),
                  ),
          ),

          // Pagination
          if (merchantState.totalPages > 1)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: merchantState.currentPage > 1
                        ? () {
                            ref
                                .read(merchantManagementProvider.notifier)
                                .loadPreviousPage();
                          }
                        : null,
                    child: const Text('Previous'),
                  ),
                  Text(
                    'Page ${merchantState.currentPage} / ${merchantState.totalPages}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed:
                        merchantState.currentPage < merchantState.totalPages
                        ? () {
                            ref
                                .read(merchantManagementProvider.notifier)
                                .loadNextPage();
                          }
                        : null,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMerchantCard(Merchant merchant) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: merchant.isActive
              ? Colors.green.shade100
              : Colors.red.shade100,
          child: Icon(
            Icons.store,
            color: merchant.isActive
                ? Colors.green.shade700
                : Colors.red.shade700,
          ),
        ),
        title: Text(
          merchant.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (merchant.businessType != null) Text(merchant.businessType!),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: merchant.isActive
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    merchant.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: merchant.isActive
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Created: ${_formatDate(merchant.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (merchant.address != null)
                  _buildInfoRow('Address', merchant.address!),
                if (merchant.contactPhone != null)
                  _buildInfoRow('Phone', merchant.contactPhone!),
                if (merchant.contactEmail != null)
                  _buildInfoRow('E-mail', merchant.contactEmail!),
                if (merchant.webhookUrl != null)
                  _buildInfoRow('Webhook URL', merchant.webhookUrl!),
                if (merchant.taxNumber != null)
                  _buildInfoRow('Tax Number', merchant.taxNumber!),
                if (merchant.apiKey != null)
                  _buildApiKeyRow(merchant.apiKey!, merchant.id),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showEditMerchantDialog(merchant),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _toggleMerchantStatus(merchant),
                      icon: Icon(
                        merchant.isActive ? Icons.pause : Icons.play_arrow,
                        size: 16,
                      ),
                      label: Text(
                        merchant.isActive ? 'Deactivate' : 'Activate',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: merchant.isActive
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildApiKeyRow(String apiKey, String merchantId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('API Key:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    apiKey,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: apiKey));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('API key copied')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _regenerateApiKey(merchantId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMerchantDialog() {
    showDialog(
      context: context,
      builder: (context) => _MerchantFormDialog(
        title: 'Add New Merchant',
        onSave: (request) async {
          final success = await ref
              .read(merchantManagementProvider.notifier)
              .createMerchant(request);
          if (success && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Merchant added successfully')),
            );
          }
        },
      ),
    );
  }

  void _showEditMerchantDialog(Merchant merchant) {
    showDialog(
      context: context,
      builder: (context) => _MerchantFormDialog(
        title: 'Edit Merchant',
        merchant: merchant,
        onSave: (request) async {
          final updateRequest = MerchantUpdateRequest(
            name: request.name,
            businessType: request.businessType,
            address: request.address,
            contactPhone: request.contactPhone,
            contactEmail: request.contactEmail,
            webhookUrl: request.webhookUrl,
            taxNumber: request.taxNumber,
            settings: request.settings,
          );

          final success = await ref
              .read(merchantManagementProvider.notifier)
              .updateMerchant(merchant.id, updateRequest);
          if (success && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Merchant updated successfully')),
            );
          }
        },
      ),
    );
  }

  void _toggleMerchantStatus(Merchant merchant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Merchant ${merchant.isActive ? 'Deactivate' : 'Activate'}',
        ),
        content: Text(
          '${merchant.name} merchant\'ı ${merchant.isActive ? 'deactivate' : 'activate'} istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref
                  .read(merchantManagementProvider.notifier)
                  .toggleMerchantStatus(merchant.id, !merchant.isActive);
              if (success && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Merchant ${merchant.isActive ? 'deactivated' : 'activated'}',
                    ),
                  ),
                );
              }
            },
            child: Text(merchant.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _regenerateApiKey(String merchantId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refresh API Key'),
        content: const Text(
          'Are you sure you want to refresh the API key? The old key will no longer work.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newApiKey = await ref
                  .read(merchantManagementProvider.notifier)
                  .regenerateApiKey(merchantId);
              if (newApiKey != null && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API key refreshed')),
                );
              }
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _MerchantFormDialog extends StatefulWidget {
  final String title;
  final Merchant? merchant;
  final Function(MerchantCreateRequest) onSave;

  const _MerchantFormDialog({
    required this.title,
    this.merchant,
    required this.onSave,
  });

  @override
  State<_MerchantFormDialog> createState() => _MerchantFormDialogState();
}

class _MerchantFormDialogState extends State<_MerchantFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _websiteController;
  late final TextEditingController _taxNumberController;

  BusinessType? _selectedBusinessType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.merchant?.name ?? '');
    _selectedBusinessType = BusinessType.fromString(
      widget.merchant?.businessType,
    );
    _addressController = TextEditingController(
      text: widget.merchant?.address ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.merchant?.contactPhone ?? '',
    );
    _emailController = TextEditingController(
      text: widget.merchant?.contactEmail ?? '',
    );
    _websiteController = TextEditingController(
      text: widget.merchant?.webhookUrl ?? '',
    );
    _taxNumberController = TextEditingController(
      text: widget.merchant?.taxNumber ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _taxNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'İşletme Adı *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'İşletme adı zorunludur';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<BusinessType>(
                  value: _selectedBusinessType,
                  decoration: const InputDecoration(
                    labelText: 'İşletme Türü',
                    border: OutlineInputBorder(),
                  ),
                  items: BusinessType.values.map((type) {
                    return DropdownMenuItem<BusinessType>(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (BusinessType? value) {
                    setState(() {
                      _selectedBusinessType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Adres',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Geçerli bir e-posta adresi giriniz';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _taxNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Vergi Numarası',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Webhook URL',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(onPressed: _saveMerchant, child: const Text('Kaydet')),
      ],
    );
  }

  void _saveMerchant() {
    if (_formKey.currentState!.validate()) {
      final request = MerchantCreateRequest(
        name: _nameController.text.trim(),
        businessType: _selectedBusinessType?.value,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        contactPhone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        contactEmail: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        taxNumber: _taxNumberController.text.trim().isEmpty
            ? null
            : _taxNumberController.text.trim(),
        webhookUrl: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
      );

      widget.onSave(request);
    }
  }
}
