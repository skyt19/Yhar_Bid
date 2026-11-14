# Use Case Diagram

This Mermaid use case diagram covers all SRS requirements for Yhar Bid (Yharbid). The system boundary encompasses the Yharbid AI Assistant application. Three actors interact with the system: User (primary), Google Calendar API (external integration for calendar synchronization), and AI Provider (external Groq API for AI-powered features). The diagram shows 10 use cases aligned with the 6 functional requirements from the SRS. UC-1 and UC-2 handle onboarding and AI style selection (FR-1). UC-3 provides two-way Google Calendar synchronization (FR-2). UC-4 is the core proactive preparation flow (FR-3), with UC-5, UC-6, and UC-7 as role-specific extensions for Student, Corporate Employee, and Educator respectively. UC-8 manages role-contextual habits (FR-4). UC-9 delivers customized short notifications (FR-5). UC-10 provides the behavioral analytics dashboard (FR-6). The AI Provider participates in UC-4 through UC-9, supporting preparation generation, behavior analysis, and personalized messaging. Google Calendar API participates in UC-3 for bidirectional synchronization and UC-4 for event detection.

## Diagram

```mermaid
graph TB
    subgraph System["Yharbid AI Assistant System Boundary"]
        UC1["UC-1: Role-Based Onboarding<br/>(Student/Corporate Employee/Educator)"]
        UC2["UC-2: Select AI Communication Style<br/>(Polite Jarvis/Friendly/Aggressive Motivator)"]
        UC3["UC-3: Google Calendar Synchronization<br/>(OAuth 2.0, read/write)"]
        UC4["UC-4: Proactive Role-Based Task Preparation<br/>(scan calendar, generate preparation)"]
        UC5["UC-5: Prepare Student Task Outline<br/>(extends UC-4)"]
        UC6["UC-6: Prepare Employee Meeting Agenda<br/>(extends UC-4)"]
        UC7["UC-7: Prepare Educator Teaching/Exam Structure<br/>(extends UC-4)"]
        UC8["UC-8: Manage Role-Contextual Habits"]
        UC9["UC-9: Receive Customized Short Notification"]
        UC10["UC-10: View Behavioral Analytics Dashboard"]
    end
    
    User((User<br/>Primary Actor))
    GoogleCalendar((Google Calendar API<br/>External System))
    AIProvider((AI Provider<br/>Groq API<br/>External System))
    
    User -->|performs| UC1
    User -->|performs| UC2
    User -->|initiates| UC3
    User -->|performs| UC8
    User -->|receives| UC9
    User -->|views| UC10
    
    GoogleCalendar -->|synchronizes with| UC3
    GoogleCalendar -->|provides events to| UC4
    
    AIProvider -->|generates for| UC4
    AIProvider -->|generates for| UC5
    AIProvider -->|generates for| UC6
    AIProvider -->|generates for| UC7
    AIProvider -->|analyzes for| UC8
    AIProvider -->|personalizes| UC9
    AIProvider -->|supports| UC10
    
    UC4 -.->|extends| UC5
    UC4 -.->|extends| UC6
    UC4 -.->|extends| UC7
    
    style System fill:#f0f0f0,stroke:#333,stroke-width:3px
    style User fill:#4CAF50,stroke:#2E7D32,stroke-width:2px,color:#fff
    style GoogleCalendar fill:#E8F5E9,stroke:#4CAF50,stroke-width:2px
    style AIProvider fill:#E8F5E9,stroke:#4CAF50,stroke-width:2px
```

## Components

- User (primary actor)
- Google Calendar API (external system)
- AI Provider / Groq API (external system)
- Yharbid AI Assistant system boundary
- 10 use cases covering all 6 functional requirements
- Extension relationships (UC-5, UC-6, UC-7 extend UC-4)
- Actor-to-use-case relationships

## FR Coverage

- FR-1: Role-Based Onboarding & Style Selection (UC-1, UC-2)
- FR-2: Google Calendar Synchronization (UC-3)
- FR-3: Proactive Role-Based Task Preparation (UC-4, UC-5, UC-6, UC-7)
- FR-4: Role-Contextual Habit Tracker (UC-8)
- FR-5: Customized Short Notifications (UC-9)
- FR-6: Behavioral Analytics Dashboard (UC-10)
