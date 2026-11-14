# Yhar Bid

**Adaptive Routine & Reminder Assistant**

A role-based AI assistant that transforms calendar events into actionable preparation plans. Built with Flutter Web and deployed on Firebase, Yhar Bid provides intelligent task preparation with adaptive AI personality modes for students, corporate employees, and educators.

**Live Application:** https://yhar-bid.web.app

---

## Problem Statement

Many users know what they need to do but may procrastinate, miss planned activities, or repeatedly ignore generic reminders. Traditional calendar apps provide passive notifications without context or preparation support. Users across different roles face distinct challenges that generic productivity tools cannot address:

- Redundant manual data entry between Google Calendar and task management systems
- Generic reminders lacking role-specific context and preferred communication style
- Inability to proactively prepare for upcoming events with role-appropriate materials
- Lack of consolidated behavioral analytics to track adherence to planned activities

**Yhar Bid addresses this by:**
- Analyzing calendar events and generating detailed preparation plans before activities occur
- Adapting communication style to user preferences (Polite Jarvis, Friendly, Aggressive Motivator)
- Providing role-specific preparation strategies for academic, professional, and educational contexts
- Delivering proactive intelligence instead of passive reminders

---

## Main Features

### Role-Based Onboarding & AI Style Selection (FR-1)
- Three role contexts: Student, Corporate Employee, Educator
- Three AI communication styles: Polite Jarvis, Friendly, Aggressive Motivator
- Personalized experience based on role and communication preference

### Google Calendar Integration (FR-2)
- Two-way synchronization with Google Calendar via OAuth 2.0
- Multi-calendar support (primary, Google Classroom, institutional calendars)
- Automatic event sync without duplicate manual entry

### Proactive Task Preparation (FR-3)
- AI-generated preparation plans for upcoming events
- Role-specific content: task outlines (Student), meeting agendas (Corporate), lesson structures (Educator)
- Downloadable UTF-8 TXT files with full Thai language support
- 14-day planning window with 3-day ahead scanning

### Role-Contextual Habit Tracker (FR-4)
- Habits linked to selected user role
- Weekly success rate calculation
- Analytics integration (⚠️ UI incomplete: backend works, dedicated view missing)

### Customized Short Notifications (FR-5)
- AI-generated notifications matching communication style
- 120-character limit for concise reminders
- Fallback templates for offline reliability

### Behavioral Analytics Dashboard (FR-6)
- Weekly calendar adherence metrics
- Habit success rate visualization
- Consolidated view of productivity patterns

---

## Technology Stack

**Frontend**
- Flutter Web (Dart framework)
- GetX (state management, dependency injection, reactive programming)

**Backend Services**
- Firebase Authentication (Google OAuth 2.0)
- Cloud Firestore (NoSQL database)
- Firebase Storage (task plan document storage)
- Firebase Hosting (production deployment)
- Supabase Edge Function (groq-proxy: Deno TypeScript)

**External Integrations**
- Google Calendar API v3 (two-way synchronization with read/write access)
- Groq Cloud API (openai/gpt-oss-20b model for AI task preparation and notifications)

**Architecture**
- Clean Architecture with separation of models, services, controllers, and views
- Security: Firebase ID Token verification (RS256), user-isolated data access

---

## Team Members

| Name | Student ID | GitHub | Role |
|------|-----------|--------|------|
| Peerapap Kummongkon | 6931503057 | skyt19 | Development |
| Achitapon Wiangmoon | (from SRS) | - | Development |
| Nattakul Pasoda | 6931503034 | SX-67 | Development |
| Phakpoom Jaiwoot | 6931503082 | Poom453, 6931503082 | Development |
| Somchay Aryi | (from SRS) | - | Development |

*Note: Git history shows 4 active contributors; SRS.md lists 5 team members. Mapping between SRS names and GitHub accounts is partially verified.*

---

## How to Run

### Prerequisites
- Flutter SDK (3.0+)
- Chrome browser (for Flutter Web)
- Firebase project configured (see docs/SUPABASE_GROQ_SETUP.md)

### Local Development

```bash
flutter pub get
flutter run -d chrome --web-port=8080
```

