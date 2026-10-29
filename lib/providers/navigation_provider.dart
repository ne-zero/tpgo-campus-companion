import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }
}

// holds which bottom nav tab is currently selected
// lets any screen (like Home's "View all" button) switch tabs
// programmatically, instead of only the bottom nav bar itself
final selectedTabProvider = NotifierProvider<SelectedTabNotifier, int>(
  SelectedTabNotifier.new,
);

// tab index constants, so screens don't use "magic numbers"
class TabIndex {
  static const int home = 0;
  static const int explore = 1;
  static const int saved = 2;
  static const int aiTips = 3;
}
