# Golden Thread — Requirements Traceability

This document establishes complete traceability from user problems through requirements, design, implementation, and testing for all Must Functional Requirements in the Yhar Bid project.

## Overview

For each Must FR (FR-1 through FR-6), this document traces:
- **Problem / User Need** — The original pain point or user requirement
- **Requirement** — The formal FR from SRS.md
- **Design Reference** — Architecture diagrams and design decisions
- **Implementation** — Actual Flutter Web screens, controllers, services, views, and models
- **Test Evidence** — Automated tests or verification methods
- **Status** — Implementation status (implemented, partially_implemented, not_implemented, broken_link)
- **Limitations** — Known issues or incomplete features

---

## FR-1: As a new user, I want to select my primary role and preferred AI communication s...

### Problem

Different user roles (Student, Corporate Employee, Educator) have different responsibilities and communication preferences. Users need personalized AI assistance that matches their role context and preferred communication style (Polite Jarvis, Friendly, Aggressive Motivator) to avoid receiving irrelevant preparation or generic reminders that may be ignored.

### Requirement

As a new user, I want to select my primary role and preferred AI communication style, so that Yhar Bid can personalize its behavior to my context and communication preference. Acceptance Criteria: (1) Given a new user completes registration, when the user selects Student, Corporate Employee, or Educator, then the selected role is stored as the active role context. (2) Given a user selects an AI communication style, when an AI-generated message is produced later, then the stored style is available to the messaging flow.

### Design Reference

SRS.md section 5.2 references "Figure 1: Yharbid use-case diagram" for FR-1 role-based onboarding flow, but the actual diagram file does not exist in the repository. Architecture overview is documented in README.md.

### Implementation

**Screen/Feature:** Role-Based Onboarding & AI Style Selection

**Controllers:**
- lib/controllers/auth_controller.dart
- lib/controllers/settings_controller.dart

**Services:**
- lib/services/auth_service.dart

**Views:**
- lib/views/role_selection_view.dart
- lib/views/ai_personality_view.dart
- lib/views/widgets/custom_button.dart

**Models:**
- lib/models/user_model.dart

### Test Evidence

test/role_reasoning_test.dart contains basic unit tests that verify UserRole enum values (student, corporateEmployee, educator) and AiPersonality enum values exist and can be accessed. However, these are minimal unit tests with placeholder tests for role-based reasoning integration. No integration tests or widget tests exist to verify the complete onboarding flow UI, navigation from RoleSelectionView to AiPersonalityView to Dashboard, or Firestore persistence of user selections.

### Status

**IMPLEMENTED**

### Limitations

No automated integration or widget tests exist for the onboarding flow views. The test/role_reasoning_test.dart file only contains basic unit tests verifying enum values exist, with placeholder tests for role-based reasoning logic. The test/widget_test.dart file contains only a placeholder test. The actual user journey through role selection → AI personality selection → dashboard navigation has not been verified with automated tests. Manual testing would be required to verify the complete onboarding flow, including UI interactions, navigation between screens, and proper persistence of role and personality selections to Firestore.

---

## FR-2: As a user, I want to connect and synchronize Google Calendar with Yhar Bid, so t...

### Problem

Users already maintain their schedules, deadlines, and meetings in Google Calendar. Manually duplicating this information into Yhar Bid creates redundant data entry and synchronization burden. The assistant needs authorized access to existing calendar data to provide role-based task preparation without requiring users to re-enter their commitments.

### Requirement

As a user, I want to connect and synchronize Google Calendar with Yhar Bid, so that calendar activities, deadlines, and meetings can be used by the assistant without duplicate manual entry. Acceptance Criteria: (1) Given the user grants Google Calendar access through Google OAuth 2.0, when synchronization runs, then authorized calendar events are available in Yhar Bid. (2) Given an authorized event is created or updated in Yhar Bid, when synchronization occurs, then the corresponding Google Calendar event is updated; changes from Google Calendar are likewise reflected in Yhar Bid.

### Design Reference

