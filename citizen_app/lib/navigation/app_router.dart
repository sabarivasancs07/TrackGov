import 'package:flutter/material.dart';
import 'route_names.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/application_status/application_status_screen.dart';
import '../screens/workflow_history/workflow_history_screen.dart';
import '../screens/ai_summary/ai_summary_screen.dart';
import '../screens/ai_assistant/ai_assistant_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/documents/documents_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.login:
        return _fadeRoute(const LoginScreen(), settings);
      case RouteNames.home:
        return _fadeRoute(const DashboardScreen(), settings);
      case RouteNames.search:
        return _slideRoute(const SearchScreen(), settings);
      case RouteNames.applicationStatus:
        // Pass application number if provided in arguments
        final String? appNumber = settings.arguments as String?;
        return _slideRoute(ApplicationStatusScreen(applicationNumber: appNumber), settings);
      case RouteNames.workflowHistory:
        final String? appNumber = settings.arguments as String?;
        return _slideRoute(WorkflowHistoryScreen(applicationNumber: appNumber), settings);
      case RouteNames.aiSummary:
        final String? appNumber = settings.arguments as String?;
        return _slideRoute(AiSummaryScreen(applicationNumber: appNumber), settings);
      case RouteNames.aiAssistant:
        final String? appNumber = settings.arguments as String?;
        return _slideRoute(AiAssistantScreen(applicationNumber: appNumber), settings);
      case RouteNames.profile:
        return _slideRoute(const ProfileScreen(), settings);
      case RouteNames.notifications:
        return _slideRoute(const NotificationsScreen(), settings);
      case RouteNames.documents:
        return _slideRoute(const DocumentsScreen(), settings);
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
