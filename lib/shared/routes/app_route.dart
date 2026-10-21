import 'package:go_router/go_router.dart';

import '../../screens/home/home_screen.dart';
import '../../screens/login/login_screen.dart';

class AppRoute {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    ],
  );
}
