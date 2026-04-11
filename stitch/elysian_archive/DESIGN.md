```markdown
# Design System Strategy: The Digital Heirloom

## 1. Overview & Creative North Star
**Creative North Star: "The Curated Memory"**
This design system moves away from the frantic, high-velocity nature of traditional social media. Instead, it adopts an editorial, "High-End Gallery" approach. The interface should feel like a premium physical journal or a curated exhibition. We achieve this through **Intentional Asymmetry** (offsetting text and imagery to create breathing room), **High-Contrast Typography Scales** (pairing dramatic display serifs with functional sans-serifs), and **Tonal Depth** that rejects the flat, "template" look of modern SaaS.

The goal is to create an environment that feels intimate and safe. Every interaction should feel deliberate, replacing "infinite scroll" anxiety with "moment-to-moment" reflection.

---

## 2. Colors & Surface Architecture
The palette is rooted in warmth. We avoid the "sterile white" of corporate tech, opting instead for a cream-based foundation that mimics fine stationery.

### The "No-Line" Rule
**Explicit Instruction:** 1px solid borders are strictly prohibited for sectioning or containment. Boundaries must be defined solely through background color shifts or subtle tonal transitions. A section is "divided" by moving from `surface` to `surface-container-low`, never by a line.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers—like stacked sheets of fine cotton paper.
- **Base Layer:** `surface` (#faf9f6) - The vast "tabletop" of the application.
- **Sectioning:** `surface-container-low` (#f4f3f1) - Use for large structural blocks.
- **Interactive Elements:** `surface-container-lowest` (#ffffff) - Use for cards and high-priority inputs to create a "lifted" feel against the cream background.

### The "Glass & Gradient" Rule
To elevate the experience, use **Glassmorphism** for floating headers or navigation bars. Use `surface` at 80% opacity with a `20px` backdrop-blur. 
**Signature CTA:** For primary actions, apply a subtle linear gradient from `primary` (#884532) to `primary_container` (#a65d48) at a 135-degree angle. This adds "soul" and a tactile, three-dimensional quality that flat hex codes lack.

---

## 3. Typography: The Editorial Voice
The system uses a high-contrast pairing to balance heritage and modernity.

- **The Serif (Newsreader):** Used for `display` and `headline` roles. This provides the "editorial" weight. It should feel authoritative yet warm. Use it for memory titles, dates, and reflective prompts.
- **The Sans (Manrope):** Used for `title`, `body`, and `label`. This is the functional engine. It ensures high readability for long-form captions and interface utility.

**Scale Strategy:**
- **Display-LG (3.5rem):** Use for "Hero" moments, like the start of a new month or a featured memory.
- **Body-MD (0.875rem):** The standard for user-generated content. Increase line-height to `1.6` to ensure the text feels "airy" and premium.

---

## 4. Elevation & Depth: Tonal Layering
Traditional shadows are often "dirty." We achieve depth through light and tone.

- **The Layering Principle:** Place a `surface-container-lowest` card on a `surface-container` background. The slight shift in brightness creates a soft, natural lift without visual noise.
- **Ambient Shadows:** When a floating state is required (e.g., a modal), use an ultra-diffused shadow: `box-shadow: 0 20px 40px rgba(134, 115, 110, 0.06)`. Note the use of `outline` (#86736e) as the shadow tint rather than black; this keeps the shadows "warm" and integrated.
- **The "Ghost Border" Fallback:** If accessibility demands a container edge, use `outline-variant` (#d9c1bb) at 15% opacity. It should be felt, not seen.

---

## 5. Components & Primitive Logic

### Buttons (The "Soft Pebble" Form)
- **Primary:** Gradient fill (`primary` to `primary_container`), white text, `md` (1.5rem) corner radius. Use generous horizontal padding (24px).
- **Secondary:** `surface-container-high` fill with `on-surface` text. No border.
- **Tertiary:** Text-only in `primary` weight, with a subtle underline appearing only on hover.

### Cards & Lists (The Memory Grid)
- **Rule:** Forbid divider lines.
- **Spacing:** Use a strict 32px or 48px vertical gap to separate items. 
- **Shape:** Use `lg` (2rem) corner radii for image-heavy cards to emphasize the "soft" brand personality.
- **Interaction:** On hover, a card should transition its background from `surface-container-lowest` to `surface-bright`.

### Input Fields
- **Style:** Minimalist. No bounding box. Use a `surface-container-highest` bottom bar (2px) that transforms into `primary` on focus.
- **Labels:** Always use `label-md` in `on-surface-variant`.

### Contextual Components: "The Memory Vault"
- **The Date-Chip:** A floating `tertiary_fixed` (#d2e7dc) pill using `label-md` for timestamping memories. It should feel like a vintage library tag.
- **The Reflection Slider:** A custom input for mood-tracking, using a `surface-variant` track and a `primary` thumb with an ambient shadow.

---

## 6. Do’s & Don’ts

### Do:
- **Use White Space as a Luxury:** Treat empty space as an intentional design choice, not a "gap" to be filled.
- **Asymmetric Layouts:** Place a headline on the left and the body text slightly offset to the right to break the "Bootstrap" feel.
- **Thin-Stroke Icons:** Use 1px or 1.5px stroke widths. Ensure they are "open" icons (no fills) to maintain the lightweight vibe.

### Don’t:
- **No Pure Blacks:** Never use #000000. Even for dark mode, use `on-surface` (#1a1c1a) to keep the tone soft.
- **No Hard Corners:** Avoid `none` or `sm` roundedness. It contradicts the "Intimate" brand pillar.
- **No Vibrant System Colors:** Avoid standard "Success Green" or "Alert Red." Use the `tertiary` (#4a5c54) for success and `error` (#ba1a1a) diluted with 50% opacity for a softer warning.

### A Final Note for Designers
This system is not a cage; it is a canvas. When in doubt, ask: *"Does this feel like a mass-market social app, or does it feel like a private, expensive journal?"* If the former, add more padding, soften the colors, and remove the lines.```