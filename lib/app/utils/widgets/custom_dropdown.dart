// app/utils/widgets/custom_dropdown.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_sys/app/utils/theme.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final IconData? prefixIcon;
  final bool isEnabled;

  const CustomDropdown({
    Key? key,
    required this.labelText,
    this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.prefixIcon,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: isEnabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText*' : labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: true,
        fillColor: isEnabled ? Colors.white : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(
            color: AppTheme.errorColor,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(
            color: AppTheme.errorColor,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
      ),
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24.r,
      isExpanded: true,
      dropdownColor: Colors.white,
      style: TextStyle(
        fontSize: 16.sp,
        color: isEnabled ? AppTheme.textPrimaryColor : AppTheme.textTertiaryColor,
      ),
    );
  }

  // Helper methods for commonly used dropdowns
  
  static Widget stringDropdown({
    required String labelText,
    String? hintText,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    String? Function(String?)? validator,
    bool isRequired = false,
    IconData? prefixIcon,
    bool isEnabled = true,
    bool Function(String item, String searchTerm)? searchMatcher,
    bool showSearchBox = false,
  }) {
    return CustomDropdown<String>(
      labelText: labelText,
      hintText: hintText,
      value: value,
      items: items.map((item) => DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
      validator: validator,
      isRequired: isRequired,
      prefixIcon: prefixIcon,
      isEnabled: isEnabled,
    );
  }
  
  static Widget numberDropdown({
    required String labelText,
    String? hintText,
    required int? value,
    required List<int> items,
    required void Function(int?)? onChanged,
    String? Function(int?)? validator,
    bool isRequired = false,
    IconData? prefixIcon,
    bool isEnabled = true,
  }) {
    return CustomDropdown<int>(
      labelText: labelText,
      hintText: hintText,
      value: value,
      items: items.map((item) => DropdownMenuItem<int>(
        value: item,
        child: Text(item.toString()),
      )).toList(),
      onChanged: onChanged,
      validator: validator,
      isRequired: isRequired,
      prefixIcon: prefixIcon,
      isEnabled: isEnabled,
    );
  }
  
  static Widget boolDropdown({
    required String labelText,
    String? hintText,
    required bool? value,
    required void Function(bool?)? onChanged,
    String? Function(bool?)? validator,
    bool isRequired = false,
    IconData? prefixIcon,
    bool isEnabled = true,
    String trueText = 'Yes',
    String falseText = 'No',
  }) {
    return CustomDropdown<bool>(
      labelText: labelText,
      hintText: hintText,
      value: value,
      items: [
        DropdownMenuItem<bool>(
          value: true,
          child: Text(trueText),
        ),
        DropdownMenuItem<bool>(
          value: false,
          child: Text(falseText),
        ),
      ],
      onChanged: onChanged,
      validator: validator,
      isRequired: isRequired,
      prefixIcon: prefixIcon,
      isEnabled: isEnabled,
    );
  }
  
  static Widget objectDropdown<T>({
    required String labelText,
    String? hintText,
    required T? value,
    required List<T> items,
    required String Function(T item) itemLabelBuilder,
    required void Function(T?)? onChanged,
    String? Function(T?)? validator,
    bool isRequired = false,
    IconData? prefixIcon,
    bool isEnabled = true,
  }) {
    return CustomDropdown<T>(
      labelText: labelText,
      hintText: hintText,
      value: value,
      items: items.map((item) => DropdownMenuItem<T>(
        value: item,
        child: Text(itemLabelBuilder(item)),
      )).toList(),
      onChanged: onChanged,
      validator: validator,
      isRequired: isRequired,
      prefixIcon: prefixIcon,
      isEnabled: isEnabled,
    );
  }
}