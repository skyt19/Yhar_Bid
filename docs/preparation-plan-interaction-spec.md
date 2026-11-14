# Preparation Plan Interaction & Progress Tracking — Implementation Specification

**Created:** 2026-11-13  
**Status:** Ready for implementation  
**Design Decision:** Per-step checkbox persistence  
**Mode:** Operate  
**Priority:** P0 (addresses critique finding: approved plans are read-only dead ends)

---

## Executive Summary

Transform approved AI preparation proposals into interactive, trackable work surfaces. Users can:
- View full AI analysis (objective, steps, resources, timeline) in detail view
- Check off preparation steps one by one with persistent state
- Track progress with real-time percentage indicator
- Resume preparation across sessions (state persists to Firestore)
- Get completion feedback when all steps are done

**Key principle:** Event-anchored preparation intelligence, not generic task management. Each plan is tied to a specific calendar event and disappears from active view after event completion.

---

## User Journey

### Entry Points

**Primary: Tasks Tab**
1. User navigates to Tasks tab → taps "แผนเตรียมงาน" filter
2. Sees list of approved preparation plan cards (green border, approved badge)
3. Taps card → opens preparation detail view
4. Works through step checklist, marks steps complete
5. Completes all steps → sees completion animation
6. Back button → returns to Tasks list, card shows "เสร็จแล้ว" badge

**Secondary: Dashboard Approval Flow**
1. User approves AI proposal in Dashboard AI Insights card
2. Gets confirmation snackbar: "บันทึกแผนแล้ว - ดูใน Tasks"
3. Proposal disappears from Dashboard (moves to approved state)
4. System creates PreparedPlan with all steps unchecked
5. User navigates to Tasks → sees new approved plan card

**Tertiary: Calendar Event Action (future enhancement)**
1. User taps calendar date with event
2. Bottom sheet shows event list with preparation status icons
3. Taps "ดูแผนเตรียมงาน" → opens preparation detail view

---

## Screen Design: Preparation Detail View

### Layout Structure

```
┌────────────────────────────────────────┐
│ [←]  นำเสนอโครงการ             [65%] │ ← Sticky header
│      20 พ.ย. 2569, 14:00              │
│      ห้องประชุม A                     │
├────────────────────────────────────────┤
│                                        │ ← Scroll container
│ วัตถุประสงค์                          │
│ เตรียมความพร้อมสำหรับการนำเสนอ         │
│ โครงการให้ทีมผู้บริหารอนุมัติ           │
│                                        │
│ ขั้นตอนเตรียมงาน (4/7)                 │
│                                        │
│ ☑ วิเคราะห์เนื้อหาโครงการ              │
│ ☑ เตรียมสไลด์นำเสนอ                    │
│ ☑ ทบทวนงบประมาณ                        │
│ ☑ เตรียมเอกสารประกอบ                   │
│ ☐ ซ้อมนำเสนอ                          │
│ ☐ ตรวจสอบอุปกรณ์                       │
│ ☐ เตรียมคำตอบคำถาม                     │
│                                        │
│ ทรัพยากรที่ต้องใช้            [▼]     │
│                                        │
│ ไทม์ไลน์แนะนำ                          │
│ ⏰ เริ่มเตรียม 2 วันก่อนงาน           │
│                                        │
├────────────────────────────────────────┤
│           [ดาวน์โหลด TXT]              │ ← Sticky footer
└────────────────────────────────────────┘
```

### Header (Sticky)

**Elements:**
- Back button (←) — closes view, returns to Tasks
- Event title (16px, bold, 2 lines max with ellipsis)
- Event datetime (13px, secondary text, Buddhist calendar format)
- Event location (13px, secondary text with location icon, 1 line max)
- Circular progress indicator (48px diameter, 65% label inside)

**Behavior:**
- Stays visible during scroll
- Progress updates in real-time as steps complete
- Background: white with subtle bottom shadow (shadowSubtle)

**Spacing:**
- 16px padding all sides
- 8px gap between title and datetime
- 4px gap between datetime and location
- Progress indicator aligned right, vertically centered

