import 'package:flutter/foundation.dart';
import '../models/ai_summary_model.dart';
import 'api_service.dart';

class AiService {
  final ApiService _apiService = ApiService();

  Future<AiSummary> getAiSummary(String applicationNumber) async {
    try {
      final response = await _apiService.get(
        '/applications/$applicationNumber/ai/status',
      );

      debugPrint('AI API RESPONSE: $response');

      if (response is! Map<String, dynamic>) {
        throw Exception('Invalid response format from backend');
      }

      final data = response['data'];

      if (data is! Map) {
        throw Exception('Backend response does not contain valid data');
      }

      final currentStage =
          data['current_stage']?.toString() ?? 'Unknown';

      final explanation =
          data['ai_explanation']?.toString() ?? '';

      debugPrint('AI CURRENT STAGE: $currentStage');
      debugPrint('AI EXPLANATION: $explanation');

      if (explanation.isEmpty) {
        throw Exception(
          'Backend returned an empty AI explanation',
        );
      }

      final overallStatus =
          data['overall_status']?.toString();

      return AiSummary(
        applicationNumber:
            data['application_id']?.toString() ?? applicationNumber,
        explanation: explanation,
        nextExpectedStep: _getNextExpectedStep(currentStage),
        estimatedCompletion: null,
        delayReason: null,
        generatedAt: DateTime.now(),
        currentStage: currentStage,
        overallStatus: overallStatus,
      );
    } catch (e) {
      debugPrint('AI API ERROR: $e');

      throw Exception('AI Summary error: $e');
    }
  }

  String _getNextExpectedStep(String currentStage) {
    switch (currentStage) {
      case 'Application Submitted':
        return 'Document Verification';

      case 'Document Verification':
        return 'Officer Verification';

      case 'Officer Verification':
        return 'Field Verification';

      case 'Field Verification':
        return 'Final Approval';

      case 'Final Approval':
        return 'Application Completion';

      default:
        return 'Please check your application status.';
    }
  }
}