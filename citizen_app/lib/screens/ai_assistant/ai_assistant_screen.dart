import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../providers/ai_summary_provider.dart';
import '../../providers/application_provider.dart';
import '../../navigation/route_names.dart';
import '../../theme/app_colors.dart';
import '../../widgets/citizen_app_shell.dart';

class AiAssistantScreen extends StatefulWidget {
  final String? applicationNumber;

  const AiAssistantScreen({super.key, this.applicationNumber});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  final List<String> _suggestedQuestions = [
    'What is the current status of my application?',
    'What documents are required?',
    'How long will it take?',
    'Why is there a delay?',
  ];

  @override
  void initState() {
    super.initState();
    _fetchInitialContext();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialContext() async {
    final aiProvider = Provider.of<AiSummaryProvider>(context, listen: false);
    final appProvider = Provider.of<ApplicationProvider>(context, listen: false);

    final appNum = widget.applicationNumber ?? appProvider.currentApplication?.applicationNumber;

    if (appNum != null && aiProvider.summary == null) {
      setState(() => _isTyping = true);
      await aiProvider.fetchAiSummary(appNum);

      if (mounted) {
        setState(() {
          _isTyping = false;
          if (aiProvider.summary != null) {
            _messages.add({
              'role': 'assistant',
              'content':
                  'Hello! I am your TrackGov AI Assistant. Here is the latest intelligent summary of your application:\n\n${aiProvider.summary!.explanation}',
            });
          } else {
            _messages.add({
              'role': 'assistant',
              'content':
                  'Hello! I am TrackGov AI Assistant. How can I help you with your application or government service tracking today?',
            });
          }
        });
        _scrollToBottom();
      }
    } else {
      setState(() {
        if (aiProvider.summary != null) {
          _messages.add({
            'role': 'assistant',
            'content':
                'Hello! I am TrackGov AI Assistant. Here is the latest intelligence for your application:\n\n${aiProvider.summary!.explanation}',
          });
        } else {
          _messages.add({
            'role': 'assistant',
            'content':
                'Hello! I am TrackGov AI Assistant. How can I help you with your application status or documents today?',
          });
        }
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      if (presetText == null) {
        _messageController.clear();
      }
      _isTyping = true;
    });
    _scrollToBottom();

    final aiProvider = Provider.of<AiSummaryProvider>(context, listen: false);
    final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
    final app = appProvider.currentApplication;

    // Provide helpful context-aware response
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      String reply;
      final q = text.toLowerCase();

      if (q.contains('status')) {
        reply = 'Your application **${app?.applicationNumber ?? ''}** is currently in the **${app?.currentStage ?? 'Verification'}** stage.\n\nOverall status is: **${app?.status ?? 'In Progress'}**.';
      } else if (q.contains('document')) {
        final completed = app?.completedDocuments.join(', ') ?? 'None';
        final requiredDocs = app?.requiredDocuments.join(', ') ?? 'Standard KYC documents';
        reply = '### Required Documents\n\n- **Submitted & Verified:** $completed\n- **Total Requirements:** $requiredDocs\n\nEnsure all certificates are legible with official stamps.';
      } else if (q.contains('how long') || q.contains('take') || q.contains('expected')) {
        final days = app?.expectedProcessingDays ?? 15;
        final pending = app?.daysPending ?? 0;
        final left = (days - pending).clamp(0, days);
        reply = 'The standard processing timeline for **${app?.certificateType ?? 'this certificate'}** is **$days days**.\n\nIt has been pending for **$pending days**, with approximately **$left days remaining**.';
      } else if (q.contains('delay')) {
        if (app?.isDelayed == true) {
          reply = '### Delay Analysis\n\nYour application has exceeded the target SLA by **${(app!.daysPending - app.expectedProcessingDays).clamp(1, 100)} days**.\n\nCommon reasons include inter-departmental verification bottlenecks or officer caseload. You can escalate via the Grievance cell or visit the local tehsil office.';
        } else {
          reply = 'No delays have been flagged for your application. Processing is currently **on schedule**.';
        }
      } else if (aiProvider.summary != null) {
        reply = aiProvider.summary!.explanation;
      } else {
        reply = 'Thank you for your question. Your application **${app?.applicationNumber ?? ''}** is actively being tracked. You can view the full timeline and verification history in the **Track Application** section.';
      }

      setState(() {
        _isTyping = false;
        _messages.add({'role': 'assistant', 'content': reply});
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<ApplicationProvider>(context);
    final appNum = widget.applicationNumber ?? appProvider.currentApplication?.applicationNumber ?? '';

    return CitizenAppShell(
      currentRoute: RouteNames.aiAssistant,
      applicationNumber: appNum,
      showBackButton: true,
      title: 'TrackGov AI Assistant',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            children: [
              // Suggested Questions Bar
              _buildSuggestedQuestions(),

              // Message History List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    final message = _messages[index];
                    final isUser = message['role'] == 'user';
                    return _buildChatBubble(message['content']!, isUser);
                  },
                ),
              ),

              // Bottom Input Bar
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUGGESTED QUESTIONS
  // ============================================================
  Widget _buildSuggestedQuestions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8EDF4)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggested Questions',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _suggestedQuestions.map((q) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    label: Text(
                      q,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    onPressed: () => _sendMessage(q),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHAT BUBBLE
  // ============================================================
  Widget _buildChatBubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.aiPurple, size: 18),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryNavy : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser ? null : Border.all(color: const Color(0xFFE5EAF1)),
                boxShadow: isUser
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: isUser
                  ? Text(
                      text,
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                    )
                  : MarkdownBody(
                      data: text,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(color: Color(0xFF334155), fontSize: 14, height: 1.5),
                        h3: const TextStyle(color: AppColors.primaryNavy, fontSize: 15, fontWeight: FontWeight.bold),
                        listBullet: const TextStyle(color: AppColors.primaryBlue),
                        strong: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ),
            ),
          ),
          if (isUser) const SizedBox(width: 32),
          if (!isUser) const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.aiPurple, size: 18),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5EAF1)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.aiPurple),
                ),
                SizedBox(width: 10),
                Text(
                  'TrackGov AI is analyzing...',
                  style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGE INPUT BAR
  // ============================================================
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE8EDF4)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Ask about status, delays, or requirements...',
                  hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppColors.primaryNavy,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _sendMessage(),
              child: const Padding(
                padding: EdgeInsets.all(13),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
