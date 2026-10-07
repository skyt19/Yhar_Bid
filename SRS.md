Yhar Bid — Software Requirements Specification · v1.1 
Software Requirements Specification 
Yhar Bid — Adaptive Routine & Reminder Assistant 
Introduction to Software Engineering (15031001) · Week 3 · Requirements & Specification 
Field Yhar Bid 
Field Yhar Bid 
Team name Yhar Bid 
Project title Yhar Bid — Adaptive Routine & Reminder Assistant 
SDLC chosen in M1 + reason Agile — develop the MVP in small iterations, test with real users, collect feedback, 
and continuously improve the application and behavior strategies. 
Date / version v1.1 · Week 3 SRS revision 
Team members Peerapap Kummongkon; Achitapon Wiangmoon; Nattakul Pasoda; Phakpoom 
Jaiwoot; Somchay Aryi 
Source basis M1-Charter_YharBid.docx, the team-provided revised requirements in this 
revision, and the Week 3 SRS worked-example structure. 
 
1. Introduction 
1.1 Purpose and scope 
Many users know what they need to do but may procrastinate, miss planned activities, or repeatedly ignore 
generic reminders. Yhar Bid is designed as a role-based AI assistant that combines routine and habit tracking 
with Google Calendar data so that the system can prepare useful information before important activities and 
adapt short notifications to the user’s preferred communication style. 
The revised MVP focuses on six connected capabilities: role-based onboarding and AI style selection, two
way Google Calendar synchronization, proactive role-based task preparation, role-contextual habit tracking, 
customized short notifications, and a behavioral analytics dashboard. The system supports three role 
contexts: Student, Corporate Employee, and Educator. 
1.2 Users and stakeholders 
Name / role Kind What they need What they fear / forbid 
Student Primary user Connect a calendar, manage habits, 
receive deadline preparation and short 
reminders. 
Irrelevant preparation or 
repetitive reminders. 
Corporate Employee Primary user Connect a calendar, prepare for meetings, 
manage habits, and receive concise 
reminders. 
Meeting preparation that is 
not relevant to the scheduled 
context. 
Educator Primary user Connect a calendar, prepare 
teaching/exam content, manage habits, 
and receive concise reminders. 
Generic preparation that 
ignores the teaching/exam 
context. 
Yar Oo; Achitapon 
Wiangmoon; Nattakul 
Pasoda 
Tester / stakeholder 
representatives 
Test role selection, calendar 
synchronization, reminders, habit tracking, 
proactive preparation, and analytics. 
A system that does not 
reflect actual user behavior 
or role needs. 
Name / role 
Kind 
What they need 
What they fear / forbid 
Google Calendar API 
External system 
Authorized read/write access to calendar 
events used by synchronization and 
proactive preparation. 
AI Provider 
External system 
Unauthorized access or 
incorrect synchronization. 
Provide AI-generated 
preparation, behavior analysis, 
and personalized notification 
content through the planned AI 
service integration. 
2. Overall description 
2.1 Product context — what it does / does not 
Service outage, invalid 
requests, or misuse of 
the AI service. 
Yhar Bid acts as a role-aware assistant around the user’s routines and calendar. It receives authorized 
Google Calendar information, tracks role-contextual habits, prepares role-specific material for upcoming 
events, and sends short notifications using the selected AI communication style. The analytics dashboard 
summarizes adherence and habit success so that the user can understand progress over time. 
IN SCOPE (MVP) 
OUT OF SCOPE (explicit promise) 
FR-1 Role-based onboarding & style selection 
Social messaging or group chat inside the app 
FR-2 Two-way Google Calendar synchronization 
Payment, subscriptions, or monetization features 
FR-3 Proactive role-based task preparation 
Replacing Google Calendar as a full general-purpose 
calendar application 
FR-4 Role-contextual habit tracker 
Automatic changes to user role or preferences without user 
control 
FR-5 Customized short notifications 
Unsupported roles outside Student, Corporate Employee, and 
Educator 
FR-6 Behavioral analytics dashboard 
Features unrelated to the stated role, calendar, habit, 
notification, and analytics flows 
2.2 Assumptions and constraints 
 Assumption: users provide their role, preferred AI communication style, habit goals, and calendar 
authorization explicitly. 
 Constraint: supported role contexts are Student, Corporate Employee, and Educator. 
 Constraint: Google Calendar synchronization uses Google OAuth 2.0 and the Google Calendar REST 
