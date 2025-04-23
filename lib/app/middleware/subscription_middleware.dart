// app/middleware/subscription_middleware.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharma_sys/app/routes/app_routes.dart';
import 'package:pharma_sys/app/modules/subscription/view_models/subscription_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Skip middleware for these routes
    if (route == Routes.LOGIN || 
        route == Routes.SIGNUP || 
        route == Routes.SUBSCRIPTION || 
        route == Routes.PAYMENT) {
      return null;
    }
    
    return _checkSubscription();
  }

  RouteSettings? _checkSubscription() async {
    // Check if user is logged in
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (!isLoggedIn) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    
    // Check if subscription is active
    try {
      final subscriptionViewModel = Get.find<SubscriptionViewModel>();
      await subscriptionViewModel.checkSubscriptionStatus();
      
      if (!subscriptionViewModel.hasSubscription.value) {
        return const RouteSettings(name: Routes.SUBSCRIPTION);
      }
    } catch (e) {
      print('Error checking subscription: $e');
      // If we can't check subscription status, we redirect to subscription page
      return const RouteSettings(name: Routes.SUBSCRIPTION);
    }
    
    return null;
  }
}