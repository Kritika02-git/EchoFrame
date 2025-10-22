
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ui/onboarding/onboarding_screen.dart';
import '../ui/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const UnlockableOnboarding(),
      ),
      // GoRoute(
      //   path: '/signup',
      //   builder: (context, state) => const SignUpScreen(),
      // ),
      // GoRoute(
      //   path: '/',
      //   builder: (context, state) => const InboxScreen(),
      // ),
      // GoRoute(
      //   path: '/compose',
      //   builder: (context, state) => const ComposeScreen(),
      // ),
    ],
  );
});
