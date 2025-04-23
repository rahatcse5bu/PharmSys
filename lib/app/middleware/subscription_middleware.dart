// app/middleware/subscription_middleware.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharma_sys/app/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modules/subscription/view_models/subscription_view_model.dart';


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

    // Check if user is logged in synchronously using GetStorage or similar
    final isLoggedIn = Get.find<SharedPreferences>().getBool('isLoggedIn') ?? false;
    if (!isLoggedIn) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    if (page?.name == Routes.HOME && page != null) {
      return GetPage(
        name: page.name,
        page: page.page,
        binding: page.binding,
        bindings: page.bindings,
        children: page.children,
        participatesInRootNavigator: page.participatesInRootNavigator,
        preventDuplicates: page.preventDuplicates,
        middlewares: [RouteGuard()],
        title: page.title,
        transition: page.transition,
        customTransition: page.customTransition,
        transitionDuration: page.transitionDuration,
        curve: page.curve,
        opaque: page.opaque,
        popGesture: page.popGesture,
        fullscreenDialog: page.fullscreenDialog,
      );
    }
    return page;
  }
}

class RouteGuard extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    try {
      // Check subscription status
      final vm = Get.find<SubscriptionViewModel>();
      await vm.checkSubscriptionStatus();
      
      if (!vm.hasSubscription.value) {
        return GetNavConfig.fromRoute(Routes.SUBSCRIPTION);
      }
      return await super.redirectDelegate(route);
    } catch (e) {
      print('Error checking subscription: $e');
      return GetNavConfig.fromRoute(Routes.SUBSCRIPTION);
    }
  }
}