import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NavigationSection {
  home,
  members,
  subscriptions,
  payments,
  staff,
  reports,
}

final navigationProvider =
    NotifierProvider<NavigationNotifier, NavigationSection>(
      NavigationNotifier.new,
    );

class NavigationNotifier extends Notifier<NavigationSection> {
  @override
  NavigationSection build() {
    return NavigationSection.home;
  }

  void select(NavigationSection section) {
    state = section;
  }
}
