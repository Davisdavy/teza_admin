import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/pricing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/google_place_autocomplete.dart';

class PricingPane extends StatefulWidget {
  const PricingPane({super.key});

  @override
  State<PricingPane> createState() => _PricingPaneState();
}

class _PricingPaneState extends State<PricingPane> {
  int _activeTab = 0; // 0 = Config, 1 = Calculator

  final _formKey = GlobalKey<FormState>();
  final _baseFeeController = TextEditingController();
  final _pricePerKmController = TextEditingController();
  final _pricePerMinController = TextEditingController();
  final _minFeeController = TextEditingController();
  final _maxFeeController = TextEditingController();
  final _peakMultiplierController = TextEditingController();
  final _weekendMultiplierController = TextEditingController();
  final _nightMultiplierController = TextEditingController();
  bool _surgeEnabled = false;

  // Calculator inputs
  final _calcFormKey = GlobalKey<FormState>();
  final _pickupAddressController = TextEditingController();
  final _dropoffAddressController = TextEditingController();
  final _pickupLatController = TextEditingController();
  final _pickupLngController = TextEditingController();
  final _dropoffLatController = TextEditingController();
  final _dropoffLngController = TextEditingController();

  PricingEstimate? _calcResult;
  bool _isCalculating = false;
  bool _isSaving = false;
  bool _isConfigLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _isConfigLoading = true);
      Provider.of<DashboardProvider>(context, listen: false).fetchPricingConfig().then((_) {
        _loadConfigToControllers();
      }).whenComplete(() {
        if (mounted) {
          setState(() => _isConfigLoading = false);
        }
      });
    });
  }

  void _loadConfigToControllers() {
    final config = Provider.of<DashboardProvider>(context, listen: false).pricingConfig;
    if (config != null) {
      _baseFeeController.text = config.baseFee.toStringAsFixed(0);
      _pricePerKmController.text = config.pricePerKilometer.toStringAsFixed(0);
      _pricePerMinController.text = config.pricePerMinute.toStringAsFixed(0);
      _minFeeController.text = config.minimumDeliveryFee.toStringAsFixed(0);
      _maxFeeController.text = config.maximumDeliveryFee.toStringAsFixed(0);
      _peakMultiplierController.text = config.peakHourMultiplier.toStringAsFixed(2);
      _weekendMultiplierController.text = config.weekendMultiplier.toStringAsFixed(2);
      _nightMultiplierController.text = config.nightMultiplier.toStringAsFixed(2);
      setState(() {
        _surgeEnabled = config.surgeEnabled;
      });
    }
  }

  @override
  void dispose() {
    _baseFeeController.dispose();
    _pricePerKmController.dispose();
    _pricePerMinController.dispose();
    _minFeeController.dispose();
    _maxFeeController.dispose();
    _peakMultiplierController.dispose();
    _weekendMultiplierController.dispose();
    _nightMultiplierController.dispose();
    _pickupAddressController.dispose();
    _dropoffAddressController.dispose();
    _pickupLatController.dispose();
    _pickupLngController.dispose();
    _dropoffLatController.dispose();
    _dropoffLngController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
      filled: true,
      fillColor: Colors.white.withOpacity(0.01),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = Provider.of<DashboardProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final isSuperAdmin = auth.isSuperAdmin;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111122),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title & Tab switches
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pricing Engine Settings',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  _buildTabButton(0, 'Configure Settings', Icons.settings_outlined),
                  const SizedBox(width: 12),
                  _buildTabButton(1, 'Fee Estimator Tool', Icons.calculate_outlined),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          Expanded(
            child: _isConfigLoading && dashboard.pricingConfig == null
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
                : SingleChildScrollView(
                    child: _activeTab == 0 ? _buildConfigTab(isSuperAdmin, dashboard) : _buildCalculatorTab(dashboard),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int tabIndex, String label, IconData icon) {
    final isActive = _activeTab == tabIndex;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = tabIndex;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF8C84FF) : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.white60, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigTab(bool isSuperAdmin, DashboardProvider dashboard) {
    if (dashboard.pricingConfig == null) {
      return Center(
        child: Text(
          'Failed to load pricing configuration. Check console or reload.',
          style: GoogleFonts.inter(color: Colors.white38),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSuperAdmin)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amberAccent, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Read-only view. Only Super Admins can save modifications to the pricing configuration.',
                      style: GoogleFonts.inter(color: Colors.amberAccent, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          Text(
            'Core Pricing Scheme',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: [
              TextFormField(
                controller: _baseFeeController,
                style: const TextStyle(color: Colors.white),
                enabled: isSuperAdmin,
                decoration: _inputDecoration('Base Fee (KES)'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _pricePerKmController,
                style: const TextStyle(color: Colors.white),
                enabled: isSuperAdmin,
                decoration: _inputDecoration('Price Per Kilometer (KES)'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _pricePerMinController,
                style: const TextStyle(color: Colors.white),
                enabled: isSuperAdmin,
                decoration: _inputDecoration('Price Per Minute (KES)'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _minFeeController,
                style: const TextStyle(color: Colors.white),
                enabled: isSuperAdmin,
                decoration: _inputDecoration('Minimum Delivery Fee (KES)'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _maxFeeController,
                style: const TextStyle(color: Colors.white),
                enabled: isSuperAdmin,
                decoration: _inputDecoration('Maximum Delivery Fee (KES)'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
            ],
          ),

          const SizedBox(height: 32),
          Divider(color: Colors.white.withOpacity(0.06)),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Surge / Multiplier Settings',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Apply Peak, Weekend, and Night hour price multipliers dynamically.',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              Switch(
                value: _surgeEnabled,
                onChanged: isSuperAdmin
                    ? (val) {
                        setState(() {
                          _surgeEnabled = val;
                        });
                      }
                    : null,
                activeColor: const Color(0xFF6C63FF),
                inactiveThumbColor: Colors.white30,
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: [
              TextFormField(
                controller: _peakMultiplierController,
                style: const TextStyle(color: Colors.white),
                enabled: isSuperAdmin && _surgeEnabled,
                decoration: _inputDecoration('Peak Hour Multiplier'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _weekendMultiplierController,
                style: const TextStyle(color: Colors.white),
                enabled: isSuperAdmin && _surgeEnabled,
                decoration: _inputDecoration('Weekend Multiplier'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _nightMultiplierController,
                style: const TextStyle(color: Colors.white),
                enabled: isSuperAdmin && _surgeEnabled,
                decoration: _inputDecoration('Night Multiplier'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
            ],
          ),

          const SizedBox(height: 40),
          if (isSuperAdmin)
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isSaving = true);
                        final newConfig = PricingConfiguration(
                          id: dashboard.pricingConfig!.id,
                          baseFee: double.parse(_baseFeeController.text),
                          pricePerKilometer: double.parse(_pricePerKmController.text),
                          pricePerMinute: double.parse(_pricePerMinController.text),
                          minimumDeliveryFee: double.parse(_minFeeController.text),
                          maximumDeliveryFee: double.parse(_maxFeeController.text),
                          surgeEnabled: _surgeEnabled,
                          peakHourMultiplier: double.parse(_peakMultiplierController.text),
                          weekendMultiplier: double.parse(_weekendMultiplierController.text),
                          nightMultiplier: double.parse(_nightMultiplierController.text),
                          updatedAt: DateTime.now(),
                        );
                        try {
                          await dashboard.updatePricingConfig(newConfig);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pricing configuration saved successfully')),
                            );
                          }
                        } catch (e) {
                          // Error banner in parent will handle
                        } finally {
                          if (mounted) setState(() => _isSaving = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text('Save Configurations', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildCalculatorTab(DashboardProvider dashboard) {
    return Form(
      key: _calcFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dry-Run Delivery Fee Estimate',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Text(
            'Search for pickup and dropoff locations to retrieve a live pricing breakdown calculation.',
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pickup Location', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    GooglePlaceAutocomplete(
                      hint: 'Search pickup place...',
                      initialValue: _pickupAddressController.text.isNotEmpty ? _pickupAddressController.text : null,
                      onSelected: (place) {
                        setState(() {
                          _pickupAddressController.text = place.placeName;
                          final loc = place.center;
                          if (loc != null) {
                            _pickupLatController.text = loc.lat.toString();
                            _pickupLngController.text = loc.long.toString();
                          }
                        });
                      },
                    ),
                    if (_pickupLatController.text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Coordinates: ${_pickupLatController.text}, ${_pickupLngController.text}',
                        style: GoogleFonts.inter(color: Colors.white30, fontSize: 11),
                      ),
                    ],
                    const SizedBox(height: 24),

                    Text('Dropoff Location', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    GooglePlaceAutocomplete(
                      hint: 'Search dropoff place...',
                      initialValue: _dropoffAddressController.text.isNotEmpty ? _dropoffAddressController.text : null,
                      onSelected: (place) {
                        setState(() {
                          _dropoffAddressController.text = place.placeName;
                          final loc = place.center;
                          if (loc != null) {
                            _dropoffLatController.text = loc.lat.toString();
                            _dropoffLngController.text = loc.long.toString();
                          }
                        });
                      },
                    ),
                    if (_dropoffLatController.text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Coordinates: ${_dropoffLatController.text}, ${_dropoffLngController.text}',
                        style: GoogleFonts.inter(color: Colors.white30, fontSize: 11),
                      ),
                    ],

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isCalculating
                          ? null
                          : () async {
                              if (_pickupLatController.text.isEmpty || _dropoffLatController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please search and select both pickup and dropoff locations')),
                                );
                                return;
                              }
                              setState(() {
                                _isCalculating = true;
                                _calcResult = null;
                              });
                              try {
                                final result = await dashboard.estimatePricing(
                                  pickupLatitude: double.parse(_pickupLatController.text),
                                  pickupLongitude: double.parse(_pickupLngController.text),
                                  dropoffLatitude: double.parse(_dropoffLatController.text),
                                  dropoffLongitude: double.parse(_dropoffLngController.text),
                                );
                                setState(() {
                                  _calcResult = result;
                                });
                              } catch (_) {} finally {
                                setState(() => _isCalculating = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isCalculating
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text('Calculate Estimate Breakdown', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),

              // Estimate Result panel
              Expanded(
                child: _calcResult == null
                    ? Container(
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.01),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.04)),
                        ),
                        child: Center(
                          child: Text(
                            'Select locations and click Calculate to see results',
                            style: GoogleFonts.inter(color: Colors.white24, fontSize: 13),
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16162E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimate Breakdown',
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            _buildBreakdownRow('Base Booking Fee', 'KES ${_calcResult!.baseFee.toStringAsFixed(0)}'),
                            _buildBreakdownRow('Distance Calculation Fee', 'KES ${_calcResult!.distanceFee.toStringAsFixed(0)}'),
                            _buildBreakdownRow('Time Traveled Fee', 'KES ${_calcResult!.timeFee.toStringAsFixed(0)}'),
                            _buildBreakdownRow('Active Surge Multiplier', 'x${_calcResult!.multiplier.toStringAsFixed(2)}'),
                            const SizedBox(height: 12),
                            Divider(color: Colors.white.withOpacity(0.08)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Estimated Delivery Fee',
                                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                Text(
                                  'KES ${_calcResult!.finalFee.toStringAsFixed(0)}',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF00E676),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildBreakdownRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
          Text(value, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}
