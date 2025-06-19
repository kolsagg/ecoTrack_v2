import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/merchant/merchant_models.dart';
import '../../providers/merchant_provider.dart';
import '../../core/constants/app_constants.dart';

class MerchantAutocompleteField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final Function(Merchant?)? onMerchantSelected;

  const MerchantAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.validator,
    this.onMerchantSelected,
  });

  @override
  ConsumerState<MerchantAutocompleteField> createState() =>
      _MerchantAutocompleteFieldState();
}

class _MerchantAutocompleteFieldState
    extends ConsumerState<MerchantAutocompleteField> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isShowingOverlay = false;
  Merchant? _selectedMerchant;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);

    // Load popular merchants when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(popularMerchantsProvider.notifier).loadPopularMerchants();
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      // Delay hiding to allow for selection
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus) {
          _hideOverlay();
        }
      });
    }
  }

  void _onTextChanged() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(merchantSearchProvider.notifier).searchMerchants(text);
    } else {
      ref.read(merchantSearchProvider.notifier).clearSearch();
      _selectedMerchant = null;
      widget.onMerchantSelected?.call(null);
    }

    if (_focusNode.hasFocus) {
      _showOverlay();
    }
  }

  void _showOverlay() {
    if (_isShowingOverlay) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isShowingOverlay = true;
  }

  void _hideOverlay() {
    if (!_isShowingOverlay) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowingOverlay = false;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Consumer(
                builder: (context, ref, child) {
                  final searchState = ref.watch(merchantSearchProvider);
                  final popularState = ref.watch(popularMerchantsProvider);

                  // Show search results if there's a search query
                  if (searchState.searchQuery != null &&
                      searchState.searchQuery!.isNotEmpty) {
                    return _buildSearchResults(searchState);
                  }

                  // Show popular merchants if no search query
                  return _buildPopularMerchants(popularState);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(MerchantSearchState state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Hata: ${state.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (state.merchants.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Eşleşen merchant bulunamadı',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '"${state.searchQuery}" olarak devam edebilirsiniz',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: state.merchants.length,
      itemBuilder: (context, index) {
        final merchant = state.merchants[index];
        return _buildMerchantTile(merchant);
      },
    );
  }

  Widget _buildPopularMerchants(PopularMerchantsState state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Hata: ${state.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (state.merchants.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Popüler merchant bulunamadı',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Popüler Merchantlar',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.merchants.length > 5
                ? 5
                : state.merchants.length, // Show max 5
            itemBuilder: (context, index) {
              final merchant = state.merchants[index];
              return _buildMerchantTile(merchant);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMerchantTile(Merchant merchant) {
    return ListTile(
      dense: true,
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.store, size: 18, color: AppConstants.primaryColor),
      ),
      title: Text(
        merchant.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: merchant.address != null
          ? Text(
              merchant.address!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: () {
        _selectMerchant(merchant);
      },
    );
  }

  void _selectMerchant(Merchant merchant) {
    setState(() {
      _selectedMerchant = merchant;
    });

    widget.controller.text = merchant.name;
    widget.onMerchantSelected?.call(merchant);

    _focusNode.unfocus();
    _hideOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.store),
          suffixIcon: _selectedMerchant != null
              ? Icon(
                  Icons.check_circle,
                  color: AppConstants.primaryColor,
                  size: 20,
                )
              : widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    widget.controller.clear();
                    _selectedMerchant = null;
                    widget.onMerchantSelected?.call(null);
                    ref.read(merchantSearchProvider.notifier).clearSearch();
                  },
                )
              : null,
        ),
        validator: widget.validator,
        onTap: () {
          if (!_focusNode.hasFocus) {
            _focusNode.requestFocus();
          }
        },
      ),
    );
  }
}
