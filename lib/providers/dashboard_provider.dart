import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/rider.dart';
import '../models/merchant.dart';
import '../models/delivery.dart';
import '../models/offer.dart';
import '../models/history.dart';
import '../models/ranked_rider.dart';
import '../models/pricing.dart';
import '../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<UserAccount> _users = [];
  List<RiderProfile> _riders = [];
  List<MerchantProfile> _merchants = [];
  List<Delivery> _deliveries = [];

  int _deliveriesPage = 0;
  final int _deliveriesSize = 10;
  int _deliveriesTotalElements = 0;
  int _deliveriesTotalPages = 0;
  bool _deliveriesIsLast = true;

  // Detail/associated data for selected delivery
  List<DeliveryOffer> _activeOffers = [];
  List<DeliveryStatusHistory> _activeHistory = [];
  List<RankedRider> _activeMatchingRiders = [];

  bool _isLoading = false;
  String? _errorMessage;

  PricingConfiguration? _pricingConfig;
  PricingEstimate? _pricingEstimate;

  DashboardProvider(this._apiService);

  PricingConfiguration? get pricingConfig => _pricingConfig;
  PricingEstimate? get pricingEstimate => _pricingEstimate;

  List<UserAccount> get users => _users;
  List<RiderProfile> get riders => _riders;
  List<MerchantProfile> get merchants => _merchants;
  List<Delivery> get deliveries => _deliveries;

  int get deliveriesPage => _deliveriesPage;
  int get deliveriesTotalElements => _deliveriesTotalElements;
  int get deliveriesTotalPages => _deliveriesTotalPages;
  bool get deliveriesIsLast => _deliveriesIsLast;

  List<DeliveryOffer> get activeOffers => _activeOffers;
  List<DeliveryStatusHistory> get activeHistory => _activeHistory;
  List<RankedRider> get activeMatchingRiders => _activeMatchingRiders;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // --- Bulk Fetch ---
  Future<void> fetchAllData({bool isMerchant = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isMerchant) {
        final merchantDeliveries = await _apiService.getMerchantDeliveries();
        _deliveries = merchantDeliveries;
        _users = [];
        _riders = [];
        _merchants = [];
        _deliveriesPage = 0;
        _deliveriesTotalElements = merchantDeliveries.length;
        _deliveriesTotalPages = 1;
        _deliveriesIsLast = true;
      } else {
        final results = await Future.wait([
          _apiService.getUsers(),
          _apiService.getRiders(),
          _apiService.getMerchants(),
          _apiService.getDeliveries(page: 0, size: _deliveriesSize),
        ]);

        _users = results[0] as List<UserAccount>;
        _riders = results[1] as List<RiderProfile>;
        _merchants = results[2] as List<MerchantProfile>;
        
        final paged = results[3] as PagedDeliveries;
        _deliveries = paged.content;
        _deliveriesPage = paged.page;
        _deliveriesTotalElements = paged.totalElements;
        _deliveriesTotalPages = paged.totalPages;
        _deliveriesIsLast = paged.last;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDeliveriesPage(int page) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final paged = await _apiService.getDeliveries(page: page, size: _deliveriesSize);
      _deliveries = paged.content;
      _deliveriesPage = paged.page;
      _deliveriesTotalElements = paged.totalElements;
      _deliveriesTotalPages = paged.totalPages;
      _deliveriesIsLast = paged.last;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- User Operations ---
  Future<void> updateUser(String id, String email, bool enabled, String role) async {
    try {
      final updated = await _apiService.updateUser(id, email, enabled, role);
      final idx = _users.indexWhere((u) => u.id == id);
      if (idx != -1) {
        _users[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _apiService.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // --- Rider Operations ---
  Future<void> approveRider(String riderId) async {
    try {
      final updated = await _apiService.updateOnboardingStatus(riderId, 'APPROVED');
      final idx = _riders.indexWhere((r) => r.id == riderId);
      if (idx != -1) {
        _riders[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> rejectRider(String riderId) async {
    try {
      final updated = await _apiService.updateOnboardingStatus(riderId, 'REJECTED');
      final idx = _riders.indexWhere((r) => r.id == riderId);
      if (idx != -1) {
        _riders[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteRider(String riderId) async {
    try {
      await _apiService.deleteRider(riderId);
      _riders.removeWhere((r) => r.id == riderId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // --- Merchant Operations ---
  Future<void> deleteMerchant(String merchantId) async {
    try {
      await _apiService.deleteMerchant(merchantId);
      _merchants.removeWhere((m) => m.id == merchantId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // --- Delivery Operations ---
  Future<void> updateDeliveryStatus(String id, String status, String reason) async {
    try {
      final updated = await _apiService.updateDeliveryStatus(id, status, reason);
      final idx = _deliveries.indexWhere((d) => d.id == id);
      if (idx != -1) {
        _deliveries[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createDelivery({
    required String pickupAddress,
    required double pickupLatitude,
    required double pickupLongitude,
    required String dropoffAddress,
    required double dropoffLatitude,
    required double dropoffLongitude,
  }) async {
    try {
      final newDelivery = await _apiService.createDelivery(
        pickupAddress: pickupAddress,
        pickupLatitude: pickupLatitude,
        pickupLongitude: pickupLongitude,
        dropoffAddress: dropoffAddress,
        dropoffLatitude: dropoffLatitude,
        dropoffLongitude: dropoffLongitude,
      );
      _deliveries.insert(0, newDelivery);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteDelivery(String id) async {
    try {
      await _apiService.deleteDelivery(id);
      _deliveries.removeWhere((d) => d.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // Fetch sub-elements of delivery
  Future<void> fetchDeliveryDetails(String deliveryId) async {
    _activeOffers = [];
    _activeHistory = [];
    _activeMatchingRiders = [];
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getOffers(deliveryId),
        _apiService.getStatusHistory(deliveryId),
        _apiService.getMatchingRiders(deliveryId),
      ]);

      _activeOffers = results[0] as List<DeliveryOffer>;
      _activeHistory = results[1] as List<DeliveryStatusHistory>;
      _activeMatchingRiders = results[2] as List<RankedRider>;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> dispatchOffer(String deliveryId, String riderId) async {
    try {
      final offer = await _apiService.createOffer(deliveryId, riderId);
      _activeOffers.add(offer);
      // Refresh deliveries list to see status/assignment updates on current page
      final freshDeliveries = await _apiService.getDeliveries(page: _deliveriesPage, size: _deliveriesSize);
      _deliveries = freshDeliveries.content;
      _deliveriesPage = freshDeliveries.page;
      _deliveriesTotalElements = freshDeliveries.totalElements;
      _deliveriesTotalPages = freshDeliveries.totalPages;
      _deliveriesIsLast = freshDeliveries.last;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // --- Pricing Methods ---

  Future<void> fetchPricingConfig() async {
    _errorMessage = null;
    notifyListeners();

    try {
      _pricingConfig = await _apiService.getPricingConfig();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> updatePricingConfig(PricingConfiguration config) async {
    _errorMessage = null;
    notifyListeners();

    try {
      _pricingConfig = await _apiService.updatePricingConfig(config);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<PricingEstimate> estimatePricing({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final estimate = await _apiService.estimatePricing(
        pickupLatitude: pickupLatitude,
        pickupLongitude: pickupLongitude,
        dropoffLatitude: dropoffLatitude,
        dropoffLongitude: dropoffLongitude,
      );
      _pricingEstimate = estimate;
      notifyListeners();
      return estimate;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}
