import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharmacy_inventory_app/app/routes/app_pages.dart';
import 'package:pharmacy_inventory_app/app/utils/theme.dart';
import 'package:pharmacy_inventory_app/app/middleware/subscription_middleware.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(const PharmacyApp());
}

class PharmacyApp extends StatelessWidget {
  const PharmacyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Pharmacy Inventory',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
          // Add subscription middleware to check subscription status
          routingCallback: (routing) {
            if (routing?.current != '/login' && 
                routing?.current != '/signup' && 
                routing?.current != '/subscription' &&
                routing?.current != '/payment') {
              // Perform subscription check before allowing access to protected routes
              final middleware = SubscriptionMiddleware();
              final redirect = middleware.redirect(routing?.current);
              if (redirect != null) {
                Get.offAllNamed(redirect.name!);
              }
            }
          },
        );
      },
    );
  }
}