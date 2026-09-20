import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/citizen_service.dart';

class AuthProvider with ChangeNotifier {
  final CitizenService _citizenService = CitizenService();

  CitizenUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  CitizenUser? get user => _user;
  bool get isAuthenticated => _user != null && _user!.isVerified;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> verifyCitizen(String applicationNumber, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _citizenService.verifyCitizen(applicationNumber, name);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _user = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }
}
