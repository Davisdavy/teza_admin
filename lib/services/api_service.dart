import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/rider.dart';
import '../models/merchant.dart';
import '../models/delivery.dart';
import '../models/offer.dart';
import '../models/history.dart';
import '../models/ranked_rider.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.100.8:8080';
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _headers({bool authenticated = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authenticated && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // --- Auth Endpoints ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: _headers(authenticated: false),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['accessToken'];
      return data;
    } else {
      final error = _parseError(response);
      throw Exception(error);
    }
  }

  Future<UserAccount> getMe() async {
    final url = Uri.parse('$baseUrl/api/users/me');
    final response = await http.get(url, headers: _headers());

    if (response.statusCode == 200) {
      return UserAccount.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_parseError(response));
    }
  }

  // --- Users Endpoints ---

  Future<List<UserAccount>> getUsers() async {
    final url = Uri.parse('$baseUrl/api/users');
    final response = await http.get(url, headers: _headers());
    print('GET /api/users response: ${response.statusCode} - ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      // Support both raw list and paged map responses
      final List<dynamic> list = decoded is List ? decoded : (decoded['content'] ?? []);
      return list.map((e) => UserAccount.fromJson(e)).toList();
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<UserAccount> updateUser(String id, String email, bool enabled, String role) async {
    final url = Uri.parse('$baseUrl/api/users/$id');
    final response = await http.put(
      url,
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'enabled': enabled,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return UserAccount.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<void> deleteUser(String id) async {
    final url = Uri.parse('$baseUrl/api/users/$id');
    final response = await http.delete(url, headers: _headers());

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
  }

  // --- Riders Endpoints ---

  Future<List<RiderProfile>> getRiders() async {
    final url = Uri.parse('$baseUrl/api/rider/profiles');
    final response = await http.get(url, headers: _headers());
    print('GET /api/rider/profiles response: ${response.statusCode} - ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> list = decoded is List ? decoded : (decoded['content'] ?? []);
      return list.map((e) => RiderProfile.fromJson(e)).toList();
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<RiderProfile> updateOnboardingStatus(String riderId, String onboardingStatus) async {
    final url = Uri.parse('$baseUrl/api/rider/profile/$riderId/onboarding');
    final response = await http.put(
      url,
      headers: _headers(),
      body: jsonEncode({
        'onboardingStatus': onboardingStatus,
      }),
    );

    if (response.statusCode == 200) {
      return RiderProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<void> deleteRider(String riderId) async {
    final url = Uri.parse('$baseUrl/api/rider/profile/$riderId');
    final response = await http.delete(url, headers: _headers());

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
  }

  // --- Merchants Endpoints ---

  Future<List<MerchantProfile>> getMerchants() async {
    final url = Uri.parse('$baseUrl/api/merchant/profiles');
    final response = await http.get(url, headers: _headers());
    print('GET /api/merchant/profiles response: ${response.statusCode} - ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> list = decoded is List ? decoded : (decoded['content'] ?? []);
      return list.map((e) => MerchantProfile.fromJson(e)).toList();
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<void> deleteMerchant(String merchantId) async {
    final url = Uri.parse('$baseUrl/api/merchant/profile/$merchantId');
    final response = await http.delete(url, headers: _headers());

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
  }

  // --- Deliveries Endpoints ---

  Future<Delivery> createDelivery({
    required String pickupAddress,
    required double pickupLatitude,
    required double pickupLongitude,
    required String dropoffAddress,
    required double dropoffLatitude,
    required double dropoffLongitude,
    required double deliveryFee,
  }) async {
    final url = Uri.parse('$baseUrl/api/delivery');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'pickupAddress': pickupAddress,
        'pickupLatitude': pickupLatitude,
        'pickupLongitude': pickupLongitude,
        'dropoffAddress': dropoffAddress,
        'dropoffLatitude': dropoffLatitude,
        'dropoffLongitude': dropoffLongitude,
        'deliveryFee': deliveryFee,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Delivery.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<PagedDeliveries> getDeliveries({int page = 0, int size = 10}) async {
    final url = Uri.parse('$baseUrl/api/delivery?page=$page&size=$size');
    final response = await http.get(url, headers: _headers());
    print('GET /api/delivery response: ${response.statusCode} - ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

    if (response.statusCode == 200) {
      return PagedDeliveries.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<List<Delivery>> getMerchantDeliveries() async {
    final url = Uri.parse('$baseUrl/api/delivery/merchant');
    final response = await http.get(url, headers: _headers());

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => Delivery.fromJson(e)).toList();
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<Delivery> updateDeliveryStatus(String id, String status, String reason) async {
    final url = Uri.parse('$baseUrl/api/delivery/$id/status');
    final response = await http.put(
      url,
      headers: _headers(),
      body: jsonEncode({
        'status': status,
        'reason': reason,
      }),
    );

    if (response.statusCode == 200) {
      return Delivery.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<void> deleteDelivery(String id) async {
    final url = Uri.parse('$baseUrl/api/delivery/$id');
    final response = await http.delete(url, headers: _headers());

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
  }

  Future<List<DeliveryOffer>> getOffers(String deliveryId) async {
    final url = Uri.parse('$baseUrl/api/delivery/$deliveryId/offers');
    final response = await http.get(url, headers: _headers());

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => DeliveryOffer.fromJson(e)).toList();
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<List<DeliveryStatusHistory>> getStatusHistory(String deliveryId) async {
    final url = Uri.parse('$baseUrl/api/delivery/$deliveryId/history');
    final response = await http.get(url, headers: _headers());

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => DeliveryStatusHistory.fromJson(e)).toList();
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<List<RankedRider>> getMatchingRiders(String deliveryId) async {
    final url = Uri.parse('$baseUrl/api/delivery/$deliveryId/matching-riders');
    final response = await http.get(url, headers: _headers());

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => RankedRider.fromJson(e)).toList();
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<DeliveryOffer> createOffer(String deliveryId, String riderId) async {
    final url = Uri.parse('$baseUrl/api/delivery/$deliveryId/offers');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'riderId': riderId,
        'durationSeconds': 60,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return DeliveryOffer.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<List<dynamic>> getPlacesAutocomplete(String input) async {
    final url = Uri.parse('$baseUrl/api/delivery/places/autocomplete?input=${Uri.encodeComponent(input)}');
    final response = await http.get(url, headers: _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['predictions'] as List? ?? [];
    } else {
      throw Exception('Failed to get predictions');
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final url = Uri.parse('$baseUrl/api/delivery/places/details?placeId=${Uri.encodeComponent(placeId)}');
    final response = await http.get(url, headers: _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result'] as Map<String, dynamic>? ?? {};
    } else {
      throw Exception('Failed to get place details');
    }
  }

  Future<String> getReverseGeocode(double lat, double lng) async {
    final url = Uri.parse('$baseUrl/api/delivery/places/reverse-geocode?lat=$lat&lng=$lng');
    final response = await http.get(url, headers: _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List?;
      if (results != null && results.isNotEmpty) {
        return results[0]['formatted_address'] as String;
      }
    }
    throw Exception('Failed to reverse geocode');
  }

  // --- Helper to Parse Backend Errors ---

  String _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      if (data is Map && data.containsKey('error')) {
        return data['error'];
      }
    } catch (_) {}
    return 'HTTP Error ${response.statusCode}: ${response.reasonPhrase}';
  }
}
