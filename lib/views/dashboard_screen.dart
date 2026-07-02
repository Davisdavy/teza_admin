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
import 'panes/pricing_pane.dart';

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
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isMerchant) {
        _selectedIndex = 4; // default to Deliveries pane
      }
      // Fetch data initially on load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<DashboardProvider>(context, listen: false)
            .fetchAllData(isMerchant: auth.isMerchant);
      });
      _isInit = false;
    }
  }

  final List<String> _titles = [
    'System Overview',
    'User Management',
    'Rider Directory & Onboarding',
    'Merchant Directory',
    'Deliveries & Dispatch Control',
    'Pricing Scheme & Estimation',
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
      const PricingPane(),
    ];

    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      appBar: isMobile
          ? AppBar(
              backgroundColor: const Color(0xFF111122),
              elevation: 0,
              title: Text(
                _activeTitle,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  tooltip: 'Refresh Data',
                  onPressed: () => dashboardProvider.fetchAllData(isMerchant: authProvider.isMerchant),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white70),
                  tooltip: 'Sign Out',
                  onPressed: () => authProvider.logout(),
                ),
              ],
            )
          : null,
      drawer: isMobile
          ? Drawer(
              backgroundColor: const Color(0xFF111122),
              child: _buildSidebar(authProvider, isMobile: true),
            )
          : null,
      body: Row(
        children: [
          // Sidebar (Desktop only)
          if (!isMobile) _buildSidebar(authProvider, isMobile: false),
          
          // Main Work Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar (Desktop only)
                if (!isMobile) _buildTopBar(authProvider, dashboardProvider),

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
                          padding: EdgeInsets.all(isMobile ? 12 : 28),
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

  Widget _buildSidebar(AuthProvider auth, {required bool isMobile}) {
    final isSuperAdmin = auth.isSuperAdmin;
    final isMerchant = auth.isMerchant;
    String roleText = 'SUPPORT';
    if (isSuperAdmin) {
      roleText = 'SUPER ADMIN';
    } else if (isMerchant) {
      roleText = 'MERCHANT';
    } else if (auth.isSupportAdmin) {
      roleText = 'SUPPORT';
    }

    return Container(
      width: isMobile ? double.infinity : 280,
      decoration: BoxDecoration(
        color: const Color(0xFF111122),
        border: isMobile
            ? null
            : Border(
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
                if (!isMerchant) ...[
                  _buildSidebarItem(0, 'Overview', Icons.dashboard_outlined, isMobile),
                  _buildSidebarItem(1, 'Users', Icons.people_outline, isMobile),
                  _buildSidebarItem(2, 'Riders', Icons.two_wheeler, isMobile),
                  _buildSidebarItem(3, 'Merchants', Icons.storefront, isMobile),
                  _buildSidebarItem(5, 'Pricing Engine', Icons.calculate_outlined, isMobile),
                ] else ...[
                  _buildSidebarItem(5, 'Cost Estimator', Icons.calculate_outlined, isMobile),
                ],
                _buildSidebarItem(4, 'Deliveries', Icons.local_shipping_outlined, isMobile),
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
                      : isMerchant
                          ? const Color(0xFF10AC84).withOpacity(0.2)
                          : const Color(0xFF00B0FF).withOpacity(0.2),
                  child: Icon(
                    isSuperAdmin
                        ? Icons.security
                        : isMerchant
                            ? Icons.storefront
                            : Icons.support_agent,
                    color: isSuperAdmin
                        ? const Color(0xFF8C84FF)
                        : isMerchant
                            ? const Color(0xFF10AC84)
                            : const Color(0xFF40C4FF),
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
                              : isMerchant
                                  ? const Color(0xFF10AC84).withOpacity(0.15)
                                  : const Color(0xFF00B0FF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          roleText,
                          style: GoogleFonts.inter(
                            color: isSuperAdmin
                                ? const Color(0xFF8C84FF)
                                : isMerchant
                                    ? const Color(0xFF10AC84)
                                    : const Color(0xFF40C4FF),
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

  Widget _buildSidebarItem(int index, String title, IconData icon, bool isMobile) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          if (isMobile) {
            Navigator.of(context).pop(); // Close drawer
          }
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
            _activeTitle,
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
                onPressed: () => dashboard.fetchAllData(isMerchant: auth.isMerchant),
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

  String get _activeTitle {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (_selectedIndex == 5 && auth.isMerchant) {
      return 'Delivery Cost Estimator';
    }
    return _titles[_selectedIndex];
  }
}
