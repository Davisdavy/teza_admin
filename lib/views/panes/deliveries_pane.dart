import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/delivery.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';

class DeliveriesPane extends StatefulWidget {
  const DeliveriesPane({super.key});

  @override
  State<DeliveriesPane> createState() => _DeliveriesPaneState();
}

class _DeliveriesPaneState extends State<DeliveriesPane> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'ALL';

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
    final isMobile = MediaQuery.of(context).size.width < 800;

    final filteredDeliveries = dashboardProvider.deliveries.where((d) {
      final matchesQuery = d.pickupAddress.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.dropoffAddress.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.id.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _statusFilter == 'ALL' || d.status == _statusFilter;

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
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header + Filters + Search
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Deliveries (${filteredDeliveries.length})',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateDeliveryDialog(context, dashboardProvider),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Create Delivery', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _statusFilter,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF16162E),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            onChanged: (val) {
                              if (val != null) {
                                  setState(() {
                                    _statusFilter = val;
                                  });
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: 'ALL', child: Text('All Statuses')),
                              DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                              DropdownMenuItem(value: 'SEARCHING', child: Text('Searching')),
                              DropdownMenuItem(value: 'ASSIGNED', child: Text('Assigned')),
                              DropdownMenuItem(value: 'ACCEPTED', child: Text('Accepted')),
                              DropdownMenuItem(value: 'ARRIVED', child: Text('Arrived')),
                              DropdownMenuItem(value: 'PICKED_UP', child: Text('Picked Up')),
                              DropdownMenuItem(value: 'IN_TRANSIT', child: Text('In Transit')),
                              DropdownMenuItem(value: 'DELIVERED', child: Text('Delivered')),
                              DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search address...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12),
                          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4), size: 16),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.02),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Deliveries (${filteredDeliveries.length})',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateDeliveryDialog(context, dashboardProvider),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Create Delivery', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Status filter dropdown
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
                            DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                            DropdownMenuItem(value: 'SEARCHING', child: Text('Searching')),
                            DropdownMenuItem(value: 'ASSIGNED', child: Text('Assigned')),
                            DropdownMenuItem(value: 'ACCEPTED', child: Text('Accepted')),
                            DropdownMenuItem(value: 'ARRIVED', child: Text('Arrived')),
                            DropdownMenuItem(value: 'PICKED_UP', child: Text('Picked Up')),
                            DropdownMenuItem(value: 'IN_TRANSIT', child: Text('In Transit')),
                            DropdownMenuItem(value: 'DELIVERED', child: Text('Delivered')),
                            DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
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
                          hintText: 'Search address or delivery ID...',
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
          SizedBox(height: isMobile ? 12 : 24),

          // Deliveries Table Headers (Desktop only)
          if (!isMobile) ...[
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
                      'Pickup Address',
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
                      'Dropoff Address',
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
                      'Fee',
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
                      'Status',
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
                      'Created At',
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
          ],

          // Deliveries Table Body
          Expanded(
            child: filteredDeliveries.isEmpty
                ? Center(
                    child: Text(
                      'No deliveries found matching your search.',
                      style: GoogleFonts.inter(color: Colors.white.withOpacity(0.4)),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredDeliveries.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.04), height: 1),
                    itemBuilder: (context, idx) {
                      final delivery = filteredDeliveries[idx];

                      if (isMobile) {
                        return _buildMobileDeliveryCard(context, dashboardProvider, delivery, canDelete);
                      }

                      final formattedDate = delivery.createdAt != null
                          ? DateFormat('MMM d, HH:mm').format(delivery.createdAt!)
                          : 'N/A';

                      return InkWell(
                        onTap: () => _showDetailsDialog(context, dashboardProvider, delivery, canDelete),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  delivery.pickupAddress,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  delivery.dropoffAddress,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'KES ${delivery.deliveryFee.toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: _buildStatusBadge(delivery.status),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  formattedDate,
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
                                    IconButton(
                                      icon: const Icon(Icons.info_outline, color: Colors.white70, size: 20),
                                      tooltip: 'View Logs & Matching Riders',
                                      onPressed: () => _showDetailsDialog(context, dashboardProvider, delivery, canDelete),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'PENDING':
        color = const Color(0xFFFF9F43);
        break;
      case 'SEARCHING':
        color = const Color(0xFFFD79A8);
        break;
      case 'ASSIGNED':
      case 'ACCEPTED':
        color = const Color(0xFF00B0FF);
        break;
      case 'ARRIVED':
        color = const Color(0xFF00D2D3);
        break;
      case 'PICKED_UP':
        color = const Color(0xFF6C63FF);
        break;
      case 'IN_TRANSIT':
        color = const Color(0xFF54A0FF);
        break;
      case 'DELIVERED':
        color = const Color(0xFF10AC84);
        break;
      case 'CANCELLED':
        color = const Color(0xFFFF5252);
        break;
      default:
        color = Colors.grey;
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

  Widget _buildMobileDeliveryCard(BuildContext context, DashboardProvider provider, Delivery delivery, bool canDelete) {
    final formattedDate = delivery.createdAt != null
        ? DateFormat('MMM d, HH:mm').format(delivery.createdAt!)
        : 'N/A';
    return Card(
      color: const Color(0xFF16162E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDetailsDialog(context, provider, delivery, canDelete),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${delivery.id.substring(0, 8)}...',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF8C84FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  _buildStatusBadge(delivery.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.circle, size: 10, color: Colors.greenAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      delivery.pickupAddress,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 12, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      delivery.dropoffAddress,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'KES ${delivery.deliveryFee.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(
    BuildContext context,
    DashboardProvider provider,
    Delivery delivery,
    bool canDelete,
  ) {
    provider.fetchDeliveryDetails(delivery.id);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final freshProvider = Provider.of<DashboardProvider>(context);
            final auth = Provider.of<AuthProvider>(context, listen: false);
            final isMerchant = auth.isMerchant;
            final isMobile = MediaQuery.of(context).size.width < 800;
            
            // Build Status Update inputs
            String? forcedStatus;
            final reasonController = TextEditingController();

            final detailsContent = ListView(
              shrinkWrap: isMobile,
              children: [
                // Info Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16162E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Info',
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildSelectableMetaRow('Delivery ID', delivery.id),
                      _buildMetaRow('Status', delivery.status),
                      _buildSelectableMetaRow('Merchant ID', delivery.merchantId),
                      _buildSelectableMetaRow('Customer ID', delivery.customerId),
                      _buildSelectableMetaRow('Rider ID', delivery.riderId ?? 'Not Assigned'),
                      _buildMetaRow('Pickup', delivery.pickupAddress),
                      _buildMetaRow('Dropoff', delivery.dropoffAddress),
                      _buildMetaRow('Fee', 'KES ${delivery.deliveryFee.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action Panel
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16162E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isMerchant) ...[
                        Text(
                          'Merchant Controls',
                          style: GoogleFonts.outfit(
                              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (delivery.status == 'PENDING') ...[
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await provider.updateDeliveryStatus(
                                  delivery.id,
                                  'SEARCHING',
                                  'Merchant published order to search',
                                );
                                provider.fetchDeliveryDetails(delivery.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Delivery published to nearby riders')),
                                  );
                                }
                              } catch (_) {}
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.flash_on),
                            label: const Text('Publish / Search Riders'),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (delivery.status != 'DELIVERED' && delivery.status != 'CANCELLED') ...[
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await provider.updateDeliveryStatus(
                                  delivery.id,
                                  'CANCELLED',
                                  'Cancelled by merchant',
                                );
                                provider.fetchDeliveryDetails(delivery.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Delivery cancelled successfully')),
                                  );
                                }
                              } catch (_) {}
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5252),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancel Order'),
                          ),
                        ] else ...[
                          Text(
                            delivery.status == 'DELIVERED'
                                ? 'Order has been delivered.'
                                : 'Order has been cancelled.',
                            style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ]
                      ] else ...[
                        Text(
                          'Manual Override Status',
                          style: GoogleFonts.outfit(
                              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          dropdownColor: const Color(0xFF131326),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Forced Status',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                          items: [
                            'PENDING',
                            'SEARCHING',
                            'ASSIGNED',
                            'ACCEPTED',
                            'ARRIVED',
                            'PICKED_UP',
                            'IN_TRANSIT',
                            'DELIVERED',
                            'CANCELLED'
                          ]
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (val) {
                            forcedStatus = val;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: reasonController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Reason for status update',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (forcedStatus != null && reasonController.text.isNotEmpty) {
                              try {
                                await provider.updateDeliveryStatus(
                                  delivery.id,
                                  forcedStatus!,
                                  reasonController.text.trim(),
                                );
                                provider.fetchDeliveryDetails(delivery.id);
                                reasonController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Delivery status updated successfully')),
                                );
                              } catch (e) {}
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Update Status',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isMobile) ...[
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: Text(
                      'History Logs',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      _buildHistoryTab(freshProvider.activeHistory, shrinkWrap: true),
                    ],
                  ),
                  if (!isMerchant) ...[
                    ExpansionTile(
                      title: Text(
                        'Rider Offers',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      children: [
                        _buildOffersTab(freshProvider.activeOffers, shrinkWrap: true),
                      ],
                    ),
                    ExpansionTile(
                      title: Text(
                        'Matching Riders',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      children: [
                        _buildMatchingTab(
                          context,
                          freshProvider.activeMatchingRiders,
                          provider,
                          delivery,
                          shrinkWrap: true,
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            );

            return AlertDialog(
              backgroundColor: const Color(0xFF131326),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Details (ID: ${delivery.id.substring(0, 8)}...)',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  if (canDelete)
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await provider.deleteDelivery(delivery.id);
                          if (context.mounted) Navigator.of(context).pop();
                        } catch (_) {}
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5252),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.delete, size: 14, color: Colors.white),
                      label: Text(
                        'Delete',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (!isMerchant)
                    const Tooltip(
                      message: 'Only SUPER_ADMIN can delete deliveries',
                      child: ElevatedButton(
                        onPressed: null,
                        child: Text('Delete Locked', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                ],
              ),
              content: SizedBox(
                width: isMobile ? double.maxFinite : 950,
                height: isMobile ? MediaQuery.of(context).size.height * 0.8 : 600,
                child: isMobile
                    ? detailsContent
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Column
                          Expanded(
                            flex: 1,
                            child: detailsContent,
                          ),
                          const SizedBox(width: 20),

                          // Right Column: Tabs (Logs, Offers, Dispatch Matches)
                          Expanded(
                            flex: 2,
                            child: DefaultTabController(
                              length: isMerchant ? 1 : 3,
                              child: Column(
                                children: [
                                  TabBar(
                                    labelColor: const Color(0xFF8C84FF),
                                    unselectedLabelColor: Colors.white.withOpacity(0.5),
                                    indicatorColor: const Color(0xFF6C63FF),
                                    tabs: [
                                      const Tab(text: 'History Logs'),
                                      if (!isMerchant) ...[
                                        const Tab(text: 'Rider Offers'),
                                        const Tab(text: 'Matching Riders (Dispatch)'),
                                      ],
                                    ],
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      children: [
                                        // Tab 1: History Logs
                                        _buildHistoryTab(freshProvider.activeHistory),
                                        // Tab 2 & 3: Admin only
                                        if (!isMerchant) ...[
                                          _buildOffersTab(freshProvider.activeOffers),
                                          _buildMatchingTab(
                                            context,
                                            freshProvider.activeMatchingRiders,
                                            provider,
                                            delivery,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close', style: GoogleFonts.inter(color: Colors.white38)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white30, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSelectableMetaRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white30, fontSize: 11)),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: GoogleFonts.inter(
              color: const Color(0xFF8C84FF),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(List<dynamic> logs, {bool shrinkWrap = false}) {
    if (logs.isEmpty) {
      return Center(
          child: Text('No status history logs recorded.', style: TextStyle(color: Colors.white.withOpacity(0.3))));
    }
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.only(top: 16),
      itemCount: logs.length,
      separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.04)),
      itemBuilder: (context, idx) {
        final log = logs[idx];
        final timeStr = log.createdAt != null
            ? DateFormat('MMM d, yyyy HH:mm').format(log.createdAt)
            : 'N/A';
        return ListTile(
          dense: true,
          title: Text(log.status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('Reason: ${log.reason ?? 'N/A'}', style: TextStyle(color: Colors.white.withOpacity(0.7))),
              const SizedBox(height: 2),
              Text('Changed By User: ${log.changedByUserId ?? 'System'}',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
            ],
          ),
          trailing: Text(timeStr, style: TextStyle(color: Colors.white.withOpacity(0.4))),
        );
      },
    );
  }

  Widget _buildOffersTab(List<dynamic> offers, {bool shrinkWrap = false}) {
    if (offers.isEmpty) {
      return Center(
          child: Text('No rider offers dispatched yet.', style: TextStyle(color: Colors.white.withOpacity(0.3))));
    }
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.only(top: 16),
      itemCount: offers.length,
      separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.04)),
      itemBuilder: (context, idx) {
        final offer = offers[idx];
        final expiresStr = offer.expiresAt != null
            ? DateFormat('HH:mm:ss').format(offer.expiresAt)
            : 'N/A';
        return ListTile(
          dense: true,
          title: Text('Rider: ${offer.riderId}', style: const TextStyle(color: Colors.white)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              SelectableText(
                'Offer ID: ${offer.id}',
                style: const TextStyle(color: Color(0xFF8C84FF), fontWeight: FontWeight.bold, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text('Expires at: $expiresStr', style: TextStyle(color: Colors.white.withOpacity(0.4))),
            ],
          ),
          trailing: _buildOfferStatusBadge(offer.status),
        );
      },
    );
  }

  Widget _buildOfferStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'ACCEPTED') color = const Color(0xFF10AC84);
    if (status == 'REJECTED') color = const Color(0xFFFF5252);
    if (status == 'EXPIRED') color = const Color(0xFFFF9F43);
    if (status == 'PENDING') color = const Color(0xFF00B0FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMatchingTab(
    BuildContext context,
    List<dynamic> riders,
    DashboardProvider provider,
    Delivery delivery, {
    bool shrinkWrap = false,
  }) {
    if (riders.isEmpty) {
      return Center(
          child: Text('No matching riders found in area.', style: TextStyle(color: Colors.white.withOpacity(0.3))));
    }

    final list = ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: riders.length,
      separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.04)),
      itemBuilder: (context, idx) {
        final rider = riders[idx];
        return ListTile(
          dense: true,
          title: Text('Rider ID: ${rider.riderId}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(
            'Distance: ${rider.distanceKm.toStringAsFixed(2)} km | Score: ${rider.score.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          trailing: delivery.status == 'DELIVERED'
              ? null
              : ElevatedButton(
                  onPressed: () async {
                    try {
                      await provider.dispatchOffer(delivery.id, rider.riderId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Offer dispatched to rider successfully')),
                      );
                    } catch (e) {
                      // Handled by error banner
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10AC84),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Dispatch Offer',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        );
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Ranked matching riders nearby. Choose a rider to manually dispatch an offer.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        if (shrinkWrap) list else Expanded(child: list),
      ],
    );
  }

  void _showCreateDeliveryDialog(BuildContext context, DashboardProvider provider) {
    final formKey = GlobalKey<FormState>();
    final pickupAddressController = TextEditingController();
    final pickupLatitudeController = TextEditingController();
    final pickupLongitudeController = TextEditingController();
    final dropoffAddressController = TextEditingController();
    final dropoffLatitudeController = TextEditingController();
    final dropoffLongitudeController = TextEditingController();
    final deliveryFeeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF131326),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
          title: Text(
            'Create New Delivery Order',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quick Select Pickup Preset
                    DropdownButtonFormField<Map<String, dynamic>>(
                      dropdownColor: const Color(0xFF16162E),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputDecoration('Select Pickup Preset').copyWith(
                        labelText: 'Quick Select Pickup Landmark',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                      items: _nairobiPresets.map((preset) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: preset,
                          child: Text(preset['name'] as String),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          pickupAddressController.text = val['name'] as String;
                          pickupLatitudeController.text = val['lat'].toString();
                          pickupLongitudeController.text = val['lng'].toString();
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pickup Address
                    Text('Pickup Address', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: pickupAddressController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('e.g. Mwimuto Shopping Center'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Pickup Coordinates
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pickup Latitude', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: pickupLatitudeController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('-1.2543'),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Required';
                                  final num = double.tryParse(val);
                                  if (num == null || num < -90.0 || num > 90.0) return 'Invalid (-90 to 90)';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pickup Longitude', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: pickupLongitudeController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('36.7582'),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Required';
                                  final num = double.tryParse(val);
                                  if (num == null || num < -180.0 || num > 180.0) return 'Invalid (-180 to 180)';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quick Select Dropoff Preset
                    DropdownButtonFormField<Map<String, dynamic>>(
                      dropdownColor: const Color(0xFF16162E),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputDecoration('Select Dropoff Preset').copyWith(
                        labelText: 'Quick Select Dropoff Landmark',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                      items: _nairobiPresets.map((preset) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: preset,
                          child: Text(preset['name'] as String),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          dropoffAddressController.text = val['name'] as String;
                          dropoffLatitudeController.text = val['lat'].toString();
                          dropoffLongitudeController.text = val['lng'].toString();
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dropoff Address
                    Text('Dropoff Address', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: dropoffAddressController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('e.g. Wangige Market'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Dropoff Coordinates
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dropoff Latitude', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: dropoffLatitudeController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('-1.2612'),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Required';
                                  final num = double.tryParse(val);
                                  if (num == null || num < -90.0 || num > 90.0) return 'Invalid (-90 to 90)';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dropoff Longitude', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: dropoffLongitudeController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('36.7410'),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Required';
                                  final num = double.tryParse(val);
                                  if (num == null || num < -180.0 || num > 180.0) return 'Invalid (-180 to 180)';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Delivery Fee
                    Text('Delivery Fee (KES)', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: deliveryFeeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('150'),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        final num = double.tryParse(val);
                        if (num == null || num < 0.0) return 'Must be positive';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await provider.createDelivery(
                      pickupAddress: pickupAddressController.text.trim(),
                      pickupLatitude: double.parse(pickupLatitudeController.text),
                      pickupLongitude: double.parse(pickupLongitudeController.text),
                      dropoffAddress: dropoffAddressController.text.trim(),
                      dropoffLatitude: double.parse(dropoffLatitudeController.text),
                      dropoffLongitude: double.parse(dropoffLongitudeController.text),
                      deliveryFee: double.parse(deliveryFeeController.text),
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Delivery order created successfully')),
                      );
                    }
                  } catch (e) {
                    // Handled by error banner
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Create Order',
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.02),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF6C63FF)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF5252)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF5252)),
      ),
    );
  }
}

const List<Map<String, dynamic>> _nairobiPresets = [
  {"name": "Nairobi CBD (General)", "lat": -1.2921, "lng": 36.8219},
  {"name": "Westlands (Sarit Centre)", "lat": -1.2628, "lng": 36.8041},
  {"name": "Kilimani (Yaya Centre)", "lat": -1.2913, "lng": 36.7979},
  {"name": "Karen (The Hub)", "lat": -1.3195, "lng": 36.7061},
  {"name": "Gigiri (Village Market)", "lat": -1.2294, "lng": 36.8048},
  {"name": "Mombasa Road (JKIA)", "lat": -1.3323, "lng": 36.9211},
  {"name": "Thika Road (Garden City)", "lat": -1.2227, "lng": 36.8837},
  {"name": "Wangige Market", "lat": -1.2612, "lng": 36.7410},
  {"name": "Mwimuto Shopping Center", "lat": -1.2543, "lng": 36.7582},
];
