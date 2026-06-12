import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import 'login_screen.dart';
import 'panes/overview_pane.dart';
import 'panes/users_pane.dart';
import 'panes/riders_pane.dart';
import 'panes/merchants_pane.dart';
import 'panes/deliveries_pane.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      // Fetch data initially on load
      Provider.of<DashboardProvider>(context, listen: false).fetchAllData();
      _isInit = false;
    }
  }

  final List<String> _titles = [
    'System Overview',
    'User Management',
    'Rider Directory & Onboarding',
    'Merchant Directory',
    'Deliveries & Dispatch Control',
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context);

    // Redirect to login if unauthenticated
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> panes = [
      const OverviewPane(),
      const UsersPane(),
      const RidersPane(),
      const MerchantsPane(),
      const DeliveriesPane(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(authProvider),
          
          // Main Work Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar
                _buildTopBar(authProvider, dashboardProvider),

                // Error Overlay Banner
                if (dashboardProvider.errorMessage != null)
                  _buildErrorBanner(dashboardProvider),

                // Active Pane Container
                Expanded(
                  child: dashboardProvider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6C63FF),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(28),
                          child: panes[_selectedIndex],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(AuthProvider auth) {
    final isSuperAdmin = auth.isSuperAdmin;
    final roleText = isSuperAdmin ? 'SUPER ADMIN' : 'SUPPORT';

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF111122),
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Branding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'TEZA ADMIN',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Sidebar Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSidebarItem(0, 'Overview', Icons.dashboard_outlined),
                _buildSidebarItem(1, 'Users', Icons.people_outline),
                _buildSidebarItem(2, 'Riders', Icons.two_wheeler),
                _buildSidebarItem(3, 'Merchants', Icons.storefront),
                _buildSidebarItem(4, 'Deliveries', Icons.local_shipping_outlined),
              ],
            ),
          ),

          // Admin User Profile Card at Bottom
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF16162E),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.04),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isSuperAdmin
                      ? const Color(0xFF6C63FF).withOpacity(0.2)
                      : const Color(0xFF00B0FF).withOpacity(0.2),
                  child: Icon(
                    isSuperAdmin ? Icons.security : Icons.support_agent,
                    color: isSuperAdmin ? const Color(0xFF8C84FF) : const Color(0xFF40C4FF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.currentUser?.email ?? 'Admin User',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSuperAdmin
                              ? const Color(0xFF6C63FF).withOpacity(0.15)
                              : const Color(0xFF00B0FF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          roleText,
                          style: GoogleFonts.inter(
                            color: isSuperAdmin ? const Color(0xFF8C84FF) : const Color(0xFF40C4FF),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.3) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF8C84FF) : Colors.white.withOpacity(0.5),
                size: 20,
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(AuthProvider auth, DashboardProvider dashboard) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF111122),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Active title
          Text(
            _titles[_selectedIndex],
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          // Utility buttons
          Row(
            children: [
              // Refresh button
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70),
                tooltip: 'Refresh Data',
                onPressed: () => dashboard.fetchAllData(),
              ),
              const SizedBox(width: 16),
              // Logout Button
              OutlinedButton.icon(
                onPressed: () => auth.logout(),
                icon: const Icon(Icons.logout, size: 16, color: Colors.white70),
                label: Text(
                  'Sign Out',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.12)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(DashboardProvider dashboard) {
    return Container(
      color: const Color(0xFFFF5252).withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF5252)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              dashboard.errorMessage!,
              style: GoogleFonts.inter(color: const Color(0xFFFF8A8A), fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70, size: 18),
            onPressed: () => dashboard.clearError(),
          ),
        ],
      ),
    );
  }
}
