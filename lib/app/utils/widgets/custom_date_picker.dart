// app/utils/widgets/custom_date_picker.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pharma_sys/app/utils/theme.dart';

class CustomDatePicker extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime) onDateSelected;
  final String labelText;
  final String? hintText;
  final bool isRequired;
  final String? errorText;
  final IconData? icon;
  final String dateFormat;

  const CustomDatePicker({
    Key? key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    required this.onDateSelected,
    required this.labelText,
    this.hintText,
    this.isRequired = false,
    this.errorText,
    this.icon = Icons.calendar_today,
    this.dateFormat = 'MMM dd, yyyy',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isRequired ? '$labelText*' : labelText,
          hintText: hintText ?? 'Select date',
          errorText: errorText,
          prefixIcon: icon != null ? Icon(icon) : null,
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          initialDate != null
              ? DateFormat(dateFormat).format(initialDate!)
              : hintText ?? 'Select date',
          style: TextStyle(
            fontSize: 16.sp,
            color: initialDate != null
                ? AppTheme.textPrimaryColor
                : AppTheme.textTertiaryColor,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime selected = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    ).then((date) {
      if (date != null) {
        onDateSelected(date);
      }
      return date ?? (initialDate ?? now);
    });
  }
  
  // Helper methods for creating different types of date pickers
  
  static Widget past({
    DateTime? initialDate,
    required Function(DateTime) onDateSelected,
    required String labelText,
    String? hintText,
    bool isRequired = false,
    String? errorText,
    IconData? icon = Icons.calendar_today,
    String dateFormat = 'MMM dd, yyyy',
  }) {
    return CustomDatePicker(
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      onDateSelected: onDateSelected,
      labelText: labelText,
      hintText: hintText,
      isRequired: isRequired,
      errorText: errorText,
      icon: icon,
      dateFormat: dateFormat,
    );
  }
  
  static Widget future({
    DateTime? initialDate,
    required Function(DateTime) onDateSelected,
    required String labelText,
    String? hintText,
    bool isRequired = false,
    String? errorText,
    IconData? icon = Icons.calendar_today,
    String dateFormat = 'MMM dd, yyyy',
  }) {
    return CustomDatePicker(
      initialDate: initialDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      onDateSelected: onDateSelected,
      labelText: labelText,
      hintText: hintText,
      isRequired: isRequired,
      errorText: errorText,
      icon: icon,
      dateFormat: dateFormat,
    );
  }
  
  static Widget dateRange({
    required BuildContext context,
    required DateTimeRange? initialDateRange,
    required Function(DateTimeRange) onDateRangeSelected,
    DateTime? firstDate,
    DateTime? lastDate,
    String startLabelText = 'Start Date',
    String endLabelText = 'End Date',
    bool isRequired = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: CustomDatePicker(
            initialDate: initialDateRange?.start,
            firstDate: firstDate,
            lastDate: initialDateRange?.end ?? lastDate,
            onDateSelected: (date) {
              final newRange = DateTimeRange(
                start: date,
                end: initialDateRange?.end ?? date,
              );
              onDateRangeSelected(newRange);
            },
            labelText: startLabelText,
            isRequired: isRequired,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: CustomDatePicker(
            initialDate: initialDateRange?.end,
            firstDate: initialDateRange?.start ?? firstDate,
            lastDate: lastDate,
            onDateSelected: (date) {
              final newRange = DateTimeRange(
                start: initialDateRange?.start ?? date,
                end: date,
              );
              onDateRangeSelected(newRange);
            },
            labelText: endLabelText,
            isRequired: isRequired,
          ),
        ),
      ],
    );
  }
}