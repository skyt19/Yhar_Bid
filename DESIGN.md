---
name: Yharbid
description: Warm, neutral productivity tool with restrained green accent
colors:
  background-light: "#F5F5F5"
  surface-white: "#FFFFFF"
  surface-gray: "#F0F0F0"
  text-primary: "#1A1A1A"
  text-secondary: "#757575"
  text-tertiary: "#9E9E9E"
  accent-green: "#4CAF50"
  accent-green-dark: "#2E7D32"
  accent-orange: "#FF9800"
  accent-red: "#F44336"
  divider: "#E0E0E0"
  border: "#E0E0E0"
  border-strong: "#BDBDBD"
  nav-background: "#757575"
typography:
  display-large:
    fontFamily: "Noto Sans Thai, -apple-system, sans-serif"
    fontSize: "32px"
    fontWeight: 700
    lineHeight: 1.2
  display-medium:
    fontFamily: "Noto Sans Thai, -apple-system, sans-serif"
    fontSize: "24px"
    fontWeight: 700
    lineHeight: 1.25
  title-large:
    fontFamily: "Noto Sans Thai, -apple-system, sans-serif"
    fontSize: "20px"
    fontWeight: 700
    lineHeight: 1.3
  title-medium:
    fontFamily: "Noto Sans Thai, -apple-system, sans-serif"
    fontSize: "16px"
    fontWeight: 600
    lineHeight: 1.4
  body-large:
    fontFamily: "Noto Sans Thai, -apple-system, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.5
  body-medium:
    fontFamily: "Noto Sans Thai, -apple-system, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Noto Sans Thai, -apple-system, sans-serif"
    fontSize: "12px"
    fontWeight: 600
    letterSpacing: "0.2px"
rounded:
  xs: "6px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "20px"
  pill: "30px"
spacing:
  xs: "2px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
  xxl: "48px"
components:
  button-primary:
    backgroundColor: "{colors.accent-green}"
    textColor: "#FFFFFF"
    rounded: "{rounded.sm}"
    padding: "12px 20px"
  button-pill:
    backgroundColor: "{colors.surface-white}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.pill}"
    padding: "16px 32px"
  card:
    backgroundColor: "{colors.surface-white}"
    rounded: "{rounded.lg}"
    padding: "16px"
  input:
    backgroundColor: "{colors.surface-white}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.md}"
    padding: "12px 16px"
  nav-button:
    backgroundColor: "{colors.surface-white}"
    size: "56px"
---

# Design System: Yharbid

## Overview

**Creative North Star: "The Warm Gray Workshop"**

Yharbid presents as a calm, neutral workspace built around warm grays and white surfaces, with green used sparingly as the sole accent color. The system prioritizes scanability and focus for productivity contexts (students, employees, educators managing calendars and tasks). Density is medium—not cramped, not spacious—optimized for information-rich screens without visual fatigue. The aesthetic is restrained and functional, avoiding decorative flourishes in favor of clear hierarchy and consistent patterns.

Blue is explicitly banned from the palette. Status indicators, information callouts, and all accent uses draw from green, orange, red, or gray. The design accommodates Thai language typography as a first-class citizen alongside English, using Noto Sans Thai as the universal typeface.

