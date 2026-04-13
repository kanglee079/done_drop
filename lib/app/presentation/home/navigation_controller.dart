import 'package:get/get.dart';

/// Manages bottom navigation state across the home screen.
/// Using GetX reactive state instead of StatefulWidget+setState ensures
/// all tabs stay synchronized and rebuild predictably.
class NavigationController extends GetxController {
  NavigationController();

  /// Current bottom nav tab index.
  /// 0=Home, 1=Feed, 2=Capture (overlay), 3=Wall, 4=Settings
  final RxInt navIndex = 0.obs;

  void setTab(int index) {
    navIndex.value = index;
  }
}
