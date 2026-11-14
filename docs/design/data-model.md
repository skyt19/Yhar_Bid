# Data Model / ER Diagram

This ER diagram maps Yhar Bid's data architecture across Firestore and Firebase Storage. The users collection serves as the root entity with three subcollections (tasks, habits, task_preparations). The taskPlanFiles collection exists at the top level and links to users via userId. Firebase Storage holds the actual TXT files referenced by taskPlanFiles metadata. Key relationships: users (1) → tasks (N), users (1) → habits (N), users (1) → taskPlanFiles (N), taskPlanFiles (1) → Storage files (1). The habits collection links back to user roles via the linkedRole enum field. Task plan files reference calendar events through sourceEventIds arrays.

## Diagram

```mermaid
erDiagram
    users ||--o{ tasks : "owns (subcollection)"
    users ||--o{ habits : "owns (subcollection)"
    users ||--o{ task_preparations : "owns (subcollection)"
    users ||--o{ taskPlanFiles : "creates"
    taskPlanFiles ||--|| STORAGE_FILES : "references"

    users {
        string uid PK
        string displayName
        string email
        string photoUrl
        enum role "student|corporateEmployee|educator"
        enum personality "politeJarvis|friendly|aggressiveMotivator"
        string languageCode "th|en"
        timestamp createdAt
    }

    tasks {
        string id PK
        string title
        string description
        boolean isDone
        timestamp createdAt
        timestamp dueDate "nullable"
        string category "nullable"
        string priority "Low|Medium|High"
        timestamp firstDownloadedAt "nullable"
        string fileUrl "nullable"
    }

    habits {
        string id PK
        string userId FK
        string title
        string description
        enum linkedRole "student|corporateEmployee|educator"
        array completedDates "DateTime[]"
        int targetDaysPerWeek
        timestamp createdAt
        boolean isActive
    }

    task_preparations {
        string id PK
        string userId FK
        string proposalText
        timestamp createdAt
    }

    taskPlanFiles {
        string id PK
        string userId FK
        string filename
        string storagePath
        string downloadUrl
        int sizeBytes "max 5MB"
        string mimeType "text/plain"
        timestamp createdAt
        timestamp planningStartDate
        timestamp planningEndDate
        array sourceEventIds "String[]"
        int eventCount
    }

    STORAGE_FILES {
        string path "task_plans/userId/filename"
        string format "UTF-8 TXT"
        int maxSize "5MB"
    }
```

## Entities

- users
- tasks
- habits
- task_preparations
- taskPlanFiles
- STORAGE_FILES

## Coverage

- Firestore collections: users (with 3 subcollections), taskPlanFiles (top-level)
- Firebase Storage: task_plans/{userId}/{filename}
- Relationships: 1:N from users to subcollections, 1:N from users to taskPlanFiles, 1:1 from taskPlanFiles to storage files
- Keys: uid (users PK), userId (FK in habits/taskPlanFiles), id (PK in tasks/habits/taskPlanFiles)
- Cardinality: ||--o{ (one-to-many), ||--|| (one-to-one)