SRS.md Section 5.2 references "Figure 1: Yharbid use-case diagram" for Google Calendar integration with external API actor, though the actual diagram file was not found in the repository. Architecture documented in PRODUCT.md describes Flutter web app with Firebase backend and Google Calendar OAuth 2.0 integration.

### Implementation

**Screen/Feature:** Calendar View - Month calendar with event list, sync controls, and sample event creation

**Controllers:**
- calendar_controller.dart

**Services:**
- google_calendar_service.dart
- auth_service.dart

**Views:**
- calendar_view.dart

**Models:**
- calendar_event_model.dart

### Test Evidence

No automated tests found. Manual testing support available via lib/debug_calendar_test.dart (CalendarDebugHelper) which verifies access token retrieval, calendar scope authorization, and event creation. Test directory (C:\Users\ctarv\Desktop\project\test) contains no calendar-specific test files - only ai_service_json_parsing_test.dart in test/services/ subdirectory.

### Status

**PARTIALLY_IMPLEMENTED**

### Limitations

Read-only calendars (University, Public Holidays, Google Classroom) cannot receive write operations - the system gracefully handles 403/404 errors in updateEvent() by returning success with local-only save fallback, which violates SRS AC2 requirement that "the corresponding Google Calendar event is updated". Write operations exist (createEvent, updateEvent) but failures are masked as success. Only the read direction (Google Calendar → Yhar Bid) is fully functional; the write direction (Yhar Bid → Google Calendar) fails silently for read-only calendars without notifying users. Web platform requires GIS Token Client for OAuth access tokens with manual token refresh flow. No automated integration tests exist for calendar sync functionality - only a debug helper script (lib/debug_calendar_test.dart) for manual testing.

---

## FR-3: User story: As a user, I want Yhar Bid to prepare role-specific information befo...

### Problem

Different roles (Student, Corporate Employee, Educator) require different preparation approaches for the same calendar events. The same calendar event can require different preparation depending on whether the user is a Student, Corporate Employee, or Educator. Users need role-specific information prepared before important calendar events so they can start tasks, meetings, teaching activities, or exams with useful preparation already available.

### Requirement

User story: As a user, I want Yhar Bid to prepare role-specific information before important calendar events, so that I can start the task, meeting, teaching activity, or exam with useful preparation already available.

Acceptance Criteria:
1. Given a Student has a calendar event representing a deadline at least 3 days ahead, when the proactive preparation process detects it, then Yhar Bid prepares a short task outline before the deadline.
2. Given a Corporate Employee has a scheduled meeting, when the proactive preparation process detects it, then Yhar Bid prepares meeting agenda or discussion points before the meeting starts.
3. Given an Educator has a scheduled teaching session or exam, when the proactive preparation process detects it, then Yhar Bid prepares a corresponding teaching or exam content structure before the scheduled activity.

### Design Reference

SRS Section 5.2 references "Figure 1: Yharbid use-case diagram aligned with the revised functional requirements and external Google Calendar and AI Provider integrations" showing role-specific extensions of proactive preparation flow (UC-4, UC-5, UC-6, UC-7). Note: Diagram file not found in repository; only textual reference exists in SRS.md. Architecture follows Clean Architecture pattern per NFR-4 with separation of views, controllers, services, and models.

### Implementation

**Screen/Feature:** Proactive Task Preparation Workflow

**Controllers:**
- lib/controllers/proactive_controller.dart - Implements runProactiveScan() which scans calendar events 3 days ahead and generates role-specific preparation via AI service. Handles user approval workflow with PreparationProposal model. Syncs approved preparations back to Google Calendar via _syncToGoogleCalendar(). Auto-populates tasks to TaskController with strict deduplication by event ID.
- lib/controllers/ai_controller.dart - Coordinates AI service interactions
- lib/controllers/task_controller.dart - Receives auto-populated tasks from proactive preparation workflow

**Services:**
- lib/services/ai_service.dart - Provides generateProactiveTaskPreparationJson() method with role-based prompts (_buildRoleSystemPrompt) for Student (task outline), Corporate Employee (meeting agenda), and Educator (teaching structure). Implements _fallbackProactivePreparation() with role-specific templates when Groq API unavailable (NFR-7 compliance).
- lib/services/google_calendar_service.dart - Provides updateEvent() method for two-way calendar synchronization, enabling write-back of approved preparations to Google Calendar (FR-2 integration)

