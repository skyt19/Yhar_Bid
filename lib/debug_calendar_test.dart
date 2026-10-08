/// Debug script for testing Google Calendar API
/// Run: flutter run -d chrome --web-port=5000
/// Then call this from DevTools console or add button in UI

import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/google_calendar_service.dart';

class CalendarDebugHelper {
  static Future<void> testCalendarSync() async {
    print('🔍 === CALENDAR SYNC DEBUG TEST ===');
    
    // Step 1: Check Access Token
    final AuthService authService = AuthService();
    final String? token = await authService.getAccessToken();
    
    if (token == null || token.isEmpty) {
      print('❌ Access Token is NULL or EMPTY');
      print('   Solution: User needs to login again');
      return;
    }
    
    print('✅ Access Token exists (length: ${token.length})');
    print('   Token preview: ${token.substring(0, 20)}...');
    
    // Step 2: Check Calendar Scope
    final bool hasScope = await authService.hasCalendarScope();
    print(hasScope ? '✅ Has Calendar Scope' : '❌ Missing Calendar Scope');
    
    if (!hasScope) {
      print('   🔄 Requesting Calendar Scope...');
      final bool granted = await authService.requestCalendarScope();
      print(granted ? '✅ Scope granted!' : '❌ User denied scope');
      
      if (!granted) {
        print('   Solution: User must approve Calendar access in popup');
        return;
      }
    }
    
    // Step 3: Test Create Event
    print('📝 Creating test event...');
    final GoogleCalendarService calService = GoogleCalendarService();
    
    final DateTime now = DateTime.now();
    final DateTime startTime = now.add(const Duration(hours: 1));
    final DateTime endTime = startTime.add(const Duration(hours: 1));
    
    final CalendarServiceResponse response = await calService.createEvent(
      token,
      title: 'DEBUG TEST EVENT',
      startTime: startTime,
      endTime: endTime,
      description: 'This is a test event from debug script',
    );
    
    if (response.status) {
      print('✅ Event created successfully!');
      print('   Message: ${response.message}');
      print('   Event ID: ${response.data?.id ?? "N/A"}');
    } else {
      print('❌ Failed to create event');
      print('   Error Message: ${response.message}');
      print('   ');
      print('🔍 TROUBLESHOOTING:');
      print('   1. Check if Calendar API is enabled in Google Cloud Console');
      print('   2. Verify OAuth consent screen has calendar scopes');
      print('   3. Check if access token is expired (try re-login)');
      print('   4. Ensure GOOGLE_CLIENT_ID in .env is correct');
    }
    
    print('🔍 === TEST COMPLETE ===');
  }
  
  static Widget buildDebugButton() {
    return FloatingActionButton.extended(
      onPressed: testCalendarSync,
      label: const Text('🔍 Debug Calendar'),
      icon: const Icon(Icons.bug_report),
      backgroundColor: Colors.deepPurple,
    );
  }
}
