import 'package:get/get.dart';
import 'package:ikuku/features/feature_onboarding/presentation/controller/onboarding_controller.dart';

void invokeControllers() {
  Get.lazyPut(() => OnboardingController(), fenix: true);
}