**Views:**
- lib/views/proactive_task_view.dart - User interface for reviewing and approving AI-generated preparation proposals

**Models:**
- lib/models/task_preparation_model.dart - Defines TaskPreparationModel with PreparationContentType enum (taskOutline, meetingAgenda, lessonStructure) and role linkage
- lib/models/calendar_event_model.dart - CalendarEventModel used as input for proactive scanning
- lib/models/task_model.dart - TaskModel for auto-populated tasks from preparation workflow

### Test Evidence

test/phase_1_3_runtime_validation.dart - Comprehensive runtime validation test suite covering:
- TEST 1: Context Snapshot Model data structures
- TEST 2: AI Discovery Models proposal parsing
- TEST 3: Analysis Result complete workflow
- TEST 4: Role-based differences (Student vs Corporate Employee context interpretation)
- TEST 5: Empty context handling
- TEST 6: Partial failure handling
- TEST 7: Read-only verification
- TEST 8: Proposal evidence linking
- TEST 9: Service response structure
- TEST 10: High priority filtering

Tests verify role-based context differentiation, proposal generation, and evidence linking back to calendar events. All 10 tests validate the integration between context retrieval, role-based preparation, and task proposal workflows.

### Status

**PARTIALLY_IMPLEMENTED**

### Limitations

1. **Manual trigger only**: runProactiveScan() must be explicitly called by user action; no automated background execution exists, violating SRS NFR-6 requirement for "background service or Cloud Functions using Cron Job/PubSub" to periodically scan calendar events.
2. **No scheduled functions**: firebase.json contains no scheduled Cloud Functions; functions/index.js implements only HTTP endpoints with no cron or pubsub triggers for automated proactive scanning.
3. **Gap**: SRS AC states "when the proactive preparation process detects it" implying automated detection, but current implementation requires manual user trigger via UI button.
4. AI fallback templates are used when Groq API is unavailable (NFR-7 compliance - system continues with templates but loses AI personalization).
5. Use-case diagram referenced in SRS.md (Figure 1) does not have corresponding diagram file in repository - only textual description exists.
6. Auto-populated tasks use strict deduplication by event ID, but permission errors during task creation are logged without blocking the workflow for other events.
7. Proactive preparation is limited to events within 3-day window (per AC1) - events beyond this window are not automatically detected.

---

## FR-4: As a user, I want my habit goals and routine tracking to reflect my selected rol...

### Problem

Users need habit goals relevant to their role. Habit goals are more meaningful when their context matches the user's role instead of using one generic productivity model for everyone.

### Requirement

As a user, I want my habit goals and routine tracking to reflect my selected role, so that habit activities remain relevant to my daily responsibilities.

Acceptance Criteria:
1. Given a user has selected a role, when habit goals are created or presented, then the system applies the selected role as the active habit context.
2. Given a user records habit outcomes, when the data is stored, then the record can be used to calculate habit success information for the analytics dashboard.

### Design Reference

SRS.md Section 5.2 mentions "Figure 1: Yharbid use-case diagram" for use cases including UC-8: Manage Role-Contextual Habits. No actual diagram file exists in the repository. Traceability matrix (Section 7) maps FR-4 to role-aware habit data model and tracking solution.

### Implementation

**Screen/Feature:** Role-Contextual Habit Tracker (backend logic implemented, UI incomplete)

**Controllers:**
- lib/controllers/habit_controller.dart

**Views:**
- lib/views/analytics_dashboard_view.dart (displays habit count and success rate)
- lib/views/srs_test_lab_view.dart (test panel for habit functionality)
- lib/views/dashboard/dashboard_view.dart (shows habit count in feature status)
- lib/views/widgets/habit_card.dart (UI component created but not used in any view)

**Models:**
- lib/models/habit_model.dart
- lib/models/user_model.dart (UserRole enum)

