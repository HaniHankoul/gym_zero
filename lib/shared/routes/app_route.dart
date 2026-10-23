import 'package:go_router/go_router.dart';

import '../../screens/home_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/members/members_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/members',
      builder: (context, state) => const MembersScreen(),
    ),
    // GoRoute(
    //   path: '/subscriptions',
    //   builder: (context, state) => const SubscriptionsScreen(),
    // ),
    // GoRoute(
    //   path: '/payments',
    //   builder: (context, state) => const PaymentsScreen(),
    // ),
    // GoRoute(path: '/staff', builder: (context, state) => const StaffScreen()),
    // GoRoute(
    //   path: '/reports',
    //   builder: (context, state) => const ReportsScreen(),
    // ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
  ],
);
