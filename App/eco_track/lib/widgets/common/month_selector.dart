import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/budget_provider.dart';

class MonthSelector extends ConsumerWidget {
  final VoidCallback? onDateChanged;
  final bool showYearSelector;
  final EdgeInsets? padding;

  const MonthSelector({
    super.key,
    this.onDateChanged,
    this.showYearSelector = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDateState = ref.watch(selectedDateProvider);
    final selectedDate = selectedDateState.selectedDate;
    final now = DateTime.now();

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous month button
          IconButton(
            onPressed: () {
              ref.read(selectedDateProvider.notifier).goToPreviousMonth();
              onDateChanged?.call();
            },
            icon: const Icon(Icons.chevron_left, size: 28),
            tooltip: 'Previous Month',
          ),

          // Month/Year display and picker
          Expanded(
            child: GestureDetector(
              onTap: () => _showMonthPicker(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppConstants.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(selectedDate),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_month,
                      color: AppConstants.primaryColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Next month button
          IconButton(
            onPressed: () {
              ref.read(selectedDateProvider.notifier).goToNextMonth();
              onDateChanged?.call();
            },
            icon: const Icon(Icons.chevron_right, size: 28),
            tooltip: 'Next Month',
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context, WidgetRef ref) async {
    final selectedDate = ref.read(selectedDateProvider).selectedDate;
    final now = DateTime.now();

    final result = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return MonthPickerDialog(
          initialDate: selectedDate,
          firstDate: DateTime(2020, 1),
          lastDate: DateTime(now.year + 2, 12),
        );
      },
    );

    if (result != null) {
      ref.read(selectedDateProvider.notifier).setSelectedDate(result);
      onDateChanged?.call();
    }
  }
}

// Custom Month Picker Dialog
class MonthPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const MonthPickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int selectedYear;
  late int selectedMonth;

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Month & Year'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Year selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: selectedYear > widget.firstDate.year
                      ? () => setState(() => selectedYear--)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  selectedYear.toString(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: selectedYear < widget.lastDate.year
                      ? () => setState(() => selectedYear++)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Month grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final monthNumber = index + 1;
                final isSelected = monthNumber == selectedMonth;
                final now = DateTime.now();
                final isCurrentMonth =
                    selectedYear == now.year && monthNumber == now.month;

                // Check if month is within allowed range
                final monthDate = DateTime(selectedYear, monthNumber, 1);
                final isEnabled =
                    monthDate.isAfter(
                      widget.firstDate.subtract(const Duration(days: 1)),
                    ) &&
                    monthDate.isBefore(
                      widget.lastDate.add(const Duration(days: 1)),
                    );

                return InkWell(
                  onTap: isEnabled
                      ? () {
                          setState(() {
                            selectedMonth = monthNumber;
                          });
                        }
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppConstants.primaryColor
                          : isCurrentMonth
                          ? Colors.green.withOpacity(0.2)
                          : isEnabled
                          ? AppConstants.primaryColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppConstants.primaryColor
                            : isCurrentMonth
                            ? Colors.green
                            : AppConstants.primaryColor.withOpacity(0.3),
                        width: isSelected || isCurrentMonth ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            months[index].substring(0, 3),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : isEnabled
                                  ? AppConstants.primaryColor
                                  : Colors.grey,
                              fontWeight: isSelected || isCurrentMonth
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          if (isCurrentMonth && !isSelected)
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final selectedDate = DateTime(selectedYear, selectedMonth, 1);
            Navigator.of(context).pop(selectedDate);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Select'),
        ),
      ],
    );
  }
}

// Compact month selector for smaller spaces
class CompactMonthSelector extends ConsumerWidget {
  final VoidCallback? onDateChanged;

  const CompactMonthSelector({super.key, this.onDateChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDateState = ref.watch(selectedDateProvider);
    final selectedDate = selectedDateState.selectedDate;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              ref.read(selectedDateProvider.notifier).goToPreviousMonth();
              onDateChanged?.call();
            },
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.chevron_left, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showMonthPicker(context, ref),
            child: Text(
              DateFormat('MMM yyyy').format(selectedDate),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              ref.read(selectedDateProvider.notifier).goToNextMonth();
              onDateChanged?.call();
            },
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.chevron_right, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context, WidgetRef ref) async {
    final selectedDate = ref.read(selectedDateProvider).selectedDate;
    final now = DateTime.now();

    final result = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return MonthPickerDialog(
          initialDate: selectedDate,
          firstDate: DateTime(2020, 1),
          lastDate: DateTime(now.year + 2, 12),
        );
      },
    );

    if (result != null) {
      ref.read(selectedDateProvider.notifier).setSelectedDate(result);
      onDateChanged?.call();
    }
  }
}

// Current month indicator
class CurrentMonthIndicator extends ConsumerWidget {
  const CurrentMonthIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDateState = ref.watch(selectedDateProvider);
    final selectedDate = selectedDateState.selectedDate;
    final now = DateTime.now();
    final isCurrentMonth =
        selectedDate.year == now.year && selectedDate.month == now.month;

    if (isCurrentMonth) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.today, size: 16, color: Colors.green.shade700),
            const SizedBox(width: 4),
            Text(
              'Current Month',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
