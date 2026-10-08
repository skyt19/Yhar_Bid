/// Quick Debug Page - Add this to bottom nav temporarily
import 'package:flutter/material.dart';
import '../debug_calendar_test.dart';
import '../services/auth_service.dart';
import '../services/google_calendar_service.dart';

class DebugCalendarView extends StatefulWidget {
  const DebugCalendarView({super.key});

  @override
  State<DebugCalendarView> createState() => _DebugCalendarViewState();
}

class _DebugCalendarViewState extends State<DebugCalendarView> {
  String _log = '';
  bool _isRunning = false;

  void _addLog(String message) {
    setState(() {
      _log += '$message\n';
    });
  }

  Future<void> _runTest() async {
    setState(() {
      _log = '';
      _isRunning = true;
    });
    
    _addLog('🔍 === STARTING CALENDAR SYNC TEST ===\n');
    
    try {
      // Step 1: Check Access Token
      final AuthService authService = AuthService();
      final String? token = await authService.getAccessToken();
      
      if (token == null || token.isEmpty) {
        _addLog('❌ FAILED: Access Token is NULL');
        _addLog('📋 ACTION: User needs to logout and login again\n');
        setState(() => _isRunning = false);
        return;
      }
      
      _addLog('✅ Access Token exists');
      _addLog('   Length: ${token.length} chars');
      _addLog('   Preview: ${token.substring(0, 30)}...\n');
      
      // Step 2: Check Calendar Scope
      _addLog('🔍 Checking Calendar Scope...');
      final bool hasScope = await authService.hasCalendarScope();
      
      if (!hasScope) {
        _addLog('❌ Missing Calendar Scope');
        _addLog('📋 Requesting scope...');
        
        final bool granted = await authService.requestCalendarScope();
        if (!granted) {
          _addLog('❌ FAILED: User denied scope');
          _addLog('📋 ACTION: Approve Calendar access in popup\n');
          setState(() => _isRunning = false);
          return;
        }
        _addLog('✅ Scope granted!\n');
      } else {
        _addLog('✅ Has Calendar Scope\n');
      }
      
      // Step 3: Create Test Event
      _addLog('📝 Creating test event...');
      final GoogleCalendarService calService = GoogleCalendarService();
      
      final DateTime now = DateTime.now();
      final DateTime startTime = now.add(const Duration(hours: 2));
      final DateTime endTime = startTime.add(const Duration(hours: 1));
      
      _addLog('   Start: ${startTime.toString()}');
      _addLog('   End: ${endTime.toString()}\n');
      
      final CalendarServiceResponse response = await calService.createEvent(
        token,
        title: '🧪 DEBUG TEST EVENT ${now.hour}:${now.minute}',
        startTime: startTime,
        endTime: endTime,
        description: 'Auto-generated test event from Calendar Sync Debug',
      );
      
      if (response.status) {
        _addLog('✅ SUCCESS: Event created!');
        _addLog('   Message: ${response.message}');
        _addLog('   Event ID: ${response.data?.id ?? "N/A"}');
        _addLog('\n🎉 Go check your Google Calendar now!');
      } else {
        _addLog('❌ FAILED: Could not create event');
        _addLog('   Error: ${response.message}\n');
        _addLog('🔧 TROUBLESHOOTING:');
        _addLog('   1. Google Cloud Console → APIs & Services');
        _addLog('   2. Enable "Google Calendar API"');
        _addLog('   3. OAuth Consent Screen → Add calendar scopes');
        _addLog('   4. Test Users → Add your email');
        _addLog('   5. Try logout/login again');
      }
      
    } catch (e) {
      _addLog('❌ EXCEPTION: ${e.toString()}');
    }
    
    _addLog('\n🔍 === TEST COMPLETE ===');
    setState(() => _isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Calendar Sync Debugger'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade50,
            child: const Text(
              'This tool helps debug Google Calendar sync issues.\n'
              'Press the button below to run diagnostics.',
              style: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isRunning ? null : _runTest,
            icon: _isRunning 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_isRunning ? 'Running Test...' : 'Run Calendar Test'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple, width: 2),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _log.isEmpty ? '>>> Console output will appear here <<<' : _log,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
