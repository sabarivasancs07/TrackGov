import 'package:flutter/foundation.dart';
import '../models/workflow_step_model.dart';
import 'mock_data_service.dart';
import 'api_service.dart';
import '../config/app_config.dart';

class WorkflowService {
  final MockDataService _mockData = MockDataService();
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getWorkflowDetails(String applicationNumber) async {
    try {
      final response = await _apiService.get('/workflow/$applicationNumber');
      if (response is Map<String, dynamic>) {
        return response;
      }
      return Map<String, dynamic>.from(response);
    } catch (e) {
      debugPrint('Workflow Details API Error: $e');
      throw Exception('Failed to fetch workflow details');
    }
  }

  Future<List<WorkflowStep>> getWorkflowTimeline(String applicationNumber) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      final app = _mockData.getApplication(applicationNumber);
      if (app != null) return app.workflowHistory;
      throw Exception('Application not found');
    }

    try {
      final response = await getWorkflowDetails(applicationNumber);
      
      final stages = response['stages'] as List? ?? [];
      return stages.map((stage) {
        final stageMap = stage as Map<String, dynamic>;
        final stageName = stageMap['stage_name']?.toString() ?? 'Stage';
        final status = stageMap['status']?.toString() ?? 'Pending';
        
        final assignedTo = stageMap['assigned_to']?.toString();
        final officerName = (assignedTo != null && assignedTo.trim().isNotEmpty && assignedTo != 'System') 
            ? assignedTo 
            : null;

        final office = stageMap['office']?.toString();
        final officeId = (office != null && office.trim().isNotEmpty && office != 'Office') 
            ? office 
            : null;

        final rawCompleted = stageMap['completed_at'] ?? stageMap['updated_at'];
        final completedAt = rawCompleted != null ? DateTime.tryParse(rawCompleted.toString()) : null;

        final rawStarted = stageMap['started_at'];
        final startedAt = rawStarted != null ? DateTime.tryParse(rawStarted.toString()) : null;

        return WorkflowStep(
          stageName: stageName,
          stageCode: stageMap['stage_id']?.toString() ?? (stageName.length >= 3 ? stageName.substring(0, 3).toUpperCase() : 'STG'),
          status: status,
          officerName: officerName,
          officeId: officeId,
          completedAt: completedAt,
          startedAt: startedAt,
          remarks: stageMap['remarks']?.toString(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Workflow API Error: $e');
      throw Exception('Failed to fetch workflow timeline');
    }
  }
}
