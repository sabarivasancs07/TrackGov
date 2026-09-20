import 'package:flutter/foundation.dart';
import '../models/ai_summary_model.dart';
import '../services/ai_service.dart';

class AiSummaryProvider with ChangeNotifier {
  final AiService _aiService = AiService();

  AiSummary? _summary;
  bool _isLoading = false;
  String? _errorMessage;

  AiSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAiSummary(String applicationNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _aiService.getAiSummary(applicationNumber);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _summary = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