### Objective Section

**Elements:**
- Section heading "วัตถุประสงค์" (15px, semibold)
- Objective text (14px, regular, 2-3 lines, gray-800)

**Behavior:**
- Read-only, no interaction
- Provides context for why preparation matters

**Spacing:**
- 24px margin top (from header)
- 8px gap between heading and text
- 20px margin bottom (to steps)

### Preparation Steps Section (Primary)

**Elements:**
- Section heading "ขั้นตอนเตรียมงาน (4/7)" (15px, semibold)
- Step list, each item:
  - Custom checkbox (24x24px visual, 56x56px touch target)
  - Step text (14px, regular, multi-line if needed)
  - Completed steps: green checkmark, strikethrough text, gray-600 color
  - Incomplete steps: empty circle, normal text, gray-900 color

**Behavior:**
- Tap anywhere on step row → toggles checkbox
- Optimistic update: checkbox changes immediately
- Background Firestore write persists state
- On completion: scale bounce animation (1.0x → 1.1x → 1.0x, 150ms)
- Progress indicator updates with count-up animation
- Final step completion: triggers celebration (see Completion Animation)

**Spacing:**
- 20px margin top (from objective)
- 8px gap between heading and first step
- 12px gap between steps (tight grouping)
- 8px padding left/right within each step row
- 16px padding top/bottom per step (touch target sizing)

**Accessibility:**
- Tab navigation: cycles through checkboxes
- Space key: toggles focused checkbox
- Screen reader: "Step 1 of 7, completed" / "Step 2 of 7, not completed"
- Focus indicator: 2px green outline on keyboard focus

### Resources Section (Collapsed by Default)

**Elements:**
- Section heading "ทรัพยากรที่ต้องใช้" with chevron icon (▼/▲)
- Resource list (when expanded):
  - Bullet list (•)
  - 14px regular text
  - 0-5 items

**Behavior:**
- Tap heading → expand/collapse section
- Chevron rotates 180° (180ms)
- Resource list slides in/out (200ms, easeOut)
- State persists during session (not across sessions)
- If 0 resources: section hidden entirely

**Spacing:**
- 20px margin top (from steps)
- 8px gap between heading and list
- 8px gap between list items
- 20px margin bottom (to timeline)

### Timeline Section

**Elements:**
- Section heading "ไทม์ไลน์แนะนำ" (15px, semibold)
- Timeline text with clock icon (⏰) (14px, regular)

**Behavior:**
- Read-only, no interaction
- Provides recommended preparation window

**Spacing:**
- 20px margin top (from resources)
- 8px gap between heading and timeline
- 80px margin bottom (space above footer)

### Footer (Sticky)

**Elements:**
- "ดาวน์โหลด TXT" button (full-width, secondary style)

**Behavior:**
- Taps generates downloadable UTF-8 TXT file
- Includes event details, objective, all steps (with ✓ for completed), resources, timeline
- Opens browser download dialog
- Same functionality as existing TXT download, now accessible from detail view

**Spacing:**
- 16px padding all sides
- Background: white with subtle top shadow
- 56px height (standard touch target)

---

## Completion Animation

**Trigger:** User checks the final unchecked step (progress goes from N-1/N to N/N).

**Sequence:**
1. **Checkbox bounce** (150ms): scale 1.0x → 1.1x → 1.0x
2. **Progress circle fill** (300ms): animates from previous % to 100% with scale bounce at 100%
3. **Confetti burst** (500ms): 3 bursts of green accent particles from progress circle center, gravity fall
4. **Card state update**: backend updates plan.completedAt = now, card badge changes to "เสร็จแล้ว"
5. **Success snackbar**: "เตรียมงานเสร็จสมบูรณ์! 🎉"

**Accessibility:**
- `prefers-reduced-motion`: skip confetti, use instant progress update with success icon
- Screen reader: announce "All 7 steps completed"

---

## Data Model

### PreparedPlanModel (New)