APIs with the user’s permission for read/write access. 
 Constraint: the planned application stack is Flutter (Dart) with table_calendar and 
flutter_local_notifications on the frontend. 
 Constraint: Firebase Auth, Firestore, and Cloud Functions are the planned backend/cloud components; 
Google Gemini API is the planned generative AI service. 
 Constraint: background synchronization and proactive preparation use a Background Service or Cloud 
Functions with a Cron Job/PubSub scheduling mechanism. 
 Constraint: AI-generated output must have a short-notification fallback template when the AI service is 
unavailable. 
 Constraint: source code must not hardcode secret keys or OAuth client secrets; secrets must be supplied 
through .env/environment variables or Firebase Secret Manager. 
Yhar Bid — Software Requirements Specification · v1.1 
3. User Requirements (Functional Requirements) 
Format: each requirement is expressed as a user story with observable acceptance criteria. The six 
functional requirements below represent the revised MVP described by the team. FR-3 uses synchronized 
calendar context and the selected role to prepare content, while FR-5 and FR-6 consume user and behavior 
information produced by the earlier flows. 
FR-1 — Role-Based Onboarding & Style Selection 
User story: As a new user, I want to select my primary role and preferred AI communication style, so that 
Yhar Bid can personalize its behavior to my context and communication preference. 
Pain / rationale: Different roles have different responsibilities, and users may prefer different tones such as 
Polite Jarvis, Friendly, or Aggressive Motivator. 
1. Given a new user completes registration, when the user selects Student, Corporate Employee, or 
Educator, then the selected role is stored as the active role context. 
2. Given a user selects an AI communication style, when an AI-generated message is produced later, then 
the stored style is available to the messaging flow. 
FR-2 — Google Calendar Synchronization 
User story: As a user, I want to connect and synchronize Google Calendar with Yhar Bid, so that calendar 
activities, deadlines, and meetings can be used by the assistant without duplicate manual entry. 
Pain / rationale: Upcoming responsibilities are already represented as calendar events, so the assistant 
needs authorized access to use the same information. 
1. Given the user grants Google Calendar access through Google OAuth 2.0, when synchronization runs, 
then authorized calendar events are available in Yhar Bid. 
2. Given an authorized event is created or updated in Yhar Bid, when synchronization occurs, then the 
corresponding Google Calendar event is updated; changes from Google Calendar are likewise reflected in 
Yhar Bid. 
FR-3 — Proactive Role-Based Task Preparation 
User story: As a user, I want Yhar Bid to prepare role-specific information before important calendar events, 
so that I can start the task, meeting, teaching activity, or exam with useful preparation already available. 
Pain / rationale: The same calendar event can require different preparation depending on whether the user 
is a Student, Corporate Employee, or Educator. 
1. Given a Student has a calendar event representing a deadline at least 3 days ahead, when the 
proactive preparation process detects it, then Yhar Bid prepares a short task outline before the deadline. 
2. Given a Corporate Employee has a scheduled meeting, when the proactive preparation process detects 
it, then Yhar Bid prepares meeting agenda or discussion points before the meeting starts. 
3. Given an Educator has a scheduled teaching session or exam, when the proactive preparation process 
detects it, then Yhar Bid prepares a corresponding teaching or exam content structure before the 
scheduled activity. 
FR-4 — Role-Contextual Habit Tracker 
User story: As a user, I want my habit goals and routine tracking to reflect my selected role, so that habit 
activities remain relevant to my daily responsibilities. 
Yhar Bid — Software Requirements Specification · v1.1 
Pain / rationale: Habit goals are more meaningful when their context matches the user’s role instead of 
using one generic productivity model for everyone. 
1. Given a user has selected a role, when habit goals are created or presented, then the system applies 
the selected role as the active habit context. 
2. Given a user records habit outcomes, when the data is stored, then the record can be used to calculate 
habit success information for the analytics dashboard. 
FR-5 — Customized Short Notifications 
User story: As a user, I want short notifications that match my selected communication style, so that 
reminders are concise and more suitable to how I prefer to be addressed. 
Pain / rationale: Generic reminders can become ineffective when they repeat the same wording regardless 
of user preference or context. 
1. Given a user has selected a communication style, when a notification is generated, then the message is 
short, direct, and consistent with the selected style. 
2. Given the AI generation service is unavailable, when a notification is needed, then the system sends an 
available fallback short-notification template instead of failing the reminder flow. 
FR-6 — Behavioral Analytics Dashboard 
User story: As a user, I want a weekly dashboard showing my calendar adherence and habit success rate, 
so that I can understand how consistently I follow my planned activities. 
Pain / rationale: Users need a consolidated view of whether planned calendar activities and habits are being 
completed successfully. 
1. Given calendar and habit outcome data exists, when the user opens the dashboard, then the system 
shows a weekly calendar-adherence summary and habit success rate. 
2. Given new outcomes are recorded, when the dashboard is refreshed, then the displayed weekly metrics 
reflect the updated stored data. 
4. Engineering & Architecture Requirements (Non-Functional) 
The supplied revised project context specifies architecture, technology, security, integration, fallback, error
handling, and coding constraints but does not provide numeric performance thresholds. These requirements 
therefore preserve the specified engineering constraints without inventing additional numeric targets. 
ID 
Kind 
Statement (testable) 
How we will check 
NFR-1 
Frontend 
technology 
The mobile client shall use Flutter (Dart), with table_calendar for 
calendar UI and flutter_local_notifications for local notifications. 
NFR-2 
Backend & cloud 
Inspect project 
dependencies and frontend 
module structure. 
The planned backend shall use Firebase Auth, Firestore, and Cloud 
Functions, with Google Gemini API for generative AI. 
NFR-3 
External integration 
Verify configured services 
and module integrations in 
the project. 
Google Calendar access shall use Google OAuth 2.0 and Google 
REST APIs with authorized read/write calendar scopes for 
synchronization. 
NFR-4 
Architecture 
Complete an OAuth 
authorization flow and verify 
authorized read/write 
synchronization. 
The Flutter codebase shall follow Clean Architecture with clear 
separation of views/, controllers/, services/, and models/, including 
google_calendar_service.dart and ai_service.dart where applicable. 
Inspect repository structure 
and confirm responsibility 
boundaries. 
Yhar Bid — Software Requirements Specification · v1.1 
Yhar Bid — Software Requirements Specification · v1.1 
ID Kind Statement (testable) How we will check 
NFR-5 Authentication & 
security 
OAuth Client Secrets and other secret keys shall not be hardcoded 
in source code and shall be supplied through environment variables 
(.env) or Firebase Secret Manager. 
Search the repository for 
hardcoded secrets and 
inspect the configured secret 
source. 
NFR-6 Background sync & 
proactive scheduler 
A background service or Cloud Functions using Cron Job/PubSub 
shall periodically scan Google Calendar events and trigger proactive 
preparation before relevant activities. 
Create test calendar events 
and verify that the scheduled 
preparation flow is triggered. 
NFR-7 AI fallback & 
availability When the AI API is unavailable, the system shall continue the core 
reminder flow by using a fallback short-notification template. 
Disable or mock the AI API 
and verify that a notification 
still reaches the user. 
NFR-8 Error handling Application services shall use custom exceptions and return the 
defined standard JSON error shape: {"status": false, "message": "...", 
"data": null}. 
Trigger representative 
service errors and verify the 
exception mapping and 
response schema. 
NFR-9 Coding style Code shall use strong typing (type hints) and explicit return types for 
functions, with Docstrings/Comments for logic; role-based prompting 
logic shall be documented in Thai. 
Review source files against 
the team coding standard. 
NFR-10 Module scope 
discipline Developers shall not modify files outside the feature/module 
assigned in the project issue. 
Review pull requests or 
commits for unrelated file 
changes. 
 