### Production Deployment
The application is deployed at https://yhar-bid.web.app via Firebase Hosting.

---

## Testing

Run all tests:
```bash
flutter test
```

**Test Files:**
- `test/task_plan_pipeline_test.dart` — 27 passing integration tests for task preparation pipeline
- `test/phase_1_3_runtime_validation.dart` — Runtime validation tests for FR-1, FR-2, FR-3, FR-6
- `test/role_reasoning_test.dart` — Role-based reasoning logic tests
- `test/ai_discovery_test.dart` — AI discovery and proposal tests
- `test/context_retrieval_test.dart` — Context snapshot retrieval tests
- `test/groq_api_test.dart` — Groq API integration tests
- `test/model_lock_test.dart` — Model lock verification tests
- `test/services/` — Service layer unit tests

---

## Documentation

**M3 Deliverables:**
- [Team Charter](docs/team-charter.md) — Project overview, objectives, team structure, collaboration rules
- [Golden Thread](docs/golden-thread.md) — Requirements traceability for all 6 Must FRs
- [Final Report](docs/final-report.md) — Comprehensive M3 implementation status report
- [AI Use Statement](docs/ai-use-statement.md) — Transparent documentation of AI usage
- [Demo Slides Outline](slides/demo-slides-outline.md) — Presentation structure for M3 demo

**Design Documentation:**
- [System Architecture](docs/design/system-architecture.md) — High-level architecture diagram
- [Use Case Diagram](docs/design/use-case-diagram.md) — All 10 use cases for FR-1 through FR-6
- [Data Model](docs/design/data-model.md) — Firestore collections and Storage structure
- [Sequence Diagrams](docs/design/sequence-diagrams.md) — Detailed flows for key features

**Project Requirements:**
- [SRS.md](SRS.md) — Software Requirements Specification v1.1 (authoritative requirements)
- [PRODUCT.md](PRODUCT.md) — Product definition and positioning

**Technical Setup:**
- [Supabase Groq Setup](docs/SUPABASE_GROQ_SETUP.md) — AI proxy configuration

---

## Known Limitations

**FR-2 (Calendar Synchronization):**
- Read operations fully functional across multiple calendars
- Write operations (createEvent, updateEvent) exist but fail gracefully for read-only calendars
- System returns success with local-only save when write to Google Calendar fails (403/404 errors)
- No automated integration tests for two-way sync verification

**FR-3 (Proactive Preparation):**
- AI generation of role-specific preparation works
- 3-day ahead scanning implemented
- Manual trigger only (runProactiveScan() requires user action)
- No automated background scheduling (NFR-6 requirement not met)
- No Cloud Functions or cron jobs for automated scanning

**FR-5 (Notifications):**
- Notification generation with AI personalization works
- Fallback templates implemented (NFR-7 compliance)
- Manual trigger only (Test Notification button)
- No automated scheduling or triggering of notifications
- scheduleNotification() method does not exist

**Testing:**
- Limited widget/integration test coverage for UI flows
- Manual testing required for complete onboarding journey
- No automated end-to-end tests

**Deployment:**
- Firebase Spark (free) plan constraints
- Groq API rate limits apply
- Background scheduling requires manual trigger (no automated cron)

**Outstanding Deliverables:**
- PowerPoint presentation file (demo-slides.pptx) not yet created

---

## Implementation Status

**Implemented (3/6 FRs — 50%):**
- ✅ FR-1: Role-Based Onboarding & AI Style Selection
- ✅ FR-4: Role-Contextual Habit Tracker
- ✅ FR-6: Behavioral Analytics Dashboard

**Partially Implemented (3/6 FRs — 50%):**
- ⚠️ FR-2: Google Calendar Synchronization (read works, write exists with graceful fallback for read-only calendars)
- ⚠️ FR-3: Proactive Role-Based Task Preparation (AI generation works, manual trigger only, no automated background scheduling)
- ⚠️ FR-5: Customized Short Notifications (generation works, no automated scheduling)

---

## License

[Project License Information]

---

## Repository

- **GitHub:** https://github.com/skyt19/Yhar_Bid.git
- **Firebase Project:** yhar-bid
- **Deployment:** https://yhar-bid.web.app
