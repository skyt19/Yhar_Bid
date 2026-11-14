# Yhar Bid
**Visual: hero-statement**

Adaptive Routine & Reminder Assistant

M3 Final Presentation | Software Engineering Project

---

# The Challenge
**Visual: cards-3**

[Column 1: Context Overload]
Students and professionals juggle multiple responsibilities across calendars, task lists, and communication tools, leading to missed deadlines and reactive workflows.

[Column 2: Generic Solutions]
Existing reminder apps treat all users the same, ignoring individual roles, preferences, and workflow patterns.

[Column 3: Manual Burden]
Users must constantly check multiple systems and manually translate calendar events into actionable preparation steps.

---

# The Vision
**Visual: hero-statement**

A context-aware assistant that understands your role, monitors your commitments, and proactively suggests personalized preparation strategies.

---

# Product Overview
**Visual: process-3-phase**

[Column 1: Learn]
Users select their primary role (Student, Corporate, Healthcare) and AI interaction style (Chill, Balanced, Aggressive).

[Column 2: Monitor]
The system integrates with Google Calendar to track upcoming commitments and responsibilities.

[Column 3: Guide]
AI generates role-appropriate preparation suggestions, tracks habits, and provides behavioral analytics.

---

# System Architecture
**Visual: cards-4**

[Column 1: Frontend]
Flutter Web application with role-based UI, responsive design, and real-time updates via Firebase.

[Column 2: Authentication]
Firebase Authentication with Google OAuth for secure calendar access and user management.

[Column 3: AI Pipeline]
Supabase Edge Function proxies requests to Groq (llama-3.3-70b-versatile) with Firebase token verification and rate limiting.

[Column 4: Data Layer]
Cloud Firestore for user profiles, habits, tasks, and calendar events with real-time synchronization.

---

# Requirements Overview
**Visual: table**

| Requirement | Status | Evidence |
|-------------|--------|----------|
| FR-1: Role-Based Onboarding | ✅ Implemented | role_selection_view.dart, user persistence |
| FR-2: Calendar Sync | ⚠️ Partial | Read works; write has fallback |
| FR-3: Proactive Preparation | ⚠️ Partial | AI works; manual trigger only |
| FR-4: Habit Tracker | ✅ Implemented | Backend + analytics integration |
| FR-5: Notifications | ⚠️ Partial | Generation works; no scheduling |
| FR-6: Analytics Dashboard | ✅ Implemented | Real-time charts + metrics |

{bold}3 of 6 requirements fully implemented (50%){/bold}

{bold}3 requirements partially implemented with working features{/bold}

---

# Implemented Features: FR-1
**Visual: process-3-phase**

[Column 1: Role Selection]
Users choose Student, Corporate, or Healthcare role with dedicated onboarding screens and role-specific context.

[Column 2: AI Personality]
Three interaction styles—Chill (supportive), Balanced (neutral), Aggressive (direct)—persist across sessions.

[Column 3: Persistence]
Role and personality stored in user_model.dart and auth_controller.dart, driving all AI interactions.

{bold}Test Evidence:{/bold} role_reasoning_test.dart validates role-based prompt differentiation.

---

# Implemented Features: FR-4, FR-6
**Visual: comparison-2**

[Column 1: Habit Tracker (FR-4)]
- habit_model.dart with linkedRole field
- habit_controller.dart manages CRUD operations
- Analytics integration calculates success rates
- Backend fully operational

{bold}Evidence:{/bold} Analytics calculations verified in runtime validation tests.

[Column 2: Analytics Dashboard (FR-6)]
- Real-time fl_chart visualizations
- Calendar compliance rate tracking
- Habit success rate metrics
- Weekly trend analysis

{bold}Evidence:{/bold} phase_1_3_runtime_validation.dart (10/10 tests passing).

---

# Partial Implementation: FR-2
**Visual: cards-3**

[Column 1: What Works]
✅ fetchUpcomingEvents() retrieves calendar data
✅ Google Calendar OAuth integration
✅ Event display in UI

[Column 2: The Gap]
⚠️ createEvent()/updateEvent() return success on 403/404 errors
⚠️ Write operations save locally but may not update Google Calendar
⚠️ Only read direction (Google → Yhar Bid) fully reliable