5. Use cases 
5.1 Use-case list 
Use case Name Actor Related FR Brief success story 
UC-1 Role-Based Onboarding User FR-1 User registers and selects Student, 
Corporate Employee, or Educator as the 
active role. 
UC-2 Select AI Communication Style User FR-1 / FR-5 User selects a preferred communication 
style for AI-generated messages. 
UC-3 Google Calendar 
Synchronization User / Google 
Calendar API FR-2 User authorizes access and calendar data 
is synchronized in both directions. 
UC-4 Proactive Role-Based Task 
Preparation 
Yharbid AI 
Assistant / AI 
Provider 
FR-3 System detects relevant calendar events 
and prepares role-specific content. 
UC-5 Prepare Student Task Outline 
Yharbid AI 
Assistant / AI 
Provider → User 
FR-3 For a Student deadline, the system 
prepares a short outline ahead of the 
deadline. 
UC-6 Prepare Employee Meeting 
Agenda 
Yharbid AI 
Assistant / AI 
Provider → User 
FR-3 For a Corporate Employee meeting, the 
system prepares an agenda or discussion 
points. 
UC-7 Prepare Educator Teaching / 
Exam Structure 
Yharbid AI 
Assistant / AI 
Provider → User 
FR-3 For an Educator class or exam, the 
system prepares a content structure. 
UC-8 Manage Role-Contextual Habits User FR-4 User manages habits whose goal context 
follows the selected role. 
Use case 
Name 
Actor 
Related FR 
Brief success story 
UC-9 
Receive Customized Short 
Notification 
Yharbid AI 
Assistant / AI 
FR-5 
Provider → User 
UC-10 
View Behavioral Analytics 
Dashboard 
User 
User receives a concise reminder using 
the selected communication style or a 
fallback template. 
FR-6 
5.2 Use-case diagram 
User views weekly calendar adherence 
and habit success rate. 
Figure 1. Yharbid use-case diagram aligned with the revised functional requirements and external Google 
Calendar and AI Provider integrations. 
Note: “Prepare Student Task Outline,” “Prepare Employee Meeting Agenda,” and “Prepare Educator 
Teaching / Exam Structure” are role-specific extensions of the proactive preparation flow. They are not 
additional functional requirements beyond FR-3. 
Note: Yharbid AI Assistant is the system under specification; Google Calendar API and AI Provider are 
external systems. The AI Provider supports AI-generated preparation, behavior analysis, and personalized 
notification content. 
6. Out of scope 
 Social messaging or group chat inside the app. 
 Payment, subscription, or monetization features. 
 Replacing Google Calendar as a complete general-purpose calendar application. 
 Automatic changes to the user’s role or communication preferences without user control. 
 Support for roles outside Student, Corporate Employee, and Educator in the MVP. 
