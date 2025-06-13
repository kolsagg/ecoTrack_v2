import 'package:eco_track/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReceiptScreen extends HookConsumerWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Control: AI / Personal / Business
          _buildSegmentedControl(),
          
          // İçerik
          Expanded(
            child: _buildReceiptList(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildScanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  
  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSegmentedButton(
              text: 'AI',
              isSelected: true,
            ),
            const SizedBox(width: 8),
            _buildSegmentedButton(
              text: 'Personal',
              isSelected: false,
            ),
            const SizedBox(width: 8),
            _buildSegmentedButton(
              text: 'Business',
              isSelected: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedButton({required String text, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryBlue : AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildReceiptList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bugünün makbuzları
          _buildDateSection('Today'),
          _buildReceiptItem('Coffee', '12:30 PM', 5.00, 'assets/images/coffee.jpg'),
          _buildReceiptItem('Breakfast', '10:00 AM', 15.00, 'assets/images/breakfast.jpg'),
          
          // Dünün makbuzları
          _buildDateSection('Yesterday'),
          _buildReceiptItem('Dinner', '7:00 PM', 30.00, 'assets/images/dinner.jpg'),
          _buildReceiptItem('Lunch', '1:00 PM', 20.00, 'assets/images/lunch.jpg'),
        ],
      ),
    );
  }

  Widget _buildDateSection(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        date,
        style: AppTextStyles.headline3,
      ),
    );
  }

  Widget _buildReceiptItem(String title, String time, double amount, String imageUrl) {
    // Gerçek bir uygulamada, burada assetlerden veya network'ten görüntü yüklenir
    // Basitlik için placeholder kullanılıyor
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Makbuz görüntüsü
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: Container(
                color: AppColors.background,
                child: const Icon(
                  Icons.receipt_long,
                  color: AppColors.textSecondary,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Makbuz detayları
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Tutar
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Accounts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.credit_card),
          label: 'Cards',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
  
  Widget _buildScanButton() {
    return FloatingActionButton(
      onPressed: () {
        // QR kod tarama ekranını aç
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => _buildScanDialog(context),
        );
      },
      backgroundColor: AppColors.primaryBlue,
      child: const Icon(Icons.qr_code_scanner),
    );
  }
  
  Widget _buildScanDialog(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scan your receipt',
                  style: AppTextStyles.headline2,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Point your camera at the QR code on your receipt',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScanOption(Icons.image, 'Gallery'),
                _buildScanOption(Icons.camera_alt, 'Camera'),
                _buildScanOption(Icons.qr_code, 'QR'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.text,
                  ),
                  child: const Text('Enter manually'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Flash'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScanOption(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28),
        ),
      ],
    );
  }
}

// Global navigator key for dialogs
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); 