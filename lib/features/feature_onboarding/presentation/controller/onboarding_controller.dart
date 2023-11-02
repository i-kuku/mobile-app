import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final activeLanguage = 'English'.obs;

  void setActiveLanguage({required String languageTitle}) =>
      activeLanguage.value = languageTitle;
}