[Column 3: Impact]
Users can view calendar events but two-way sync is not guaranteed. SRS AC2 (bidirectional sync) not met.

---

# Partial Implementation: FR-3, FR-5
**Visual: comparison-2**

[Column 1: FR-3 Proactive Preparation]
{bold}What Works:{/bold}
- runProactiveScan() analyzes upcoming events
- Role-based AI reasoning generates preparation proposals
- Context snapshot and evidence linking

{bold}The Gap:{/bold}
- Manual trigger only (no automated background scanning)
- No Cloud Functions or cron jobs
- NFR-6 (background scheduler) requirement not met

[Column 2: FR-5 Notifications]
{bold}What Works:{/bold}
- AI generates personalized 120-char notifications
- 9 fallback templates (3 roles × 3 personalities)
- Test button in Settings validates generation

{bold}The Gap:{/bold}
- No scheduleNotification() method exists
- Manual trigger only (no automated delivery)
- No background notification system

---

# Technical Stack
**Visual: cards-4**

[Column 1: Core]
- Flutter 3.24.5 (Web)
- Dart 3.5.4
- Clean Architecture pattern
- Responsive design

[Column 2: Backend]
- Firebase (Auth, Firestore, Storage)
- Supabase Edge Function (AI proxy)
- Google Calendar API v3
- OAuth 2.0

[Column 3: AI]
- Groq API (llama-3.3-70b-versatile)
- Firebase token verification
- Rate limiting + error handling
- Offline fallback templates

[Column 4: Deployment]
- Firebase Hosting
- Production: yhar-bid.web.app
- CI/CD via Firebase CLI
- Environment-based config

---

# Testing & Validation
**Visual: cards-3**

[Column 1: Automated Tests]
{bold}27 passing tests across 8 suites:{/bold}
- phase_1_3_runtime_validation.dart (10/10)
- role_reasoning_test.dart
- groq_api_test.dart
- ai_service_json_parsing_test.dart
- notification_service_test.dart
- habit_model_test.dart
- analytics_controller_test.dart
- calendar_service_test.dart

[Column 2: What Was Verified]
✅ Role-based context interpretation
✅ AI proposal structure + parsing
✅ Calendar event → task workflow
✅ Analytics calculations
✅ Notification field presence
✅ Fallback system (NFR-7)

[Column 3: Manual Validation]
- Google Calendar OAuth flow
- UI interactions + navigation
- Firestore persistence
- Cross-browser compatibility
- Real-world calendar sync behavior

---

# Limitations & Future Work
**Visual: cards-4**

[Column 1: Calendar Sync]
- Implement reliable two-way sync with proper error handling
- Distinguish read-only calendars from writable ones
- Add retry logic for transient failures

[Column 2: Background Automation]
- Deploy Cloud Functions for proactive scanning
- Implement cron jobs or PubSub triggers
- Add automated notification scheduling
- Meet NFR-6 requirement

[Column 3: Test Coverage]
- Add integration tests for FR-1 onboarding flow
- Automated tests for FR-2 calendar sync
- End-to-end workflow tests across all 6 FRs

[Column 4: Documentation]
- Generate missing use-case diagrams
- Verify Firestore security rules
- Manual accessibility testing with assistive technologies

---

# Golden Thread
**Visual: process-4-phase**

[Column 1: Problem]
Users struggle with context overload, generic solutions, and manual burden across multiple responsibility-tracking systems.

[Column 2: Requirements]
6 functional requirements covering role-based onboarding, calendar sync, proactive preparation, habit tracking, notifications, and analytics.

[Column 3: Design & Implementation]
Clean Architecture Flutter Web app with Firebase backend, Groq AI integration, and role-specific reasoning engine.

[Column 4: Validation]
27 automated tests, manual validation, and honest assessment: 3 FRs implemented, 3 partially implemented with documented gaps.

---

# Yhar Bid
**Visual: hero-statement**

{bold}3 of 6 requirements fully implemented{/bold}

{bold}3 requirements partially implemented with working features{/bold}

A foundation for adaptive, role-aware assistance with clear next steps for completion.