Yhar Bid — Software Requirements Specification · v1.1 
Yhar Bid — Software Requirements Specification · v1.1 
 Features unrelated to calendar synchronization, role-based preparation, habit tracking, notifications, or 
analytics. 
7. Traceability matrix (Golden Thread) 
The revised thread is: different role contexts and upcoming calendar events → synchronized schedule and 
habit data → proactive role-specific preparation and concise notifications → weekly analytics feedback. FR-1 
defines context and communication preference; FR-2 provides calendar input; FR-4 supplies habit outcomes; 
FR-5 and FR-6 turn those inputs into user-facing adaptation and measurement. 
Problem / pain Requirement (FR) Solution / design Feature built Test 
Different roles require 
different preparation. FR-1 Role + style 
selection Role context + communication 
style Role-based onboarding / 
preference flow Role selection tests 
Calendar information is 
already part of users’ 
schedules. FR-2 Calendar sync Google Calendar OAuth + 
read/write synchronization Calendar integration 
service Two-way sync tests 
Upcoming deadlines, 
meetings, teaching, and 
exams need preparation. 
FR-3 Proactive 
preparation Role-based preparation 
pipeline Outline / agenda / 
structure generation Role-specific 
preparation tests 
Users need habit goals 
relevant to their role. FR-4 Role
contextual habits Role-aware habit data model 
and tracking Habit tracker Habit context and 
persistence tests 
Generic reminders may be 
ignored. FR-5 Short 
notifications Style-aware message strategy 
+ fallback template Notification feature Style and fallback 
tests 
Users need a consolidated 
view of adherence and 
habit success. 
FR-6 Analytics 
dashboard Weekly aggregation of 
calendar and habit outcomes Behavioral analytics 
dashboard Dashboard 
calculation tests 
 
