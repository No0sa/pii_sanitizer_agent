import 'dart:convert';
import 'package:flutter/foundation.dart';

class TrajectoryLogger {
  static final List<Map<String, dynamic>> _logs = [];

  static Future<void> logAgentAction({
    required String agentName,
    required String systemPrompt,
    required String userInput,
    required String agentOutput,
    Map<String, dynamic>? metadata,
  }) async {
    final entry = {
      'timestamp': DateTime.now().toIso8601String(),
      'agent': agentName,
      'system_prompt': systemPrompt,
      'user_input': userInput,
      'agent_output': agentOutput,
      'metadata': metadata ?? {},
    };

    _logs.add(entry);
    debugPrint('=== [TRAJECTORY LOG: $agentName] ===');
    debugPrint(jsonEncode(entry));
  }

  static List<Map<String, dynamic>> get logs => List.unmodifiable(_logs);
}
