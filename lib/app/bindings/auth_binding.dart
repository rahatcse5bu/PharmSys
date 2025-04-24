// app/bindings/auth_binding.dart

import 'package:get/get.dart';
import 'package:pharma_sys/app/modules/auth/controllers/auth_controller.dart';
import 'package:pharma_sys/app/modules/auth/view_models/auth_view_model.dart';
import '../modules/subscription/controllers/subscription_controller.dart';
import '../modules/subscription/view_models/subscription_view_model.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Create and inject view models
    Get.lazyPut<AuthViewModel>(() => AuthViewModel());
    
    // Create and inject controllers
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<SubscriptionController>(
      () => SubscriptionController(viewModel: Get.find<SubscriptionViewModel>())
    );
  }
}