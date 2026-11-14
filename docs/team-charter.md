# Team Charter — Yhar Bid Project

## 1. Project Name and Overview

**Project Name:** Yhar Bid (ยาบิด)

**Tagline:** Adaptive Routine & Reminder Assistant

**Overview:** Yhar Bid is an AI-powered web application that transforms calendar events into actionable preparation plans. Built with Flutter and deployed on Firebase Hosting, it provides intelligent task preparation, adaptive AI personality modes, and proactive assistance for students, corporate employees, and educators.

**Repository:** https://github.com/skyt19/Yhar_Bid.git

**Deployment:** https://yhar-bid.web.app

**Development Model:** Agile — iterative development with continuous testing, user feedback collection, and incremental improvement of features and AI behavior strategies.

---

## 2. Problem Statement

Many users know what they need to do but may procrastinate, miss planned activities, or repeatedly ignore generic reminders. Traditional calendar and reminder applications provide passive notifications without context or preparation support. Users across different roles (students, corporate employees, educators) face the same challenge: upcoming responsibilities require different preparation strategies, but existing tools treat all events identically.

Yhar Bid addresses this by:
- Analyzing calendar events and generating detailed preparation plans before activities occur
- Adapting communication style to user preferences (Polite Jarvis, Friendly, Aggressive Motivator)
- Providing role-specific preparation strategies for academic, professional, and educational contexts
- Delivering proactive intelligence instead of passive reminders

---

## 3. Project Objectives

1. **Intelligent Event Preparation:** Transform calendar events into structured task plans with preparation steps, required resources, timelines, risk assessments, and verification checklists.

2. **Role-Based Adaptation:** Support three primary user contexts (Student, Corporate Employee, Educator) with preparation strategies tailored to each role's specific needs.

3. **Adaptive AI Personality:** Provide three communication styles that match user preferences and deliver contextual motivation based on task completion patterns.

4. **Seamless Calendar Integration:** Implement two-way Google Calendar synchronization supporting multiple calendars with OAuth 2.0 authentication.

5. **Privacy-First Architecture:** Ensure user-isolated data storage with owner-only access enforced at both Firestore and Storage rules levels.

6. **Free-Tier Deployment:** Operate within Firebase Spark (free) plan constraints using client-side API calls and Supabase Edge Functions for AI proxy.

---

## 4. Scope and Boundaries

### In Scope (MVP)

| Feature ID | Feature | Description |
|:-----------|:--------|:------------|
| **FR-1** | Role-Based Onboarding & Style Selection | User selects primary role (Student, Corporate Employee, Educator) and preferred AI communication style |
| **FR-2** | Two-Way Google Calendar Synchronization | OAuth 2.0 integration with multi-calendar support; bidirectional event sync |
| **FR-3** | Proactive Role-Based Task Preparation | AI-generated preparation plans for upcoming events based on user role and event context |
| **FR-4** | Role-Contextual Habit Tracker | Habit tracking with goals relevant to selected user role |
| **FR-5** | Customized Short Notifications | Style-aware notifications with offline fallback templates |
| **FR-6** | Behavioral Analytics Dashboard | Weekly calendar adherence and habit success rate visualization |

### Out of Scope (Explicit Boundaries)

- Social messaging or group chat functionality
- Payment, subscription, or monetization features
- Full replacement of Google Calendar as a general-purpose calendar application
- Automatic role or preference changes without user control
- Support for roles outside Student, Corporate Employee, and Educator
- Native mobile applications (web-only in MVP)
- Features unrelated to calendar sync, preparation, habits, notifications, and analytics

### Technical Constraints

- **Platform:** Firebase Spark (free) plan — no Cloud Functions; all API calls client-side
- **API Limits:** Google Calendar API rate limits; Groq free-tier (30 requests/minute)
- **Model:** Groq API using `openai/gpt-oss-20b` (permanently locked, never overridden)
- **File Size:** Maximum 5 MB per file in Firebase Storage
- **Encoding:** UTF-8 required (no BOM)
- **Browser Support:** Modern browsers only; no native mobile apps in MVP

