import '../models/application_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class CitizenService {
  final ApiService _apiService = ApiService();

  Future<CitizenUser> verifyCitizen(
    String applicationNumber,
    String name,
  ) async {
    try {
      final app = await searchApplication(
        applicationNumber,
        name,
      );

      if (app.applicantName.trim().toLowerCase() ==
          name.trim().toLowerCase()) {
        return CitizenUser(
          name: app.applicantName,
          applicationNumber: app.applicationNumber,
          isVerified: true,
        );
      }

      throw Exception(
        'Verification failed. Details do not match our records.',
      );
    } catch (e) {
      throw Exception(
        'Verification failed. Details do not match our records.',
      );
    }
  }

  Future<ApplicationModel> searchApplication(
    String applicationNumber,
    String applicantName,
  ) async {
    try {
      final response = await _apiService.get(
        '/citizen/track/'
        '$applicationNumber'
        '?applicant_name=${Uri.encodeComponent(applicantName)}',
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response received from backend.',
        );
      }

      final appData = response['application'];

      if (appData is! Map) {
        throw Exception(
          'Application data not found.',
        );
      }

      final workflowData = response['workflow'];
      final delayData = response['delay_info'];

      return ApplicationModel(
        applicationNumber:
            appData['application_id']?.toString() ??
                applicationNumber,

        applicantName:
            appData['applicant_name']?.toString() ??
                applicantName,

        certificateType:
            appData['application_type']?.toString() ??
                'Government Service',

        submissionDate:
            DateTime.parse(
          appData['submitted_date'].toString(),
        ),

        currentOffice:
            workflowData is Map
                ? workflowData['current_stage_details'] is Map
                    ? workflowData['current_stage_details']
                            ['office']
                        ?.toString() ??
                    'Office'
                    : 'Office'
                : 'Office',

        currentStage:
            appData['current_stage']?.toString() ??
                'Application Submitted',

        status:
            appData['status']?.toString() ??
                'Under Process',

        daysPending:
            delayData is Map
                ? int.tryParse(
                      delayData['days_pending']
                              ?.toString() ??
                          '0',
                    ) ??
                    0
                : 0,

        expectedProcessingDays:
            delayData is Map
                ? int.tryParse(
                      delayData['expected_processing_days']
                              ?.toString() ??
                          '15',
                    ) ??
                    15
                : 15,

        workflowHistory: [],

        auditLog: [],

        requiredDocuments: (appData['required_documents'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],

        completedDocuments: (appData['completed_documents'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
    } catch (e) {
      throw Exception(
        'Application not found or connection failed: $e',
      );
    }
  }

  Future<ApplicationModel> getApplicationStatus(
    String applicationNumber,
    String applicantName,
  ) async {
    return searchApplication(
      applicationNumber,
      applicantName,
    );
  }
}