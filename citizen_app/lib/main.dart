import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Config & Theme
import 'config/app_config.dart';
import 'theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'navigation/route_names.dart';

// Providers
import 'providers/application_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/workflow_provider.dart';
import 'providers/ai_summary_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TrackGovCitizenApp());
}

class TrackGovCitizenApp extends StatelessWidget {
  const TrackGovCitizenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
        ChangeNotifierProvider(create: (_) => WorkflowProvider()),
        ChangeNotifierProvider(create: (_) => AiSummaryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConfig.appName,
            theme: AppTheme.lightTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            initialRoute: RouteNames.splash,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
