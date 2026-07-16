import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/delivery.dart';
import '../../models/rider.dart';
import '../../models/rider_location.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/api_service.dart';

class LiveTrackingPane extends StatefulWidget {
  const LiveTrackingPane({super.key});

  @override
  State<LiveTrackingPane> createState() => _LiveTrackingPaneState();
}

class _LiveTrackingPaneState extends State<LiveTrackingPane> {
  Delivery? _selectedDelivery;
  RiderProfile? _riderProfile;
  RiderLocation? _riderLocation;
  bool _loadingRider = false;
  String? _riderError;
  Timer? _trackingTimer;

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  void _selectDelivery(Delivery delivery) {
    setState(() {
      _selectedDelivery = delivery;
      _riderProfile = null;
      _riderLocation = null;
      _riderError = null;
    });
    _trackingTimer?.cancel();

    if (delivery.riderId != null) {
      _fetchRiderDetails(delivery.riderId!);
      // Start periodic updates every 5 seconds
      _trackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_selectedDelivery?.id == delivery.id && delivery.riderId != null) {
          _refreshRiderLocation(delivery.riderId!);
        } else {
          timer.cancel();
        }
      });
    }
  }

  Future<void> _fetchRiderDetails(String riderId) async {
    if (!mounted) return;
    setState(() {
      _loadingRider = true;
      _riderError = null;
    });

    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final profile = await apiService.getRiderProfile(riderId);
      final location = await apiService.getRiderLocation(riderId).catchError((_) => null);
      if (!mounted) return;

      setState(() {
        _riderProfile = profile;
        _riderLocation = location;
        _loadingRider = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _riderError = e.toString().replaceFirst('Exception: ', '');
        _loadingRider = false;
      });
    }
  }

  Future<void> _refreshRiderLocation(String riderId) async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final location = await apiService.getRiderLocation(riderId);
      if (!mounted) return;
      setState(() {
        _riderLocation = location;
      });
    } catch (_) {
      // Silently ignore periodic refresh errors to keep UI smooth
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // pi / 180
    final a = 0.5 - math.cos((lat2 - lat1) * p)/2 + 
          math.cos(lat1 * p) * math.cos(lat2 * p) * 
          (1 - math.cos((lon2 - lon1) * p))/2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final activeStatuses = ['ASSIGNED', 'ARRIVED', 'PICKED_UP', 'IN_TRANSIT'];
    
    // Filter active deliveries for this merchant
    final activeDeliveries = dashboardProvider.deliveries
        .where((d) => activeStatuses.contains(d.status))
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sidebar list of active deliveries
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: const Color(0xFF111122),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.explore_outlined, color: Color(0xFF6C63FF), size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Active Deliveries',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        activeDeliveries.length.toString(),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8C84FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              Expanded(
                child: activeDeliveries.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_shipping_outlined, color: Colors.white30, size: 40),
                              const SizedBox(height: 12),
                              Text(
                                'No active deliveries',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: Colors.white38,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: activeDeliveries.length,
                        separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                        itemBuilder: (context, index) {
                          final delivery = activeDeliveries[index];
                          final isSelected = _selectedDelivery?.id == delivery.id;
                          return InkWell(
                            onTap: () => _selectDelivery(delivery),
                            child: Container(
                              color: isSelected ? Colors.white.withOpacity(0.03) : Colors.transparent,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Dropoff: ${delivery.dropoffAddress}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStatusBadge(delivery.status),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'ID: ${delivery.id.substring(0, 8)}...',
                                    style: GoogleFonts.inter(
                                      color: Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Fee: \$${delivery.deliveryFee.toStringAsFixed(2)}',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF10AC84),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
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
        ),
        const SizedBox(width: 24),
        // Tracking board details panel
        Expanded(
          child: _selectedDelivery == null
              ? _buildEmptyState()
              : _buildTrackingBoard(context),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16162E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.explore_outlined,
                color: Color(0xFF6C63FF),
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Live Delivery Tracking',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select an active delivery from the left pane to monitor rider\nmovement, ETA, and pickup arrivals in real-time.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white38,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingBoard(BuildContext context) {
    final delivery = _selectedDelivery!;
    
    // Status banner updates
    Widget statusNotice = const SizedBox.shrink();
    if (delivery.status == 'ARRIVED') {
      statusNotice = Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF10AC84).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10AC84).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10AC84), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rider Arrived at Store!',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF10AC84),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'The rider is currently at your pickup location. Please dispatch the package immediately.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (delivery.status == 'IN_TRANSIT') {
      statusNotice = Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.directions_run_rounded, color: Color(0xFF6C63FF), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rider is In Transit',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF8C84FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rider is on the road delivering the order to the dropoff destination.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Dynamic calculations
    double distanceKm = 0.0;
    int etaMinutes = 0;
    if (_riderLocation != null) {
      final isGoingToPickup = delivery.status == 'ASSIGNED' || delivery.status == 'ARRIVED';
      final targetLat = isGoingToPickup ? delivery.pickupLatitude : delivery.dropoffLatitude;
      final targetLng = isGoingToPickup ? delivery.pickupLongitude : delivery.dropoffLongitude;

      distanceKm = _calculateDistance(
        _riderLocation!.latitude,
        _riderLocation!.longitude,
        targetLat,
        targetLng,
      );
      
      const averageSpeed = 30.0; // 30 km/h average city speed
      etaMinutes = (distanceKm / averageSpeed * 60).round();
      if (etaMinutes < 1) etaMinutes = 1;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Notice banner
          statusNotice,

          // Main Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF16162E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery ID: ${delivery.id}',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created At: ${delivery.createdAt?.toLocal().toString().substring(0, 16) ?? 'N/A'}',
                          style: GoogleFonts.inter(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    _buildStatusBadge(delivery.status, large: true),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildAddressCol('Pickup Location 🏪', delivery.pickupAddress),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildAddressCol('Dropoff Location 📍', delivery.dropoffAddress),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Steps Timeline Tracker
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF16162E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Lifecycle',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTimeline(delivery.status),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Live Tracker stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16162E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assigned Rider Profile',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_loadingRider)
                        const Center(child: CircularProgressIndicator())
                      else if (_riderError != null)
                        Text(
                          'Error loading rider: $_riderError',
                          style: GoogleFonts.inter(color: const Color(0xFFFF5252), fontSize: 13),
                        )
                      else if (_riderProfile == null)
                        Text(
                          'No rider assigned',
                          style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                        )
                      else ...[
                        _buildRiderDetailRow('Rider ID', _riderProfile!.id),
                        _buildRiderDetailRow('Vehicle Type', _riderProfile!.vehicleType.toUpperCase()),
                        _buildRiderDetailRow('Plate Number', _riderProfile!.vehiclePlateNum),
                        _buildRiderDetailRow('Total Deliveries', '${_riderProfile!.totalDeliveries} completed'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16162E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Live Tracking Stats',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_riderLocation != null)
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10AC84),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Live',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF10AC84),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_riderLocation == null)
                        Text(
                          _loadingRider
                              ? 'Locating rider...'
                              : 'Rider coordinates not available. The rider app might be offline or has disabled tracking permission.',
                          style: GoogleFonts.inter(color: Colors.white38, fontSize: 13, height: 1.5),
                        )
                      else ...[
                        _buildRiderDetailRow(
                          delivery.status == 'ASSIGNED' || delivery.status == 'ARRIVED'
                              ? 'Distance to Store'
                              : 'Distance to Dropoff',
                          '${distanceKm.toStringAsFixed(2)} km',
                        ),
                        _buildRiderDetailRow(
                          delivery.status == 'ASSIGNED' || delivery.status == 'ARRIVED'
                              ? 'Est. Pickup Time'
                              : 'Est. Delivery Time',
                          '$etaMinutes min',
                          valueColor: const Color(0xFF00E676),
                        ),
                        _buildRiderDetailRow(
                          'Last Update',
                          _riderLocation!.updatedAt != null
                              ? '${DateTime.now().difference(_riderLocation!.updatedAt!).inSeconds}s ago'
                              : 'Just now',
                        ),
                        _buildRiderDetailRow(
                          'Current Coords',
                          '${_riderLocation!.latitude.toStringAsFixed(4)}, ${_riderLocation!.longitude.toStringAsFixed(4)}',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.4),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildRiderDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, {bool large = false}) {
    Color color = const Color(0xFF6C63FF);
    if (status == 'PENDING' || status == 'SEARCHING') {
      color = const Color(0xFFFF9F43);
    } else if (status == 'ARRIVED') {
      color = const Color(0xFF00D2D3);
    } else if (status == 'PICKED_UP' || status == 'IN_TRANSIT') {
      color = const Color(0xFF00B0FF);
    } else if (status == 'DELIVERED') {
      color = const Color(0xFF10AC84);
    } else if (status == 'CANCELLED') {
      color = const Color(0xFFFF5252);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: large ? 12 : 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final steps = ['ASSIGNED', 'ARRIVED', 'PICKED_UP', 'IN_TRANSIT', 'DELIVERED'];
    final int currentIdx = steps.indexOf(currentStatus);

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Line separator
          final stepIdx = (index - 1) ~/ 2;
          final passed = stepIdx < currentIdx;
          return Expanded(
            child: Container(
              height: 2,
              color: passed ? const Color(0xFF6C63FF) : Colors.white10,
            ),
          );
        } else {
          // Node step
          final stepIdx = index ~/ 2;
          final stepName = steps[stepIdx];
          final active = stepIdx == currentIdx;
          final completed = stepIdx < currentIdx;

          return Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF6C63FF)
                      : completed
                          ? const Color(0xFF6C63FF).withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: active
                      ? Border.all(color: Colors.white, width: 2)
                      : completed
                          ? Border.all(color: const Color(0xFF6C63FF).withOpacity(0.5), width: 1.5)
                          : Border.all(color: Colors.white10, width: 1.5),
                ),
                child: Icon(
                  completed ? Icons.check : Icons.circle,
                  size: completed ? 12 : 8,
                  color: active
                      ? Colors.white
                      : completed
                          ? const Color(0xFF6C63FF)
                          : Colors.transparent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatStepLabel(stepName),
                style: GoogleFonts.inter(
                  color: active
                      ? Colors.white
                      : completed
                          ? Colors.white70
                          : Colors.white30,
                  fontSize: 10,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }
      }),
    );
  }

  String _formatStepLabel(String step) {
    switch (step) {
      case 'ASSIGNED':
        return 'Assigned';
      case 'ARRIVED':
        return 'Arrived';
      case 'PICKED_UP':
        return 'Picked Up';
      case 'IN_TRANSIT':
        return 'In Transit';
      case 'DELIVERED':
        return 'Delivered';
      default:
        return step;
    }
  }
}