```dart
/// lib/models/prepared_plan_model.dart
class PreparedPlanModel {
  final String id;
  final String userId;
  final String proposalId; // links back to PreparationProposal
  final String eventId; // Google Calendar Event ID
  final String eventTitle;
  final DateTime eventDateTime;
  final String eventLocation;
  final String objective; // parsed from aiContent
  final List<PreparationStep> steps; // parsed from aiContent
  final List<String> resources; // parsed from aiContent
  final String timeline; // parsed from aiContent
  final DateTime createdAt;
  final DateTime? completedAt; // null until all steps complete
  
  // Computed properties
  int get completedStepCount => steps.where((s) => s.isCompleted).length;
  int get totalSteps => steps.length;
  double get progressPercentage => totalSteps > 0 ? completedStepCount / totalSteps : 0.0;
  bool get isCompleted => completedStepCount == totalSteps;
  
  // Factory: parse AI content into structured plan
  factory PreparedPlanModel.fromProposal(PreparationProposal proposal) {
    // Parse proposal.aiContent string into structured sections
    // Expected format:
    // วัตถุประสงค์: <objective text>
    // ขั้นตอนเตรียมงาน:
    // 1. <step 1>
    // 2. <step 2>
    // ทรัพยากร: <resource1>, <resource2>
    // ไทม์ไลน์: <timeline text>
    
    final sections = _parseAiContent(proposal.aiContent);
    return PreparedPlanModel(
      id: 'plan_${proposal.id}',
      userId: proposal.event.userId,
      proposalId: proposal.id,
      eventId: proposal.event.id,
      eventTitle: proposal.event.title,
      eventDateTime: proposal.event.startTime,
      eventLocation: proposal.event.location,
      objective: sections['objective'] ?? '',
      steps: sections['steps'] ?? [],
      resources: sections['resources'] ?? [],
      timeline: sections['timeline'] ?? '',
      createdAt: DateTime.now(),
      completedAt: null,
    );
  }
  
  // Firestore serialization
  Map<String, dynamic> toFirestore() { ... }
  factory PreparedPlanModel.fromFirestore(DocumentSnapshot doc) { ... }
}

class PreparationStep {
  final String id; // step_1, step_2, etc.
  final int order; // 1-based ordering
  final String text; // "วิเคราะห์เนื้อหาโครงการ"
  final bool isCompleted;
  final DateTime? completedAt;
  
  PreparationStep copyWith({bool? isCompleted, DateTime? completedAt}) { ... }
}
```

### Firestore Structure

**Collection:** `preparedPlans/{userId}/plans/{planId}`

```json
{
  "proposalId": "prop_abc123",
  "eventId": "cal_event_xyz789",
  "eventTitle": "นำเสนอโครงการ",
  "eventDateTime": "2026-11-20T14:00:00+07:00",
  "eventLocation": "ห้องประชุม A",
  "objective": "เตรียมความพร้อมสำหรับการนำเสนอโครงการให้ทีมผู้บริหารอนุมัติ",
  "steps": [
    {
      "id": "step_1",
      "order": 1,
      "text": "วิเคราะห์เนื้อหาโครงการ",
      "isCompleted": true,
      "completedAt": "2026-11-18T10:30:00Z"
    },
    {
      "id": "step_2",
      "order": 2,
      "text": "เตรียมสไลด์นำเสนอ",
      "isCompleted": true,
      "completedAt": "2026-11-18T15:20:00Z"
    },
    {
      "id": "step_3",
      "order": 3,
      "text": "ซ้อมนำเสนอ",
      "isCompleted": false,
      "completedAt": null
    }
  ],
  "resources": ["Google Slides", "โครงการ PDF", "งบประมาณ Excel"],
  "timeline": "เริ่มเตรียม 2 วันก่อนงาน",
  "createdAt": "2026-11-17T09:00:00Z",
  "completedAt": null
}
```

**Indexes:**
- `userId, eventDateTime` (for filtering upcoming preparations)
- `userId, completedAt` (for filtering completed vs in-progress)

---

## State Management

### PreparedPlanController (New)

