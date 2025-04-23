// app/modules/subscription/controllers/subscription_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharma_sys/app/modules/subscription/view_models/subscription_view_model.dart';
import 'package:pharma_sys/app/routes/app_routes.dart';
import 'package:uuid/uuid.dart';

class SubscriptionController extends GetxController {
  final SubscriptionViewModel _viewModel;
  
  // Form controllers for payment information
  final phoneController = TextEditingController();
  final transactionIdController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  // Selected payment method
  final RxString selectedPaymentMethod = 'bKash'.obs;
  
  // List of payment methods
  final List<String> paymentMethods = [
    'bKash',
    'Nagad',
    'Rocket',
    'Bank Transfer',
  ];
  
  // Getters from view model
  Rx<SubscriptionModel?> get currentSubscription => _viewModel.currentSubscription;
  RxBool get hasSubscription => _viewModel.hasSubscription;
  RxInt get daysRemaining => _viewModel.daysRemaining;
  RxBool get isLoading => _viewModel.isLoading;
  RxString get errorMessage => _viewModel.errorMessage;
  RxBool get isTrialActive => _viewModel.isTrialActive;
  RxList<SubscriptionModel> get subscriptionHistory => _viewModel.subscriptionHistory;
  
  SubscriptionController({required SubscriptionViewModel viewModel})
      : _viewModel = viewModel;
  
  @override
  void onInit() {
    super.onInit();
    checkSubscriptionStatus();
  }

  @override
  void onClose() {
    phoneController.dispose();
    transactionIdController.dispose();
    super.onClose();
  }
  
  Future<void> checkSubscriptionStatus() => _viewModel.checkSubscriptionStatus();
  
  Future<bool> startFreeTrial() async {
    final result = await _viewModel.createTrialSubscription();
    if (result) {
      Get.snackbar(
        'Success',
        'Your 7-day free trial has started!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.snackbar(
        'Error',
        _viewModel.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return result;
  }

  Future<bool> subscribeMonthly() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    
    // For demo purposes, we'll generate a transaction ID if not provided
    String transactionId = transactionIdController.text.trim();
    if (transactionId.isEmpty) {
      transactionId = 'TX-${const Uuid().v4().substring(0, 8)}';
    }
    
    final result = await _viewModel.createMonthlySubscription(
      transactionId,
      selectedPaymentMethod.value,
    );
    
    if (result) {
      Get.snackbar(
        'Success',
        'Your subscription has been activated!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.snackbar(
        'Error',
        _viewModel.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return result;
  }

  Future<bool> cancelSubscription() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your subscription? You will lose access to the app when your current subscription period ends.'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No, Keep Subscription'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return false;
    
    final result = await _viewModel.cancelCurrentSubscription();
    if (result) {
      Get.snackbar(
        'Success',
        'Your subscription has been cancelled.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        _viewModel.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return result;
  }

  // Validate user subscription and redirect if needed
  Future<bool> validateSubscription() => _viewModel.validateSubscription();
  
  // Get readable plan name
  String getPlanName() => _viewModel.getPlanName();
  
  // Get subscription amount with currency
  String getSubscriptionAmount() => _viewModel.getSubscriptionAmount();
  
  // Validate form fields
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your payment phone number';
    }
    if (!GetUtils.isPhoneNumber(value) || value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
  
  String? validateTransactionId(String? value) {
    // Transaction ID is optional for demo purposes
    return null;
  }
  
  void setPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }
  
  void goToHome() {
    Get.offAllNamed(Routes.HOME);
  }
  
  void goToPayment() {
    Get.toNamed(Routes.PAYMENT);
  }
}