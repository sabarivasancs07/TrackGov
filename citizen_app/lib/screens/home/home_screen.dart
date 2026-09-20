import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../navigation/route_names.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/info_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/search_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 0;
  final _searchController = TextEditingController();

  void _onBottomNavTapped(int index) {
    if (index == 0) return; // Already on Home
    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(RouteNames.search);
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed(RouteNames.profile);
    }
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
      appProvider.searchApplication(query.trim(), auth.user?.name ?? '');
      Navigator.of(context).pushNamed(
        RouteNames.applicationStatus, 
        arguments: query.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Dashboard',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user?.name ?? 'Citizen',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Quick Search Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Track Application',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Enter your application number to get live status.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SearchField(
                      controller: _searchController,
                      hintText: 'e.g. INC-2023-001',
                      onSubmitted: _onSearch,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Quick Actions / Info
            const SectionHeader(title: 'Quick Access'),
            const SizedBox(height: AppSpacing.md),
            InfoCard(
              icon: Icons.article,
              title: 'My Application',
              value: user?.applicationNumber ?? 'Not found',
              onTap: () {
                if (user?.applicationNumber != null) {
                  _onSearch(user!.applicationNumber);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            InfoCard(
              icon: Icons.help_outline,
              title: 'Help & Support',
              value: 'FAQs and Contact Info',
              onTap: () {
                // Navigate to help (not defined in requirements, can show snackbar)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help section coming soon')),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}
