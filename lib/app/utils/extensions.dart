// app/utils/extensions.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return '';
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
  
  String titleCase() {
    if (this.isEmpty) return '';
    
    final words = this.split(' ');
    final capitalized = words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    });
    
    return capitalized.join(' ');
  }
  
  bool get isValidEmail {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(this);
  }
  
  bool get isValidPhone {
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegExp.hasMatch(this);
  }
  
  bool get isValidPassword {
    return this.length >= 6;
  }
}

extension DateTimeExtension on DateTime {
  String toFormattedDate() {
    return DateFormat('dd/MM/yyyy').format(this);
  }
  
  String toFormattedTime() {
    return DateFormat('HH:mm').format(this);
  }
  
  String toFormattedDateTime() {
    return DateFormat('dd/MM/yyyy HH:mm').format(this);
  }
  
  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }
  
  int get daysInMonth {
    return DateTime(this.year, this.month + 1, 0).day;
  }
  
  DateTime get firstDayOfMonth {
    return DateTime(this.year, this.month, 1);
  }
  
  DateTime get lastDayOfMonth {
    return DateTime(this.year, this.month + 1, 0);
  }
  
  DateTime get firstDayOfWeek {
    return subtract(Duration(days: weekday - 1));
  }
  
  DateTime get lastDayOfWeek {
    return add(Duration(days: DateTime.daysPerWeek - weekday));
  }
  
  bool isSameDay(DateTime other) {
    return this.year == other.year && this.month == other.month && this.day == other.day;
  }
}

extension DoubleExtension on double {
  String toFormattedCurrency({String symbol = '৳'}) {
    return '$symbol ${toStringAsFixed(2)}';
  }
  
  String toFormattedString({int decimalPlaces = 2}) {
    return toStringAsFixed(decimalPlaces);
  }
}

extension IntExtension on int {
  String toFormattedCurrency({String symbol = '৳'}) {
    return '$symbol $this';
  }
  
  String toFormattedNumber() {
    final formatter = NumberFormat('#,###');
    return formatter.format(this);
  }
  
  String toZeroPadded(int width) {
    return toString().padLeft(width, '0');
  }
}

extension WidgetExtension on Widget {
  Widget paddingAll(double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: this,
    );
  }
  
  Widget paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      ),
      child: this,
    );
  }
  
  Widget paddingOnly({double left = 0.0, double top = 0.0, double right = 0.0, double bottom = 0.0}) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }
  
  Widget get centerWidget {
    return Center(child: this);
  }
  
  Widget withBorder({
    Color color = Colors.grey,
    double width = 1.0,
    BorderRadius borderRadius = BorderRadius.zero,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: color,
          width: width,
        ),
        borderRadius: borderRadius,
      ),
      child: this,
    );
  }
}

extension ColorExtension on Color {
  Color get lighter {
    return withOpacity(0.5);
  }
  
  Color get darker {
    final hsl = HSLColor.fromColor(this);
    final darkerHsl = hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0));
    return darkerHsl.toColor();
  }
  
  Color withBrightness(double brightness) {
    final hsl = HSLColor.fromColor(this);
    final adjustedHsl = hsl.withLightness((hsl.lightness * brightness).clamp(0.0, 1.0));
    return adjustedHsl.toColor();
  }
}

extension ListExtension on List {
  List<T> filterByType<T>() {
    return whereType<T>().toList();
  }
}

extension ContextExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
  
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    return await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}