```dart
/// lib/controllers/prepared_plan_controller.dart
class PreparedPlanController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxList<PreparedPlanModel> plans = <PreparedPlanModel>[].obs;
  final RxBool isLoading = false.obs;
  
  // Getters
  List<PreparedPlanModel> get activePlans => 
    plans.where((p) => !p.isCompleted && p.eventDateTime.isAfter(DateTime.now())).toList();
  
  List<PreparedPlanModel> get completedPlans => 
    plans.where((p) => p.isCompleted).toList();
  
  // Fetch plans for current user
  Future<void> fetchPlans() async { ... }
  
  // Toggle step completion
  Future<void> toggleStep(String planId, String stepId) async {
    // Optimistic update
    final plan = plans.firstWhere((p) => p.id == planId);
    final stepIndex = plan.steps.indexWhere((s) => s.id == stepId);
    final step = plan.steps[stepIndex];
    
    // Update local state immediately
    plan.steps[stepIndex] = step.copyWith(
      isCompleted: !step.isCompleted,
      completedAt: !step.isCompleted ? DateTime.now() : null,
    );
    
    // Check if all steps complete
    if (plan.isCompleted && plan.completedAt == null) {
      plan.completedAt = DateTime.now();
      _triggerCompletionAnimation(planId);
    }
    
    plans.refresh();
    
    // Persist to Firestore
    try {
      await _firestore
        .collection('preparedPlans')
        .doc(userId)
        .collection('plans')
        .doc(planId)
        .update({
          'steps': plan.steps.map((s) => s.toMap()).toList(),
          'completedAt': plan.completedAt?.toIso8601String(),
        });
    } catch (e) {
      // Revert on failure
      plan.steps[stepIndex] = step;
      plans.refresh();
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถบันทึกได้ กรุณาลองใหม่');
    }
  }
  
  void _triggerCompletionAnimation(String planId) {
    // Trigger confetti animation via event bus
    Get.find<AnimationController>().showCompletionAnimation(planId);
  }
}
```

---

## Tasks View Integration

### Updated Preparation Card

**Changes to `lib/views/tasks/tasks_view.dart` → `_preparationCard`:**

```dart
Widget _preparationCard(PreparationProposal proposal, BuildContext context) {
  // Fetch corresponding PreparedPlan to show progress
  final preparedPlanCtrl = Get.find<PreparedPlanController>();
  final plan = preparedPlanCtrl.plans.firstWhereOrNull(
    (p) => p.proposalId == proposal.id
  );
  
  final bool isCompleted = plan?.isCompleted ?? false;
  final int completedSteps = plan?.completedStepCount ?? 0;
  final int totalSteps = plan?.totalSteps ?? 0;
  
  return GestureDetector(
    onTap: () {
      if (plan != null) {
        Get.to(() => PreparationDetailView(plan: plan));
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowCard,
        border: Border.all(
          color: isCompleted 
            ? AppTheme.accentGreen.withValues(alpha: 0.5)
            : AppTheme.accentGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge row: approved badge + progress badge
            Row(
              children: [
                _approvedBadge(),
                if (!isCompleted && totalSteps > 0) ...[
                  const SizedBox(width: 8),
                  _progressBadge(completedSteps, totalSteps),
                ],
                if (isCompleted) ...[
                  const SizedBox(width: 8),
                  _completedBadge(),
                ],
                const Spacer(),
                Text(
                  '${proposal.createdAt.day}/${proposal.createdAt.month}/${proposal.createdAt.year}',
                  style: AppTheme.caption,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Event title and details (unchanged)
            Text(proposal.event.title, style: ...),
            // ... rest of card content
          ],
        ),
      ),
    ),
  );
}

Widget _progressBadge(int completed, int total) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppTheme.accentGreen.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppTheme.radiusXS),
    ),
    child: Text(
      '$completed/$total เสร็จแล้ว',
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.accentGreen,
      ),
    ),
  );
}

Widget _completedBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppTheme.accentGreen,
      borderRadius: BorderRadius.circular(AppTheme.radiusXS),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, size: 12, color: Colors.white),
        SizedBox(width: 4),
        Text(
          'เสร็จแล้ว',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}
```

