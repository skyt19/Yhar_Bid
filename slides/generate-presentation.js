const pptxgen = require('pptxgenjs');

// ============================================================
// YHAR BID M3 PRESENTATION
// Premium, Editorial-Quality Design
// Inspired by Apple product launches and design studios
// ============================================================

// VISUAL IDENTITY
// Sophisticated, minimal, editorial, cinematic
// Distinctive palette: graphite, warm white, muted silver, warm gold accent
const PALETTE = {
  graphite: "1A1D23",      // Deep graphite (hero backgrounds, primary text on light)
  warmWhite: "FAFAF9",     // Warm white (primary backgrounds)
  silver: "8B919A",        // Muted silver (secondary text, supporting elements)
  gold: "D4AF37",          // Warm gold accent (distinctive, premium)
  charcoal: "2D3436",      // Supporting charcoal
  mutedRed: "C1666B",      // Partial implementation status
  mutedGreen: "5B8C5A",    // Implemented status
  lightGray: "E8E6E3"      // Subtle backgrounds
};

// TYPOGRAPHY
// Modern, editorial hierarchy
// Segoe UI (Windows standard) - clean, readable, professional
const TYPE = {
  display: "Segoe UI",     // Large headlines
  body: "Segoe UI"         // Body text
};

const pres = new pptxgen();
pres.layout = 'LAYOUT_16x9';
pres.author = 'Yhar Bid Team';
pres.company = 'Software Engineering Project';
pres.subject = 'M3 Final Presentation';
pres.title = 'Yhar Bid — Adaptive Routine & Reminder Assistant';

// ============================================================
// SLIDE 1: HERO OPENING
// Full-bleed dark background, oversized typography, dramatic opening
// ============================================================
let slide = pres.addSlide();
slide.background = { color: PALETTE.graphite };

// Oversized hero headline with deliberate line break
slide.addText("Yhar Bid", {
  x: 0.8, y: 1.5, w: 8.4, h: 1.4,
  fontSize: 88, bold: true, color: PALETTE.warmWhite,
  fontFace: TYPE.display, lineSpacing: 0.9
});

slide.addText("Adaptive Routine &\nReminder Assistant", {
  x: 0.8, y: 3.1, w: 8.4, h: 1.0,
  fontSize: 32, color: PALETTE.silver,
  fontFace: TYPE.body, lineSpacing: 1.3
});

// Subtle accent line
slide.addShape(pres.ShapeType.rect, {
  x: 0.8, y: 4.4, w: 2.5, h: 0.03,
  fill: { color: PALETTE.gold }
});

slide.addText("M3 Final Presentation", {
  x: 0.8, y: 4.7, w: 8.4, h: 0.4,
  fontSize: 14, color: PALETTE.silver,
  fontFace: TYPE.body
});

// ============================================================
// SLIDE 2: THE CHALLENGE
// Asymmetric layout, strong typographic hierarchy
// ============================================================
slide = pres.addSlide();
slide.background = { color: PALETTE.warmWhite };