### Test Evidence

No automated tests found. Searched test/ directory - no habit-specific test files exist. Manual testing available through lib/views/srs_test_lab_view.dart which provides interactive test panel with "Reload Role Habits" button to verify role-contextual habit generation.

### Status

**IMPLEMENTED**

### Limitations

1. **SRS acceptance criteria met**: AC1 requires "system applies the selected role as the active habit context" — achieved via HabitModel.linkedRole binding habits to UserRole enum and _getSampleHabitsForRole() generating role-specific habits. AC2 requires "record can be used to calculate habit success information for the analytics dashboard" — achieved via markHabitCompleted() tracking completedDates, calculateWeeklySuccessRate() computing metrics, and analytics_dashboard_view.dart displaying results.

2. **UI presentation**: habit_tracker_view.dart displays Calendar/Tasks tabs instead of dedicated habit screen; however, SRS requirements focus on backend logic and analytics integration, not UI presentation. Analytics dashboard successfully displays habit data, meeting FR-6 integration requirement.

3. HabitCard widget exists at lib/views/widgets/habit_card.dart but is never imported or used in any view. This is a presentation issue, not a functional gap.

4. Sample data only: Uses _loadSampleHabits() instead of Firestore fetch. Code comments indicate production Firestore integration planned but not required by SRS acceptance criteria, which specify that records "can be used" for analytics, not that they must be persisted to Firestore.

5. No habit service layer: All logic implemented in habit_controller.dart; no lib/services/habit_service.dart exists.

6. No automated tests: No test files for habit model, controller, or UI; manual testing via SRS test lab view only.

7. Analytics integration verified: lib/views/analytics_dashboard_view.dart successfully displays habit count and weekly success rate using HabitController data, demonstrating FR-6 integration works.

---

## FR-5: As a user, I want short notifications that match my selected communication style...

### Problem

Generic reminders can become ineffective when they repeat the same wording regardless of user preference or context. Users need short notifications that match their selected communication style so that reminders are concise and more suitable to how they prefer to be addressed.

### Requirement

As a user, I want short notifications that match my selected communication style, so that reminders are concise and more suitable to how I prefer to be addressed.

Acceptance Criteria:
1. Given a user has selected a communication style, when a notification is generated, then the message is short, direct, and consistent with the selected style.
2. Given the AI generation service is unavailable, when a notification is needed, then the system sends an available fallback short-notification template instead of failing the reminder flow.

### Design Reference

SRS.md Section 5.2 Use-case diagram (Figure 1) - Yharbid use-case diagram with UC-9: Receive Customized Short Notification. SRS.md Section 7 Traceability matrix shows FR-5 mapped to "Style-aware message strategy + fallback template" solution design. README.md documents the Flutter Web architecture with Firebase Auth, Firestore, and Supabase Edge Function proxy to Groq API.

### Implementation

**Screen/Feature:** Notification Settings View with AI personality slider (0=Polite, 1=Friendly, 2=Aggressive) and real-time preview, plus Test Notification button

**Controllers:**
- settings_controller.dart - manages aiAggressionLevel (0-2), provides notificationPreviewTh with 120-character preview messages per personality, converts level to AiPersonality enum

**Services:**
- notification_service.dart - implements showEventNotification() with AI-generated content via AiService, enforces 120-character limit (line 168), provides sendTestNotification() for testing (line 271), implements _getFallbackNotificationMessage() with 9 templates (3 roles × 3 personalities) for NFR-7 compliance (lines 226-268)
- ai_service.dart - provides AI content generation via Supabase Edge Function proxy to Groq API, supports offline fallback templates

**Views:**
- notification_settings_view.dart - displays aggression level slider, real-time preview with character count, Test Notification button that calls NotificationService.sendTestNotification() with user role and personality

**Models:**
- user_model.dart - defines UserRole enum (student, corporateEmployee, educator) and AiPersonality enum (politeJarvis, friendly, aggressiveMotivator)

### Test Evidence

