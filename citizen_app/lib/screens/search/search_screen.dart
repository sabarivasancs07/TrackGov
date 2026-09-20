import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/route_names.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/search_field.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/info_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final int _currentIndex = 1;
  final _searchController = TextEditingController();

  void _onBottomNavTapped(int index) {
    if (index == 1) return; // Already on Search
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(RouteNames.home);
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed(RouteNames.profile);
    }
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<ApplicationProvider>(context, listen: false)
          .searchApplication(query.trim(), auth.user?.name ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Search Application',
        showBackButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            SearchField(
              controller: _searchController,
              hintText: 'Enter Application Number',
              onSubmitted: _onSearch,
              onClear: () {
                Provider.of<ApplicationProvider>(context, listen: false).clear();
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: Consumer<ApplicationProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const LoadingWidget(message: 'Searching...');
                  }

                  if (provider.errorMessage != null) {
                    return ErrorCard(message: provider.errorMessage!);
                  }

                  if (provider.currentApplication != null) {
                    final app = provider.currentApplication!;
                    return ListView(
                      children: [
                        const Text(
                          'Search Result',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        InfoCard(
                          icon: Icons.article,
                          title: app.applicationNumber,
                          value: app.certificateType,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              RouteNames.applicationStatus,
                              arguments: app.applicationNumber,
                            );
                          },
                        ),
                      ],
                    );
                  }

                  return const EmptyState(
                    icon: Icons.search,
                    title: 'Search Applications',
                    message: 'Enter your application number above to check its live status.',
                  );
                },
              ),
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