---

## 5. Team Members and Responsibilities

**Note:** The following team members are listed in the SRS document. Git commit history shows 4 active contributors. Individual role assignments are not confirmed from project records and should be verified with the team.

### Team Members from SRS

| Name | Student ID | Git Email | Git Username | Commits | Role/Responsibility |
|:-----|:-----------|:----------|:-------------|:--------|:--------------------|
| Peerapap Kummongkon | [Not confirmed from project records] | [Not confirmed from project records] | [Not confirmed from project records] | [Not confirmed] | [To be assigned based on team agreement] |
| Achitapon Wiangmoon | [Not confirmed from project records] | [Not confirmed from project records] | [Not confirmed from project records] | [Not confirmed] | [To be assigned based on team agreement] |
| Nattakul Pasoda | [Not confirmed from project records] | [Not confirmed from project records] | [Not confirmed from project records] | [Not confirmed] | [To be assigned based on team agreement] |
| Phakpoom Jaiwoot | [Not confirmed from project records] | [Not confirmed from project records] | [Not confirmed from project records] | [Not confirmed] | [To be assigned based on team agreement] |
| Somchay Aryi | [Not confirmed from project records] | [Not confirmed from project records] | [Not confirmed from project records] | [Not confirmed] | [To be assigned based on team agreement] |

### Verified Git Contributors

The following contributors are verified from git commit history (201 total commits):

| Git Username | Git Email | Commits | First Commit | Last Activity |
|:-------------|:----------|:--------|:-------------|:--------------|
| skyt19 | 6931503057@lamduan.mfu.ac.th | 186 | Initial commit | 2026-11-13 |
| SX-67 | 6931503034@lamduan.mfu.ac.th | 11 | 2026-10-18 | 2026-11-12 |
| Poom453 | 164710138+Poom453@users.noreply.github.com | 2 | 2026-11-09 | 2026-11-09 |
| 6931503082 | 6931503082@lamduan.mfu.ac.th | 2 | 2026-11-09 | 2026-11-09 |

**Action Required:** Team should create a mapping document correlating SRS names with git usernames and assign specific responsibilities (Frontend, Backend, AI Integration, Testing, Documentation, DevOps) based on actual work distribution.

---

## 6. Communication and Collaboration Approach

### Communication Channels

**Primary Documentation:**
- **SRS Document:** Software Requirements Specification (v1.1) defines functional and non-functional requirements
- **PRODUCT.md:** Product vision, positioning, capabilities, and brand commitments
- **Technical Documentation:** Implementation reports, deployment guides, and setup instructions in project root and `docs/` directory

**Code Review and Quality:**
- Pull requests for feature integration
- Commit messages follow descriptive format: `type(scope): description`
- Example: `feat(core): implement two-way calendar sync`, `fix(ui): Login button colors`

**Development Updates:**
- Commit history documents feature progress and bug fixes
- Implementation completion reports track milestone achievements
- Test results validate feature readiness

### Collaboration Patterns (from Git History)

**Primary Development:** skyt19 (186 commits, 92.5%) handles core architecture, features, UI, and deployment
**Feature Contributions:** SX-67 (11 commits) contributes model updates and Easter eggs
**Testing & Quality:** Poom453 (2 commits) enhances widget tests and validation
**Support:** 6931503082 (2 commits) handles file uploads and minor fixes

**Development Cadence:**
- Active development from initial commit through current date
- Regular feature iterations with documentation updates
- Backup branches maintained before major changes (`backup/pre-secret-cleanup-20261109`)

---

## 7. GitHub Collaboration Rules

### Repository Structure

**Main Branch:** `main` — production-ready code deployed to https://yhar-bid.web.app

