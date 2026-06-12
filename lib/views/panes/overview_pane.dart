import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';

class OverviewPane extends StatelessWidget {
  const OverviewPane({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final totalDeliveries = provider.deliveries.length;
    final activeDeliveries = provider.deliveries
        .where((d) => d.status != 'DELIVERED' && d.status != 'CANCELLED')
        .length;
    final totalUsers = provider.users.length;
    final approvedRiders = provider.riders
        .where((r) => r.onboardingStatus == 'APPROVED')
        .length;
    final pendingRiders = provider.riders
        .where((r) => r.onboardingStatus == 'PENDING')
        .length;
    final totalMerchants = provider.merchants.length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stat KPI Grid
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            children: [
              _buildStatCard(
                title: 'Active Deliveries',
                value: activeDeliveries.toString(),
                sub: 'Total: $totalDeliveries',
                icon: Icons.local_shipping_outlined,
                color: const Color(0xFF6C63FF),
              ),
              _buildStatCard(
                title: 'Pending Riders',
                value: pendingRiders.toString(),
                sub: 'Approved: $approvedRiders',
                icon: Icons.two_wheeler,
                color: const Color(0xFFFF9F43),
              ),
              _buildStatCard(
                title: 'Total Merchants',
                value: totalMerchants.toString(),
                sub: 'Partner accounts',
                icon: Icons.storefront,
                color: const Color(0xFF10AC84),
              ),
              _buildStatCard(
                title: 'Registered Users',
                value: totalUsers.toString(),
                sub: 'Across all roles',
                icon: Icons.people_outline,
                color: const Color(0xFF00D2D3),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Lower Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pending Onboarding List
              Expanded(
                flex: 2,
                child: _buildPendingRidersSection(context, provider),
              ),
              const SizedBox(width: 24),
              // System Info Panel
              Expanded(
                flex: 1,
                child: _buildSystemInfoSection(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF16162E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRidersSection(BuildContext context, DashboardProvider provider) {
    final pending = provider.riders.where((r) => r.onboardingStatus == 'PENDING').toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111122),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riders Awaiting Onboarding Approval',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9F43).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${pending.length} pending',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFF9F43),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (pending.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.done_all, color: Colors.white.withOpacity(0.2), size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No riders awaiting approval at this time.',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pending.length,
              separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.04)),
              itemBuilder: (context, idx) {
                final rider = pending[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plate: ${rider.vehiclePlateNum}',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vehicle: ${rider.vehicleType}',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => provider.rejectRider(rider.id),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFFF5252),
                            ),
                            child: const Text('Reject'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => provider.approveRider(rider.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10AC84),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: const Text('Approve'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111122),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'System Environment',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Host', 'localhost:8080'),
          _buildInfoRow('API Status', 'Online', success: true),
          _buildInfoRow('Version', '1.0.0-PROD'),
          _buildInfoRow('Flutter SDK', 'v3.38.9'),
          _buildInfoRow('Java VM', 'JVM 25.0.2'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool success = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
          Container(
            padding: success ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2) : null,
            decoration: success
                ? BoxDecoration(
                    color: const Color(0xFF10AC84).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: success ? const Color(0xFF10AC84) : Colors.white.withOpacity(0.85),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