---

## Dashboard Integration

### Approval Flow Update

**Changes to `lib/controllers/proactive_controller.dart` → `approveProposal`:**

```dart
Future<void> approveProposal(int index) async {
  if (index < 0 || index >= proposals.length) return;
  
  final proposal = proposals[index];
  
  // Update proposal status
  proposals[index] = proposal.copyWith(status: PreparationStatus.approved);
  
  // Create PreparedPlan from approved proposal
  final preparedPlan = PreparedPlanModel.fromProposal(proposal);
  
  // Persist to Firestore
  final preparedPlanCtrl = Get.find<PreparedPlanController>();
  await preparedPlanCtrl.createPlan(preparedPlan);
  
  // Show success message with navigation hint
  Get.snackbar(
    'บันทึกแผนแล้ว',
    'ดูแผนเตรียมงานใน Tasks → แผนเตรียมงาน',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AppTheme.accentGreen,
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
  );
}
```

---

## AI Content Parsing

### Expected AI Response Format

The AI service (`lib/services/ai_service.dart`) already generates preparation content. We need to ensure consistent structure for parsing.

**Current format (from code inspection):**
```
[Free-form preparation steps in Thai, 3-5 items]
```

**Required format for parsing:**
```
วัตถุประสงค์: เตรียมความพร้อมสำหรับการนำเสนอโครงการให้ทีมผู้บริหารอนุมัติ

ขั้นตอนเตรียมงาน:
1. วิเคราะห์เนื้อหาโครงการและจุดเด่น
2. เตรียมสไลด์นำเสนอพร้อมข้อมูลสนับสนุน
3. ทบทวนงบประมาณและไทม์ไลน์โครงการ
4. เตรียมเอกสารประกอบการนำเสนอ
5. ซ้อมนำเสนอและเตรียมคำตอบคำถาม

ทรัพยากร: Google Slides, โครงการ PDF, งบประมาณ Excel

ไทม์ไลน์: เริ่มเตรียม 2 วันก่อนงาน, ซ้อมนำเสนอในเช้าวันงาน
```

### Parser Implementation

```dart
/// lib/utils/ai_content_parser.dart
class AiContentParser {
  static Map<String, dynamic> parse(String aiContent) {
    final lines = aiContent.split('\n').where((l) => l.trim().isNotEmpty).toList();
    
    String objective = '';
    List<PreparationStep> steps = [];
    List<String> resources = [];
    String timeline = '';
    
    String currentSection = '';
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.startsWith('วัตถุประสงค์:')) {
        currentSection = 'objective';
        objective = line.replaceFirst('วัตถุประสงค์:', '').trim();
      } else if (line.startsWith('ขั้นตอนเตรียมงาน:')) {
        currentSection = 'steps';
      } else if (line.startsWith('ทรัพยากร:')) {
        currentSection = 'resources';
        final resourceText = line.replaceFirst('ทรัพยากร:', '').trim();
        resources = resourceText.split(',').map((r) => r.trim()).toList();
      } else if (line.startsWith('ไทม์ไลน์:')) {
        currentSection = 'timeline';
        timeline = line.replaceFirst('ไทม์ไลน์:', '').trim();
      } else if (currentSection == 'objective' && objective.isEmpty) {
        objective = line;
      } else if (currentSection == 'steps' && line.contains(RegExp(r'^\d+\.'))) {
        final stepText = line.replaceFirst(RegExp(r'^\d+\.'), '').trim();
        steps.add(PreparationStep(
          id: 'step_${steps.length + 1}',
          order: steps.length + 1,
          text: stepText,
          isCompleted: false,
          completedAt: null,
        ));
      }
    }
    
    // Fallback: if parsing failed, treat entire content as single step
    if (steps.isEmpty) {
      steps.add(PreparationStep(
        id: 'step_1',
        order: 1,
        text: aiContent,
        isCompleted: false,
        completedAt: null,
      ));
    }
    
    return {
      'objective': objective.isNotEmpty ? objective : 'เตรียมความพร้อมสำหรับงาน',
      'steps': steps,
      'resources': resources,
      'timeline': timeline.isNotEmpty ? timeline : 'ควรเตรียมล่วงหน้าก่อนงาน',
    };
  }
}
```

