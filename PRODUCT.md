# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

**Students** managing academic schedules (lectures, assignments, exams, presentations), **corporate employees** managing professional work (meetings, projects, deadlines, reports), and **educators** managing teaching activities (lesson planning, grading, parent meetings, administrative tasks). All three audiences use the product equally, with the AI adapting its preparation strategies and communication style to their specific contexts.

## Product Purpose

Yharbid transforms calendar events into actionable preparation plans. Rather than passive reminders, it analyzes upcoming events and generates detailed task breakdowns with preparation steps, required resources, timelines, risk assessments, and verification checklists. The AI proactively helps users prepare for what matters, reducing last-minute stress and improving outcomes.

## Positioning

The combination of **intelligent task preparation** (AI-generated step-by-step plans with resources, timelines, and risks from calendar events) with **adaptive AI personality** (communication style that matches user preference—Polite Jarvis, Friendly, or Aggressive Motivator—and provides contextual motivation based on task completion). Competing calendar and reminder apps provide notifications; Yharbid provides preparation intelligence and personality-matched support.

## Operating Context

Users connect their Google Calendar (primary calendar, Google Classroom, and institutional calendars). The system runs as a public web application (yhar-bid.web.app) deployed on Firebase Hosting. Users authenticate with Google accounts. The AI analyzes events within a 14-day planning window, excluding cancelled events and events without meaningful titles. Generated task plans are delivered as downloadable UTF-8 TXT files with Thai language support, stored in Firebase Storage with per-user isolation.

## Capabilities and Constraints

### Core Functionality
- Google Calendar integration (multi-calendar support with OAuth 2.0)
- AI-powered event analysis via Groq API (model: **openai/gpt-oss-20b**, permanently locked and never overridden)
- Task preparation plan generation (objective, preparation steps, execution steps, required resources, priority classification, estimated prep time, suggested timeline, dependencies, risks, checklist, missing information)
- Downloadable UTF-8 TXT reports with Thai language full support
- Three AI personality modes: Polite Jarvis (professional/courteous), Friendly (casual/supportive), Aggressive Motivator (challenging/intense)
- Task management with Firebase Firestore (user-isolated, owner-only access)
- File lifecycle management (list, preview, delete with two-phase confirmation)

### Technical Constraints
- Firebase Spark (free) plan: no Cloud Functions, all API calls client-side
- Google Calendar API rate limits apply
- Groq API key required for AI functionality (401 errors fall back to offline templates marked with warning prefixes)
- Maximum TXT file size: 5 MB per Firebase Storage rules
- UTF-8 encoding required (no BOM)
- Browser-only (no native mobile apps)

### Terminology
- **Task Plan**: AI-generated preparation document for calendar events
- **Event Analysis**: Structured AI output per event (objective, steps, resources, timeline)
- **Proactive Secretary**: Feature name for task preparation pipeline
- **File Lifecycle**: States for deletion management (idle → confirmation_requested → deleting → deleted/failed)

## Brand Commitments

**Name**: Yharbid (อย่าบิด in Thai)  
**Tagline**: "Adaptive Routine & Reminder Assistant"  
**Language**: Bilingual Thai/English with TH/EN toggle (Thai primary)  
**Voice**: Adapts to selected AI personality (polite professional, friendly supportive, or aggressive motivational)  
**Color Palette**: Warm gray backgrounds (#E0E0E0), white surfaces, green accents (#4CAF50) for primary actions—**no blue tones**  
**Typography**: System fonts with Thai language support; Google Fonts loaded  
**Deployment**: https://yhar-bid.web.app (Firebase Hosting)

## Evidence on Hand

- Working codebase: Flutter web app (GetX state management, Firebase Auth/Firestore/Storage, Google Calendar API integration)
- Existing mockups referenced in code comments (login_view.dart: "Mockup 1_onboarding.jpg", ai_personality_view.dart: "Mockup 2")
- Deployed production site at yhar-bid.web.app
- 27 passing integration tests for task plan pipeline (test/task_plan_pipeline_test.dart)
- Complete implementation documentation (TASK_PLAN_PIPELINE_IMPLEMENTATION.md)
- Security rules defined for Firestore (taskPlanFiles collection) and Firebase Storage (task_plans/{userId} path)
- README describes original vision: picture-based task verification, motivational quotes on incompletion (not yet implemented)

**Missing evidence**: Real user testimonials, usage metrics, performance benchmarks, example generated task plans from production use.

## Product Principles

1. **Proactive intelligence over passive notifications**: The product analyzes events and generates preparation plans before users ask, rather than waiting for users to create tasks manually.

2. **Personality-matched motivation**: Communication adapts to user preference (professional, friendly, or challenging) because different people respond to different motivational styles.

3. **Multi-role adaptability**: Students, employees, and educators receive preparation strategies tailored to their specific contexts (academic, professional, or educational) without requiring separate products.

4. **Transparent AI fallbacks**: When the AI service is unavailable, the product uses offline templates marked with clear warning prefixes rather than failing silently or pretending templates are real AI responses.

5. **Privacy-first file management**: All generated plans are user-isolated with owner-only access enforced at both Firestore rules and Storage rules levels; no cross-user data leakage possible.

## Accessibility & Inclusion

Thai language is a first-class citizen with full UTF-8 support in all generated documents, UI text, and error messages. The TH/EN toggle preserves user language preference across sessions. Firebase Auth provides standard web accessibility for Google Sign-In. The product runs as a web application, accessible on any device with a modern browser and internet connection. No specific WCAG compliance target has been established yet.
