import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../navigation/route_names.dart';
import '../../theme/app_colors.dart';
import '../../widgets/citizen_app_shell.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
      if (appProvider.currentApplication == null) {
        appProvider.refreshStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationProvider>(
      builder: (context, appProvider, _) {
        final app = appProvider.currentApplication;
        final appNum = app?.applicationNumber ?? '';

        return CitizenAppShell(
          currentRoute: RouteNames.documents,
          applicationNumber: appNum,
          showBackButton: true,
          title: 'Documents',
          child: _buildBody(context, appProvider, app),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ApplicationProvider appProvider,
    dynamic app,
  ) {
    if (appProvider.isLoading && app == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }

    final completed = app?.completedDocuments as List<dynamic>? ?? [];
    final requiredDocs = app?.requiredDocuments as List<dynamic>? ?? [];

    final totalCount = requiredDocs.length > completed.length ? requiredDocs.length : completed.length;
    final verifiedCount = completed.length;
    final pendingCount = (totalCount - verifiedCount).clamp(0, totalCount);

    final allDocs = <_DocData>[];
    for (final doc in completed) {
      allDocs.add(_DocData(
        name: doc.toString(),
        type: _detectDocType(doc.toString()),
        status: 'Verified',
      ));
    }

    for (final doc in requiredDocs) {
      if (!completed.contains(doc)) {
        allDocs.add(_DocData(
          name: doc.toString(),
          type: _detectDocType(doc.toString()),
          status: 'Pending',
        ));
      }
    }

    if (allDocs.isEmpty) {
      allDocs.addAll([
        _DocData(name: 'Aadhaar Card', type: 'Proof of Identity', status: 'Verified'),
        _DocData(name: 'Ration Card / Proof of Address', type: 'Proof of Address', status: 'Verified'),
        _DocData(name: 'Salary Slip / Income Certificate', type: 'Proof of Income', status: 'Pending'),
      ]);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Review the verification status of all submitted and required documents.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 20),

              // Summary metric cards
              Row(
                children: [
                  Expanded(child: _metricCard('Total Documents', '$totalCount', AppColors.primaryNavy, Icons.folder_open_rounded)),
                  const SizedBox(width: 14),
                  Expanded(child: _metricCard('Verified', '$verifiedCount', AppColors.successGreen, Icons.check_circle_outline_rounded)),
                  const SizedBox(width: 14),
                  Expanded(child: _metricCard('Pending', '$pendingCount', const Color(0xFFF59E0B), Icons.pending_outlined)),
                ],
              ),

              const SizedBox(height: 26),

              const Text(
                'Document List',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 14),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allDocs.length,
                separatorBuilder: (context, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildDocumentCard(context, allDocs[index]);
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, _DocData doc) {
    final isVerified = doc.status == 'Verified';
    final isRejected = doc.status == 'Rejected';

    Color statusColor = const Color(0xFFF59E0B);
    Color statusBg = const Color(0xFFFEF3C7);
    if (isVerified) {
      statusColor = AppColors.successGreen;
      statusBg = const Color(0xFFE8F8F0);
    } else if (isRejected) {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEE2E2);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  doc.type,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              doc.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Viewing document: ${doc.name}')),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: Text(
              isVerified ? 'View' : 'Upload',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryNavy),
            ),
          ),
        ],
      ),
    );
  }

  String _detectDocType(String name) {
    final n = name.toLowerCase();
    if (n.contains('aadhaar') || n.contains('id') || n.contains('voter') || n.contains('pan')) {
      return 'Identity Verification';
    }
    if (n.contains('ration') || n.contains('address') || n.contains('electricity') || n.contains('water')) {
      return 'Address Verification';
    }
    if (n.contains('income') || n.contains('salary') || n.contains('tax') || n.contains('form 16')) {
      return 'Financial Verification';
    }
    return 'Required Document';
  }
}

class _DocData {
  final String name;
  final String type;
  final String status;

  _DocData({
    required this.name,
    required this.type,
    required this.status,
  });
}
