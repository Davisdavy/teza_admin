import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/merchant.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';

class MerchantsPane extends StatefulWidget {
  const MerchantsPane({super.key});

  @override
  State<MerchantsPane> createState() => _MerchantsPaneState();
}

class _MerchantsPaneState extends State<MerchantsPane> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

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

    final filteredMerchants = dashboardProvider.merchants.where((m) {
      final nameMatch = m.businessName.toLowerCase().contains(_searchQuery.toLowerCase());
      final phoneMatch = m.phoneNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      final addressMatch = m.address.toLowerCase().contains(_searchQuery.toLowerCase());
      return nameMatch || phoneMatch || addressMatch;
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
          // Header + Search
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Merchants (${filteredMerchants.length})',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              // Search field
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search business, phone or address...',
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
          const SizedBox(height: 24),

          // Table Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF16162E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Business Name',
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
                    'Phone Number',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Physical Address',
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
                    'Date Joined',
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

          // Table Body
          Expanded(
            child: filteredMerchants.isEmpty
                ? Center(
                    child: Text(
                      'No merchants found matching your query.',
                      style: GoogleFonts.inter(color: Colors.white.withOpacity(0.4)),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredMerchants.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.04), height: 1),
                    itemBuilder: (context, idx) {
                      final merchant = filteredMerchants[idx];
                      final joinedDate = merchant.createdAt != null
                          ? DateFormat('MMM d, yyyy').format(merchant.createdAt!)
                          : 'N/A';

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                merchant.businessName,
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
                                merchant.phoneNumber,
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                merchant.address,
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                joinedDate,
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (canDelete)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Color(0xFFFF5252), size: 20),
                                      tooltip: 'Delete Merchant Profile',
                                      onPressed: () => _confirmDelete(context, dashboardProvider, merchant),
                                    )
                                  else
                                    Tooltip(
                                      message: 'Only SUPER_ADMIN can delete merchant profiles',
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

  void _confirmDelete(BuildContext context, DashboardProvider provider, MerchantProfile merchant) {
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
            'Delete Merchant Profile?',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to permanently delete merchant profile for "${merchant.businessName}"? This action cannot be undone.',
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
                  await provider.deleteMerchant(merchant.id);
                  if (context.mounted) Navigator.of(context).pop();
                } catch (e) {
                  // Handled by error overlay
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Confirm Delete',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