---

## Edge Cases & Error Handling

### Empty States
- **No approved preparations:** Show empty state in Tasks → แผนเตรียมงาน filter (already implemented)
- **Event has passed:** Plan still visible but add visual indicator "งานผ่านไปแล้ว" badge
- **0 resources:** Hide Resources section entirely
- **Parsing fails:** Create single-step plan with entire AI content as step text

### Error States
- **Firestore write fails:** Revert checkbox state, show error snackbar with retry button
- **Offline mode:** Allow checkbox taps, queue writes, sync when online (use Firestore offline persistence)
- **Network timeout:** Show error after 10s, allow retry
- **Corrupted data:** Graceful degradation—show what can be parsed, log error for debugging

### Sync Conflicts
- **Last-write-wins:** User completes step on device A, then device B—device B's completion timestamp takes precedence
- **Optimistic UI:** Always update UI immediately, background sync handles persistence

### Performance
- **Large step lists:** Virtual scrolling not needed (max 7 steps per design constraint)
- **Animation performance:** Use `AnimatedContainer` and `TweenAnimationBuilder` for smooth 60fps
- **Firestore reads:** Cache plans in controller, only refetch on pull-to-refresh

---

## Accessibility

### Keyboard Navigation
- Tab: cycles through checkboxes in order
- Space: toggles focused checkbox
- Escape: closes detail view
- Enter on back button: closes view

### Screen Reader
- Header announces: "Preparation plan for [event title], [completed] out of [total] steps complete"
- Each step announces: "Step [N] of [total]: [step text], [completed/not completed]"
- Progress updates announce: "[N] steps complete"
- Completion announces: "All steps complete, congratulations"

### Reduced Motion
- `prefers-reduced-motion: reduce` detected:
  - Disable confetti animation
  - Use instant progress percentage update (no count-up)
  - Checkbox toggle has no scale bounce
  - Section expand/collapse is instant

