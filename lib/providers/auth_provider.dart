import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  UserAccount? _currentUser;
  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._apiService);

  UserAccount? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isSuperAdmin => _currentUser?.role == 'SUPER_ADMIN';
  bool get isSupportAdmin => _currentUser?.role == 'SUPPORT_ADMIN';
  bool get isAdmin => isSuperAdmin || isSupportAdmin;
  bool get canDelete => isSuperAdmin; // SUPPORT_ADMIN cannot delete

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authData = await _apiService.login(email, password);
      _token = authData['accessToken'];
      _apiService.setToken(_token);

      // Fetch user profile info
      _currentUser = await _apiService.getMe();
      
      // Ensure user is an admin
      if (!isAdmin) {
        _token = null;
        _currentUser = null;
        _apiService.setToken(null);
        _isAuthenticated = false;
        _errorMessage = 'Access denied: You must be an administrator to log in here.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _token = null;
      _currentUser = null;
      _apiService.setToken(null);
      _isAuthenticated = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _token = null;
    _currentUser = null;
    _apiService.setToken(null);
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
