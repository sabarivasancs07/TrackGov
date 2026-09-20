import 'package:flutter/foundation.dart';
import '../models/application_model.dart';
import '../services/citizen_service.dart';

class ApplicationProvider with ChangeNotifier {
  final CitizenService _citizenService = CitizenService();

  ApplicationModel? _currentApplication;
  bool _isLoading = false;
  String? _errorMessage;

  ApplicationModel? get currentApplication => _currentApplication;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> searchApplication(String applicationNumber, String applicantName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentApplication = await _citizenService.searchApplication(applicationNumber, applicantName);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _currentApplication = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshStatus() async {
    if (_currentApplication == null) return;
    
    try {
      _currentApplication = await _citizenService.getApplicationStatus(_currentApplication!.applicationNumber, _currentApplication!.applicantName);
      notifyListeners();
    } catch (e) {
      // Keep existing data on refresh error
      debugPrint('Error refreshing: $e');
    }
  }
  
  void clear() {
    _currentApplication = null;
    _errorMessage = null;
    notifyListeners();
  }
}
