// app/modules/subscription/view_models/subscription_view_model.dart

import 'package:get/get.dart';
import 'package:pharma_sys/app/data/models/subscription_model.dart';
import 'package:pharma_sys/app/data/repositories/subscription_repository.dart';
import 'package:pharma_sys/app/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionViewModel extends GetxController {
  final SubscriptionRepository _subscriptionRepository;
  
  // Observable variables
  final Rx<SubscriptionModel?> currentSubscription = Rx<SubscriptionModel?>(null);
  final RxBool hasSubscription = false.obs;
  final RxInt daysRemaining = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isTrialActive = false.obs;
  final RxList<SubscriptionModel> subscriptionHistory = <SubscriptionModel>[].obs;

  SubscriptionViewModel({required SubscriptionRepository subscriptionRepository})
      : _subscriptionRepository = subscriptionRepository;

  @override
  void onInit() {
    super.onInit();
    checkSubscriptionStatus();
  }

  Future<void> checkSubscriptionStatus() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        errorMessage.value = 'User not found. Please login again.';
        isLoading.value = false;
        return;
      }
      
      // Check and update expired subscriptions
      await _subscriptionRepository.checkAndUpdateExpiredSubscriptions();
      
      // Get current subscription
      final subscription = await _subscriptionRepository.getCurrentSubscription(userId);
      currentSubscription.value = subscription;
      
      if (subscription != null) {
        hasSubscription.value = !subscription.isExpired();
        daysRemaining.value = subscription.daysLeft();
        isTrialActive.value = subscription.planType == 'trial';
      } else {
        hasSubscription.value = false;
        daysRemaining.value = 0;
        isTrialActive.value = false;
      }
      
      // Load subscription history
      final history = await _subscriptionRepository.getSubscriptionHistory(userId);
      subscriptionHistory.value = history;
      
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Failed to check subscription status: ${e.toString()}';
      isLoading.value = false;
      print(errorMessage.value);
    }
  }

  Future<bool> createTrialSubscription() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        errorMessage.value = 'User not found. Please login again.';
        isLoading.value = false;
        return false;
      }
      
      // Check if user already had a trial
      final history = await _subscriptionRepository.getSubscriptionHistory(userId);
      final hadTrial = history.any((sub) => sub.planType == 'trial');
      
      if (hadTrial) {
        errorMessage.value = 'You have already used your free trial.';
        isLoading.value = false;
        return false;
      }
      
      // Create trial subscription
      await _subscriptionRepository.createTrialSubscription(userId);
      await checkSubscriptionStatus();
      
      isLoading.value = false;
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to create trial subscription: ${e.toString()}';
      isLoading.value = false;
      print(errorMessage.value);
      return false;
    }
  }

  Future<bool> createMonthlySubscription(String transactionId, String paymentMethod) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        errorMessage.value = 'User not found. Please login again.';
        isLoading.value = false;
        return false;
      }
      
      // Create monthly subscription
      await _subscriptionRepository.createMonthlySubscription(
        userId,
        transactionId,
        paymentMethod,
      );
      
      await checkSubscriptionStatus();
      
      isLoading.value = false;
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to create subscription: ${e.toString()}';
      isLoading.value = false;
      print(errorMessage.value);
      return false;
    }
  }

  Future<bool> cancelCurrentSubscription() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      if (currentSubscription.value == null) {
        errorMessage.value = 'No active subscription found.';
        isLoading.value = false;
        return false;
      }
      
      // Cancel the subscription
      await _subscriptionRepository.cancelSubscription(currentSubscription.value!.id);
      await checkSubscriptionStatus();
      
      isLoading.value = false;
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to cancel subscription: ${e.toString()}';
      isLoading.value = false;
      print(errorMessage.value);
      return false;
    }
  }

  // Check if the user has an active subscription and redirect if not
  Future<bool> validateSubscription() async {
    await checkSubscriptionStatus();
    
    if (!hasSubscription.value) {
      Get.offAllNamed(Routes.SUBSCRIPTION);
      return false;
    }
    
    return true;
  }

  // Get readable plan details
  String getPlanName() {
    if (currentSubscription.value == null) return 'No Subscription';
    
    switch (currentSubscription.value!.planType) {
      case 'trial':
        return 'Free Trial';
      case 'monthly':
        return 'Monthly Plan';
      case 'yearly':
        return 'Yearly Plan';
      default:
        return currentSubscription.value!.planType.capitalize!;
    }
  }

  // Get subscription amount with currency
  String getSubscriptionAmount() {
    if (currentSubscription.value == null) return '0 BDT';
    
    return '${currentSubscription.value!.amount} ${currentSubscription.value!.currency}';
  }
}