### Contrast
- All text meets WCAG AA 4.5:1 minimum
- Green accent (#4CAF50) on white passes 3:1 for large text
- Focus indicator is 2px solid green (passes 3:1 contrast requirement)

---

## Testing Checklist

### Functional
- [ ] Tap approved plan card → opens detail view
- [ ] Tap checkbox → toggles completion state
- [ ] Progress indicator updates in real-time
- [ ] Complete all steps → triggers completion animation
- [ ] Back button → returns to Tasks list
- [ ] Card badge updates after completion
- [ ] Download TXT button generates file with completion status
- [ ] Resources section expands/collapses
- [ ] State persists across app restarts

### States
- [ ] Empty state (no approved plans)
- [ ] Loading state (skeleton cards)
- [ ] In-progress state (some steps complete)
- [ ] Completed state (all steps complete)
- [ ] Error state (sync failure)
- [ ] Event passed state (datetime < now)

### Responsive
- [ ] Narrow viewport (<640px): full-screen layout
- [ ] Wide viewport (≥640px): centered modal overlay
- [ ] Touch targets meet 56x56px minimum
- [ ] Text wraps gracefully on narrow screens

### Accessibility
- [ ] Keyboard navigation works (Tab, Space, Escape)
- [ ] Screen reader announces progress correctly
- [ ] Focus indicators visible
- [ ] Reduced motion respected
- [ ] Contrast ratios pass WCAG AA

### Performance
- [ ] Checkbox toggle is instant (<100ms perceived latency)
- [ ] Progress animation is smooth (60fps)
- [ ] No jank during scroll
- [ ] Completion animation doesn't block UI

### Error Handling
- [ ] Offline checkbox taps queue for sync
- [ ] Sync failure shows error + retry
- [ ] Parsing failure creates fallback plan
- [ ] Corrupted data handled gracefully

---

## Implementation Priority

### Phase 1: Core Interaction (Must-have)
1. Create `PreparedPlanModel` and Firestore schema
2. Implement AI content parser
3. Build `PreparationDetailView` UI (header, steps, footer)
4. Wire checkbox toggle with Firestore persistence
5. Update Tasks card to show progress badge and handle tap

**Deliverable:** Users can view approved plans, check off steps, see progress, and have state persist.

### Phase 2: Polish & Feedback (Should-have)
1. Add circular progress indicator to header
2. Implement completion animation (confetti + bounce)
3. Add Resources expandable section
4. Add completion badge to Tasks card
5. Keyboard navigation and screen reader support

**Deliverable:** Polished interaction with delightful feedback and full accessibility.

### Phase 3: Dashboard Integration (Should-have)
1. Update `approveProposal` to create `PreparedPlan`
2. Add success snackbar with navigation hint
3. Ensure proposal disappears from Dashboard after approval

**Deliverable:** Seamless approval-to-action flow from Dashboard to Tasks.

### Phase 4: Edge Cases & Future (Nice-to-have)
1. Event passed indicator
2. Archive completed plans after 7 days
3. Calendar event action sheet (tertiary entry point)
4. Offline mode with sync queue
5. Performance optimizations

**Deliverable:** Production-ready with all edge cases handled.

---

## Success Metrics

**Adoption:**
- % of approved proposals that get at least 1 step completed (target: >60%)
- Average steps completed per plan (target: >4 out of 7)
- % of plans reaching 100% completion (target: >40%)

**Engagement:**
- Average time from approval to first step completion (target: <24 hours)
- Average time from first to last step completion (target: <3 days)
- % of users returning to incomplete plans (target: >50%)

**Satisfaction:**
- Reduction in "approved plans are dead ends" feedback
- Increase in active daily users during event preparation windows
- User-reported confidence in event preparation (survey)

---

## Open Questions for Future Iteration

1. **Collaboration:** Should preparation plans support shared completion (teams preparing together)?
2. **Notifications:** Should users get reminders to complete remaining steps N hours before event?
3. **Customization:** Should users be able to add/edit/remove AI-generated steps?
4. **History:** What happens to completed plans after event passes—archive automatically, or keep indefinitely?
5. **Analytics:** Should we track which step types get completed fastest/slowest to improve AI recommendations?

---

## Appendix: Visual Design Tokens

All visual design follows existing AppTheme from `DESIGN.md`:

**Colors:**
- Background: `#F5F5F5`
- Surface: `#FFFFFF`
- Surface light: `#F0F0F0`
- Accent green: `#4CAF50`
- Accent green dark: `#2E7D32`
- Text primary: `#212121`
- Text secondary: `#757575`
- Text tertiary: `#9E9E9E`
- Border: `#E0E0E0`
- Border strong: `#BDBDBD`

**Typography:**
- Title: 16px / semibold / Noto Sans Thai
- Body: 14px / regular / Noto Sans Thai
- Caption: 13px / regular / Noto Sans Thai
- Small: 12px / regular / Noto Sans Thai

**Spacing:**
- XS: 4px
- S: 8px
- M: 12px
- L: 16px
- XL: 20px
- XXL: 24px
- XXXL: 32px

**Radius:**
- XS: 6px
- S: 8px
- M: 12px
- L: 16px
- XL: 20px
- Pill: 999px

**Shadows:**
- Subtle: `0 1px 4px rgba(0,0,0,0.04)`
- Card: `0 2px 8px rgba(0,0,0,0.08)`
- Elevated: `0 4px 16px rgba(0,0,0,0.12)`

**Animations:**
- Fast: 150ms
- Normal: 250ms
- Slow: 400ms
- Easing: `easeOut` (cubic-bezier(0.0, 0.0, 0.2, 1.0))

---

**End of Specification**

This document is ready for implementation by a Flutter developer familiar with GetX state management and Firebase Firestore. All design decisions are finalized based on product requirements, user research (critique findings), and technical constraints (Firebase Spark free tier).
