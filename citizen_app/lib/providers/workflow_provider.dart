import 'package:flutter/foundation.dart';
import '../models/workflow_step_model.dart';
import '../services/workflow_service.dart';

class WorkflowProvider with ChangeNotifier {
  final WorkflowService _workflowService = WorkflowService();

  List<WorkflowStep>? _timeline;
  String? _currentStage;
  String? _overallStatus;
  int? _progressPercentage;
  bool _isLoading = false;
  String? _errorMessage;

  List<WorkflowStep>? get timeline => _timeline;
  String? get currentStage => _currentStage;
  String? get overallStatus => _overallStatus;
  int? get progressPercentage => _progressPercentage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTimeline(String applicationNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final details = await _workflowService.getWorkflowDetails(applicationNumber);
      _currentStage = details['current_stage']?.toString();
      _overallStatus = details['overall_status']?.toString();
      final progress = details['progress_percentage'];
      if (progress is int) {
        _progressPercentage = progress;
      } else if (progress is num) {
        _progressPercentage = progress.toInt();
      }

      _timeline = await _workflowService.getWorkflowTimeline(applicationNumber);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _timeline = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
