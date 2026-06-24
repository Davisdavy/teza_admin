// lib/widgets/google_place_autocomplete.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class GooglePlace {
  final String placeName;
  final ({double lat, double long})? center;

  GooglePlace({required this.placeName, this.center});
}

class GooglePlacePrediction {
  final String description;
  final String placeId;

  GooglePlacePrediction({required this.description, required this.placeId});

  factory GooglePlacePrediction.fromJson(Map<String, dynamic> json) {
    return GooglePlacePrediction(
      description: json['description'] as String,
      placeId: json['place_id'] as String,
    );
  }
}

class GooglePlaceAutocomplete extends StatefulWidget {
  final String hint;
  final ValueChanged<GooglePlace> onSelected;
  final String? initialValue;

  const GooglePlaceAutocomplete({
    Key? key,
    required this.hint,
    required this.onSelected,
    this.initialValue,
  }) : super(key: key);

  @override
  State<GooglePlaceAutocomplete> createState() => _GooglePlaceAutocompleteState();
}

class _GooglePlaceAutocompleteState extends State<GooglePlaceAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<String> _recent = [];
  List<GooglePlacePrediction> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _loadRecent();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recent = prefs.getStringList('recent_google_places') ?? [];
    });
  }

  Future<void> _addToRecent(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList('recent_google_places') ?? [];
    recent.remove(query);
    recent.insert(0, query);
    if (recent.length > 5) recent.removeLast();
    await prefs.setStringList('recent_google_places', recent);
    setState(() {
      _recent = recent;
    });
  }

  void _onQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final rawPredictions = await apiService.getPlacesAutocomplete(query);

      final predictions = rawPredictions
          .map((p) => GooglePlacePrediction.fromJson(p as Map<String, dynamic>))
          .toList();

      setState(() {
        _suggestions = predictions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("getPlacesAutocomplete Exception: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onPredictionSelected(GooglePlacePrediction prediction) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.getPlaceDetails(prediction.placeId);
      final geometry = result['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;

      if (location != null) {
        final lat = (location['lat'] as num).toDouble();
        final lng = (location['lng'] as num).toDouble();

        final place = GooglePlace(
          placeName: prediction.description,
          center: (lat: lat, long: lng),
        );

        _controller.text = prediction.description;
        _addToRecent(prediction.description);
        widget.onSelected(place);
      }
    } catch (e) {
      debugPrint("getPlaceDetails Exception: $e");
    } finally {
      setState(() {
        _suggestions.clear();
        _isLoading = false;
      });
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent searches as quick‑select chips
        if (_recent.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _recent.map((q) => ActionChip(
                label: Text(q, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                backgroundColor: Colors.white.withOpacity(0.02),
                padding: EdgeInsets.zero,
                onPressed: () async {
                  _controller.text = q;
                  await _performSearch(q);
                },
              )).toList(),
            ),
          ),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.02),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            suffixIcon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          ),
          onChanged: _onQueryChanged,
        ),
        if (_suggestions.isNotEmpty)
          Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF16162E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final prediction = _suggestions[index];
                  return ListTile(
                    title: Text(
                      prediction.description,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    onTap: () => _onPredictionSelected(prediction),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