8. AI usage log 
This SRS includes AI-assisted drafting. The table below records AI-assisted work used during the 
development of the document; the team should verify requirements against stakeholder feedback before 
submission. 
Date Tool / model What we asked What AI produced What we changed / 
verified What we learned 
10 Sep 2026 ChatGPT 
Draft project-specific 
functional requirements 
from the Yhar Bid M1 
charter. 
Drafts for FR-1 to FR-5 
covering routines, 
reminders, behavior 
records, analysis, and 
personalized messages. 
Team should compare 
each draft with M1 wording 
and confirm the final 
acceptance criteria. 
Requirements are 
stronger when each 
FR has a clear user 
outcome and testable 
condition. 
12 Sep 2026 ChatGPT 
Draft measurable non
functional requirements 
and use cases for the 
SRS. 
Proposed performance, 
notification reliability, 
usability, privacy, 
reliability, and AI fallback 
requirements plus five 
use cases. 
Team should confirm 
numeric thresholds and 
test methods with actual 
stakeholders before 
submission. 
NFRs need 
measurable targets 
rather than vague 
words such as “fast” 
or “easy”. 
13 Sep 2026 ChatGPT 
Organize the SRS into 
scope, traceability, and AI 
usage log sections using 
the Week 3 example 
structure. 
Structured the five FRs 
into a problem → 
requirement → solution → 
feature → test thread and 
aligned the use-case list. 
Removed StudyMate
specific content and kept 
only the document 
structure relevant to Yhar 
Bid. 
The SRS should 
preserve Yhar Bid’s 
own problem and 
MVP while using the 
example’s 
organization. 
5 Oct 2026 ChatGPT Update the SRS 
functional requirements 
to match the revised 
Yharbid context: role
based onboarding, AI 
Reworked the 
functional-requirements 
section into role-based 
onboarding and style 
selection, Google 
Checked that the 
revised features remain 
connected to the 
intended Yharbid AI 
Assistant scope and 
Requirements are 
clearer when user 
roles, external 
integrations, and 
proactive AI 
Yhar Bid — Software Requirements Specification · v1.1 
Date Tool / model What we asked What AI produced What we changed / 
verified What we learned 
communication style 
selection, Google 
Calendar 
synchronization, 
proactive role-based 
task preparation, habit 
tracking, short 
notifications, and 
analytics. 
Calendar 
synchronization, 
proactive preparation 
for Student/Corporate 
Employee/Educator 
roles, role-contextual 
habit tracking, 
customized short 
notifications, and the 
behavioral analytics 
dashboard. 
separated the external 
Google Calendar 
integration from internal 
application behavior. 
actions are stated 
explicitly. 
5 Oct 2026 ChatGPT Add an external AI 
Provider actor to the 
use-case model and 
align the actors with the 
revised architecture. 
Updated the use-case 
model to include AI 
Provider as an external 
system actor and 
connected it to AI
related use cases such 
as task preparation, 
behavior analysis, and 
personalized message 
generation. 
Reviewed actor names 
and relationships so AI 
Provider is external to 
Yharbid and Google 
Calendar API remains a 
separate external 
system. 
External 
dependencies 
should be 
represented as 
actors when they 
participate directly 
in system 
interactions. 
5 Oct 2026 ChatGPT Update the engineering 
and architecture 
requirements to reflect 
Flutter, Firebase, 
Google Gemini, Google 
Calendar API, OAuth 
2.0, background 
scheduling, fallback 
notifications, error 
handling, and coding 
standards. 
Revised the non
functional/engineering 
requirements to specify 
the proposed 
technology stack, 
Clean Architecture 
structure, 
authentication and 
secret-management 
rules, background 
synchronization, AI 
fallback behavior, 
standard error 
responses, and code
quality conventions. 
Checked each 
technology and 
architecture item against 
the revised project 
context supplied by the 
team and kept the 
requirements testable 
where possible. 
Architecture 
requirements are 
easier to verify 
when 
implementation 
technologies, 
security rules, and 
fallback behavior 
are stated as 
explicit constraints. 
 
9. Self-check 
☑ Every FR is written as a user story with a stated user benefit. 
☑ Every FR has observable acceptance criteria covering the revised role, calendar, preparation, habit, 
notification, or analytics behavior. 
☑ FR-3 is the proactive preparation requirement and is explicitly tied to Google Calendar context and the 
selected user role. 
☑ Scope and out-of-scope items are stated for the revised MVP. 
☑ The use-case list covers all six functional requirements and the diagram distinguishes the system boundary 
from the external Google Calendar API and AI Provider. 
☑ The Golden Thread traces role/context and calendar inputs through preparation, notifications, and 
analytics. 
☑ Engineering and architecture constraints include Flutter, Firebase, Gemini, Google Calendar OAuth 2.0, 
Clean Architecture, background scheduling, fallback handling, error handling, and coding standards. 
☑ The AI usage log is retained as provided and is not modified in this revision. 
Course note: AI-assisted drafting should be verified against real stakeholder feedback, and every FR should 
be understandable and explainable by the team during evaluation. 