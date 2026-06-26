// lib/widgets/map_picker.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class MapPicker extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final Function(double lat, double lng, String address) onLocationSelected;

  const MapPicker({
    Key? key,
    this.initialLatitude = -1.2921,
    this.initialLongitude = 36.8219,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  late double _latitude;
  late double _longitude;
  double _zoom = 14.0;
  
  Offset _dragOffset = Offset.zero;
  bool _isGeocoding = false;
  String _currentAddress = '';

  @override
  void initState() {
    super.initState();
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
    _reverseGeocodeCurrent();
  }

  Future<void> _reverseGeocodeCurrent() async {
    setState(() {
      _isGeocoding = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final address = await apiService.getReverseGeocode(_latitude, _longitude);
      setState(() {
        _currentAddress = address;
      });
    } catch (e) {
      debugPrint("Geocoding error: $e");
      setState(() {
        _currentAddress = 'Coordinates: ${_latitude.toStringAsFixed(5)}, ${_longitude.toStringAsFixed(5)}';
      });
    } finally {
      setState(() {
        _isGeocoding = false;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // 256 pixels is the Mapbox tile size. At zoom level Z, the full map width is 256 * 2^Z pixels.
    final degreesPerPixel = 360.0 / (256.0 * math.pow(2.0, _zoom));
    
    // Calculate new center based on translation offset
    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;

    setState(() {
      _longitude -= dx * degreesPerPixel;
      _latitude += dy * degreesPerPixel * math.cos(_latitude * math.pi / 180.0);
      _dragOffset = Offset.zero;
    });

    _reverseGeocodeCurrent();
  }

  String get _mapUrl {
    final width = 500;
    final height = 280;
    return '${ApiService.baseUrl}/api/delivery/places/static-map?lat=$_latitude&lng=$_longitude&zoom=${_zoom.toInt()}&width=$width&height=$height';
  }

  void _zoomIn() {
    if (_zoom < 20) {
      setState(() {
        _zoom += 1.0;
      });
      _reverseGeocodeCurrent();
    }
  }

  void _zoomOut() {
    if (_zoom > 1) {
      setState(() {
        _zoom -= 1.0;
      });
      _reverseGeocodeCurrent();
    }
  }

  void _selectPreset(String name, double lat, double lng) {
    setState(() {
      _latitude = lat;
      _longitude = lng;
      _zoom = 14.0;
    });
    _reverseGeocodeCurrent();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16162E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Preset Buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _presets.map((preset) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ActionChip(
                      label: Text(preset['name'] as String, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                      backgroundColor: Colors.white.withOpacity(0.02),
                      padding: EdgeInsets.zero,
                      onPressed: () => _selectPreset(
                        preset['name'] as String,
                        preset['lat'] as double,
                        preset['lng'] as double,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Map Area with Crosshair and Drag Handler
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 280,
              child: Stack(
                children: [
                  // Map Image shifted by drag offset
                  GestureDetector(
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Transform.translate(
                      offset: _dragOffset,
                      child: Image.network(
                        _mapUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: const Color(0xFF111122),
                            child: const Center(
                              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Center Crosshair Indicator
                  IgnorePointer(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_searching,
                            size: 32,
                            color: const Color(0xFF6C63FF).withOpacity(0.9),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Target Center',
                              style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Map Zoom Controls
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'zoom_in_btn',
                          onPressed: _zoomIn,
                          backgroundColor: const Color(0xFF131326).withOpacity(0.85),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        FloatingActionButton.small(
                          heroTag: 'zoom_out_btn',
                          onPressed: _zoomOut,
                          backgroundColor: const Color(0xFF131326).withOpacity(0.85),
                          child: const Icon(Icons.remove, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Address Summary / Action Row
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF6C63FF), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _isGeocoding ? 'Loading address...' : _currentAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    if (_isGeocoding)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isGeocoding
                      ? null
                      : () {
                          widget.onLocationSelected(_latitude, _longitude, _currentAddress);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white.withOpacity(0.04),
                    disabledForegroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Confirm Location',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const List<Map<String, dynamic>> _presets = [
  {"name": "Nairobi CBD", "lat": -1.2921, "lng": 36.8219},
  {"name": "Westlands", "lat": -1.2628, "lng": 36.8041},
  {"name": "Kilimani", "lat": -1.2913, "lng": 36.7979},
  {"name": "Karen", "lat": -1.3195, "lng": 36.7061},
  {"name": "Gigiri", "lat": -1.2294, "lng": 36.8048},
  {"name": "JKIA Airport", "lat": -1.3323, "lng": 36.9211},
];
