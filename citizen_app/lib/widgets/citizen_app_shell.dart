import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../navigation/route_names.dart';
import '../theme/app_colors.dart';

class CitizenAppShell extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  final String? applicationNumber;
  final bool showBackButton;
  final String? title;

  const CitizenAppShell({
    super.key,
    required this.child,
    required this.currentRoute,
    this.applicationNumber,
    this.showBackButton = false,
    this.title,
  });

  @override
  State<CitizenAppShell> createState() => _CitizenAppShellState();
}

class _CitizenAppShellState extends State<CitizenAppShell> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userName = auth.user?.name ?? 'Citizen';
    final appNum = widget.applicationNumber ?? auth.user?.applicationNumber ?? '';

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1200;
            final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;

            if (isDesktop || isTablet) {
              final isCollapsed = isTablet ? true : _isSidebarCollapsed;
              return Row(
                children: [
                  _buildNavigationSidebar(
                    context,
                    currentRoute: widget.currentRoute,
                    appNum: appNum,
                    isCollapsed: isCollapsed,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _buildTopHeader(context, isDesktop: isDesktop, userName: userName, appNum: appNum),
                        Expanded(child: widget.child),
                      ],
                    ),
                  ),
                ],
              );
            }

            // Mobile layout
            return Column(
              children: [
                _buildMobileTopBar(context, userName: userName, appNum: appNum),
                Expanded(child: widget.child),
                _buildMobileBottomNav(context, currentRoute: widget.currentRoute, appNum: appNum),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION SIDEBAR (Dark navy #102F63)
  // ============================================================
  Widget _buildNavigationSidebar(
    BuildContext context, {
    required String currentRoute,
    required String appNum,
    required bool isCollapsed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isCollapsed ? 88 : 280,
      color: AppColors.sidebarNavy,
      child: Column(
        children: [
          // Sidebar header with TrackGov AI brand
          Padding(
            padding: EdgeInsets.fromLTRB(isCollapsed ? 12 : 20, 24, isCollapsed ? 12 : 20, 24),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: AppColors.sidebarNavy,
                    size: 22,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'TrackGov AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _sidebarNavItem(
                    context,
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    isSelected: currentRoute == RouteNames.home,
                    isCollapsed: isCollapsed,
                    onTap: () {
                      if (currentRoute != RouteNames.home) {
                        Navigator.of(context).pushReplacementNamed(RouteNames.home);
                      }
                    },
                  ),
                  _sidebarNavItem(
                    context,
                    icon: Icons.track_changes_rounded,
                    title: 'Track Application',
                    isSelected: currentRoute == RouteNames.applicationStatus,
                    isCollapsed: isCollapsed,
                    onTap: () {
                      if (currentRoute != RouteNames.applicationStatus) {
                        Navigator.of(context).pushNamed(RouteNames.applicationStatus, arguments: appNum);
                      }
                    },
                  ),
                  _sidebarNavItem(
                    context,
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    isSelected: currentRoute == RouteNames.notifications,
                    isCollapsed: isCollapsed,
                    onTap: () {
                      if (currentRoute != RouteNames.notifications) {
                        Navigator.of(context).pushNamed(RouteNames.notifications);
                      }
                    },
                  ),
                  _sidebarNavItem(
                    context,
                    icon: Icons.folder_copy_outlined,
                    title: 'Documents',
                    isSelected: currentRoute == RouteNames.documents,
                    isCollapsed: isCollapsed,
                    onTap: () {
                      if (currentRoute != RouteNames.documents) {
                        Navigator.of(context).pushNamed(RouteNames.documents);
                      }
                    },
                  ),
                  _sidebarNavItem(
                    context,
                    icon: Icons.auto_awesome_rounded,
                    title: 'AI Assistant',
                    isSelected: currentRoute == RouteNames.aiAssistant,
                    isCollapsed: isCollapsed,
                    onTap: () {
                      if (currentRoute != RouteNames.aiAssistant) {
                        Navigator.of(context).pushNamed(RouteNames.aiAssistant, arguments: appNum);
                      }
                    },
                  ),
                  _sidebarNavItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    isSelected: false, // Settings doesn't have an independent route in the sidebar right now
                    isCollapsed: isCollapsed,
                    onTap: () {
                      if (currentRoute != RouteNames.profile) {
                        Navigator.of(context).pushNamed(RouteNames.profile);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Collapse Toggle
          InkWell(
            onTap: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Icon(
                isCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                color: Colors.white70,
              ),
            ),
          ),

          // Sidebar Footer: "People • Process • Progress", Digital India
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'People • Process • Progress',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.account_balance,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Digital India',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Strong Together',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sidebarNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isSelected,
    required bool isCollapsed,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 16, vertical: 12),
            alignment: isCollapsed ? Alignment.center : Alignment.centerLeft,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white70,
                  size: 20,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP HEADER (Desktop / Tablet)
  // ============================================================
  Widget _buildTopHeader(
    BuildContext context, {
    required bool isDesktop,
    required String userName,
    required String appNum,
  }) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8EDF4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.showBackButton) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryNavy),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacementNamed(RouteNames.home);
                }
              },
            ),
            const SizedBox(width: 8),
          ],
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(width: 20),
          ],
          // Search Field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE8EDF4),
                ),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search application, scheme or ask anything...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.primaryNavy,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 11),
                ),
                onSubmitted: (query) {
                  if (query.trim().isNotEmpty) {
                    Navigator.of(context).pushNamed(RouteNames.applicationStatus, arguments: query.trim());
                  }
                },
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Notifications button with indicator
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  if (widget.currentRoute != RouteNames.notifications) {
                    Navigator.of(context).pushNamed(RouteNames.notifications);
                  }
                },
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.primaryNavy,
                  size: 24,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // User Profile & Dropdown
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.of(context).pushNamed(RouteNames.profile);
              } else if (value == 'logout') {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.login, (r) => false);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textPrimary),
                    const SizedBox(width: 10),
                    Text('My Profile ($userName)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
                    SizedBox(width: 10),
                    Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444))),
                  ],
                ),
              ),
            ],
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: const Color(0xFFE8F0FF),
                  child: Text(
                    _initials(userName),
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE TOP BAR (< 768px)
  // ============================================================
  Widget _buildMobileTopBar(
    BuildContext context, {
    required String userName,
    required String appNum,
  }) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8EDF4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.showBackButton) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryNavy),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacementNamed(RouteNames.home);
                }
              },
            ),
            const SizedBox(width: 4),
          ],
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: AppColors.primaryNavy,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            widget.title ?? 'TrackGov AI',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryNavy,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(RouteNames.notifications);
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primaryNavy,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(RouteNames.profile);
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE8F0FF),
              child: Text(
                _initials(userName),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE BOTTOM NAVIGATION
  // ============================================================
  Widget _buildMobileBottomNav(
    BuildContext context, {
    required String currentRoute,
    required String appNum,
  }) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE8EDF4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _mobileNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            isSelected: currentRoute == RouteNames.home,
            onTap: () {
              if (currentRoute != RouteNames.home) {
                Navigator.of(context).pushReplacementNamed(RouteNames.home);
              }
            },
          ),
          _mobileNavItem(
            icon: Icons.track_changes_rounded,
            label: 'Track',
            isSelected: currentRoute == RouteNames.applicationStatus,
            onTap: () {
              if (currentRoute != RouteNames.applicationStatus) {
                Navigator.of(context).pushNamed(RouteNames.applicationStatus, arguments: appNum);
              }
            },
          ),
          _mobileNavItem(
            icon: Icons.auto_awesome_rounded,
            label: 'AI',
            isSelected: currentRoute == RouteNames.aiAssistant || currentRoute == RouteNames.aiSummary,
            onTap: () {
              if (currentRoute != RouteNames.aiAssistant) {
                Navigator.of(context).pushNamed(RouteNames.aiAssistant, arguments: appNum);
              }
            },
          ),
          _mobileNavItem(
            icon: Icons.notifications_none_rounded,
            label: 'Alerts',
            isSelected: currentRoute == RouteNames.notifications,
            onTap: () {
              if (currentRoute != RouteNames.notifications) {
                Navigator.of(context).pushNamed(RouteNames.notifications);
              }
            },
          ),
          _mobileNavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            isSelected: currentRoute == RouteNames.profile,
            onTap: () {
              if (currentRoute != RouteNames.profile) {
                Navigator.of(context).pushNamed(RouteNames.profile);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _mobileNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
