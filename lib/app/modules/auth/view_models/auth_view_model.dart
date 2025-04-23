// app/modules/auth/view_models/auth_view_model.dart

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharma_sys/app/data/models/user_model.dart';

class AuthViewModel extends GetxController {
  // Observable variables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }
  
  Future<void> checkLoginStatus() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final loggedIn = prefs.getBool('isLoggedIn') ?? false;
      
      if (loggedIn) {
        // Retrieve user data from SharedPreferences
        final userId = prefs.getString('userId') ?? '';
        final name = prefs.getString('userName') ?? '';
        final email = prefs.getString('userEmail') ?? '';
        final phone = prefs.getString('userPhone') ?? '';
        final role = prefs.getString('userRole') ?? 'user';
        final profileImage = prefs.getString('userProfileImage');
        
        // Create user model
        currentUser.value = UserModel(
          id: userId,
          name: name,
          email: email,
          phone: phone,
          password: '', // Don't store password in memory
          role: role,
          profileImage: profileImage,
          createdAt: DateTime.now(), // Placeholder
          updatedAt: DateTime.now(), // Placeholder
          isActive: true,
        );
        
        isLoggedIn.value = true;
      } else {
        isLoggedIn.value = false;
        currentUser.value = null;
      }
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to check login status: ${e.toString()}';
      print(errorMessage.value);
    }
  }
  
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // For demo purposes, check hardcoded credentials
      // In a real app, you would call your auth API here
      if (email == 'admin@pharmacy.com' && password == 'admin123') {
        // Create demo user
        final user = UserModel(
          id: '1',
          name: 'Admin User',
          email: email,
          phone: '+1234567890',
          password: '', // Don't store password in memory
          role: 'admin',
          profileImage: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        );
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', user.id);
        await prefs.setString('userName', user.name);
        await prefs.setString('userEmail', user.email);
        await prefs.setString('userPhone', user.phone);
        await prefs.setString('userRole', user.role);
        if (user.profileImage != null) {
          await prefs.setString('userProfileImage', user.profileImage!);
        }
        
        currentUser.value = user;
        isLoggedIn.value = true;
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = 'Invalid email or password';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Login failed: ${e.toString()}';
      print(errorMessage.value);
      return false;
    }
  }
  
  Future<bool> register(String name, String email, String phone, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // For demo purposes, simulate successful registration
      // In a real app, you would call your registration API here
      await Future.delayed(const Duration(seconds: 2));
      
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Registration failed: ${e.toString()}';
      print(errorMessage.value);
      return false;
    }
  }
  
  Future<bool> logout() async {
    try {
      isLoading.value = true;
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      currentUser.value = null;
      isLoggedIn.value = false;
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Logout failed: ${e.toString()}';
      print(errorMessage.value);
      return false;
    }
  }
  
  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // For demo purposes, simulate password reset
      // In a real app, you would call your password reset API here
      await Future.delayed(const Duration(seconds: 2));
      
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Password reset failed: ${e.toString()}';
      print(errorMessage.value);
      return false;
    }
  }
  
  String getUserRole() {
    return currentUser.value?.role ?? '';
  }
  
  bool isAdmin() {
    return getUserRole() == 'admin';
  }
  
  bool isManager() {
    return getUserRole() == 'manager' || isAdmin();
  }
  
  bool canManageInventory() {
    return isManager() || getUserRole() == 'pharmacist';
  }
  
  bool canManageEmployees() {
    return isManager();
  }
  
  bool canViewReports() {
    return isManager();
  }
}