**Key Characteristics:**
- Warm neutral foundation (#F5F5F5 background, white surfaces)
- Single accent strategy: green only, used sparingly
- Medium density with generous card padding
- Bilingual Thai/English support via Noto Sans Thai
- Circular navigation buttons with subtle shadow states

## Colors

The palette centers on warm neutrals with a restrained green accent. No blue tones appear anywhere in the system.

### Primary
- **Meadow Green** (#4CAF50): Primary action color for buttons, active states, and affirmative feedback. Used on ~5-10% of any screen—its scarcity is intentional. Never used for informational text or large background areas.
- **Deep Forest Green** (#2E7D32): Pressed and selected states, darker variant of primary accent.

### Secondary
- **Warm Orange** (#FF9800): Warning states, pending actions, and moderate-priority alerts. Complements green without introducing cool tones.

### Tertiary
- **Alert Red** (#F44336): Danger actions (delete, cancel with consequence), error states, overdue indicators.

### Neutral
- **Warm Light Gray** (#F5F5F5): Default scaffold background. Creates soft contrast with white cards without harshness.
- **Pure White** (#FFFFFF): Card surfaces, input backgrounds, navigation buttons.
- **Whisper Gray** (#F0F0F0): Secondary surfaces, subtle background differentiation.
- **Charcoal** (#1A1A1A): Primary text, high-contrast readable content.
- **Mid Gray** (#757575): Secondary text, labels, bottom navigation background.
- **Soft Gray** (#9E9E9E): Tertiary text, placeholders, disabled states, secondary actions.
- **Divider Gray** (#E0E0E0): Borders, dividers, subtle separators.
- **Border Gray** (#BDBDBD): Strong borders for outlined elements.

### Named Rules
**The No Blue Rule.** Blue tones are prohibited throughout the system. Information, status, and all accent uses draw from green, orange, red, or gray. This brand constraint overrides Material Design defaults.

**The Sparing Accent Rule.** The green accent appears on ≤10% of any screen's surface area. Buttons, active icons, and selected states only—not backgrounds, not large containers.

## Typography

**Display Font:** Noto Sans Thai (with -apple-system, BlinkMacSystemFont, sans-serif fallback)  
**Body Font:** Noto Sans Thai (same family)  
**Label/Mono Font:** (same family, weight differentiation only)

**Character:** Noto Sans Thai provides comprehensive Thai language support with clean, legible Latin glyphs. The single-family strategy simplifies the stack while supporting bilingual UI. Weight variation (400/600/700) handles all hierarchy needs.

### Hierarchy
- **Display Large** (700, 32px, 1.2): Hero headlines on dashboard and major views. Rare; ≤1 per screen.
- **Display Medium** (700, 24px, 1.25): Section headlines, dialog titles.
- **Title Large** (700, 20px, 1.3): Card headers, prominent UI labels.
- **Title Medium** (600, 16px, 1.4): Subsection headers, emphasized labels.
- **Body Large** (400, 16px, 1.5): Primary body text, task descriptions, longer content. Max line length ~70ch where applicable.
- **Body Medium** (400, 14px, 1.5): Default UI text, list items, secondary content.
- **Label** (600, 12px, 0.2px letter-spacing): Uppercase micro-labels, form labels, captions requiring emphasis.

### Named Rules
**The Single Family Rule.** All text uses Noto Sans Thai. Hierarchy comes from size and weight variation, not family contrast.

## Layout

The layout follows a centered, max-width content model optimized for web and tablet. The scaffold background is warm gray (#F5F5F5); content containers are white cards with consistent 16px padding. Maximum content width is 900px on wide screens to maintain scanability—text lines never exceed comfortable reading length.

Spacing uses an 8px base rhythm (2px, 4px, 8px, 12px, 16px, 20px, 24px, 32px, 48px, 64px). Card margins and internal padding align to this scale. Breakpoints adapt for mobile (single column, full-width cards) and desktop (centered column with breathing room).

Bottom navigation is fixed at 80px height, dark gray (#757575), with circular white buttons (56px diameter) arranged with `spaceAround`. This five-button navigation is the primary wayfinding pattern, always visible.

Density is medium: not cramped (≥16px card padding), not spacious. Information-rich views (calendar, task lists) pack content efficiently without sacrificing clarity.

## Elevation & Depth

This system uses subtle shadows for layered surfaces, not flat/tonal design. Shadows are soft and ambient, creating gentle depth perception rather than strong material metaphors.

### Shadow Vocabulary
- **Card Shadow** (`0 2px 8px rgba(0,0,0,0.08)`): Standard white cards floating above gray background. Barely perceptible but provides separation.
- **Elevated Shadow** (`0 4px 16px rgba(0,0,0,0.12)`): Dialogs, bottom sheets, floating action buttons. Slightly stronger but still soft.
- **Subtle Shadow** (`0 1px 4px rgba(0,0,0,0.04)`): Navigation bar, sticky headers, minimal lift.

### Named Rules
**The Ambient Shadow Rule.** Shadows are diffuse and low-contrast (~4-12% black). No harsh drop shadows or high-offset effects. The goal is perceived depth, not dramatic elevation.

## Shapes

The form language favors soft, approachable corners with consistent radius values. Buttons and primary interactive elements use pill shapes (30px radius) for a friendly, accessible feel. Cards and containers use moderate rounding (12-16px) that reads as modern without being overly playful.

**Radius Scale:**
- **XS (6px):** Small chips, tight corners
- **Small (8px):** Standard buttons, inputs
- **Medium (12px):** Input fields, secondary containers
- **Large (16px):** Cards, major containers
- **XL (20px):** Large cards, hero containers
- **Pill (30px):** Pill buttons, circular button backgrounds
- **Circle (999px):** Navigation buttons, avatars

Borders, when used, are thin (1px) and low-contrast (#E0E0E0 or #BDBDBD for emphasis). The system generally prefers shadow-based separation over stroke-based separation.

## Components

### Buttons

- **Shape:** Rounded rectangle (8px radius for standard, 30px pill radius for prominent actions)
- **Primary:** Green background (#4CAF50), white text, 12px vertical / 20px horizontal padding. No elevation at rest; 0-2px subtle lift on hover.
- **Pill Variant:** White background, black text, 16px vertical / 32px horizontal padding, pill radius (30px), 2px elevation. Used for hero actions (Google Sign-In, major CTAs).
- **Secondary (Outlined):** White background, border (#BDBDBD), text-primary color, same padding as primary.
- **Ghost:** Transparent background, green text, same shape. Minimal visual weight.
- **Danger:** Red background (#F44336), white text. For destructive actions only.
- **Hover / Focus:** Subtle background darkening (5-10% opacity shift) and optional 2px upward translateY. Transitions at 180-200ms ease-out.

### Navigation

- **Style:** Fixed bottom bar (80px height), dark gray background (#757575).
- **Buttons:** Five circular white buttons (56px diameter) with centered icons (26px). Active state: green border (2.5px) + green icon color + subtle green glow shadow. Inactive: black icons, no border.
- **Special:** Second button (Calendar) uses a custom gradient-circle "G" icon representing Google Calendar (rainbow gradient: blue/red/yellow/green). This is the only use of blue in the system, confined to a recognizable third-party icon.
- **Mobile:** Same layout; buttons scale to fit narrow screens via spaceAround distribution.

### Cards / Containers

- **Corner Style:** 16px radius (large)
- **Background:** White (#FFFFFF)
- **Shadow Strategy:** Card shadow (0 2px 8px rgba(0,0,0,0.08))
- **Border:** None by default; relies on shadow for separation
- **Internal Padding:** 16px uniform

### Inputs / Fields

- **Style:** White fill, 1px border (#E0E0E0), 12px radius
- **Padding:** 12px vertical, 16px horizontal
- **Focus:** Border color shifts to green (#4CAF50), border width increases to 1.5px
- **Placeholder:** Tertiary text color (#9E9E9E)
- **Error:** Border shifts to red (#F44336), error message appears below in red text
- **Disabled:** Gray fill (#F0F0F0), tertiary text

### Chips / Tags

- **Style:** White background, 1px border (#BDBDBD), pill radius (30px)
- **Padding:** 6px vertical, 12px horizontal
- **Selected:** Green background (#4CAF50), white text
- **Unselected:** White background, text-primary color

### Dialogs

- **Container:** White background, 20px radius (XL), elevated shadow (0 4px 16px rgba(0,0,0,0.12))
- **Padding:** 24px
- **Actions:** Right-aligned button row with 8px spacing between buttons
- **Dismissal:** ESC key support, backdrop tap (optional per context)

## Do's and Don'ts

### Do:
- **Do** use warm gray (#F5F5F5) as the default scaffold background for all screens.
- **Do** limit green accent usage to ≤10% of screen surface area—buttons, active icons, and selected states only.
- **Do** maintain 16px minimum padding inside all cards and containers.
- **Do** use pill-radius buttons (30px) for prominent single-action CTAs.
- **Do** use Noto Sans Thai for all text to ensure Thai language support.
- **Do** apply card shadow (0 2px 8px rgba(0,0,0,0.08)) to white containers floating on gray backgrounds.
- **Do** use 1px borders in divider gray (#E0E0E0) for subtle separations; stronger borders (#BDBDBD) for outlined interactive elements.

### Don't:
- **Don't** introduce blue tones anywhere in the UI. Use green, orange, red, or gray for all accents, status indicators, and information design.
- **Don't** use green for large background areas or text passages. It's an accent, not a neutral.
- **Don't** exceed 900px content width on desktop layouts. Maintain the centered column for scanability.
- **Don't** use multiple font families. Noto Sans Thai covers both Latin and Thai scripts.
- **Don't** apply harsh shadows or high-offset drop shadows. Keep blur radius ≤16px and opacity ≤12%.
- **Don't** create custom radius values outside the documented scale (6px / 8px / 12px / 16px / 20px / 30px / 999px).
