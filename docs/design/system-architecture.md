# System Architecture Diagram

This diagram shows the complete Yhar Bid system architecture with all components, data flows, and authentication boundaries.

**Key Components:**

1. **Flutter Web Client** - Hosted on Firebase Hosting, serves the SPA from build/web directory
2. **Firebase Authentication** - Handles Google Sign-In with OAuth 2.0, issues Firebase ID tokens
3. **Firebase Firestore** - NoSQL database with collections:
   - users (top-level, stores user profiles)
   - users/{userId}/tasks (subcollection, user tasks)
   - users/{userId}/habits (subcollection, user habits)
   - taskPlanFiles (top-level, metadata for TXT files)
4. **Firebase Storage** - Stores task plan TXT files at task_plans/{userId}/
5. **Supabase Edge Function (groq-proxy)** - Serverless proxy that verifies Firebase ID tokens and forwards requests to Groq API
6. **Groq API** - AI service using locked model openai/gpt-oss-20b
7. **Google Calendar API** - OAuth 2.0 integration with calendar.events and calendar scopes for read/write access

**Authentication Boundaries:**

- Firebase Auth issues ID tokens (RS256 JWT) after Google Sign-In
- All Firestore/Storage operations require authenticated Firebase user
- Supabase proxy verifies Firebase ID tokens against Google's public certificates before forwarding to Groq
- Google Calendar API uses OAuth 2.0 access tokens from google_sign_in package

**Data Flow:**

- User authenticates via Google Sign-In → Firebase Auth
- Client reads/writes data → Firestore (users, tasks, habits, taskPlanFiles)
- Client uploads TXT files → Firebase Storage (task_plans/{userId}/)
- Client requests AI features → Supabase proxy (with Firebase ID token) → Groq API
- Client reads/writes calendar → Google Calendar API (with OAuth access token)

## Diagram

```mermaid
graph TB
    subgraph "Client Layer"
        A[Flutter Web Client<br/>Firebase Hosting<br/>build/web]
    end
    
    subgraph "Authentication Layer"
        B[Firebase Authentication<br/>Google Sign-In<br/>OAuth 2.0]
        C[Google OAuth<br/>Access Token]
    end
    
    subgraph "Data Storage Layer"
        D[(Firebase Firestore<br/>users<br/>users/{userId}/tasks<br/>users/{userId}/habits<br/>taskPlanFiles)]
        E[Firebase Storage<br/>task_plans/{userId}/]
    end
    
    subgraph "AI Service Layer"
        F[Supabase Edge Function<br/>groq-proxy<br/>Firebase Token Verification]
        G[Groq API<br/>model: openai/gpt-oss-20b]
    end
    
    subgraph "External Services"
        H[Google Calendar API<br/>OAuth 2.0<br/>read/write access]
        I[User's Google Calendar<br/>Events & Schedules]
    end
    
    A -->|Google Sign-In| B
    B -->|Firebase ID Token| A
    B -->|OAuth Access Token| C
    
    A -->|Read/Write<br/>Firebase ID Token| D
    A -->|Upload/Download TXT<br/>Firebase ID Token| E
    
    A -->|AI Request<br/>Firebase ID Token +<br/>Supabase Key| F
    F -->|Verify Token<br/>RS256 + Google Certs| B
    F -->|Forward Request<br/>GROQ_API_KEY| G
    G -->|AI Response| F
    F -->|Response| A
    
    A -->|OAuth Access Token| H
    H -->|Read Events<br/>Create/Update/Delete| I
    I -->|Calendar Data| H
    H -->|Events JSON| A
    
    C -.->|Access Token| A
    
    style A fill:#e1f5ff,stroke:#0288d1
    style B fill:#fff3e0,stroke:#f57c00
    style C fill:#fff3e0,stroke:#f57c00
    style D fill:#f3e5f5,stroke:#7b1fa2
    style E fill:#f3e5f5,stroke:#7b1fa2
    style F fill:#e8f5e9,stroke:#388e3c
    style G fill:#e8f5e9,stroke:#388e3c
    style H fill:#fff9c4,stroke:#f9a825
    style I fill:#fff9c4,stroke:#f9a825
```

## Components

- Flutter Web Client
- Firebase Hosting
- Firebase Authentication
- Google Sign-In OAuth 2.0
- Firebase Firestore
- Firebase Storage
- Supabase Edge Function groq-proxy
- Groq API
- Google Calendar API
- User's Google Calendar

## FR Coverage

- Flutter Web Client hosted on Firebase Hosting
- Firebase Authentication with Google Sign-In
- Firebase Firestore collections: users, tasks, habits, taskPlanFiles
- Firebase Storage at task_plans/{userId}/
- Supabase Edge Function groq-proxy with Firebase token verification
- Groq API with locked model openai/gpt-oss-20b
- Google Calendar API with OAuth 2.0 read/write access
- Authentication boundaries and data flow patterns
