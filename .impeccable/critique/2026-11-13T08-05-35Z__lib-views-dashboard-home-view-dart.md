---
target: dashboard and navigation
total_score: 19
max_score: 40
na_heuristics: 
p0_count: 3
p1_count: 2
target_identity: "file:C:\\Users\\ctarv\\Desktop\\project\\lib\\views\\dashboard_home_view.dart"
target_fingerprint: "sha256:5994e4755df904f69a499fd5c6466a69b97e6448e455b244cfa78c04e023956e"
target_path: "C:\\Users\\ctarv\\Desktop\\project\\lib\\views\\dashboard_home_view.dart"
timestamp: 2026-11-13T08-05-35Z
slug: lib-views-dashboard-home-view-dart
---
## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 2/4 | AI analysis state unclear; no indication of preparation coverage percentage |
| 2 | Match System / Real World | 3/4 | Role-adaptive labels superficial; doesn't reflect preparation workflow mental model |
| 3 | User Control and Freedom | 2/4 | No undo for AI proposal rejection; keyboard shortcuts undiscoverable |
| 4 | Consistency and Standards | 3/4 | Design tokens applied but Colors.red.shade300 / Colors.orange break system |
| 5 | Error Prevention | 2/4 | No confirmation on proposal rejection; sync lacks rate-limit feedback |
| 6 | Recognition Rather Than Recall | 1/4 | Keyboard shortcuts require memorization; icon-only navigation with no labels |
| 7 | Flexibility and Efficiency | 2/4 | Keyboard shortcuts hidden; no bulk operations for AI proposals |
| 8 | Aesthetic and Minimalist Design | 3/4 | Clean but hierarchy unclear; AI insights visually equal to stat cards |
| 9 | Error Recovery | 1/4 | Generic error messages; no OAuth re-auth guidance; AI failure states absent |
| 10 | Help and Documentation | 0/4 | Zero contextual help; no onboarding hints; shortcut legend desktop-only |
| **Total** | | **19/40** | **Poor (48%)** |

## Design Specificity Verdict

**LLM Assessment:** The dashboard fails to express Yharbid's unique identity. While technically aligned with the warm gray aesthetic and restrained green accent, nothing communicates "preparation intelligence." The interface could serve any calendar tool unchanged.

**Deterministic Scan:** 1 finding - Font family declaration inconsistency (NotoSansThai vs Noto Sans Thai with fallback). Manual scan additions: Colors.red.shade300/Colors.orange usage breaks design tokens, hardcoded Thai strings break bilingual strategy.

## Overall Impression

Clean design system execution but interface hides unique value. Users see "events I already know about" rather than "preparation work I need to do." AI preparation feature buried in visually undifferentiated card.

## What's Working

1. Design System Discipline: Color tokens, spacing, typography faithfully executed
2. Keyboard Shortcuts: R for sync, N for new task shows power-user consideration
3. Role-Adaptive Infrastructure: Foundation for personalization without UI rewrites

## Priority Issues

**[P0] AI Insights Card Visual Hierarchy:** Product value proposition visually indistinguishable from stat cards. Fix: Full-width hero placement, increased height (min 200px), shadowElevated, XL radius.

**[P0] Proposal Context Blindness:** Users approve/reject based on 1-line ellipsed titles. Fix: Show full event details (date/time/location) before commitment.

**[P0] Missing Preparation Entry Point:** Approved plans disappear with no clear path to view. Fix: Add persistent "View My Preparation Plans" card showing active count.

**[P1] Keyboard Shortcut Discoverability:** Power features invisible. Fix: Add tooltips (N)/(R), shortcuts reference, or first-launch overlay.

**[P1] AI Scanning State Ambiguity:** Spinner with no progress. Fix: Show "Analyzing 3 of 12 events" or time estimate.

## Persona Red Flags

**Alex (Power User):** No bulk operations for 20 meetings/week. Keyboard shortcuts hidden. No consolidated preparation dashboard.

**Jordan (First-Timer):** Value prop unclear on empty state. Psychology icon ambiguous. Role selection invisible except label swap.

## Minor Observations

- Sync timestamp threshold too narrow
- AppBar duplication bug (two stacked)
- FAB overlaps content
- Calendar widget dominates without prep-specific value

## Questions to Consider

1. Why show calendar widget when users have Google Calendar? Replace with preparation timeline?
2. If AI personality is differentiator, why only in greeting? Should Aggressive Motivator show red urgency throughout?
3. What happens with 50 approved proposals? Show Preparation Capacity gauge?
