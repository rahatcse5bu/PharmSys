// app/utils/validators.dart

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  // Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? '$fieldName is required' : 'This field is required';
    }
    
    return null;
  }
  
  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  // Number validation
  static String? validateNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? '$fieldName is required' : 'This field is required';
    }
    
    if (int.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    
    return null;
  }
  
  // Positive number validation
  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? '$fieldName is required' : 'This field is required';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (number <= 0) {
      return 'Please enter a number greater than zero';
    }
    
    return null;
  }
  
  // Price validation
  static String? validatePrice(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? '$fieldName is required' : 'This field is required';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }
    
    if (price < 0) {
      return 'Price cannot be negative';
    }
    
    return null;
  }
  
  // Date validation
  static String? validateDate(DateTime? date, {String? fieldName}) {
    if (date == null) {
      return fieldName != null ? '$fieldName is required' : 'Date is required';
    }
    
    return null;
  }
  
  // Future date validation
  static String? validateFutureDate(DateTime? date, {String? fieldName}) {
    if (date == null) {
      return fieldName != null ? '$fieldName is required' : 'Date is required';
    }
    
    if (date.isBefore(DateTime.now())) {
      return 'Date must be in the future';
    }
    
    return null;
  }
  
  // Past date validation
  static String? validatePastDate(DateTime? date, {String? fieldName}) {
    if (date == null) {
      return fieldName != null ? '$fieldName is required' : 'Date is required';
    }
    
    if (date.isAfter(DateTime.now())) {
      return 'Date must be in the past';
    }
    
    return null;
  }
  
  // URL validation
  static String? validateUrl(String? value, {String? fieldName, bool isRequired = false}) {
    if ((value == null || value.isEmpty) && isRequired) {
      return fieldName != null ? '$fieldName is required' : 'URL is required';
    }
    
    if (value != null && value.isNotEmpty) {
      final urlRegExp = RegExp(
        r'^(https?:\/\/)?(www\.)?[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}(:[0-9]{1,5})?(\/.*)?$'
      );
      
      if (!urlRegExp.hasMatch(value)) {
        return 'Please enter a valid URL';
      }
    }
    
    return null;
  }
}