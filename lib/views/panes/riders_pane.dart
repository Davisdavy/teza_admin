import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/rider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';

class RidersPane extends StatefulWidget {
  const RidersPane({super.key});

  @override
  State<RidersPane> createState() => _RidersPaneState();
}

class _RidersPaneState extends State<RidersPane> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'ALL'; // ALL, PENDING, APPROVED, REJECTED

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final canDelete = authProvider.canDelete;

    final filteredRiders = dashboardProvider.riders.where((r) {
      // Search query filter
      final matchesQuery = r.vehiclePlateNum.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.vehicleType.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Status filter
      final matchesStatus = _statusFilter == 'ALL' || r.onboardingStatus == _statusFilter;

      return matchesQuery && matchesStatus;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111122),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header + Filters + Search
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riders (${filteredRiders.length})',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  // Onboarding status filter dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _statusFilter,
                        dropdownColor: const Color(0xFF16162E),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _statusFilter = val;
                            });
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All Statuses')),
                          DropdownMenuItem(value: 'PENDING', child: Text('Pending Only')),
                          DropdownMenuItem(value: 'APPROVED', child: Text('Approved Only')),
                          DropdownMenuItem(value: 'REJECTED', child: Text('Rejected Only')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Search field
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search plate or type...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4), size: 18),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.02),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Riders Table Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF16162E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Plate Number',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Vehicle Type',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Duty State',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Onboarding',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Actions',
                    textAlign: TextAlign.end,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Riders Table Body
          Expanded(
            child: filteredRiders.isEmpty
                ? Center(
                    child: Text(
                      'No riders match the active filters.',
                      style: GoogleFonts.inter(color: Colors.white.withOpacity(0.4)),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredRiders.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.04), height: 1),
                    itemBuilder: (context, idx) {
                      final rider = filteredRiders[idx];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                rider.vehiclePlateNum.isEmpty ? 'Not Provided' : rider.vehiclePlateNum,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                rider.vehicleType,
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _buildDutyIndicator(rider.available),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildOnboardingBadge(rider.onboardingStatus),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (rider.onboardingStatus == 'PENDING') ...[
                                    IconButton(
                                      icon: const Icon(Icons.check_circle_outline, color: Color(0xFF10AC84), size: 20),
                                      tooltip: 'Approve Rider',
                                      onPressed: () => dashboardProvider.approveRider(rider.id),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(Icons.cancel_outlined, color: Color(0xFFFF5252), size: 20),
                                      tooltip: 'Reject Rider',
                                      onPressed: () => dashboardProvider.rejectRider(rider.id),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  if (canDelete)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Color(0xFFFF5252), size: 20),
                                      tooltip: 'Delete Rider Profile',
                                      onPressed: () => _confirmDelete(context, dashboardProvider, rider),
                                    )
                                  else
                                    Tooltip(
                                      message: 'Only SUPER_ADMIN can delete rider profiles',
                                      child: IconButton(
                                        icon: Icon(Icons.delete_outline, color: Colors.white.withOpacity(0.15), size: 20),
                                        onPressed: null,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDutyIndicator(bool available) {
    final color = available ? const Color(0xFF10AC84) : const Color(0xFFFF9F43);
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          available ? 'Available' : 'Busy',
          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildOnboardingBadge(String status) {
    Color color;
    switch (status) {
      case 'APPROVED':
        color = const Color(0xFF10AC84);
        break;
      case 'REJECTED':
        color = const Color(0xFFFF5252);
        break;
      case 'PENDING':
      default:
        color = const Color(0xFFFF9F43);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Text(
            status,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, DashboardProvider provider, RiderProfile rider) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16162E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
          title: Text(
            'Delete Rider Profile?',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to permanently delete rider profile with plate ${rider.vehiclePlateNum}? This will remove onboarding records.',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await provider.deleteRider(rider.id);
                  if (context.mounted) Navigator.of(context).pop();
                } catch (e) {
                  // Handled by error overlay
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
              ),
              child: const Text('Confirm Delete'),
            ),
          ],
        );
      },
    );
  }
}