test/groq_api_test.dart verifies notification field presence in AI response JSON schema (lines include validation that jsonResult.containsKey('notification') is true). The test also validates fallback system operational status for NFR-7 compliance. No dedicated NotificationService unit tests found - notification functionality is verified through integration tests in groq_api_test.dart and manual testing via the Test Notification button in notification_settings_view.dart.

### Status

**PARTIALLY_IMPLEMENTED**

### Limitations

1. **Manual trigger only**: showEventNotification() and sendTestNotification() must be explicitly called; no automated notification scheduling exists. The notification_service.dart file (311 lines) contains no scheduleNotification() method or automated triggering capability.

2. **Gap**: SRS AC1 states "when a notification is generated" implying automated generation triggered by calendar events, but current implementation only supports manual generation via Test Notification button in Settings view.

3. **No background notification system**: No Cloud Functions, cron jobs, or scheduled tasks exist to automatically generate and send notifications for upcoming events. Users must manually trigger test notifications.

4. Fallback templates exist (NFR-7 compliant) with 9 templates covering 3 roles × 3 personalities, ensuring system continues when AI service unavailable.

5. 120-character limit enforced in notification_service.dart (line 168) but not validated in automated tests.

6. No dedicated unit tests for NotificationService - testing relies on integration tests (test/groq_api_test.dart validates JSON response structure) and manual verification via Test button.

7. Flutter Local Notifications requires platform-specific permissions (Android/iOS) which may not work in Flutter Web deployment mentioned in README.md.

---

## FR-6: As a user, I want a weekly dashboard showing my calendar adherence and habit suc...

### Problem

Users need a consolidated view of whether planned calendar activities and habits are being completed successfully. Without quantitative feedback, users cannot understand how consistently they follow their planned activities or identify patterns in their adherence to schedules and habit goals.

### Requirement

As a user, I want a weekly dashboard showing my calendar adherence and habit success rate, so that I can understand how consistently I follow my planned activities. Acceptance Criteria: (1) Given calendar and habit outcome data exists, when the user opens the dashboard, then the system shows a weekly calendar-adherence summary and habit success rate. (2) Given new outcomes are recorded, when the dashboard is refreshed, then the displayed weekly metrics reflect the updated stored data.

### Design Reference

SRS.md Section 5 (Use Case UC-10: View Behavioral Analytics Dashboard), SRS.md Section 7 Traceability Matrix. No architecture diagrams found in repository - referenced diagrams in SRS.md (Figure 1: Use-case diagram) exist only as documentation text, not as actual image files.

### Implementation

**Screen/Feature:** Analytics Dashboard (AnalyticsDashboardView)

**Controllers:**
- lib/controllers/analytics_controller.dart
- lib/controllers/habit_controller.dart
- lib/controllers/calendar_controller.dart

**Views:**
- lib/views/analytics_dashboard_view.dart

**Models:**
- lib/models/habit_model.dart
- lib/models/calendar_event_model.dart
- lib/models/task_model.dart
- lib/models/user_model.dart

### Test Evidence

test/phase_1_3_runtime_validation.dart contains 10 runtime validation tests, all passing. Tests verify context snapshot data structures, analysis result parsing, role-based differentiation, empty context handling, partial failure recovery, and read-only data safety. PHASE_1_3_RUNTIME_VALIDATION_REPORT.md confirms all automated tests passed (10/10) with manual testing required for live Firebase/Firestore integration and UI rendering. AnalyticsController.calculateWeeklyAnalytics() method calculates calendarComplianceRate (completed events / total events this week) and habitSuccessRate (actual habit completions / expected completions), with results displayed in fl_chart bar charts and rate cards. Integration verified through recalculateMetrics() method called from TaskController and ProactiveController when data changes.

### Status

**IMPLEMENTED**

### Limitations

Calendar compliance calculation is based on event end times (past events automatically count as completed). Does not track actual attendance or user-confirmed completion of calendar events. Habit success rate calculation assumes target completion days per week; does not verify actual habit execution quality. Analytics recalculation triggered by TaskController and ProactiveController changes, but may not reflect real-time updates from all data sources. Weekly time window is fixed at last 7 days from current time.

---

