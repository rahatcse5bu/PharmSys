// app/bindings/auth_binding.dart

import 'package:get/get.dart';
import 'package:pharma_sys/app/modules/auth/controllers/auth_controller.dart';
import 'package:pharma_sys/app/modules/auth/view_models/auth_view_model.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Create and inject view model if needed
    Get.lazyPut<AuthViewModel>(() => AuthViewModel());
    
    // Create and inject controller
    Get.lazyPut<AuthController>(() => AuthController());
  }
}