// Large headline, left-aligned
slide.addText("The Challenge", {
  x: 0.8, y: 0.6, w: 8.4, h: 0.8,
  fontSize: 54, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

// Three challenge cards with subtle styling
const challenges = [
  {
    title: "Context\nOverload",
    text: "Students and professionals juggle multiple responsibilities across calendars, task lists, and communication tools.",
    y: 1.8
  },
  {
    title: "Generic\nSolutions",
    text: "Existing reminder apps treat all users the same, ignoring individual roles and workflow patterns.",
    y: 3.0
  },
  {
    title: "Manual\nBurden",
    text: "Users constantly check multiple systems and manually translate events into action steps.",
    y: 4.2
  }
];

challenges.forEach(ch => {
  slide.addText(ch.title, {
    x: 0.8, y: ch.y, w: 2.5, h: 0.8,
    fontSize: 24, bold: true, color: PALETTE.charcoal,
    fontFace: TYPE.display, lineSpacing: 1.1
  });

  slide.addText(ch.text, {
    x: 3.5, y: ch.y + 0.05, w: 5.7, h: 0.8,
    fontSize: 15, color: PALETTE.silver,
    fontFace: TYPE.body, lineSpacing: 1.4
  });

  // Subtle divider
  if (ch.y < 4.2) {
    slide.addShape(pres.ShapeType.rect, {
      x: 0.8, y: ch.y + 0.95, w: 8.4, h: 0.01,
      fill: { color: PALETTE.lightGray }
    });
  }
});

// ============================================================
// SLIDE 3: THE VISION
// Centered, editorial statement slide
// ============================================================
slide = pres.addSlide();
slide.background = { color: PALETTE.warmWhite };

// Minimal top accent
slide.addShape(pres.ShapeType.rect, {
  x: 0, y: 0, w: 10, h: 0.05,
  fill: { color: PALETTE.gold }
});

slide.addText("The Vision", {
  x: 1.5, y: 1.2, w: 7.0, h: 0.6,
  fontSize: 20, bold: true, color: PALETTE.gold,
  fontFace: TYPE.display, align: "center"
});

// Large, readable vision statement
slide.addText("A context-aware assistant that\nunderstands your role, monitors\nyour commitments, and proactively\nsuggests personalized preparation\nstrategies.", {
  x: 1.0, y: 2.2, w: 8.0, h: 2.5,
  fontSize: 28, color: PALETTE.graphite, align: "center",
  fontFace: TYPE.body, lineSpacing: 1.5, bold: false
});

// ============================================================
// SLIDE 4: PRODUCT OVERVIEW
// Visual process flow with numbered steps
// ============================================================
slide = pres.addSlide();
slide.background = { color: PALETTE.warmWhite };

slide.addText("Product Overview", {
  x: 0.8, y: 0.6, w: 8.4, h: 0.7,
  fontSize: 48, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

const phases = [
  { num: "1", title: "Learn", desc: "Users select their primary role and AI interaction style", x: 0.8 },
  { num: "2", title: "Monitor", desc: "Integration with Google Calendar tracks commitments", x: 3.8 },
  { num: "3", title: "Guide", desc: "AI generates role-appropriate preparation and analytics", x: 6.8 }
];

phases.forEach(ph => {
  // Number circle
  slide.addShape(pres.ShapeType.ellipse, {
    x: ph.x, y: 2.0, w: 0.6, h: 0.6,
    fill: { color: PALETTE.gold }
  });
  slide.addText(ph.num, {
    x: ph.x, y: 2.0, w: 0.6, h: 0.6,
    fontSize: 28, bold: true, color: PALETTE.graphite,
    align: "center", valign: "middle", fontFace: TYPE.display
  });

  slide.addText(ph.title, {
    x: ph.x, y: 2.8, w: 2.5, h: 0.4,
    fontSize: 22, bold: true, color: PALETTE.charcoal,
    fontFace: TYPE.display
  });

  slide.addText(ph.desc, {
    x: ph.x, y: 3.3, w: 2.5, h: 1.0,
    fontSize: 13, color: PALETTE.silver,
    fontFace: TYPE.body, lineSpacing: 1.4
  });
});

// ============================================================
// SLIDE 5: SYSTEM ARCHITECTURE
// Clean diagram with visual hierarchy
// ============================================================
slide = pres.addSlide();
slide.background = { color: PALETTE.warmWhite };

slide.addText("System Architecture", {
  x: 0.8, y: 0.6, w: 8.4, h: 0.7,
  fontSize: 48, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

// Four architecture components in 2x2 grid
const arch = [
  { title: "Frontend", items: "Flutter Web\nRole-based UI\nResponsive design\nReal-time updates", x: 0.8, y: 1.8 },
  { title: "Authentication", items: "Firebase Auth\nGoogle OAuth\nSecure calendar access\nUser management", x: 5.4, y: 1.8 },
  { title: "AI Pipeline", items: "Supabase Edge Function\nGroq (llama-3.3-70b)\nFirebase token verification\nRate limiting", x: 0.8, y: 3.6 },
  { title: "Data Layer", items: "Cloud Firestore\nUser profiles & habits\nTasks & events\nReal-time sync", x: 5.4, y: 3.6 }
];

arch.forEach(comp => {
  // Subtle card with accent border
  slide.addShape(pres.ShapeType.rect, {
    x: comp.x, y: comp.y, w: 4.0, h: 1.5,
    fill: { color: PALETTE.lightGray },
    line: { color: PALETTE.gold, width: 2 }
  });

  slide.addText(comp.title, {
    x: comp.x + 0.3, y: comp.y + 0.2, w: 3.4, h: 0.3,
    fontSize: 18, bold: true, color: PALETTE.graphite,
    fontFace: TYPE.display
  });

  slide.addText(comp.items, {
    x: comp.x + 0.3, y: comp.y + 0.6, w: 3.4, h: 0.8,
    fontSize: 11, color: PALETTE.charcoal,
    fontFace: TYPE.body, lineSpacing: 1.5
  });
});

// ============================================================
// SLIDE 6: REQUIREMENTS OVERVIEW
// Clean table with clear status indicators
// ============================================================
slide = pres.addSlide();
slide.background = { color: PALETTE.warmWhite };

slide.addText("Requirements Overview", {
  x: 0.8, y: 0.6, w: 8.4, h: 0.7,
  fontSize: 48, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

// Table with refined styling
const reqs = [
  { fr: "FR-1: Role-Based Onboarding", status: "✓ Implemented", evidence: "Complete user persistence", color: PALETTE.mutedGreen },
  { fr: "FR-2: Calendar Sync", status: "◐ Partial", evidence: "Read works; write has fallback", color: PALETTE.mutedRed },
  { fr: "FR-3: Proactive Preparation", status: "◐ Partial", evidence: "AI works; manual trigger only", color: PALETTE.mutedRed },
  { fr: "FR-4: Habit Tracker", status: "✓ Implemented", evidence: "Backend + analytics integration", color: PALETTE.mutedGreen },
  { fr: "FR-5: Notifications", status: "◐ Partial", evidence: "Generation works; no scheduling", color: PALETTE.mutedRed },
  { fr: "FR-6: Analytics Dashboard", status: "✓ Implemented", evidence: "Real-time charts + metrics", color: PALETTE.mutedGreen }
];

let tableY = 1.7;

// Header row
slide.addText("Requirement", { x: 0.8, y: tableY, w: 3.8, h: 0.35, fontSize: 13, bold: true, color: PALETTE.warmWhite, fill: { color: PALETTE.charcoal }, margin: 0.12, fontFace: TYPE.display });
slide.addText("Status", { x: 4.6, y: tableY, w: 1.6, h: 0.35, fontSize: 13, bold: true, color: PALETTE.warmWhite, fill: { color: PALETTE.charcoal }, margin: 0.12, fontFace: TYPE.display });
slide.addText("Evidence", { x: 6.2, y: tableY, w: 3.0, h: 0.35, fontSize: 13, bold: true, color: PALETTE.warmWhite, fill: { color: PALETTE.charcoal }, margin: 0.12, fontFace: TYPE.display });

tableY += 0.35;
reqs.forEach((row, idx) => {
  const bg = idx % 2 === 0 ? PALETTE.warmWhite : PALETTE.lightGray;
  slide.addText(row.fr, { x: 0.8, y: tableY, w: 3.8, h: 0.38, fontSize: 12, color: PALETTE.graphite, fill: { color: bg }, margin: 0.12, fontFace: TYPE.body });
  slide.addText(row.status, { x: 4.6, y: tableY, w: 1.6, h: 0.38, fontSize: 12, color: row.color, bold: true, fill: { color: bg }, margin: 0.12, fontFace: TYPE.body });
  slide.addText(row.evidence, { x: 6.2, y: tableY, w: 3.0, h: 0.38, fontSize: 11, color: PALETTE.silver, fill: { color: bg }, margin: 0.12, fontFace: TYPE.body });
  tableY += 0.38;
});

// Summary
slide.addText("3 of 6 requirements fully implemented  •  3 requirements partially implemented", {
  x: 0.8, y: tableY + 0.25, w: 8.4, h: 0.4,
  fontSize: 15, bold: true, color: PALETTE.charcoal,
  fontFace: TYPE.body, align: "center"
});

// ============================================================
// SLIDE 7: FR-1 IMPLEMENTATION
// Feature showcase with visual flow
// ============================================================
slide = pres.addSlide();
slide.background = { color: PALETTE.warmWhite };

slide.addText("FR-1: Role-Based Onboarding", {
  x: 0.8, y: 0.6, w: 8.4, h: 0.7,
  fontSize: 44, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

slide.addShape(pres.ShapeType.rect, {
  x: 0.8, y: 1.4, w: 0.8, h: 0.04,
  fill: { color: PALETTE.mutedGreen }
});

// Three implementation phases
const fr1 = [
  { num: "1", title: "Role Selection", desc: "Student, Corporate, or Healthcare with dedicated onboarding screens", y: 2.1 },
  { num: "2", title: "AI Personality", desc: "Chill, Balanced, or Aggressive interaction style persists across sessions", y: 3.2 },
  { num: "3", title: "Persistence", desc: "Stored in user_model.dart and auth_controller.dart, drives all AI interactions", y: 4.3 }
];

fr1.forEach(ph => {
  slide.addShape(pres.ShapeType.ellipse, {
    x: 0.8, y: ph.y, w: 0.5, h: 0.5,
    fill: { color: PALETTE.mutedGreen }
  });
  slide.addText(ph.num, {
    x: 0.8, y: ph.y, w: 0.5, h: 0.5,
    fontSize: 22, bold: true, color: PALETTE.warmWhite,
    align: "center", valign: "middle", fontFace: TYPE.display
  });

  slide.addText(ph.title, {
    x: 1.5, y: ph.y, w: 7.7, h: 0.25,
    fontSize: 18, bold: true, color: PALETTE.charcoal,
    fontFace: TYPE.display
  });

  slide.addText(ph.desc, {
    x: 1.5, y: ph.y + 0.3, w: 7.7, h: 0.5,
    fontSize: 13, color: PALETTE.silver,
    fontFace: TYPE.body, lineSpacing: 1.3
  });
});

// ============================================================
// SLIDE 8: FR-4 + FR-6 IMPLEMENTATION
// Side-by-side feature comparison
// ============================================================
slide = pres.addSlide();
slide.background = { color: PALETTE.warmWhite };

slide.addText("FR-4 + FR-6: Habit Tracking & Analytics", {
  x: 0.8, y: 0.6, w: 8.4, h: 0.7,
  fontSize: 40, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

// Left: FR-4
slide.addShape(pres.ShapeType.rect, {
  x: 0.8, y: 1.6, w: 4.0, h: 3.4,
  fill: { color: PALETTE.lightGray },
  line: { color: PALETTE.mutedGreen, width: 3 }
});

slide.addText("Habit Tracker", {
  x: 1.1, y: 1.9, w: 3.4, h: 0.4,
  fontSize: 20, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

slide.addText("habit_model.dart with linkedRole field\n\nhabit_controller.dart CRUD operations\n\nAnalytics integration calculates success rates\n\nBackend fully operational", {
  x: 1.1, y: 2.5, w: 3.4, h: 2.0,
  fontSize: 12, color: PALETTE.charcoal,
  fontFace: TYPE.body, lineSpacing: 1.6
});

// Right: FR-6
slide.addShape(pres.ShapeType.rect, {
  x: 5.2, y: 1.6, w: 4.0, h: 3.4,
  fill: { color: PALETTE.lightGray },
  line: { color: PALETTE.mutedGreen, width: 3 }
});

slide.addText("Analytics Dashboard", {
  x: 5.5, y: 1.9, w: 3.4, h: 0.4,
  fontSize: 20, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

slide.addText("Real-time fl_chart visualizations\n\nCalendar compliance rate tracking\n\nHabit success rate metrics\n\nWeekly trend analysis", {
  x: 5.5, y: 2.5, w: 3.4, h: 2.0,
  fontSize: 12, color: PALETTE.charcoal,
  fontFace: TYPE.body, lineSpacing: 1.6
});

// ============================================================
// SLIDE 9: FR-2 PARTIAL IMPLEMENTATION
// Honest gap analysis with visual clarity
// ============================================================
slide = pres.addSlide();
slide.background = { color: PALETTE.warmWhite };

slide.addText("FR-2: Calendar Sync", {
  x: 0.8, y: 0.6, w: 8.4, h: 0.7,
  fontSize: 44, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

slide.addShape(pres.ShapeType.rect, {
  x: 0.8, y: 1.4, w: 0.8, h: 0.04,
  fill: { color: PALETTE.mutedRed }
});

// Three-column analysis
const fr2cols = [
  { title: "What Works", content: "fetchUpcomingEvents() retrieves data\n\nGoogle Calendar OAuth integration\n\nEvent display in UI", x: 0.8, icon: "✓" },
  { title: "The Gap", content: "createEvent() / updateEvent() return success on 403/404\n\nWrite operations save locally but may not sync\n\nOnly read direction fully reliable", x: 3.6, icon: "⚠" },
  { title: "Impact", content: "Users can view calendar events\n\nTwo-way sync not guaranteed\n\nSRS AC2 requirement not met", x: 6.4, icon: "○" }
];

fr2cols.forEach(col => {
  slide.addText(col.icon, {
    x: col.x, y: 2.0, w: 0.4, h: 0.4,
    fontSize: 28, bold: true, color: PALETTE.mutedRed,
    fontFace: TYPE.display
  });

  slide.addText(col.title, {
    x: col.x + 0.5, y: 2.05, w: 2.0, h: 0.3,
    fontSize: 16, bold: true, color: PALETTE.charcoal,
    fontFace: TYPE.display
  });

  slide.addText(col.content, {
    x: col.x, y: 2.6, w: 2.5, h: 2.2,
    fontSize: 11, color: PALETTE.silver,
    fontFace: TYPE.body, lineSpacing: 1.5
  });
});

// ============================================================
// SLIDE 10: FR-3 + FR-5 PARTIAL IMPLEMENTATION
// Dual gap analysis
// ============================================================
slide = pres.addSlide();
slide.background = { color: PALETTE.warmWhite };

slide.addText("FR-3 + FR-5: Partial Implementation", {
  x: 0.8, y: 0.6, w: 8.4, h: 0.7,
  fontSize: 40, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

// Left: FR-3
slide.addShape(pres.ShapeType.rect, {
  x: 0.8, y: 1.6, w: 4.0, h: 3.4,
  fill: { color: "FFF9F5" },
  line: { color: PALETTE.mutedRed, width: 3 }
});

slide.addText("FR-3: Proactive Preparation", {
  x: 1.1, y: 1.9, w: 3.4, h: 0.35,
  fontSize: 17, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

slide.addText("✓ Works", {
  x: 1.1, y: 2.4, w: 3.4, h: 0.25,
  fontSize: 12, bold: true, color: PALETTE.mutedGreen,
  fontFace: TYPE.body
});
slide.addText("runProactiveScan() analyzes events\nRole-based AI reasoning\nContext snapshot and evidence linking", {
  x: 1.1, y: 2.7, w: 3.4, h: 0.7,
  fontSize: 10, color: PALETTE.charcoal,
  fontFace: TYPE.body, lineSpacing: 1.4
});

slide.addText("⚠ Gap", {
  x: 1.1, y: 3.5, w: 3.4, h: 0.25,
  fontSize: 12, bold: true, color: PALETTE.mutedRed,
  fontFace: TYPE.body
});
slide.addText("Manual trigger only\nNo Cloud Functions or cron jobs\nNFR-6 requirement not met", {
  x: 1.1, y: 3.8, w: 3.4, h: 0.7,
  fontSize: 10, color: PALETTE.charcoal,
  fontFace: TYPE.body, lineSpacing: 1.4
});

// Right: FR-5
slide.addShape(pres.ShapeType.rect, {
  x: 5.2, y: 1.6, w: 4.0, h: 3.4,
  fill: { color: "FFF9F5" },
  line: { color: PALETTE.mutedRed, width: 3 }
});

slide.addText("FR-5: Notifications", {
  x: 5.5, y: 1.9, w: 3.4, h: 0.35,
  fontSize: 17, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

slide.addText("✓ Works", {
  x: 5.5, y: 2.4, w: 3.4, h: 0.25,
  fontSize: 12, bold: true, color: PALETTE.mutedGreen,
  fontFace: TYPE.body
});
slide.addText("AI generates 120-char notifications\n9 fallback templates\nTest button validates generation", {
  x: 5.5, y: 2.7, w: 3.4, h: 0.7,
  fontSize: 10, color: PALETTE.charcoal,
  fontFace: TYPE.body, lineSpacing: 1.4
});

slide.addText("⚠ Gap", {
  x: 5.5, y: 3.5, w: 3.4, h: 0.25,
  fontSize: 12, bold: true, color: PALETTE.mutedRed,
  fontFace: TYPE.body
});
slide.addText("No scheduleNotification() method\nManual trigger only\nNo background notification system", {
  x: 5.5, y: 3.8, w: 3.4, h: 0.7,
  fontSize: 10, color: PALETTE.charcoal,
  fontFace: TYPE.body, lineSpacing: 1.4
});

// ============================================================
// SLIDE 11: TECHNICAL STACK
// Clean, organized technology overview
// ============================================================
slide = pres.addSlide();
slide.background = { color: PALETTE.warmWhite };

slide.addText("Technical Stack", {
  x: 0.8, y: 0.6, w: 8.4, h: 0.7,
  fontSize: 48, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

const techStack = [
  { title: "Core", tech: "Flutter 3.24.5 (Web) • Dart 3.5.4\nClean Architecture • Responsive design", x: 0.8, y: 1.8 },
  { title: "Backend", tech: "Firebase (Auth, Firestore, Storage)\nSupabase Edge Function • Google Calendar API v3", x: 5.1, y: 1.8 },
  { title: "AI", tech: "Groq API (llama-3.3-70b-versatile)\nFirebase token verification • Offline fallback", x: 0.8, y: 3.4 },
  { title: "Deployment", tech: "Firebase Hosting • yhar-bid.web.app\nCI/CD via Firebase CLI", x: 5.1, y: 3.4 }
];

techStack.forEach(tech => {
  slide.addText(tech.title, {
    x: tech.x, y: tech.y, w: 3.8, h: 0.35,
    fontSize: 18, bold: true, color: PALETTE.graphite,
    fontFace: TYPE.display
  });

  slide.addShape(pres.ShapeType.rect, {
    x: tech.x, y: tech.y + 0.4, w: 3.8, h: 0.02,
    fill: { color: PALETTE.gold }
  });

  slide.addText(tech.tech, {
    x: tech.x, y: tech.y + 0.55, w: 3.8, h: 0.8,
    fontSize: 12, color: PALETTE.charcoal,
    fontFace: TYPE.body, lineSpacing: 1.5
  });
});

// ============================================================
// SLIDE 12: TESTING & VALIDATION
// Credible testing overview
// ============================================================
slide = pres.addSlide();
slide.background = { color: PALETTE.warmWhite };

slide.addText("Testing & Validation", {
  x: 0.8, y: 0.6, w: 8.4, h: 0.7,
  fontSize: 48, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

// Three columns
slide.addShape(pres.ShapeType.rect, {
  x: 0.8, y: 1.8, w: 2.6, h: 3.2,
  fill: { color: "F0FFF4" },
  line: { color: PALETTE.mutedGreen, width: 2 }
});
slide.addText("Automated Tests", {
  x: 1.0, y: 2.0, w: 2.2, h: 0.3,
  fontSize: 15, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});
slide.addText("27 passing tests across 8 suites:\n\nphase_1_3_runtime_validation.dart (10/10)\nrole_reasoning_test.dart\ngroq_api_test.dart\nai_service_json_parsing_test.dart\nnotification_service_test.dart\nhabit_model_test.dart\nanalytics_controller_test.dart\ncalendar_service_test.dart", {
  x: 1.0, y: 2.4, w: 2.2, h: 2.4,
  fontSize: 9, color: PALETTE.charcoal,
  fontFace: TYPE.body, lineSpacing: 1.5
});

slide.addShape(pres.ShapeType.rect, {
  x: 3.7, y: 1.8, w: 2.6, h: 3.2,
  fill: { color: "F0FFF4" },
  line: { color: PALETTE.mutedGreen, width: 2 }
});
slide.addText("Verified Features", {
  x: 3.9, y: 2.0, w: 2.2, h: 0.3,
  fontSize: 15, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});
slide.addText("✓ Role-based context interpretation\n\n✓ AI proposal structure + parsing\n\n✓ Calendar event → task workflow\n\n✓ Analytics calculations\n\n✓ Notification field presence\n\n✓ Fallback system (NFR-7)", {
  x: 3.9, y: 2.4, w: 2.2, h: 2.4,
  fontSize: 10, color: PALETTE.charcoal,
  fontFace: TYPE.body, lineSpacing: 1.5
});

slide.addShape(pres.ShapeType.rect, {
  x: 6.6, y: 1.8, w: 2.6, h: 3.2,
  fill: { color: "F0FFF4" },
  line: { color: PALETTE.mutedGreen, width: 2 }
});
slide.addText("Manual Validation", {
  x: 6.8, y: 2.0, w: 2.2, h: 0.3,
  fontSize: 15, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});
slide.addText("• Google Calendar OAuth flow\n\n• UI interactions + navigation\n\n• Firestore persistence\n\n• Cross-browser compatibility\n\n• Real-world calendar sync behavior", {
  x: 6.8, y: 2.4, w: 2.2, h: 2.4,
  fontSize: 10, color: PALETTE.charcoal,
  fontFace: TYPE.body, lineSpacing: 1.5
});

// ============================================================
// SLIDE 13: LIMITATIONS & FUTURE WORK
// Honest assessment with clear next steps
// ============================================================
slide = pres.addSlide();
slide.background = { color: PALETTE.warmWhite };

slide.addText("Limitations & Future Work", {
  x: 0.8, y: 0.6, w: 8.4, h: 0.7,
  fontSize: 44, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

const limitations = [
  { title: "Calendar Sync", items: "• Implement reliable two-way sync\n• Distinguish read-only calendars\n• Add retry logic for failures", x: 0.8, y: 1.8 },
  { title: "Background Automation", items: "• Deploy Cloud Functions\n• Implement cron/PubSub triggers\n• Add notification scheduling\n• Meet NFR-6 requirement", x: 5.1, y: 1.8 },
  { title: "Test Coverage", items: "• Integration tests for FR-1 flow\n• Automated tests for FR-2 sync\n• End-to-end workflow tests", x: 0.8, y: 3.6 },
  { title: "Documentation", items: "• Generate missing diagrams\n• Verify security rules\n• Accessibility testing", x: 5.1, y: 3.6 }
];

limitations.forEach(lim => {
  slide.addText(lim.title, {
    x: lim.x, y: lim.y, w: 3.8, h: 0.35,
    fontSize: 17, bold: true, color: PALETTE.graphite,
    fontFace: TYPE.display
  });

  slide.addShape(pres.ShapeType.rect, {
    x: lim.x, y: lim.y + 0.4, w: 3.8, h: 0.02,
    fill: { color: PALETTE.mutedRed }
  });

  slide.addText(lim.items, {
    x: lim.x, y: lim.y + 0.55, w: 3.8, h: 1.0,
    fontSize: 11, color: PALETTE.charcoal,
    fontFace: TYPE.body, lineSpacing: 1.5
  });
});

// ============================================================
// SLIDE 14: GOLDEN THREAD
// Visual journey from problem to validation
// ============================================================
slide = pres.addSlide();
slide.background = { color: PALETTE.warmWhite };

slide.addText("Golden Thread", {
  x: 0.8, y: 0.6, w: 8.4, h: 0.7,
  fontSize: 48, bold: true, color: PALETTE.graphite,
  fontFace: TYPE.display
});

const thread = [
  { num: "1", title: "Problem", text: "Context overload, generic solutions, manual burden across multiple systems", x: 0.8 },
  { num: "2", title: "Requirements", text: "6 functional requirements covering onboarding, calendar, preparation, habits, notifications, analytics", x: 3.1 },
  { num: "3", title: "Design & Implementation", text: "Clean Architecture Flutter Web with Firebase backend and Groq AI integration", x: 5.4 },
  { num: "4", title: "Validation", text: "27 automated tests with honest assessment: 3 implemented, 3 partial with documented gaps", x: 7.7 }
];

thread.forEach((item, idx) => {
  // Connection line
  if (idx < thread.length - 1) {
    slide.addShape(pres.ShapeType.rect, {
      x: item.x + 1.8, y: 2.45, w: 1.0, h: 0.02,
      fill: { color: PALETTE.gold }
    });
  }

  // Number circle
  slide.addShape(pres.ShapeType.ellipse, {
    x: item.x + 0.6, y: 2.1, w: 0.7, h: 0.7,
    fill: { color: PALETTE.gold }
  });
  slide.addText(item.num, {
    x: item.x + 0.6, y: 2.1, w: 0.7, h: 0.7,
    fontSize: 26, bold: true, color: PALETTE.graphite,
    align: "center", valign: "middle", fontFace: TYPE.display
  });

  slide.addText(item.title, {
    x: item.x, y: 3.0, w: 2.0, h: 0.3,
    fontSize: 13, bold: true, color: PALETTE.charcoal,
    fontFace: TYPE.display, align: "center"
  });

  slide.addText(item.text, {
    x: item.x, y: 3.4, w: 2.0, h: 1.2,
    fontSize: 10, color: PALETTE.silver,
    fontFace: TYPE.body, lineSpacing: 1.4, align: "center"
  });
});

// ============================================================
// SLIDE 15: CLOSING
// Strong, honest conclusion
// ============================================================
slide = pres.addSlide();
slide.background = { color: PALETTE.graphite };

slide.addText("Yhar Bid", {
  x: 0.8, y: 1.8, w: 8.4, h: 1.0,
  fontSize: 72, bold: true, color: PALETTE.warmWhite, align: "center",
  fontFace: TYPE.display
});

// Accent line
slide.addShape(pres.ShapeType.rect, {
  x: 3.5, y: 3.0, w: 3.0, h: 0.03,
  fill: { color: PALETTE.gold }
});

slide.addText("3 of 6 requirements\nfully implemented", {
  x: 1.0, y: 3.4, w: 8.0, h: 0.7,
  fontSize: 24, bold: true, color: PALETTE.warmWhite, align: "center",
  fontFace: TYPE.body, lineSpacing: 1.4
});

slide.addText("3 requirements partially implemented\nwith working features", {
  x: 1.0, y: 4.2, w: 8.0, h: 0.6,
  fontSize: 20, color: PALETTE.silver, align: "center",
  fontFace: TYPE.body, lineSpacing: 1.4
});

slide.addText("A foundation for adaptive, role-aware assistance\nwith clear next steps for completion", {
  x: 1.5, y: 5.0, w: 7.0, h: 0.5,
  fontSize: 15, color: PALETTE.silver, align: "center",
  fontFace: TYPE.body, lineSpacing: 1.5, italic: true
});

// ============================================================
// SAVE PRESENTATION
// ============================================================
pres.writeFile({ fileName: 'demo-slides.pptx' });
console.log('✅ Premium presentation generated: demo-slides.pptx');
console.log('   Distinctive visual identity with warm gold accent');
console.log('   Editorial typography and varied compositions');
console.log('   All 15 slides with correct FR statuses');