**Backup Branches:**
- `backup/main-before-sync` — pre-synchronization state
- `backup/pre-secret-cleanup-20261109` — before secret removal refactoring

### Branching Strategy

**Current Practice (from git history):**
- Direct commits to `main` branch for rapid iteration
- Backup branches created before major refactoring
- No feature branches observed in current history

**Recommended Practice for Team Collaboration:**
1. Create feature branches from `main`: `feature/<feature-name>`
2. Commit changes to feature branch with descriptive messages
3. Create pull request for code review
4. Merge to `main` after review approval
5. Tag releases for deployment milestones

### Commit Message Conventions

**Format:** `type(scope): description`

**Types:**
- `feat`: New feature (e.g., `feat(core): implement two-way calendar sync`)
- `fix`: Bug fix (e.g., `fix(ui): Login button colors`)
- `refactor`: Code restructuring (e.g., `refactor(ui): rebuild views matching mockups`)
- `docs`: Documentation (e.g., `docs: add Google OAuth setup guide`)
- `test`: Testing (e.g., `test: enhance widget tests`)
- `security`: Security improvements (e.g., `security: remove hardcoded secrets`)

**Examples from project history:**
```
feat(core): embed built-in fallback configuration keys
fix(critical): hardcode production API keys to resolve White Screen
refactor(ui): complete visual overhaul matching latest mockups
security: remove real credentials from .env.example
docs: add 401 error troubleshooting
```

### Code Review Requirements

1. **Before Merging to Main:**
   - Code compiles without errors
   - Tests pass (27 integration tests for task plan pipeline expected)
   - No hardcoded secrets or credentials
   - Follows Clean Architecture structure (`views/`, `controllers/`, `services/`, `models/`)
   - Strong typing with explicit return types
   - Documentation comments (Docstrings) for complex logic

2. **Security Checklist:**
   - No API keys, OAuth secrets, or tokens in source code
   - Environment variables used via `.env` or Firebase Secret Manager
   - User data access follows Firebase security rules
   - Firebase Storage rules enforce user isolation

3. **File Scope Discipline:**
   - Changes limited to assigned feature/module
   - No modifications to unrelated files
   - Update relevant documentation for API changes

### Pull Request Guidelines

**Title:** Clear, concise description (under 70 characters)

**Description Template:**
```markdown
## Summary
[Brief description of changes]

## Related Requirements
[Reference FR-X from SRS]

## Changes Made
- [List key changes]

## Testing
- [x] Unit tests pass
- [x] Integration tests pass
- [x] Manual testing completed

## Deployment Notes
[Any deployment considerations]
```

---

## 8. Decision-Making Process

### Technical Decisions

**Architecture and Technology Stack:**
- **Consensus Required:** Core technology choices (Flutter, Firebase, Groq API)
- **Lead Developer:** skyt19 has made primary architectural decisions based on git history
- **Documentation:** Major decisions recorded in implementation reports (e.g., TASK_PLAN_PIPELINE_IMPLEMENTATION.md, PRODUCTION_AI_DEPLOYMENT.md)

**Decision Documentation:**
- Major architectural changes documented in markdown reports
- Technical constraints captured in SRS Non-Functional Requirements
- AI model choice (`openai/gpt-oss-20b`) locked and documented in PRODUCT.md

### Feature Prioritization

**Based on SRS Functional Requirements:**
1. **Phase 1:** Core authentication and calendar integration (FR-1, FR-2)
2. **Phase 2:** AI preparation and task management (FR-3, FR-4)
3. **Phase 3:** Notifications and analytics (FR-5, FR-6)

**Priority Drivers:**
- User value and MVP scope
- Technical dependencies (calendar sync before preparation)
- Resource constraints (Firebase Spark free tier)

### Conflict Resolution

