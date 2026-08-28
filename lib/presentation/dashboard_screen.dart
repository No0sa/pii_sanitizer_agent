import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pii_sanitizer_agent/core/trajectory_logger.dart';
import 'package:pii_sanitizer_agent/models/user_record.dart';
import 'package:pii_sanitizer_agent/services/generator_agent.dart';
import 'package:pii_sanitizer_agent/services/inspector_agent.dart';
import 'package:pii_sanitizer_agent/services/verification_agent.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agentic PII Sanitizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF6366F1),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController(
    text:
        'Customer Ahmed Ali called from +201012345678 to reset password. Credit card verification was 4111-2222-3333-4444.',
  );

  bool _isRedactionMode = false;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _inspectionResult;
  UserRecord? _sanitizedRecord;
  Map<String, dynamic>? _verificationResult;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _runPipeline() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      setState(() {
        _errorMessage = 'الرجاء إدخال Gemini API Key أولاً';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _inspectionResult = null;
      _sanitizedRecord = null;
      _verificationResult = null;
    });

    try {
      final currentRecord = UserRecord(
        userId: 'USR-8801',
        status: 'ACTIVE',
        email: 'ahmed.ali@techcorp.com',
        phone: '+201012345678',
        internalNotes: _notesController.text,
        accountStatus: '',
      );

      final inspector = InspectorAgent(apiKey: apiKey);
      final inspection = await inspector.inspectRecord(currentRecord);

      final generator = GeneratorAgent();
      final sanitized = await generator.sanitizeRecord(
        currentRecord,
        inspection,
        redactionOnly: _isRedactionMode,
      );

      final verifier = VerificationAgent(apiKey: apiKey);
      final verification = await verifier.verifySanitization(
        originalRecord: currentRecord,
        sanitizedRecord: sanitized,
      );

      setState(() {
        _inspectionResult = inspection;
        _sanitizedRecord = sanitized;
        _verificationResult = verification;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Pipeline Error: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  void _showLogsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Agent Trajectory Logs',
          style: TextStyle(color: Color(0xFF6366F1)),
        ),
        content: SizedBox(
          width: 600,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              const JsonEncoder.withIndent('  ').convert(TrajectoryLogger.logs),
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Color(0xFF34D399),
                fontSize: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const emeraldColor = Color(0xFF10B981);
    const emeraldAccent = Color(0xFF34D399);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Agentic PII Sanitizer - micro1 Challenge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long, color: Color(0xFF6366F1)),
            tooltip: 'View Trajectory Logs',
            onPressed: _showLogsDialog,
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Chip(
              label: const Text('Gemini 3.6 Flash Pipeline'),
              backgroundColor: emeraldColor.withOpacity(0.2),
              labelStyle: const TextStyle(color: emeraldAccent),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Controls Bar: API Key, Mode Switcher, Run Button
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter Gemini API Key...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(
                        Icons.key,
                        color: Color(0xFF6366F1),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _isRedactionMode
                            ? 'Mode: Redaction'
                            : 'Mode: Synthetic',
                        style: TextStyle(
                          color: _isRedactionMode
                              ? Colors.orangeAccent
                              : emeraldAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: _isRedactionMode,
                        activeColor: Colors.orangeAccent,
                        inactiveThumbColor: emeraldAccent,
                        onChanged: (val) {
                          setState(() {
                            _isRedactionMode = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _runPipeline,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.flash_on),
                  label: Text(
                    _isLoading ? 'Running Pipeline...' : 'Run Agent Pipeline',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildCard(
                      'Custom Input Data',
                      _buildRawInputView(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCard(
                      'Inspector & Verification',
                      _buildInspectionView(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCard(
                      'Sanitized Output',
                      _buildSanitizedView(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6366F1),
            ),
          ),
          const Divider(height: 24, color: Color(0xFF334155)),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildRawInputView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User ID: USR-8801',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          const Text(
            'Status: ACTIVE',
            style: TextStyle(color: Color(0xFF34D399)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Input Unstructured Text:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 6,
            style: const TextStyle(color: Colors.white70, height: 1.4),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionView() {
    if (_inspectionResult == null) {
      return const Center(
        child: Text(
          'Click "Run Agent Pipeline" to start',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    final isVerified = _verificationResult?['is_fully_sanitized'] == true;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            avatar: Icon(
              isVerified ? Icons.check_circle : Icons.warning,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              isVerified ? 'VERIFICATION PASSED' : 'VERIFICATION FAILED',
            ),
            backgroundColor: isVerified ? const Color(0xFF10B981) : Colors.red,
            labelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              const JsonEncoder.withIndent('  ').convert(_inspectionResult),
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Color(0xFF34D399),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSanitizedView() {
    if (_sanitizedRecord == null) {
      return const Center(
        child: Text(
          'Click "Run Agent Pipeline" to start',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sanitized Email: ${_sanitizedRecord!.email}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Sanitized Phone: ${_sanitizedRecord!.phone}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sanitized Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF34D399),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18, color: Colors.white54),
                tooltip: 'Copy Output',
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: _sanitizedRecord!.internalNotes),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sanitized notes copied to clipboard!'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF10B981)),
            ),
            child: Text(
              _sanitizedRecord!.internalNotes,
              style: const TextStyle(color: Colors.white, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
