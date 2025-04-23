import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() async {
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);
    // ...existing bindings...
  }
}