**Process (recommended):**
1. **Discussion:** Team discusses technical options and tradeoffs
2. **SRS Reference:** Check alignment with requirements and scope
3. **Prototyping:** Test approach if uncertainty exists
4. **Documentation:** Record decision and rationale
5. **Review:** Revisit if new information emerges

**Escalation:** For deadlocks, refer to course instructor or project advisor.

---

## 9. Definition of Done

A feature or task is considered "Done" when ALL of the following criteria are met:

### Code Quality
- [ ] Code compiles without errors or warnings
- [ ] Follows Clean Architecture structure with clear separation of concerns
- [ ] Uses strong typing with explicit return types
- [ ] Includes comments/docstrings for complex logic
- [ ] No hardcoded secrets, API keys, or credentials in source code

### Functionality
- [ ] Meets acceptance criteria defined in corresponding functional requirement (FR-X)
- [ ] Works correctly in production environment (https://yhar-bid.web.app)
- [ ] Handles error cases gracefully (follows standard error JSON format)
- [ ] Implements AI fallback templates when API unavailable (where applicable)

### Testing
- [ ] Unit tests written and passing
- [ ] Integration tests written and passing (27 integration tests baseline for task pipeline)
- [ ] Manual testing completed for user-facing features
- [ ] Edge cases and error scenarios tested

### Security and Privacy
- [ ] Firebase Security Rules enforce user isolation
- [ ] No cross-user data leakage possible
- [ ] OAuth 2.0 scopes limited to required calendar access
- [ ] Secrets managed via environment variables or Firebase Secret Manager

### Documentation
- [ ] Code changes documented with inline comments
- [ ] API changes reflected in relevant service documentation
- [ ] User-facing features described in README or documentation
- [ ] Implementation reports created for major features

### Deployment
- [ ] Changes merged to `main` branch
- [ ] Deployed to Firebase Hosting (https://yhar-bid.web.app)
- [ ] Production deployment verified working
- [ ] No breaking changes to existing features

### Review and Approval
- [ ] Code reviewed by at least one team member
- [ ] Pull request approved (when using PR workflow)
- [ ] No unresolved review comments
- [ ] Aligns with project scope and SRS requirements

### Performance and Constraints
- [ ] Operates within Firebase Spark (free) plan limits
- [ ] Respects Google Calendar API rate limits
- [ ] File uploads stay within 5 MB limit
- [ ] UTF-8 encoding properly handled for Thai language support

---

## 10. Project Timeline and Milestones

**Git History Timeline:**
- **Initial Commit:** Project initialization with basic structure
- **Phase 1-3 Complete:** Core UI, authentication, calendar integration (documented in PHASE_1_3_IMPLEMENTATION_COMPLETE.md)
- **Runtime Validation:** Production testing completed (PHASE_1_3_RUNTIME_VALIDATION_REPORT.md)
- **Navigation Integration:** Complete navigation flow implemented (NAVIGATION_INTEGRATION_COMPLETE.md)
- **Current Status:** Active development with 201 commits, deployed production site

**Upcoming Milestones (based on SRS):**
1. Complete all FR-1 through FR-6 acceptance criteria
2. Full test suite coverage (expand beyond 27 baseline tests)
3. Performance optimization for free-tier constraints
4. User acceptance testing with real stakeholders
5. Final MVP release and evaluation

---

## 11. Quality Assurance and Testing

### Testing Strategy

**Current Test Coverage:**
- 27 passing integration tests for task plan pipeline (`test/task_plan_pipeline_test.dart`)
- Widget tests for route and translation validation
- Manual production testing documented in validation reports

**Required Test Types:**
1. **Unit Tests:** Individual functions and methods
2. **Integration Tests:** Feature workflows and API interactions
3. **Widget Tests:** UI components and user interactions
4. **End-to-End Tests:** Complete user scenarios from login to task completion

### Quality Gates

**Before Commit:**
- Code analysis passes (no errors)
- Local tests pass
- No TODO or FIXME comments unresolved

**Before Merge:**
- All tests pass in latest `main` branch state
- Code review approved
- Documentation updated

**Before Deployment:**
- Production build succeeds
- Firebase deployment completes without errors
- Deployed site accessible and functional
- No console errors in browser

---

## 12. Risk Management

### Technical Risks

| Risk | Impact | Mitigation Strategy | Status |
|:-----|:-------|:-------------------|:-------|
| Google Calendar API rate limits | HIGH | Implement caching and batch requests | Monitoring |
| Groq API unavailable | MEDIUM | Fallback to offline templates with warning prefixes | Implemented |
| Firebase Spark plan limits exceeded | HIGH | Monitor usage, optimize queries, plan upgrade path | Active monitoring |
| OAuth token expiration | MEDIUM | Implement token refresh flow | To be verified |
| Data loss or corruption | HIGH | Firebase automatic backups, enforce security rules | Implemented |

### Process Risks

| Risk | Impact | Mitigation Strategy | Status |
|:-----|:-------|:-------------------|:-------|
| Unclear role assignments | MEDIUM | Create team responsibility matrix | Action required |
| Merge conflicts from concurrent work | MEDIUM | Adopt feature branch workflow | Recommended |
| Insufficient testing coverage | HIGH | Expand test suite beyond 27 baseline tests | In progress |
| Scope creep beyond MVP | MEDIUM | Strict adherence to SRS scope boundaries | Active |

---

## 13. Success Criteria

The Yhar Bid project will be considered successful when:

1. **Functional Completeness:** All FR-1 through FR-6 acceptance criteria met
2. **Technical Stability:** Deployed production site operates without critical errors
3. **User Value:** Real users report reduced stress and improved preparation for scheduled activities
4. **Quality Standards:** Test coverage meets course requirements and Definition of Done applied consistently
5. **Documentation:** Complete SRS, PRODUCT.md, implementation reports, and this Team Charter maintained
6. **Collaboration:** Team members contribute according to agreed responsibilities with clear git history
7. **Constraints Met:** System operates successfully within Firebase Spark free tier and Groq API limits

---

## 14. Document Maintenance

**Version:** 1.0

**Last Updated:** 2026-11-13

**Maintenance Responsibility:** Team should review and update this charter when:
- Team member responsibilities change
- Major technical decisions alter architecture or scope
- SRS requirements updated
- New collaboration patterns adopted
- Milestone achievements require timeline updates

**Review Cadence:** Review at start of each major development phase or when blockers arise.

---

## Appendix A: Key Technical Resources

### Documentation Files
- `SRS.md` — Software Requirements Specification v1.1
- `PRODUCT.md` — Product vision and positioning
- `README.md` — Project overview and setup instructions
- `TASK_PLAN_PIPELINE_IMPLEMENTATION.md` — Task preparation feature documentation
- `PRODUCTION_AI_DEPLOYMENT.md` — AI service integration guide
- `docs/SUPABASE_GROQ_SETUP.md` — Groq proxy setup instructions

### Technology Stack
- **Frontend:** Flutter (Dart), GetX state management, `table_calendar`, `flutter_local_notifications`
- **Backend:** Firebase Auth, Firestore, Firebase Storage (Spark free tier)
- **AI Proxy:** Supabase Edge Functions with Groq API (`openai/gpt-oss-20b`)
- **Calendar:** Google Calendar API via OAuth 2.0
- **Deployment:** Firebase Hosting (https://yhar-bid.web.app)

### External Dependencies
- Google Calendar API (rate limits apply)
- Groq API (30 requests/minute free tier)
- Firebase services (Spark plan limits)
- Supabase Edge Functions (Free plan)

---

**Acknowledgment:** This Team Charter was created based on verified project documentation (SRS.md, PRODUCT.md, README.md) and git commit history. Team members should review, correct any inaccuracies, and add missing information about individual responsibilities and role assignments.
