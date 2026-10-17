import 'package:go_router/go_router.dart';

import '../../screens/home_screen.dart';

class AppRoute {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    ],
  );
}
