# DoOne — Home + Settings bundle

Self-contained dump of every file needed to render the Home and Settings pages outside the main app.
Drop this whole file into Claude Designer and ask it to iterate on the UI.

## File map

```
index.html                         — google fonts + root mount
src/main.jsx                       — react entry
src/App.jsx                        — app shell, page switching, palette
src/index.css                      — full design system + glass primitive
src/lib/constants.js               — VIBE/SURFACE/DENSITY/FONTS presets
src/lib/supabaseClient.js          — data layer (stubbable)
src/lib/palette.js                 — extract dominant colors from wallpaper
src/ai-agent/tools.js              — check_conflicts (used by EventFormModal)
src/pages/HomePage.jsx             — Home tab
src/pages/SettingsPage.jsx         — Settings tab
src/components/MiniCalendar.jsx    — mini month grid (Home)
src/components/EventFormModal.jsx  — quick-add event modal (Home)
src/components/AlgorithmicOrnament.jsx — generative SVG flourishes
src/components/VibeIcon.jsx        — Settings vibe icons
src/components/LowPolyWallpaper.jsx — Settings wallpaper preview
src/assets/wallpaper.png           — background image (binary, not in this file)
```

## Mock data (for stubbing App.jsx props)

```js
const events = [
  { id: '1', title: 'work', start: '2026-05-11T11:00', end: '2026-05-11T12:00', allDay: false, tag: 'ev-tag1' },
  { id: '2', title: 'lunch w/ sam', start: '2026-05-11T13:30', end: '2026-05-11T14:30', allDay: false, tag: 'ev-tag2' },
  { id: '3', title: 'gym', start: '2026-05-11T18:00', end: '2026-05-11T19:00', allDay: false, tag: 'ev-tag3' },
]
const tasks = [
  { id: 't1', title: 'finish PR review', done: false },
  { id: 't2', title: 'reply to client', done: true },
  { id: 't3', title: 'pick up groceries', done: false },
]
```

---

## `index.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>DoOne</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:wght@300;400;500;600;700&family=Caveat:wght@400;600&family=Crimson+Pro:ital,wght@0,400;0,600;0,700;1,400&family=DM+Sans:wght@300;400;500;600&family=Fraunces:opsz,wght@9..144,400;9..144,500;9..144,600&family=IBM+Plex+Mono:wght@400;500;600&family=IBM+Plex+Sans:wght@300;400;500;600&family=Inconsolata:wght@400;500;600;700&family=Instrument+Sans:wght@300;400;500;600&family=Instrument+Serif:ital@0;1&family=JetBrains+Mono:wght@400;500;600&family=Lora:wght@400;500;600;700&family=Manrope:wght@300;400;500;600;700&family=Outfit:wght@300;400;500;600;700&family=Playfair+Display:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&family=Quicksand:wght@300;400;500;600;700&family=Space+Grotesk:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&family=Syne:wght@400;500;600;700&display=swap" rel="stylesheet">
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
```

## `src/index.css`

```css
/* ═══════════════════════════════════════════════════
   DoOne — design system
   glassmorphism + adaptive palette via CSS vars
   ═══════════════════════════════════════════════════ */

:root {
  --ink: hsl(220, 30%, 16%);
  --ink-soft: hsl(220, 20%, 32%);
  --ink-muted: hsl(220, 15%, 48%);
  --surface-1: rgba(255,255,255,0.55);
  --surface-2: rgba(255,255,255,0.40);
  --surface-3: rgba(255,255,255,0.30);
  --stroke: rgba(40,40,60,0.14);
  --stroke-strong: rgba(40,40,60,0.22);
  --accent: hsl(340, 60%, 60%);
  --accent-soft: hsl(340, 40%, 88%);
  --tag-1: hsl(340, 55%, 80%);
  --tag-2: hsl(40,  55%, 80%);
  --tag-3: hsl(170, 50%, 78%);
  --tag-4: hsl(260, 50%, 82%);
  --hue: 340;
  --blur: 22px;
  --accent-boost: 1;
  --surface-alpha-mult: 1;
  --font: "Manrope", system-ui, sans-serif;
  --font-accent: "Caveat", serif;
  --rad: 18px;
  --rad-sm: 12px;
  --rad-lg: 26px;
  --panel-gap: 16px;
  --panel-pad: 18px;
  --type-scale: 1;
  --vibe-sat-mult: 0.85;
  --vibe-glow-alpha: 0.10;
  --vibe-glow-blur: 80px;
  --vibe-veil-alpha: 0.18;
  --stroke-mult: 1;
  --shadow-mult: 1;
  --panel-tint: 0;
}

/* Vibe glow */
.vibe-glow {
  position: absolute; inset: 0; z-index: -1;
  pointer-events: none;
  background:
    radial-gradient(circle at 12% 18%, hsla(var(--hue), 70%, 65%, var(--vibe-glow-alpha)) 0%, transparent 45%),
    radial-gradient(circle at 88% 82%, hsla(calc(var(--hue) + 50), 70%, 60%, calc(var(--vibe-glow-alpha) * 0.85)) 0%, transparent 45%);
  filter: blur(var(--vibe-glow-blur));
  transition: opacity .4s, filter .4s;
}
.vibe-mono .vibe-glow { display: none; }
.vibe-mono { filter: saturate(calc(var(--vibe-sat-mult))); }
.vibe-luminous .wallpaper { filter: brightness(1.08) saturate(1.1); }
.vibe-vivid .wallpaper { filter: saturate(1.15) contrast(1.05); }

/* Type scale */
.page-title { font-size: calc(36px * var(--type-scale)); }
.hero-title  { font-size: calc(38px * var(--type-scale)); }
.panel { padding: var(--panel-pad); }

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html, body, #root { height: 100%; }
html { background: #1a1a1a; }
body {
  font-family: var(--font);
  color: var(--ink);
  background: transparent;
  overflow: hidden;
  -webkit-font-smoothing: antialiased;
  text-rendering: optimizeLegibility;
}
button, input, textarea, select { font: inherit; color: inherit; }
button { cursor: pointer; border: 0; background: transparent; }

/* ─── WALLPAPER ──────────────────────────────────────────── */
.wallpaper {
  position: absolute; inset: 0; z-index: -2;
  background-size: cover; background-position: center;
}
.wallpaper-veil {
  position: absolute; inset: 0; z-index: -1;
  background:
    radial-gradient(ellipse at 20% 0%, hsla(var(--hue), 50%, 50%, 0.10) 0%, transparent 55%),
    radial-gradient(ellipse at 90% 100%, hsla(var(--hue), 40%, 30%, 0.15) 0%, transparent 50%),
    linear-gradient(180deg, hsla(var(--hue), 20%, 8%, 0.0) 0%, hsla(var(--hue), 20%, 8%, var(--vibe-veil-alpha)) 100%);
  pointer-events: none;
  transition: opacity .4s;
}

/* ─── APP SHELL ──────────────────────────────────────────── */
.app {
  position: relative;
  isolation: isolate;
  height: 100vh; width: 100vw;
  display: grid;
  grid-template-columns: auto 1fr;
  overflow: hidden;
  align-items: center;
}
.app.is-mobile { grid-template-columns: 1fr; }
.app-main {
  overflow: hidden; padding: 22px 24px 24px;
  height: 100vh; display: flex; flex-direction: column;
  align-self: stretch;
}
.app-main:has(.journal-page),
.app-main:has(.settings-page) { overflow-y: auto; }
.app.is-mobile .app-main { padding: 18px 16px 110px; overflow-y: auto; height: 100vh; display: block; }
.app-main::-webkit-scrollbar { width: 8px; }
.app-main::-webkit-scrollbar-thumb { background: var(--stroke); border-radius: 4px; }

/* ─── GLASS PRIMITIVE ────────────────────────────────────── */
.glass {
  position: relative;
  isolation: isolate;
  overflow: hidden;
  background:
    linear-gradient(135deg,
      hsla(var(--hue), 60%, 60%, calc(var(--panel-tint) * 0.6)),
      hsla(calc(var(--hue) + 40), 60%, 60%, var(--panel-tint))),
    color-mix(in srgb, var(--surface-1) calc(var(--surface-alpha-mult) * 100%), transparent);
  border: 1px solid color-mix(in srgb, var(--stroke) calc(var(--stroke-mult) * 100%), transparent);
  border-radius: var(--rad);
  box-shadow:
    0 1px 0 0 rgba(255,255,255,calc(0.18 * var(--shadow-mult))) inset,
    0 16px 40px -16px rgba(0,0,0,calc(0.25 * var(--shadow-mult))),
    0 2px 8px -2px rgba(0,0,0,calc(0.08 * var(--shadow-mult)));
  transition: background .35s, border-radius .35s, padding .35s;
}
/* Pseudo-element holds a viewport-aligned blurred copy of the wallpaper.
   background-attachment: fixed keeps the bg locked to the viewport, so each
   card's pseudo-element shows the correct slice of wallpaper for its position.
   Using filter (not backdrop-filter) avoids Chrome's compositor quirks that
   broke blur after page navigation. */
.glass::before {
  content: "";
  position: absolute;
  inset: calc(var(--blur) * -2);
  z-index: -1;
  background-image: var(--wallpaper-url, none);
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
  filter: blur(var(--blur)) saturate(calc(140% * var(--vibe-sat-mult)));
  pointer-events: none;
}
.surface-solid .glass { background: var(--surface-1); }
.surface-solid .glass::before { display: none; }

/* ─── NAV RAIL ───────────────────────────────────────────── */
.nav-rail {
  margin: 0 0 0 18px;
  height: fit-content;
  width: 76px;
  border-radius: 28px;
  display: flex; flex-direction: column;
  align-items: center; padding: 22px 0;
  gap: 10px;
  z-index: 60;
}
.nav-brand {
  width: 36px; height: 36px;
  border-radius: 12px;
  background: linear-gradient(135deg, var(--accent), color-mix(in srgb, var(--accent) 60%, white));
  color: white; font-weight: 700; font-size: 18px;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 8px 20px -6px color-mix(in srgb, var(--accent) 60%, transparent);
}
.nav-divider { width: 24px; height: 1px; background: var(--stroke-strong); margin: 4px 0 6px; }
.nav-items { display: flex; flex-direction: column; gap: 6px; }
.nav-item {
  position: relative;
  width: 52px; height: 52px;
  border-radius: 16px;
  display: flex; align-items: center; justify-content: center;
  color: var(--ink-soft);
  transition: all .2s ease;
}
.nav-item:hover { background: var(--surface-3); color: var(--ink); }
.nav-item.is-active,
.nav-item.is-active:hover {
  background: var(--ink);
  color: #fff;
}
.nav-item.is-active svg { color: #fff; stroke: #fff; }
.dock-item.is-active,
.dock-item.is-active .dock-icon,
.dock-item.is-active svg { color: #fff; stroke: #fff; }
.nav-tip {
  position: absolute; left: 62px; top: 50%; transform: translateY(-50%);
  background: var(--ink); color: color-mix(in srgb, var(--surface-1) 95%, white);
  padding: 5px 12px;
  border-radius: 8px; font-size: 12px; font-weight: 500; white-space: nowrap;
  opacity: 0; pointer-events: none; transition: opacity .15s;
  z-index: 100;
  box-shadow: 0 6px 16px -4px rgba(0,0,0,0.35);
}
.nav-item:hover .nav-tip { opacity: 0.96; }

/* ─── MOBILE DOCK ────────────────────────────────────────── */
.mobile-dock {
  position: fixed; left: 50%; transform: translateX(-50%);
  bottom: 18px; z-index: 50;
  display: flex; gap: 4px; padding: 8px;
  border-radius: 999px;
  min-width: 280px;
}
.dock-item {
  flex: 1; min-width: 60px;
  display: flex; flex-direction: column; align-items: center;
  gap: 2px; padding: 7px 10px;
  border-radius: 999px;
  color: var(--ink-soft);
  transition: all .2s;
}
.dock-item.is-active { background: var(--ink); color: var(--surface-1); }
.dock-item.is-active .dock-icon { color: white; }
.dock-label { font-size: 10px; letter-spacing: 0.2px; }

/* ─── PAGE HEADER ────────────────────────────────────────── */
.page { display: flex; flex-direction: column; gap: 20px; min-height: 100%; }
.page-header {
  display: flex; align-items: flex-end; justify-content: space-between; gap: 16px;
  flex-wrap: wrap; margin-bottom: 4px;
}
.eyebrow {
  font-size: 20px; text-transform: capitalize; letter-spacing: 0.02em;
  color: var(--ink-soft); font-weight: 700; margin-bottom: 8px;
}
.page-title {
  font-size: 36px; font-weight: 600; letter-spacing: -0.02em; line-height: 1.05;
  color: var(--ink);
}
.app.is-mobile .page-title { font-size: 28px; }
.page-sub { font-size: 16px; color: var(--ink-soft); font-weight: 500; margin-top: 6px; }

/* page-header pill treatment — applied to every top-of-page header
   so titles + eyebrows + sublabels read clearly on busy wallpapers. */
.page-header .eyebrow,
.page-header .page-sub,
.page-header .page-title {
  display: inline-block;
  background: color-mix(in srgb, var(--surface-1) 78%, transparent);
  border: 1px solid color-mix(in srgb, var(--stroke) 90%, transparent);
  color: var(--ink);
  border-radius: 999px;
  box-shadow: 0 2px 10px -4px rgba(0,0,0,0.22);
  width: fit-content;
}
.page-header .eyebrow {
  font-size: 13px; font-weight: 600;
  padding: 4px 12px;
  margin-bottom: 10px;
}
.page-header .page-sub {
  font-size: 13px; font-weight: 500;
  padding: 4px 12px;
  margin-top: 12px;
}
.page-header .page-title {
  padding: 8px 24px;
  border-radius: 999px;
  letter-spacing: -0.015em;
  line-height: 1.05;
}
.app.is-mobile .page-header .page-title { padding: 6px 18px; }
.accent-glyph { color: var(--accent); }
.header-tools { display: flex; gap: 8px; flex-wrap: wrap; }

/* ─── CHIPS ──────────────────────────────────────────────── */
.chip {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 8px 14px; border-radius: 999px;
  font-size: 13px; font-weight: 600;
  background: color-mix(in srgb, var(--ink) 12%, var(--surface-1));
  border: 1px solid var(--stroke-strong);
  color: var(--ink);
  backdrop-filter: blur(10px);
  transition: all .15s;
}
.chip:hover { background: color-mix(in srgb, var(--ink) 18%, var(--surface-1)); }
.chip.ghost { background: color-mix(in srgb, var(--ink) 8%, transparent); }
.chip.primary {
  background: var(--accent); color: white; border-color: transparent;
  box-shadow: 0 4px 12px -4px color-mix(in srgb, var(--accent) 70%, transparent);
}
.chip.primary:hover { background: color-mix(in srgb, var(--accent) 88%, white); }

/* ─── PANELS ─────────────────────────────────────────────── */
.panel { padding: 20px 22px; position: relative; overflow: hidden; }
.panel-head {
  display: flex; align-items: center; justify-content: space-between;
  margin-bottom: 14px;
}
.panel-head h3 { font-size: 16px; font-weight: 600; letter-spacing: 0.01em; }
.muted { color: var(--ink-muted); font-size: 12px; }
.small { font-size: 11px; }

/* ─── BUTTONS ────────────────────────────────────────────── */
.btn {
  padding: 8px 16px; border-radius: 999px;
  font-size: 13px; font-weight: 500;
  border: none; cursor: pointer; font-family: inherit;
  transition: all .15s; display: inline-flex; align-items: center; justify-content: center;
}
.btn.solid { background: var(--ink); color: color-mix(in srgb, var(--surface-1) 90%, white); }
.btn.solid:hover { background: color-mix(in srgb, var(--ink) 90%, var(--accent)); }
.btn.ghost {
  background: var(--surface-3);
  border: 1px solid var(--stroke);
  color: var(--ink-soft);
}
.btn.ghost:hover { color: var(--ink); }
.btn.full { width: 100%; display: flex; }
.btn:disabled { opacity: 0.45; cursor: not-allowed; }

/* ─── HOME GRID ──────────────────────────────────────────── */
@keyframes page-in {
  from { opacity: 0.4; }
  to   { opacity: 1; }
}
.home-page, .calendar-page, .journal-page, .settings-page {
  animation: page-in .38s cubic-bezier(0.22, 1, 0.36, 1) both;
}
.home-page { flex: 1; min-height: 0; display: flex; flex-direction: column; gap: var(--panel-gap); }
.home-grid {
  display: grid; gap: var(--panel-gap);
  grid-template-columns: 1.4fr 1fr 1fr;
  grid-template-rows: auto 1fr;
  grid-template-areas:
    "hero hero tasks"
    "timeline timeline tasks"
    "timeline timeline mini";
  flex: 1; min-height: 0;
}
.home-grid > .panel { min-height: 0; display: flex; flex-direction: column; overflow: hidden; }
.home-grid > .panel .timeline,
.home-grid > .panel .tasks { overflow-y: auto; flex: 1; }
.app.is-mobile .home-grid {
  grid-template-columns: 1fr;
  grid-template-rows: none;
  grid-template-areas: "hero" "timeline" "tasks" "mini";
  flex: initial;
}
.app.is-mobile .home-grid > .panel { overflow: visible; }
.app.is-mobile .home-grid > .panel .timeline,
.app.is-mobile .home-grid > .panel .tasks { overflow: visible; flex: initial; }

/* hero */
.hero-panel {
  min-height: 180px;
  background:
    linear-gradient(135deg,
      color-mix(in srgb, var(--accent) 22%, var(--surface-1)) 0%,
      var(--surface-1) 70%);
}
.hero-eyebrow {
  font-size: 11px; text-transform: uppercase; letter-spacing: 0.18em;
  color: var(--ink-soft); font-weight: 600;
}
.hero-title {
  font-size: 38px; font-weight: 600; letter-spacing: -0.02em; line-height: 1.05;
  margin-top: 10px;
}
.app.is-mobile .hero-title { font-size: 28px; }
.hero-meta { font-size: 14px; color: var(--ink-soft); margin-top: 6px; }
.hero-actions { display: flex; gap: 8px; margin-top: 18px; }
.hero-orb {
  position: absolute; right: -40px; top: -40px;
  width: 220px; height: 220px; border-radius: 50%;
  background: radial-gradient(circle, color-mix(in srgb, var(--accent) 60%, transparent) 0%, transparent 70%);
  pointer-events: none; filter: blur(10px);
}

/* timeline */
.timeline { list-style: none; display: flex; flex-direction: column; gap: 6px; padding-right: 4px; }
.tl-row {
  display: grid; grid-template-columns: 72px 10px 1fr auto;
  gap: 14px; align-items: stretch;
  padding: 10px 12px;
  border-radius: var(--rad-sm);
  background: color-mix(in srgb, var(--surface-1) 25%, transparent);
  border: 1px solid color-mix(in srgb, var(--stroke) 60%, transparent);
  position: relative;
  transition: background .2s, transform .2s, box-shadow .2s, border-color .2s;
}
.tl-row:hover {
  background: color-mix(in srgb, var(--surface-1) 50%, transparent);
  transform: translateX(2px);
  box-shadow: 0 4px 12px -6px rgba(0,0,0,0.18);
}
.tl-row.next {
  border-color: color-mix(in srgb, var(--accent) 60%, transparent);
  background: color-mix(in srgb, var(--accent) 10%, var(--surface-2));
  box-shadow: 0 4px 14px -6px color-mix(in srgb, var(--accent) 50%, transparent);
}
.tl-time {
  font-size: 13px; font-weight: 600;
  color: var(--ink); font-variant-numeric: tabular-nums;
  align-self: center;
}
.tl-time-end {
  display: block;
  font-size: 11px; font-weight: 500;
  color: var(--ink-muted);
  margin-top: 2px;
}
.tl-bar {
  width: 4px; min-height: 36px;
  border-radius: 999px;
  background: var(--tag-1);
  box-shadow: 0 0 0 1px color-mix(in srgb, var(--ink) 8%, transparent);
}
.tl-bar.ev-tag1 { background: linear-gradient(180deg, color-mix(in srgb, var(--tag-1) 100%, transparent), color-mix(in srgb, var(--tag-1) 60%, var(--accent))); }
.tl-bar.ev-tag2 { background: linear-gradient(180deg, color-mix(in srgb, var(--tag-2) 100%, transparent), color-mix(in srgb, var(--tag-2) 60%, var(--accent))); }
.tl-bar.ev-tag3 { background: linear-gradient(180deg, color-mix(in srgb, var(--tag-3) 100%, transparent), color-mix(in srgb, var(--tag-3) 60%, var(--accent))); }
.tl-bar.ev-tag4 { background: linear-gradient(180deg, color-mix(in srgb, var(--tag-4) 100%, transparent), color-mix(in srgb, var(--tag-4) 60%, var(--accent))); }
.tl-bar.ghost {
  background: transparent;
  border-left: 2px dashed var(--stroke-strong);
  width: 0;
}
.tl-body { display: flex; flex-direction: column; gap: 4px; min-width: 0; align-self: center; }
.tl-title {
  font-size: 14px; font-weight: 600; color: var(--ink);
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.tl-where, .tl-meta { font-size: 12px; color: var(--ink-muted); font-weight: 500; }
.tl-row.past { opacity: 0.55; }
.tl-row.past .tl-title { text-decoration: line-through; color: var(--ink-muted); }
.tl-row.free { background: transparent; border-style: dashed; }
.tl-row.free .tl-title { font-style: italic; color: var(--ink-muted); font-weight: 500; }
.tl-badge {
  align-self: center;
  font-size: 10px; font-weight: 700; letter-spacing: 0.08em;
  text-transform: uppercase;
  padding: 4px 8px; border-radius: 999px;
  background: var(--accent); color: white;
}

/* empty-state: fills the timeline panel, vertically centered, decorative */
.tl-empty {
  flex: 1; min-height: 0;
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
  text-align: center;
  gap: 8px;
  padding: 32px 24px;
  position: relative;
}
.tl-empty-glyph {
  width: 84px; height: 84px;
  color: var(--ink-soft);
  opacity: 0.55;
  margin-bottom: 6px;
  animation: tl-empty-rotate 90s linear infinite;
}
.tl-empty-glyph circle {
  fill: none;
  stroke: currentColor;
  stroke-width: 0.6;
}
.tl-empty-glyph .tl-empty-dot {
  fill: var(--accent); stroke: none;
}
@keyframes tl-empty-rotate { to { transform: rotate(360deg); } }
.tl-empty-eyebrow {
  font-size: 10px; font-weight: 700; letter-spacing: 0.18em;
  text-transform: uppercase;
  color: var(--ink-muted);
}
.tl-empty-title {
  font-family: var(--font-accent);
  font-size: 30px; font-weight: 600;
  color: var(--ink);
  line-height: 1.15;
  letter-spacing: -0.01em;
}
.tl-empty-hint {
  font-size: 13px; color: var(--ink-muted);
  margin-bottom: 14px;
  max-width: 32ch;
}

/* tasks */
.tasks { list-style: none; display: flex; flex-direction: column; gap: 4px; }
.task {
  display: flex; align-items: center; gap: 10px;
  padding: 8px 10px; border-radius: var(--rad-sm);
  font-size: 14px; cursor: pointer; transition: background .15s;
}
.task:hover { background: var(--surface-3); }
.task.done .task-text { text-decoration: line-through; color: var(--ink-muted); }
.task-text { flex: 1; min-width: 0; }
.task-del {
  opacity: 0; font-size: 16px; line-height: 1; color: var(--ink-muted);
  padding: 2px 6px; border-radius: 6px; transition: opacity .15s, color .15s;
  flex-shrink: 0;
}
.task:hover .task-del { opacity: 1; }
.task-del:hover { color: var(--ink); background: var(--surface-3); }
.check {
  width: 16px; height: 16px; flex-shrink: 0;
  border-radius: 5px; border: 1.5px solid var(--stroke-strong);
  position: relative; transition: all .15s;
}
.check.on { background: var(--accent); border-color: var(--accent); }
.check.on::after {
  content: ""; position: absolute; left: 4px; top: 1px;
  width: 4px; height: 9px;
  border: solid white; border-width: 0 2px 2px 0;
  transform: rotate(45deg);
}
.task-add { margin-top: 10px; display: flex; gap: 6px; width: 100%; min-width: 0; }
.task-add input {
  flex: 1; min-width: 0; padding: 8px 12px;
  border-radius: 999px; background: var(--surface-3);
  border: 1px solid var(--stroke); outline: none;
  font-size: 13px; color: var(--ink);
}
.task-add input:focus { border-color: var(--accent); }
.task-add-btn {
  flex: 0 0 auto; width: 32px; height: 32px; border-radius: 50%;
  display: inline-flex; align-items: center; justify-content: center;
  background: var(--accent); color: white;
  font-size: 18px; font-weight: 500; line-height: 1; border: none;
  cursor: pointer; transition: transform .12s, background .15s;
  box-shadow: 0 2px 8px -2px color-mix(in srgb, var(--accent) 60%, transparent);
}
.task-add-btn:hover { background: color-mix(in srgb, var(--accent) 90%, white); transform: scale(1.05); }
.task-add-btn:active { transform: scale(0.95); }

/* mini calendar */
.mini-nav { display: flex; gap: 4px; }
.mini-nav button {
  width: 24px; height: 24px; border-radius: 6px; color: var(--ink-soft);
}
.mini-nav button:hover { background: var(--surface-3); color: var(--ink); }
.mini-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 3px; text-align: center; }
.mini-dow {
  font-size: 10px; font-weight: 600; letter-spacing: 0.06em;
  color: var(--ink-muted); padding-bottom: 4px;
}
.mini-day {
  position: relative; padding: 6px 0;
  font-size: 12px; font-variant-numeric: tabular-nums;
  border-radius: 8px; cursor: pointer; transition: background .15s;
}
.mini-day:hover { background: var(--surface-3); }
.mini-day.empty { cursor: default; }
.mini-day.empty:hover { background: transparent; }
.mini-day.today {
  background: var(--ink);
  color: white;
  font-weight: 700;
  border-radius: 10px;
  box-shadow: 0 2px 8px -2px rgba(0,0,0,0.35);
}
.mini-dot {
  position: absolute; bottom: 2px; left: 50%; transform: translateX(-50%);
  width: 3px; height: 3px; border-radius: 50%; background: var(--accent);
}

/* ─── CALENDAR PAGE ──────────────────────────────────────── */
.calendar-page { flex: 1; min-height: 0; display: flex; flex-direction: column; gap: var(--panel-gap); }
.calendar-panel { flex: 1; padding: 12px; min-height: 0; display: flex; overflow: hidden; }
.app.is-mobile .calendar-page { flex: initial; }
.app.is-mobile .calendar-panel { height: 600px; min-height: 600px; }
.fc-host { flex: 1; align-self: stretch; min-height: 0; min-width: 0; }

.seg {
  display: inline-flex; gap: 2px; padding: 3px;
  background: color-mix(in srgb, var(--ink) 18%, var(--surface-2));
  border: 1px solid var(--stroke-strong); border-radius: 999px;
  backdrop-filter: blur(10px);
}
.seg button {
  padding: 6px 14px; border-radius: 999px;
  font-size: 12px; font-weight: 600; color: var(--ink);
  min-width: 28px; opacity: 0.7;
}
.seg button:hover { opacity: 1; background: color-mix(in srgb, var(--ink) 8%, transparent); }
.seg button.on {
  background: var(--accent); color: white; opacity: 1;
  box-shadow: 0 2px 6px -2px color-mix(in srgb, var(--accent) 70%, transparent);
}

/* FullCalendar overrides */
.fc {
  --fc-border-color: var(--stroke);
  --fc-page-bg-color: transparent;
  --fc-neutral-bg-color: var(--surface-3);
  --fc-today-bg-color: color-mix(in srgb, var(--accent) 10%, transparent);
  --fc-now-indicator-color: var(--accent);
  font-family: var(--font);
}
.fc .fc-col-header-cell-cushion,
.fc .fc-daygrid-day-number { color: var(--ink); text-decoration: none; padding: 8px; font-size: 14px; font-weight: 600; }
.fc .fc-col-header-cell-cushion { font-size: 12px; text-transform: uppercase; letter-spacing: 0.1em; font-weight: 700; color: var(--ink); }
.fc .fc-daygrid-day.fc-day-today .fc-daygrid-day-number {
  color: white; font-weight: 800;
  background: var(--accent); border-radius: 50%;
  width: 28px; height: 28px; display: flex; align-items: center; justify-content: center; padding: 0;
  box-shadow: 0 2px 10px -2px color-mix(in srgb, var(--accent) 70%, transparent);
}
.fc .fc-scrollgrid, .fc .fc-scrollgrid-section > * { border-color: var(--stroke) !important; }
.fc td, .fc th { border-color: var(--stroke); }
.fc .fc-timegrid-slot-label { font-size: 12px; color: var(--ink-soft); font-weight: 500; }
.fc .fc-timegrid-axis-cushion { color: var(--ink-soft); font-size: 12px; font-weight: 500; }
.fc-event { border: 0 !important; padding: 3px 8px; border-radius: 7px; font-size: 12px; font-weight: 600; cursor: pointer; }
.fc-event.ev-tag1 { background: var(--tag-1) !important; color: var(--ink) !important; }
.fc-event.ev-tag2 { background: var(--tag-2) !important; color: var(--ink) !important; }
.fc-event.ev-tag3 { background: var(--tag-3) !important; color: var(--ink) !important; }
.fc-event.ev-tag4 { background: var(--tag-4) !important; color: var(--ink) !important; }
.fc-event:hover { transform: translateY(-1px); box-shadow: 0 4px 8px -2px rgba(0,0,0,0.15); }
.fc-daygrid-event-dot { display: none; }
.fc-button, .fc-button-primary { display: none !important; }

/* ─── JOURNAL PAGE ───────────────────────────────────────── */
.journal-page { display: flex; flex-direction: column; gap: var(--panel-gap); }
.journal-grid {
  display: grid; grid-template-columns: 280px 1fr;
  gap: var(--panel-gap); flex: 1; min-height: 0;
}
.app.is-mobile .journal-grid { grid-template-columns: 1fr; }
.journal-list { display: flex; flex-direction: column; min-height: 0; }
.entry-list { list-style: none; display: flex; flex-direction: column; gap: 4px; overflow-y: auto; }
.entry-row {
  padding: 10px 12px; border-radius: var(--rad-sm);
  cursor: pointer; border: 1px solid transparent; transition: all .15s;
}
.entry-row:hover { background: var(--surface-3); }
.entry-row.on { background: var(--surface-2); border-color: var(--stroke); }
.entry-date { font-size: 12px; font-weight: 600; color: var(--ink); }
.entry-preview {
  font-size: 12px; color: var(--ink-muted); margin-top: 3px;
  overflow: hidden; text-overflow: ellipsis;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
}
.journal-editor { display: flex; flex-direction: column; gap: 18px; padding: 24px 28px; }
.editor-meta { display: flex; align-items: baseline; justify-content: space-between; }
.editor-field { display: flex; flex-direction: column; gap: 6px; }
.field-label {
  font-size: 11px; text-transform: uppercase; letter-spacing: 0.16em;
  font-weight: 600; color: var(--ink-muted);
}
.editor-field textarea, .editor-field input {
  background: var(--surface-3); border: 1px solid var(--stroke);
  border-radius: var(--rad-sm); padding: 12px 14px; font-size: 14px;
  outline: none; resize: vertical; font-family: inherit;
  color: var(--ink); line-height: 1.5; transition: border-color .15s, background .15s;
}
.editor-field textarea:focus, .editor-field input:focus { border-color: var(--accent); background: var(--surface-2); }
.editor-field textarea::placeholder, .editor-field input::placeholder { color: var(--ink-muted); }

/* ─── SETTINGS PAGE ──────────────────────────────────────── */
.settings-page { display: flex; flex-direction: column; gap: var(--panel-gap); }
.settings-grid {
  columns: 4 280px; column-gap: var(--panel-gap);
}
.settings-grid > * {
  break-inside: avoid; margin-bottom: var(--panel-gap); display: block;
}
/* organic vertical stagger — kills the straight line where panels start.
   Pseudo-random offsets keyed off DOM order. Last-of-column collapses
   naturally because multi-column reflow groups by available height. */
.settings-grid > *:nth-child(8n+1) { margin-top: 0; }
.settings-grid > *:nth-child(8n+2) { margin-top: 28px; }
.settings-grid > *:nth-child(8n+3) { margin-top: 12px; }
.settings-grid > *:nth-child(8n+4) { margin-top: 44px; }
.settings-grid > *:nth-child(8n+5) { margin-top: 6px; }
.settings-grid > *:nth-child(8n+6) { margin-top: 32px; }
.settings-grid > *:nth-child(8n+7) { margin-top: 18px; }
.settings-grid > *:nth-child(8n+8) { margin-top: 38px; }
/* NOTE: avoid `transform` on these — a transformed ancestor becomes the
   containing block for `background-attachment: fixed` on .glass::before,
   which would make every card sample the same slice of wallpaper. */
/* compact font list — scrolls internally so panel stays viewport-friendly */
.font-pick {
  display: grid;
  grid-template-columns: 1fr;
  gap: 4px;
  max-height: 360px;
  overflow-y: auto;
  padding-right: 4px;
}
.font-pick::-webkit-scrollbar { width: 6px; }
.font-pick::-webkit-scrollbar-thumb { background: var(--stroke-strong); border-radius: 3px; }
.font-pick::-webkit-scrollbar-track { background: transparent; }
.font-card {
  text-align: left;
  padding: 8px 12px;
  border-radius: var(--rad-sm);
  background: transparent;
  border: 1px solid transparent;
  transition: background .15s, border-color .15s;
  display: grid;
  grid-template-columns: 1fr auto;
  align-items: center;
  gap: 12px;
  min-height: 38px;
}
.font-card:hover { background: var(--surface-3); }
.font-card.on {
  background: color-mix(in srgb, var(--accent) 14%, var(--surface-2));
  border-color: color-mix(in srgb, var(--accent) 50%, transparent);
}
.font-name {
  font-size: 16px; font-weight: 600; color: var(--ink);
  line-height: 1.1;
}
.font-note {
  font-size: 11px; color: var(--ink-muted);
  font-family: var(--font); /* always sans for note, ignoring card's font */
}
.font-spec {
  font-size: 15px; color: var(--ink-soft);
  font-variant-numeric: tabular-nums;
  justify-self: end;
  letter-spacing: 0.02em;
}

.theme-info { display: grid; grid-template-columns: repeat(3, 1fr); gap: 6px; margin-bottom: 10px; }
.theme-card {
  display: flex; flex-direction: column; align-items: center; gap: 4px;
  padding: 8px; border-radius: var(--rad-sm);
  background: var(--surface-3); border: 1px solid var(--stroke);
  font-size: 11px; color: var(--ink-muted);
}
.theme-swatch { width: 36px; height: 36px; border-radius: 10px; border: 1px solid var(--stroke); }
.theme-swatch.ink    { background: var(--ink); }
.theme-swatch.accent { background: var(--accent); }
.theme-swatch.t1     { background: var(--tag-1); }
.theme-swatch.t2     { background: var(--tag-2); }
.theme-swatch.t3     { background: var(--tag-3); }
.theme-swatch.t4     { background: var(--tag-4); }

.setting-row { margin-bottom: 14px; }
.setting-row label { display: flex; flex-direction: column; gap: 8px; font-size: 13px; color: var(--ink-soft); }
.setting-row input[type=range] {
  appearance: none; -webkit-appearance: none; -moz-appearance: none;
  width: 100%; height: 6px; border-radius: 999px;
  background: var(--stroke-strong); outline: none; cursor: pointer;
  transition: background .2s;
}
.setting-row input[type=range]::-webkit-slider-thumb {
  appearance: none; -webkit-appearance: none;
  width: 18px; height: 18px; border-radius: 50%;
  background: var(--accent); border: 2px solid white;
  cursor: pointer; box-shadow: 0 2px 8px rgba(0,0,0,0.25);
  transition: transform .15s, box-shadow .15s;
}
.setting-row input[type=range]::-webkit-slider-thumb:hover {
  transform: scale(1.15); box-shadow: 0 4px 12px rgba(0,0,0,0.3);
}
.setting-row input[type=range]::-moz-range-thumb {
  width: 18px; height: 18px; border-radius: 50%;
  background: var(--accent); border: 2px solid white;
  cursor: pointer; box-shadow: 0 2px 8px rgba(0,0,0,0.25);
  transition: transform .15s, box-shadow .15s;
}
.setting-row input[type=range]::-moz-range-thumb:hover {
  transform: scale(1.15); box-shadow: 0 4px 12px rgba(0,0,0,0.3);
}
.setting-row input[type=range]::-moz-range-track {
  background: transparent; border: none;
}

.wp-preview {
  width: 100%; aspect-ratio: 16/9; border-radius: var(--rad-sm);
  border: 1px solid var(--stroke); margin-bottom: 10px;
  overflow: hidden; position: relative;
  background: color-mix(in srgb, var(--surface-1) 60%, transparent);
}
.wp-preview canvas {
  display: block;
  width: 100%; height: 100%;
  image-rendering: pixelated;
  image-rendering: crisp-edges;
}

/* algorithmic art: thin generative ornament that overlays glass cards
   (subtle, hue-shifted, doesn't interfere with content readability) */
.ornament {
  position: absolute;
  pointer-events: none;
  opacity: 0.35;
  mix-blend-mode: overlay;
}
.ornament.tr { top: 0; right: 0; width: 120px; height: 120px; }
.ornament.bl { bottom: 0; left: 0;  width: 120px; height: 120px; transform: rotate(180deg); }
.ornament path,
.ornament circle,
.ornament line {
  stroke: var(--accent);
  fill: none;
  stroke-width: 1;
}

.preset-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 14px; }
.preset-card {
  position: relative; aspect-ratio: 1/1; border-radius: var(--rad-sm);
  border: 1px solid var(--stroke); background: var(--surface-3);
  overflow: hidden; cursor: pointer; padding: 0;
  transition: transform .15s, border-color .15s;
}
.preset-card:hover { transform: translateY(-1px); }
.preset-card.on { border-color: var(--accent); box-shadow: 0 0 0 2px color-mix(in srgb, var(--accent) 35%, transparent); }
.preset-name {
  position: absolute; left: 6px; bottom: 4px; font-size: 11px; font-weight: 500;
  color: var(--ink); text-transform: capitalize;
}
.vibe-icon {
  position: absolute; left: 50%; top: 38%; transform: translate(-50%, -50%);
  width: 72%; height: 72%;
  pointer-events: none;
}
.vibe-icon-luminous { animation: vibe-pulse 6s ease-in-out infinite; }
@keyframes vibe-pulse {
  0%, 100% { transform: translate(-50%, -50%) scale(1); }
  50%      { transform: translate(-50%, -50%) scale(1.06); }
}
.vibe-icon-mono { filter: saturate(0); }
.preset-card.vibe-preview { background: color-mix(in srgb, var(--surface-1) 50%, transparent); }
.preset-card.vibe-preview.on { background: color-mix(in srgb, var(--accent) 12%, var(--surface-1)); }
.preset-sheet {
  position: absolute; inset: 22% 18% 22% 18%;
  border-radius: 6px; border: 1px solid rgba(255,255,255,0.4);
  background: rgba(255,255,255,0.55); backdrop-filter: blur(8px);
  box-shadow: 0 6px 14px -4px rgba(0,0,0,0.18);
}

/* density preset algorithmic art — dot fields */
.density-preview { background: linear-gradient(135deg, color-mix(in srgb, var(--accent) 8%, var(--surface-1)), var(--surface-2)); }
.density-art {
  position: absolute; left: 14%; right: 14%; top: 14%;
  aspect-ratio: 1/1;
  display: grid; gap: var(--dot-gap, 6px);
  grid-template-columns: repeat(var(--dot-cols, 3), 1fr);
  pointer-events: none;
}
.density-art span {
  display: block;
  background: color-mix(in srgb, var(--ink) 65%, transparent);
  border-radius: 50%;
  aspect-ratio: 1/1;
  transform: scale(var(--dot-scale, 1));
  transition: transform .3s, background .3s;
}
.density-preview.on .density-art span { background: var(--accent); }
.density-airy   { --dot-cols: 3; --dot-gap: 9px; --dot-scale: 0.7; }
.density-cozy   { --dot-cols: 4; --dot-gap: 5px; --dot-scale: 0.85; }
.density-packed { --dot-cols: 6; --dot-gap: 2px; --dot-scale: 1; }
.surface-preview { background: linear-gradient(135deg, hsl(var(--hue), 50%, 70%), hsl(calc(var(--hue) + 60), 50%, 65%)); }
.surface-preview.surface-glass  .preset-sheet { background: rgba(255,255,255,0.45); backdrop-filter: blur(10px); }
.surface-preview.surface-paper  .preset-sheet { background: rgba(255,255,255,0.85); backdrop-filter: blur(4px); }
.surface-preview.surface-solid  .preset-sheet { background: rgba(255,255,255,0.98); backdrop-filter: none; }
.surface-preview.surface-sheer  .preset-sheet { background: rgba(255,255,255,0.18); backdrop-filter: blur(14px); }

.adv-toggle {
  width: 100%; text-align: left; font-size: 11px; font-weight: 600;
  text-transform: uppercase; letter-spacing: 0.12em; color: var(--ink-muted);
  padding: 8px 0; border-top: 1px solid var(--stroke); margin-top: 4px;
  background: none; border-bottom: none; border-left: none; border-right: none;
  cursor: pointer; font-family: inherit;
  display: flex; align-items: center; gap: 5px;
}
.adv-toggle:hover { color: var(--ink); }
.adv-arrow {
  display: inline-block;
  transition: transform .3s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.adv-arrow.open { transform: rotate(90deg); }

.adv-dials {
  display: grid; grid-template-rows: 0fr;
  transition: grid-template-rows .35s cubic-bezier(0.4, 0, 0.2, 1),
              opacity .25s ease, margin-top .3s ease;
  opacity: 0; overflow: hidden; margin-top: 0;
}
.adv-dials > * { min-height: 0; }
.adv-dials.open {
  grid-template-rows: 1fr;
  opacity: 1; margin-top: 8px;
}

.json-dump {
  background: rgba(0,0,0,0.18); color: color-mix(in srgb, var(--ink) 92%, transparent);
  border: 1px solid var(--stroke); border-radius: var(--rad-sm);
  padding: 12px 14px; font-family: ui-monospace, monospace;
  font-size: 11px; line-height: 1.5; overflow-x: auto;
  max-height: 280px; margin-bottom: 10px; white-space: pre;
}
.settings-row {
  display: flex; justify-content: space-between; align-items: center;
  padding: 10px 0; border-bottom: 1px solid var(--stroke); font-size: 13px;
}
.settings-row:last-child { border-bottom: 0; }
.switch { width: 32px; height: 18px; background: var(--stroke-strong); border-radius: 999px; position: relative; cursor: pointer; }
.switch .dot { position: absolute; width: 14px; height: 14px; border-radius: 50%; background: white; top: 2px; left: 2px; transition: left .2s; }

/* ─── EVENT MODAL ────────────────────────────────────────── */
.modal-back {
  position: fixed; inset: 0; z-index: 100;
  background: rgba(0,0,0,0.35); backdrop-filter: blur(8px);
  display: flex; align-items: center; justify-content: center; padding: 20px;
}
.modal { width: 100%; max-width: 440px; padding: 0; overflow: hidden; }
.modal-head, .modal-foot {
  display: flex; align-items: center; justify-content: space-between;
  padding: 16px 20px; border-bottom: 1px solid var(--stroke);
}
.modal-foot { border-bottom: 0; border-top: 1px solid var(--stroke); gap: 8px; justify-content: flex-end; }
.modal-head h3 { font-size: 15px; font-weight: 600; }
.modal-head .x { width: 28px; height: 28px; border-radius: 8px; font-size: 18px; color: var(--ink-muted); }
.modal-head .x:hover { background: var(--surface-3); color: var(--ink); }
.modal-body { padding: 20px; display: flex; flex-direction: column; gap: 14px; }
.modal-body label { display: flex; flex-direction: column; gap: 6px; font-size: 12px; color: var(--ink-soft); font-weight: 500; }
.modal-body input, .modal-body textarea {
  background: var(--surface-3); border: 1px solid var(--stroke);
  border-radius: 10px; padding: 10px 12px; font-size: 14px; font-family: inherit; outline: none;
}
.modal-body input:focus, .modal-body textarea:focus { border-color: var(--accent); }
.modal-allday-row { display: flex; align-items: center; gap: 8px; font-size: 13px; color: var(--ink-soft); }
.modal-allday-row input { width: auto; }
.row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.tag-pick { display: flex; gap: 8px; padding: 4px 0; }
.tag-swatch { width: 28px; height: 28px; border-radius: 8px; cursor: pointer; border: 2px solid transparent; transition: border-color .15s; }
.tag-swatch:hover { border-color: var(--ink-muted); }
.tag-swatch.selected { border-color: var(--ink) !important; }
.tag-swatch.ev-tag1 { background: var(--tag-1); }
.tag-swatch.ev-tag2 { background: var(--tag-2); }
.tag-swatch.ev-tag3 { background: var(--tag-3); }
.tag-swatch.ev-tag4 { background: var(--tag-4); }
.modal-conflicts {
  background: color-mix(in srgb, var(--tag-2) 30%, var(--surface-3));
  border: 1px solid color-mix(in srgb, var(--tag-2) 60%, transparent);
  border-radius: var(--rad-sm); padding: 10px 12px;
  font-size: 12px; color: var(--ink-soft);
}
.modal-conflicts strong { display: block; margin-bottom: 4px; font-size: 11px; text-transform: uppercase; letter-spacing: 0.1em; }
.modal-conflicts ul { padding-left: 1rem; }
.modal-btn-delete { background: color-mix(in srgb, var(--tag-1) 30%, var(--surface-3)); color: var(--ink); border: 1px solid color-mix(in srgb, var(--tag-1) 50%, transparent); }
.modal-btn-delete:hover { background: color-mix(in srgb, var(--tag-1) 50%, var(--surface-3)); }

/* ─── RESPONSIVE ─────────────────────────────────────────── */
@media (max-width: 880px) {
  .page-title { font-size: 26px; }
  .hero-title  { font-size: 26px; }
  .panel { padding: 16px; }
}
```

## `src/lib/constants.js`

```js
export const VIBE_PRESETS = {
  calm:     { satMult: 0.85, lightShift: 0.04,  glowAlpha: 0.10, glowBlur: 80,  veilAlpha: 0.18 },
  vivid:    { satMult: 1.25, lightShift: -0.02, glowAlpha: 0.22, glowBlur: 60,  veilAlpha: 0.22 },
  luminous: { satMult: 1.05, lightShift: 0.10,  glowAlpha: 0.32, glowBlur: 110, veilAlpha: 0.08 },
  mono:     { satMult: 0.15, lightShift: 0,     glowAlpha: 0.04, glowBlur: 40,  veilAlpha: 0.25 },
}

export const SURFACE_PRESETS = {
  glass: { alphaMult: 1.0,  blur: 22, strokeMult: 1.0, shadowMult: 1.0, panelTint: 0.0 },
  paper: { alphaMult: 1.55, blur: 8,  strokeMult: 1.2, shadowMult: 0.6, panelTint: 0.0 },
  solid: { alphaMult: 1.85, blur: 0,  strokeMult: 1.4, shadowMult: 0.4, panelTint: 0.0 },
  sheer: { alphaMult: 0.45, blur: 36, strokeMult: 0.6, shadowMult: 1.4, panelTint: 0.08 },
}

export const DENSITY_PRESETS = {
  airy:   { pad: 26, gap: 22, scale: 1.05, radius: 22 },
  cozy:   { pad: 18, gap: 16, scale: 1.0,  radius: 18 },
  packed: { pad: 12, gap: 10, scale: 0.94, radius: 12 },
}

export const FONTS = [
  // sans
  { id: 'manrope',    name: 'Manrope',         stack: '"Manrope", system-ui, sans-serif',            note: 'clean sans · default' },
  { id: 'outfit',     name: 'Outfit',          stack: '"Outfit", system-ui, sans-serif',             note: 'rounded geometric' },
  { id: 'jakarta',    name: 'Plus Jakarta',    stack: '"Plus Jakarta Sans", system-ui, sans-serif',  note: 'friendly modern' },
  { id: 'grotesk',    name: 'Space Grotesk',   stack: '"Space Grotesk", system-ui, sans-serif',      note: 'slightly techy' },
  { id: 'dm',         name: 'DM Sans',         stack: '"DM Sans", system-ui, sans-serif',            note: 'soft sans' },
  { id: 'instrument', name: 'Instrument',      stack: '"Instrument Sans", system-ui, sans-serif',    note: 'editorial sans' },
  { id: 'plex',       name: 'IBM Plex',        stack: '"IBM Plex Sans", system-ui, sans-serif',      note: 'precise sans' },
  { id: 'quicksand',  name: 'Quicksand',       stack: '"Quicksand", system-ui, sans-serif',          note: 'soft rounded' },
  { id: 'bricolage',  name: 'Bricolage',       stack: '"Bricolage Grotesque", system-ui, sans-serif',note: 'expressive display' },
  { id: 'syne',       name: 'Syne',            stack: '"Syne", system-ui, sans-serif',               note: 'experimental display' },
  // serif
  { id: 'fraunces',   name: 'Fraunces',        stack: '"Fraunces", Georgia, serif',                  note: 'warm editorial serif' },
  { id: 'playfair',   name: 'Playfair',        stack: '"Playfair Display", Georgia, serif',          note: 'high-contrast serif' },
  { id: 'lora',       name: 'Lora',            stack: '"Lora", Georgia, serif',                      note: 'calligraphic serif' },
  { id: 'crimson',    name: 'Crimson',         stack: '"Crimson Pro", Georgia, serif',               note: 'classic book serif' },
  { id: 'instser',    name: 'Instrument Serif',stack: '"Instrument Serif", Georgia, serif',          note: 'tall elegant serif' },
  // mono
  { id: 'jbmono',     name: 'JetBrains Mono',  stack: '"JetBrains Mono", ui-monospace, monospace',   note: 'engineering mono' },
  { id: 'plexmono',   name: 'IBM Plex Mono',   stack: '"IBM Plex Mono", ui-monospace, monospace',    note: 'editorial mono' },
  { id: 'spacemono',  name: 'Space Mono',      stack: '"Space Mono", ui-monospace, monospace',       note: 'retro-tech mono' },
  { id: 'inconsolata',name: 'Inconsolata',     stack: '"Inconsolata", ui-monospace, monospace',      note: 'humanist mono' },
]

export const ACCENT_FONT = '"Caveat", "Instrument Serif", serif'

export const TAGS = ['ev-tag1', 'ev-tag2', 'ev-tag3', 'ev-tag4']

export const DEFAULT_PREFS = {
  font: 'manrope',
  vibe: 'calm',
  surface: 'glass',
  density: 'cozy',
  accentBoost: 1.0,
  blurAmount: 22,
  surfaceAlpha: 0.55,
  panelGap: 16,
}
```

## `src/lib/supabaseClient.js`

```js
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'YOUR_SUPABASE_URL'
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'YOUR_SUPABASE_ANON_KEY'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

## `src/lib/palette.js`

```js
function rgb2hsl(r, g, b) {
  r /= 255; g /= 255; b /= 255
  const max = Math.max(r, g, b), min = Math.min(r, g, b)
  let h = 0, s = 0
  const l = (max + min) / 2
  if (max !== min) {
    const d = max - min
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
    switch (max) {
      case r: h = (g - b) / d + (g < b ? 6 : 0); break
      case g: h = (b - r) / d + 2; break
      case b: h = (r - g) / d + 4; break
    }
    h *= 60
  }
  return [h, s, l]
}

function hsl(h, s, l, a = 1) {
  return `hsla(${h.toFixed(0)}, ${(s * 100).toFixed(0)}%, ${(l * 100).toFixed(0)}%, ${a})`
}

export async function extractPalette(src) {
  return new Promise((resolve, reject) => {
    const img = new Image()
    img.crossOrigin = 'anonymous'
    img.onload = () => {
      try {
        const W = 80, H = 80
        const c = document.createElement('canvas')
        c.width = W; c.height = H
        const ctx = c.getContext('2d')
        ctx.drawImage(img, 0, 0, W, H)
        const data = ctx.getImageData(0, 0, W, H).data

        const hueBuckets = new Array(12).fill(0)
        const satSum = new Array(12).fill(0)
        const lightSum = new Array(12).fill(0)
        let lumSum = 0, n = 0

        for (let i = 0; i < data.length; i += 4) {
          const r = data[i], g = data[i + 1], b = data[i + 2]
          const [h, s, l] = rgb2hsl(r, g, b)
          const lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255
          lumSum += lum; n++
          if (s > 0.08 && l > 0.15 && l < 0.85) {
            const bucket = Math.min(11, Math.floor(h / 30))
            hueBuckets[bucket] += 1
            satSum[bucket] += s
            lightSum[bucket] += l
          }
        }

        const avgLum = lumSum / n
        let bestBucket = 0, bestCount = -1
        for (let i = 0; i < 12; i++) {
          if (hueBuckets[i] > bestCount) { bestCount = hueBuckets[i]; bestBucket = i }
        }
        const domH = bestBucket * 30 + 15
        const domS = Math.min(0.75, Math.max(0.35, (satSum[bestBucket] / Math.max(1, hueBuckets[bestBucket])) * 1.3))
        const domL = Math.min(0.75, Math.max(0.45, lightSum[bestBucket] / Math.max(1, hueBuckets[bestBucket])))
        const dark = avgLum < 0.55

        const ink      = dark ? hsl(domH, 0.12, 0.96) : hsl(domH, 0.30, 0.16)
        const inkSoft  = dark ? hsl(domH, 0.12, 0.78) : hsl(domH, 0.20, 0.32)
        const inkMuted = dark ? hsl(domH, 0.10, 0.62) : hsl(domH, 0.15, 0.48)
        const surface1 = dark ? `hsla(${domH}, 20%, 18%, 0.55)` : `hsla(${domH}, 40%, 96%, 0.55)`
        const surface2 = dark ? `hsla(${domH}, 20%, 22%, 0.45)` : `hsla(${domH}, 40%, 98%, 0.40)`
        const surface3 = dark ? `hsla(${domH}, 25%, 28%, 0.35)` : `hsla(${domH}, 30%, 100%, 0.30)`
        const stroke       = dark ? `hsla(${domH}, 20%, 90%, 0.18)` : `hsla(${domH}, 30%, 20%, 0.14)`
        const strokeStrong = dark ? `hsla(${domH}, 20%, 90%, 0.30)` : `hsla(${domH}, 30%, 20%, 0.22)`
        const accent     = hsl(domH, domS, dark ? 0.62 : 0.50)
        const accentSoft = hsl(domH, domS * 0.7, dark ? 0.30 : 0.85)
        const sec1H = (domH + 60) % 360
        const sec2H = (domH + 180) % 360
        const sec3H = (domH - 40 + 360) % 360
        const tag1 = hsl(domH,  0.50, dark ? 0.55 : 0.78)
        const tag2 = hsl(sec1H, 0.50, dark ? 0.55 : 0.80)
        const tag3 = hsl(sec2H, 0.45, dark ? 0.55 : 0.82)
        const tag4 = hsl(sec3H, 0.50, dark ? 0.55 : 0.80)

        resolve({ dark, domH, ink, inkSoft, inkMuted, surface1, surface2, surface3, stroke, strokeStrong, accent, accentSoft, tag1, tag2, tag3, tag4 })
      } catch (e) { reject(e) }
    }
    img.onerror = reject
    img.src = src
  })
}

export function applyPalette(p) {
  const r = document.documentElement
  const map = {
    '--ink': p.ink, '--ink-soft': p.inkSoft, '--ink-muted': p.inkMuted,
    '--surface-1': p.surface1, '--surface-2': p.surface2, '--surface-3': p.surface3,
    '--stroke': p.stroke, '--stroke-strong': p.strokeStrong,
    '--accent': p.accent, '--accent-soft': p.accentSoft,
    '--tag-1': p.tag1, '--tag-2': p.tag2, '--tag-3': p.tag3, '--tag-4': p.tag4,
    '--hue': p.domH,
  }
  Object.entries(map).forEach(([k, v]) => r.style.setProperty(k, String(v)))
  r.style.colorScheme = p.dark ? 'dark' : 'light'
}
```

## `src/ai-agent/tools.js`

```js
import { supabase } from '../lib/supabaseClient.js';

/**
 * AI Toolset for interacting with the Day Planner Database via Supabase.
 * These functions are specifically designed to be called by an LLM (like Gemini).
 */

// ---------------------------------------------------------
// 1. Core CRUD Tools
// ---------------------------------------------------------

/**
 * Create a new event.
 */
export async function create_event(args) {
  const { title, start_time, end_time, all_day = false } = args;
  
  if (!title || !start_time) {
    return { error: 'Missing required fields: title, start_time' };
  }

  const { data, error } = await supabase
    .from('events')
    .insert([{ title, start_time, end_time, all_day }])
    .select()
    .single();

  if (error) return { error: error.message };
  return { success: true, event: data };
}

/**
 * Update an existing event.
 */
export async function update_event(args) {
  const { event_id, updates } = args;

  if (!event_id || !updates) {
    return { error: 'Missing required fields: event_id, updates' };
  }

  const { data, error } = await supabase
    .from('events')
    .update(updates)
    .eq('id', event_id)
    .select()
    .single();

  if (error) return { error: error.message };
  return { success: true, event: data };
}

/**
 * Delete an event.
 */
export async function delete_event(args) {
  const { event_id } = args;

  if (!event_id) {
    return { error: 'Missing required field: event_id' };
  }

  const { error } = await supabase
    .from('events')
    .delete()
    .eq('id', event_id);

  if (error) return { error: error.message };
  return { success: true, message: `Event ${event_id} deleted successfully.` };
}

/**
 * Get events between two dates.
 */
export async function get_events(args) {
  const { start_date, end_date } = args;

  let query = supabase.from('events').select('*').order('start_time', { ascending: true });

  if (start_date) query = query.gte('start_time', start_date);
  if (end_date) query = query.lte('start_time', end_date);

  const { data, error } = await query;

  if (error) return { error: error.message };
  return { events: data };
}


// ---------------------------------------------------------
// 2. Intelligence & Ambiguity Resolution Tools
// ---------------------------------------------------------

/**
 * Semantic-ish search for events based on title.
 */
export async function search_events(args) {
  const { query, limit = 5 } = args;

  if (!query) {
    return { error: 'Missing required field: query' };
  }

  // Using case-insensitive wildcards for fuzzy matching
  const { data, error } = await supabase
    .from('events')
    .select('*')
    .ilike('title', `%${query}%`)
    .limit(limit);

  if (error) return { error: error.message };
  return { results: data };
}

/**
 * Check if a proposed time slot overlaps with any existing events.
 */
export async function check_conflicts(args) {
  const { start_time, end_time, exclude_id } = args;

  if (!start_time || !end_time) {
    return { error: 'Missing required fields: start_time, end_time' };
  }

  // A conflict exists if an existing event starts before the new event ends
  // AND the existing event ends after the new event starts.
  let query = supabase
    .from('events')
    .select('*')
    .lt('start_time', end_time)
    .gt('end_time', start_time);

  if (exclude_id) query = query.neq('id', exclude_id);

  const { data, error } = await query;

  if (error) return { error: error.message };
  
  if (data.length > 0) {
    return { has_conflict: true, conflicting_events: data };
  }
  return { has_conflict: false };
}

/**
 * Find free time slots on a specific date for a given duration.
 */
export async function find_free_slots(args) {
  const { date, duration_minutes, work_day_start = "09:00", work_day_end = "18:00" } = args;

  if (!date || !duration_minutes) {
    return { error: 'Missing required fields: date, duration_minutes' };
  }

  // Fetch all events for that date
  const startOfDay = new Date(`${date}T00:00:00.000Z`).toISOString();
  const endOfDay = new Date(`${date}T23:59:59.999Z`).toISOString();

  const { data: events, error } = await supabase
    .from('events')
    .select('*')
    .gte('start_time', startOfDay)
    .lte('end_time', endOfDay)
    .order('start_time', { ascending: true });

  if (error) return { error: error.message };

  // Calculate free slots
  const freeSlots = [];
  let currentStart = new Date(`${date}T${work_day_start}:00.000Z`);
  const endOfWorkDay = new Date(`${date}T${work_day_end}:00.000Z`);

  for (const event of events) {
    const eventStart = new Date(event.start_time);
    const eventEnd = new Date(event.end_time);

    // If there is a gap between current time and the event start time
    const gapMinutes = (eventStart - currentStart) / (1000 * 60);
    if (gapMinutes >= duration_minutes) {
      freeSlots.push({
        start: currentStart.toISOString(),
        end: eventStart.toISOString()
      });
    }

    // Move the current pointer to the end of the event (or keep it if the event overlaps but started earlier)
    if (eventEnd > currentStart) {
      currentStart = eventEnd;
    }
  }

  // Check the gap after the last event until the end of the workday
  const finalGapMinutes = (endOfWorkDay - currentStart) / (1000 * 60);
  if (finalGapMinutes >= duration_minutes) {
    freeSlots.push({
      start: currentStart.toISOString(),
      end: endOfWorkDay.toISOString()
    });
  }

  return { free_slots: freeSlots };
}
```

## `src/components/MiniCalendar.jsx`

```jsx
import { useState } from 'react'

export default function MiniCalendar({ events = [] }) {
  const [month, setMonth] = useState(() => {
    const d = new Date(); d.setDate(1); return d
  })

  const monthName = month.toLocaleDateString(undefined, { month: 'long', year: 'numeric' })
  const firstDow = (month.getDay() + 6) % 7
  const daysInMonth = new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate()
  const cells = []
  for (let i = 0; i < firstDow; i++) cells.push(null)
  for (let d = 1; d <= daysInMonth; d++) cells.push(d)
  while (cells.length % 7 !== 0) cells.push(null)

  const today = new Date()
  const eventDays = new Set(
    events
      .map(e => new Date(e.start))
      .filter(d => d.getMonth() === month.getMonth() && d.getFullYear() === month.getFullYear())
      .map(d => d.getDate())
  )

  const prev = () => { const x = new Date(month); x.setMonth(x.getMonth() - 1); setMonth(x) }
  const next = () => { const x = new Date(month); x.setMonth(x.getMonth() + 1); setMonth(x) }

  return (
    <>
      <div className="panel-head">
        <h3>{monthName}</h3>
        <div className="mini-nav">
          <button onClick={prev}>‹</button>
          <button onClick={next}>›</button>
        </div>
      </div>
      <div className="mini-grid">
        {['M','T','W','T','F','S','S'].map((d, i) => (
          <span key={i} className="mini-dow">{d}</span>
        ))}
        {cells.map((d, i) => {
          const isToday = d && d === today.getDate()
            && month.getMonth() === today.getMonth()
            && month.getFullYear() === today.getFullYear()
          const hasEv = d && eventDays.has(d)
          return (
            <span key={i} className={`mini-day ${isToday ? 'today' : ''} ${!d ? 'empty' : ''}`}>
              {d || ''}
              {hasEv && !isToday && <span className="mini-dot" />}
            </span>
          )
        })}
      </div>
    </>
  )
}
```

## `src/components/EventFormModal.jsx`

```jsx
import { useState, useEffect, useRef } from 'react'
import { supabase } from '../lib/supabaseClient'
import { check_conflicts } from '../ai-agent/tools'

const TAGS = ['ev-tag1', 'ev-tag2', 'ev-tag3', 'ev-tag4']

export default function EventFormModal({ mode, defaultValues, onClose }) {
  const [title, setTitle] = useState(defaultValues.title ?? '')
  const [allDay, setAllDay] = useState(defaultValues.allDay ?? false)
  const [startTime, setStartTime] = useState(defaultValues.startTime ?? '')
  const [endTime, setEndTime] = useState(defaultValues.endTime ?? '')
  const [tag, setTag] = useState(defaultValues.tag ?? 'ev-tag1')
  const [conflicts, setConflicts] = useState([])
  const [saving, setSaving] = useState(false)
  const conflictTimer = useRef(null)

  useEffect(() => {
    clearTimeout(conflictTimer.current)
    if (!startTime || !endTime || allDay) { setConflicts([]); return }
    conflictTimer.current = setTimeout(async () => {
      const result = await check_conflicts({
        start_time: new Date(startTime).toISOString(),
        end_time: new Date(endTime).toISOString(),
        exclude_id: defaultValues.id,
      })
      setConflicts(result.has_conflict ? result.conflicting_events : [])
    }, 400)
    return () => clearTimeout(conflictTimer.current)
  }, [startTime, endTime, allDay])

  async function handleSave() {
    if (!title.trim()) return
    setSaving(true)
    const payload = {
      title: title.trim(),
      all_day: allDay,
      start_time: allDay ? startTime : new Date(startTime).toISOString(),
      end_time: endTime ? (allDay ? endTime : new Date(endTime).toISOString()) : null,
      tag,
    }
    if (mode === 'create') {
      await supabase.from('events').insert(payload)
    } else {
      await supabase.from('events').update(payload).eq('id', defaultValues.id)
    }
    setSaving(false)
    onClose()
  }

  async function handleDelete() {
    setSaving(true)
    await supabase.from('events').delete().eq('id', defaultValues.id)
    setSaving(false)
    onClose()
  }

  function handleKeyDown(e) {
    if (e.key === 'Escape') onClose()
    if (e.key === 'Enter' && !e.shiftKey && title.trim() && !saving) handleSave()
  }

  return (
    <div
      className="modal-back"
      onClick={e => e.target === e.currentTarget && onClose()}
      onKeyDown={handleKeyDown}
    >
      <div className="modal glass" role="dialog" aria-modal="true">
        <div className="modal-head">
          <h3>{mode === 'create' ? 'New event' : 'Edit event'}</h3>
          <button className="x" onClick={onClose} aria-label="Close">✕</button>
        </div>

        <div className="modal-body">
          <label>
            Title
            <input
              type="text"
              placeholder="Event title"
              value={title}
              onChange={e => setTitle(e.target.value)}
              onKeyDown={handleKeyDown}
              autoFocus
            />
          </label>

          <div className="modal-allday-row">
            <input
              type="checkbox"
              id="allday-check"
              checked={allDay}
              onChange={e => setAllDay(e.target.checked)}
            />
            <label htmlFor="allday-check" style={{ flexDirection: 'row', alignItems: 'center' }}>All day</label>
          </div>

          <div className="row-2">
            <label>
              Start
              <input
                type={allDay ? 'date' : 'datetime-local'}
                value={startTime}
                onChange={e => setStartTime(e.target.value)}
              />
            </label>
            <label>
              End
              <input
                type={allDay ? 'date' : 'datetime-local'}
                value={endTime}
                onChange={e => setEndTime(e.target.value)}
              />
            </label>
          </div>

          <label>
            Color
            <div className="tag-pick">
              {TAGS.map(t => (
                <button
                  key={t}
                  type="button"
                  className={`tag-swatch ${t} ${tag === t ? 'selected' : ''}`}
                  onClick={() => setTag(t)}
                  aria-label={t}
                />
              ))}
            </div>
          </label>

          {conflicts.length > 0 && (
            <div className="modal-conflicts">
              <strong>Conflicts with</strong>
              <ul>
                {conflicts.map(c => <li key={c.id}>{c.title}</li>)}
              </ul>
            </div>
          )}
        </div>

        <div className="modal-foot">
          {mode === 'edit' && (
            <button className="chip modal-btn-delete" onClick={handleDelete} disabled={saving}>
              Delete
            </button>
          )}
          <button className="chip" onClick={onClose}>Cancel</button>
          <button
            className="chip primary"
            onClick={handleSave}
            disabled={saving || !title.trim()}
          >
            {saving ? 'Saving…' : 'Save'}
          </button>
        </div>
      </div>
    </div>
  )
}
```

## `src/components/AlgorithmicOrnament.jsx`

```jsx
/**
 * Tiny seeded generative SVG flourish — placed in card corners as quiet
 * ambient ornaments. Same `seed` → same output (deterministic).
 *
 * Variants:
 *   'arc'    concentric quarter-arcs
 *   'mesh'   loose triangle mesh
 *   'wave'   stacked sine waves
 *   'stars'  tiny seeded star field
 */

function mulberry32(seed) {
  let a = seed >>> 0
  return function () {
    a |= 0; a = (a + 0x6D2B79F5) | 0
    let t = Math.imul(a ^ (a >>> 15), 1 | a)
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296
  }
}

export default function AlgorithmicOrnament({ variant = 'arc', seed = 1, size = 120, className = '', position = 'tr' }) {
  const r = mulberry32(seed)
  const els = []

  if (variant === 'arc') {
    const cx = size, cy = 0
    for (let i = 0; i < 8; i++) {
      const rad = 16 + i * 10 + r() * 6
      els.push(
        <path key={i}
          d={`M ${cx - rad} ${cy} A ${rad} ${rad} 0 0 0 ${cx} ${cy + rad}`}
          strokeOpacity={0.35 + i * 0.06}
        />
      )
    }
  } else if (variant === 'mesh') {
    const pts = []
    for (let i = 0; i < 7; i++) pts.push([r() * size, r() * size])
    for (let i = 0; i < pts.length; i++) {
      for (let j = i + 1; j < pts.length; j++) {
        if (r() > 0.55) continue
        els.push(<line key={`${i}-${j}`} x1={pts[i][0]} y1={pts[i][1]} x2={pts[j][0]} y2={pts[j][1]} strokeOpacity={0.5} />)
      }
    }
    pts.forEach(([x, y], k) => els.push(<circle key={`p${k}`} cx={x} cy={y} r={1.4} fill="currentColor" stroke="none" />))
  } else if (variant === 'wave') {
    for (let i = 0; i < 5; i++) {
      const amp = 4 + i * 2
      const yBase = 18 + i * 18
      let d = `M 0 ${yBase}`
      for (let x = 0; x <= size; x += 4) {
        const y = yBase + Math.sin((x / size) * Math.PI * 2 + r() * 6) * amp
        d += ` L ${x.toFixed(1)} ${y.toFixed(1)}`
      }
      els.push(<path key={i} d={d} strokeOpacity={0.5 - i * 0.07} />)
    }
  } else if (variant === 'stars') {
    for (let i = 0; i < 22; i++) {
      const x = r() * size, y = r() * size
      const rad = 0.6 + r() * 1.4
      els.push(<circle key={i} cx={x} cy={y} r={rad} fill="currentColor" stroke="none" fillOpacity={0.3 + r() * 0.5} />)
    }
  }

  return (
    <svg
      className={`ornament ${position} ${className}`}
      viewBox={`0 0 ${size} ${size}`}
      width={size}
      height={size}
      aria-hidden="true"
    >
      {els}
    </svg>
  )
}
```

## `src/components/VibeIcon.jsx`

```jsx
/**
 * Distinct algorithmic vibe visuals — replaces the old uniform blurred-orb.
 * Each takes the current --hue/--accent and reads as its own mood at a glance.
 */
export default function VibeIcon({ variant = 'calm' }) {
  if (variant === 'calm') return <Calm />
  if (variant === 'vivid') return <Vivid />
  if (variant === 'luminous') return <Luminous />
  if (variant === 'mono') return <Mono />
  return null
}

function Calm() {
  return (
    <svg viewBox="0 0 64 64" className="vibe-icon vibe-icon-calm" aria-hidden="true">
      <defs>
        <radialGradient id="vi-calm-g" cx="50%" cy="50%" r="50%">
          <stop offset="0%"  stopColor="hsl(var(--hue), 70%, 80%)" stopOpacity="0.9" />
          <stop offset="60%" stopColor="hsl(var(--hue), 60%, 70%)" stopOpacity="0.5" />
          <stop offset="100%" stopColor="hsl(var(--hue), 50%, 60%)" stopOpacity="0" />
        </radialGradient>
      </defs>
      {/* soft concentric rings */}
      <circle cx="32" cy="32" r="26" fill="url(#vi-calm-g)" />
      <circle cx="32" cy="32" r="20" fill="none" stroke="hsl(var(--hue), 55%, 70%)" strokeOpacity="0.45" strokeWidth="0.8" />
      <circle cx="32" cy="32" r="13" fill="none" stroke="hsl(var(--hue), 55%, 70%)" strokeOpacity="0.55" strokeWidth="0.8" />
      <circle cx="32" cy="32" r="6"  fill="hsl(var(--hue), 65%, 78%)" />
    </svg>
  )
}

function Vivid() {
  // bold central disc + radiating spokes
  const spokes = []
  for (let i = 0; i < 14; i++) {
    const a = (i / 14) * Math.PI * 2
    const x1 = 32 + Math.cos(a) * 14
    const y1 = 32 + Math.sin(a) * 14
    const x2 = 32 + Math.cos(a) * 26
    const y2 = 32 + Math.sin(a) * 26
    spokes.push(<line key={i} x1={x1} y1={y1} x2={x2} y2={y2} stroke="hsl(var(--hue), 80%, 60%)" strokeOpacity="0.7" strokeWidth="1.6" strokeLinecap="round" />)
  }
  return (
    <svg viewBox="0 0 64 64" className="vibe-icon vibe-icon-vivid" aria-hidden="true">
      <defs>
        <radialGradient id="vi-viv-g" cx="50%" cy="50%" r="50%">
          <stop offset="0%"  stopColor="hsl(var(--hue), 100%, 70%)" />
          <stop offset="100%" stopColor="hsl(var(--hue), 80%, 50%)" />
        </radialGradient>
      </defs>
      {spokes}
      <circle cx="32" cy="32" r="11" fill="url(#vi-viv-g)" />
      <circle cx="32" cy="32" r="11" fill="none" stroke="hsl(var(--hue), 90%, 80%)" strokeOpacity="0.6" />
    </svg>
  )
}

function Luminous() {
  // brilliant core + halo + scattered light points
  return (
    <svg viewBox="0 0 64 64" className="vibe-icon vibe-icon-luminous" aria-hidden="true">
      <defs>
        <radialGradient id="vi-lum-halo" cx="50%" cy="50%" r="50%">
          <stop offset="0%"  stopColor="hsl(calc(var(--hue) + 30), 100%, 80%)" stopOpacity="0.7" />
          <stop offset="60%" stopColor="hsl(calc(var(--hue) + 30), 100%, 70%)" stopOpacity="0.2" />
          <stop offset="100%" stopColor="hsl(calc(var(--hue) + 30), 100%, 70%)" stopOpacity="0" />
        </radialGradient>
        <radialGradient id="vi-lum-core" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stopColor="#fff" />
          <stop offset="60%" stopColor="hsl(var(--hue), 100%, 80%)" />
          <stop offset="100%" stopColor="hsl(var(--hue), 100%, 65%)" />
        </radialGradient>
      </defs>
      <circle cx="32" cy="32" r="28" fill="url(#vi-lum-halo)" />
      <circle cx="32" cy="32" r="10" fill="url(#vi-lum-core)" />
      {/* sparkles */}
      {[[14,16,1.2],[50,20,0.9],[12,46,1],[52,46,1.1],[32,8,0.8],[32,56,0.9],[8,32,0.7],[56,32,1]].map(([x,y,r],i) => (
        <circle key={i} cx={x} cy={y} r={r} fill="hsl(var(--hue), 100%, 88%)" fillOpacity="0.85" />
      ))}
    </svg>
  )
}

function Mono() {
  // desaturated dot grid — algorithmic noise field
  const dots = []
  for (let y = 0; y < 9; y++) {
    for (let x = 0; x < 9; x++) {
      const cx = 8 + x * 6
      const cy = 8 + y * 6
      // pseudo-random density based on position
      const seed = (x * 7 + y * 13) % 11
      const r = 0.6 + (seed / 11) * 1.6
      const op = 0.25 + (seed / 11) * 0.55
      dots.push(<circle key={`${x}-${y}`} cx={cx} cy={cy} r={r} fill="hsl(220, 8%, 30%)" fillOpacity={op} />)
    }
  }
  return (
    <svg viewBox="0 0 64 64" className="vibe-icon vibe-icon-mono" aria-hidden="true">
      <rect x="0" y="0" width="64" height="64" rx="10" fill="hsl(220, 6%, 92%)" />
      {dots}
    </svg>
  )
}
```

## `src/components/LowPolyWallpaper.jsx`

```jsx
import { useEffect, useRef } from 'react'

/**
 * Renders a tiny pixelated downscaled copy of the given image URL.
 * Browser samples it at low resolution; CSS image-rendering: pixelated then
 * scales the canvas up cleanly, producing a low-poly / pixel-art feel without
 * the aliasing you get from arbitrarily-scaling the full-resolution image.
 *
 * Doubles up by drawing the downscaled buffer to a slightly larger canvas
 * with averaged pixel sampling — the result reads as a chunky mosaic that
 * still shows the wallpaper's composition.
 */
export default function LowPolyWallpaper({ src, cols = 32, rows = 18 }) {
  const canvasRef = useRef(null)

  useEffect(() => {
    if (!src) return
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')
    if (!ctx) return

    canvas.width = cols
    canvas.height = rows

    const img = new Image()
    img.crossOrigin = 'anonymous'
    img.onload = () => {
      ctx.imageSmoothingEnabled = true
      ctx.imageSmoothingQuality = 'high'
      // draw scaled-down: browser averages the source pixels for us
      ctx.drawImage(img, 0, 0, cols, rows)
    }
    img.src = src
  }, [src, cols, rows])

  return <canvas ref={canvasRef} aria-hidden="true" />
}
```

## `src/pages/HomePage.jsx`

```jsx
import { useState } from 'react'
import MiniCalendar from '../components/MiniCalendar'
import EventFormModal from '../components/EventFormModal'
import AlgorithmicOrnament from '../components/AlgorithmicOrnament'
import { supabase } from '../lib/supabaseClient'

const fmtTime = d => d.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })

function todayDateStr() {
  const d = new Date()
  const pad = n => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}`
}

export default function HomePage({ events, tasks, setTasks }) {
  const now = new Date()
  const [newTask, setNewTask] = useState('')
  const [quickModal, setQuickModal] = useState(false)

  const todays = events
    .filter(e => !e.allDay && new Date(e.start).toDateString() === now.toDateString())
    .map(e => ({ ...e, _start: new Date(e.start), _end: new Date(e.end || e.start) }))
    .sort((a, b) => a._start - b._start)

  const next = todays.find(e => e._end > now) || todays[0]
  const minsUntil = next ? Math.max(0, Math.round((new Date(next.start) - now) / 60000)) : 0

  async function toggleTask(task) {
    await supabase.from('tasks').update({ done: !task.done }).eq('id', task.id)
  }

  async function deleteTask(e, task) {
    e.stopPropagation()
    await supabase.from('tasks').delete().eq('id', task.id)
  }

  async function addTask() {
    if (!newTask.trim()) return
    await supabase.from('tasks').insert({ title: newTask.trim() })
    setNewTask('')
  }

  return (
    <div className="page home-page">
      <header className="page-header">
        <div>
          <div className="eyebrow">
            {now.toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric' })}
          </div>
          <h1 className="page-title">
            Good {now.getHours() < 12 ? 'morning' : now.getHours() < 17 ? 'afternoon' : 'evening'}<span className="accent-glyph">.</span>
          </h1>
          <div className="page-sub">
            {tasks.filter(t => !t.done).length} tasks open · {todays.length} events today
          </div>
        </div>
        <div className="header-tools">
          <button className="chip primary" onClick={() => setQuickModal(true)}>
            <PlusIcon width="14" height="14" /> quick add
          </button>
        </div>
      </header>

      <div className="home-grid">
        {/* Hero — next up */}
        <section className="panel glass hero-panel" style={{ gridArea: 'hero' }}>
          <AlgorithmicOrnament variant="arc" seed={7} position="tr" size={140} />
          <div className="hero-eyebrow">
            {next ? `Next up · in ${minsUntil} min` : 'Nothing scheduled'}
          </div>
          <h2 className="hero-title">{next?.title || 'Free time'}</h2>
          <div className="hero-meta">
            {next && `${fmtTime(new Date(next.start))} — ${fmtTime(new Date(next.end || next.start))}`}
          </div>
          <div className="hero-orb" aria-hidden="true" />
        </section>

        {/* Timeline */}
        <section className="panel glass" style={{ gridArea: 'timeline' }}>
          <AlgorithmicOrnament variant="wave" seed={42} position="bl" size={130} />
          <div className="panel-head">
            <h3>Today's schedule</h3>
            <span className="muted">{todays.length} event{todays.length === 1 ? '' : 's'}</span>
          </div>
          {todays.length === 0 ? (
            <ScheduleEmpty onAdd={() => setQuickModal(true)} />
          ) : (
          <ul className="timeline">
            {todays.map(e => {
              const isPast = e._end < now
              const isNext = next && e.id === next.id && !isPast
              const hasEnd = e.end && e._end > e._start
              return (
                <li key={e.id} className={`tl-row ${isPast ? 'past' : ''} ${isNext ? 'next' : ''}`}>
                  <span className="tl-time">
                    {fmtTime(e._start)}
                    {hasEnd && <span className="tl-time-end">{fmtTime(e._end)}</span>}
                  </span>
                  <span className={`tl-bar ${e.tag || 'ev-tag1'}`} />
                  <span className="tl-body">
                    <span className="tl-title">{e.title}</span>
                    <span className="tl-meta">
                      {hasEnd
                        ? `${Math.max(1, Math.round((e._end - e._start) / 60000))} min`
                        : 'all day'}
                    </span>
                  </span>
                  {isNext && <span className="tl-badge">next</span>}
                </li>
              )
            })}
          </ul>
          )}
        </section>

        {/* Tasks */}
        <section className="panel glass" style={{ gridArea: 'tasks' }}>
          <div className="panel-head">
            <h3>Tasks</h3>
            <span className="muted">{tasks.filter(t => !t.done).length} open</span>
          </div>
          <ul className="tasks">
            {tasks.map(t => (
              <li key={t.id} className={`task ${t.done ? 'done' : ''}`} onClick={() => toggleTask(t)}>
                <span className={`check ${t.done ? 'on' : ''}`} />
                <span className="task-text">{t.title}</span>
                <button className="task-del" onClick={e => deleteTask(e, t)} aria-label="delete task">×</button>
              </li>
            ))}
          </ul>
          <div className="task-add">
            <input
              value={newTask}
              onChange={e => setNewTask(e.target.value)}
              onKeyDown={e => e.key === 'Enter' && addTask()}
              placeholder="add a task…"
            />
            <button className="task-add-btn" onClick={addTask} aria-label="add task">+</button>
          </div>
        </section>

        {/* Mini calendar */}
        <section className="panel glass" style={{ gridArea: 'mini' }}>
          <MiniCalendar events={events} />
        </section>
      </div>

      {quickModal && (
        <EventFormModal
          mode="create"
          defaultValues={{ allDay: false, startTime: `${todayDateStr()}T09:00`, endTime: `${todayDateStr()}T10:00`, tag: 'ev-tag1' }}
          onClose={() => setQuickModal(false)}
        />
      )}
    </div>
  )
}

function PlusIcon(p) {
  return <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" {...p}><path d="M12 5v14M5 12h14" /></svg>
}

// rotating empty-state copy — picked deterministically by date so it stays
// consistent through the day instead of jittering between renders.
const EMPTY_LINES = [
  { eyebrow: 'wide open',       title: 'A day to yourself.',         hint: 'Block time before it blocks you.' },
  { eyebrow: 'clean slate',     title: 'Nothing booked.',            hint: 'Make the first move.' },
  { eyebrow: 'today',           title: 'Free as a bird.',            hint: 'Add something — or don’t.' },
  { eyebrow: 'quiet hours',     title: 'Calendar is quiet.',         hint: 'Good day to do one thing well.' },
  { eyebrow: 'unscheduled',     title: 'Your canvas is empty.',      hint: 'Sketch the day.' },
  { eyebrow: 'open agenda',     title: 'No plans yet.',              hint: 'Pick a moment, claim it.' },
  { eyebrow: 'breathing room',  title: 'Today is undecided.',        hint: 'Decide what matters.' },
  { eyebrow: 'just today',      title: 'Infinite possibilities.',    hint: 'Or just one good one.' },
]

function ScheduleEmpty({ onAdd }) {
  const idx = new Date().getDate() % EMPTY_LINES.length
  const line = EMPTY_LINES[idx]
  return (
    <div className="tl-empty">
      <svg className="tl-empty-glyph" viewBox="0 0 120 120" aria-hidden="true">
        {Array.from({ length: 6 }).map((_, i) => (
          <circle key={i} cx="60" cy="60" r={14 + i * 8} />
        ))}
        <circle className="tl-empty-dot" cx="60" cy="60" r="4" />
      </svg>
      <div className="tl-empty-eyebrow">{line.eyebrow}</div>
      <div className="tl-empty-title">{line.title}</div>
      <div className="tl-empty-hint">{line.hint}</div>
      <button className="chip primary" onClick={onAdd}>
        <PlusIcon width="14" height="14" /> add event
      </button>
    </div>
  )
}
```

## `src/pages/SettingsPage.jsx`

```jsx
import { useState } from 'react'
import { FONTS, VIBE_PRESETS, SURFACE_PRESETS } from '../lib/constants'
import { supabase } from '../lib/supabaseClient'
import LowPolyWallpaper from '../components/LowPolyWallpaper'
import VibeIcon from '../components/VibeIcon'

export default function SettingsPage({
  font, setFont,
  vibe, setVibe,
  surface, setSurface,
  density, setDensity,
  vibeDials, setVibeDial, resetVibe,
  surfaceDials, setSurfaceDial, resetSurface,
  accentBoost, setAccentBoost,
  blurAmount, setBlurAmount,
  surfaceAlpha, setSurfaceAlpha,
  panelGap, setPanelGap,
  repalette, prefId,
  wallpaper, setWallpaper,
}) {
  const [showAdvVibe, setShowAdvVibe] = useState(false)
  const [showAdvSurface, setShowAdvSurface] = useState(false)
  const [saving, setSaving] = useState(false)

  async function savePrefs() {
    setSaving(true)
    const payload = {
      font, vibe, surface, density,
      vibe_dials: vibeDials,
      surface_dials: surfaceDials,
      accent_boost: accentBoost,
      blur_amount: blurAmount,
      surface_alpha: surfaceAlpha,
      panel_gap: panelGap,
      updated_at: new Date().toISOString(),
    }
    if (prefId) {
      await supabase.from('user_preferences').update(payload).eq('id', prefId)
    } else {
      await supabase.from('user_preferences').insert(payload)
    }
    setSaving(false)
  }

  const exportPrefs = () => ({ font, vibe, surface, density, vibeDials, surfaceDials, accentBoost, blurAmount, surfaceAlpha, panelGap })

  return (
    <div className="page settings-page">
      <header className="page-header">
        <div>
          <div className="eyebrow">preferences</div>
          <h1 className="page-title">Settings</h1>
        </div>
        <div className="header-tools">
          <button className="chip primary" onClick={savePrefs} disabled={saving}>
            {saving ? 'Saving…' : 'Save preferences'}
          </button>
        </div>
      </header>

      <div className="settings-grid">
        {/* Vibe */}
        <section className="panel glass">
          <div className="panel-head"><h3>Vibe</h3><span className="muted">overall mood</span></div>
          <div className="preset-row">
            {['calm','vivid','luminous','mono'].map(v => (
              <button key={v} className={`preset-card vibe-preview vibe-${v} ${vibe === v ? 'on' : ''}`} onClick={() => setVibe(v)}>
                <VibeIcon variant={v} />
                <span className="preset-name">{v}</span>
              </button>
            ))}
          </div>
          <button className="adv-toggle" onClick={() => setShowAdvVibe(s => !s)}>
            <span className={`adv-arrow ${showAdvVibe ? 'open' : ''}`}>▸</span> advanced dials
          </button>
          <div className={`adv-dials ${showAdvVibe ? 'open' : ''}`}><div>
            <div className="setting-row"><label>Saturation × {vibeDials.satMult.toFixed(2)}<input type="range" min="0" max="2" step="0.05" value={vibeDials.satMult} onChange={e => setVibeDial('satMult', +e.target.value)} /></label></div>
            <div className="setting-row"><label>Glow alpha · {Math.round(vibeDials.glowAlpha * 100)}%<input type="range" min="0" max="0.6" step="0.02" value={vibeDials.glowAlpha} onChange={e => setVibeDial('glowAlpha', +e.target.value)} /></label></div>
            <div className="setting-row"><label>Glow blur · {vibeDials.glowBlur}px<input type="range" min="20" max="160" step="5" value={vibeDials.glowBlur} onChange={e => setVibeDial('glowBlur', +e.target.value)} /></label></div>
            <div className="setting-row"><label>Wallpaper veil · {Math.round(vibeDials.veilAlpha * 100)}%<input type="range" min="0" max="0.5" step="0.02" value={vibeDials.veilAlpha} onChange={e => setVibeDial('veilAlpha', +e.target.value)} /></label></div>
            <button className="btn ghost full" onClick={resetVibe}>↻ reset to "{vibe}"</button>
          </div></div>
        </section>

        {/* Surface */}
        <section className="panel glass">
          <div className="panel-head"><h3>Surface</h3><span className="muted">window material</span></div>
          <div className="preset-row">
            {['glass','paper','solid','sheer'].map(s => (
              <button key={s} className={`preset-card surface-preview surface-${s} ${surface === s ? 'on' : ''}`} onClick={() => setSurface(s)}>
                <span className="preset-sheet" />
                <span className="preset-name">{s}</span>
              </button>
            ))}
          </div>
          <button className="adv-toggle" onClick={() => setShowAdvSurface(s => !s)}>
            <span className={`adv-arrow ${showAdvSurface ? 'open' : ''}`}>▸</span> advanced dials
          </button>
          <div className={`adv-dials ${showAdvSurface ? 'open' : ''}`}><div>
            <div className="setting-row"><label>Opacity × {surfaceDials.alphaMult.toFixed(2)}<input type="range" min="0.2" max="2.5" step="0.05" value={surfaceDials.alphaMult} onChange={e => setSurfaceDial('alphaMult', +e.target.value)} /></label></div>
            <div className="setting-row"><label>Blur · {surfaceDials.blur}px<input type="range" min="0" max="40" step="1" value={surfaceDials.blur} onChange={e => setSurfaceDial('blur', +e.target.value)} /></label></div>
            <div className="setting-row"><label>Stroke × {surfaceDials.strokeMult.toFixed(2)}<input type="range" min="0" max="2" step="0.05" value={surfaceDials.strokeMult} onChange={e => setSurfaceDial('strokeMult', +e.target.value)} /></label></div>
            <div className="setting-row"><label>Shadow × {surfaceDials.shadowMult.toFixed(2)}<input type="range" min="0" max="2" step="0.05" value={surfaceDials.shadowMult} onChange={e => setSurfaceDial('shadowMult', +e.target.value)} /></label></div>
            <button className="btn ghost full" onClick={resetSurface}>↻ reset to "{surface}"</button>
          </div></div>
        </section>

        {/* Density */}
        <section className="panel glass">
          <div className="panel-head"><h3>Density</h3><span className="muted">spacing &amp; scale</span></div>
          <div className="preset-row">
            {[['airy','open + roomy'],['cozy','balanced'],['packed','compact']].map(([id, note]) => {
              // algorithmic dot field — count derives from grid columns squared
              const cols = id === 'airy' ? 3 : id === 'cozy' ? 4 : 6
              return (
                <button key={id} className={`preset-card density-preview density-${id} ${density === id ? 'on' : ''}`} onClick={() => setDensity(id)}>
                  <span className="density-art" aria-hidden="true">
                    {Array.from({ length: cols * cols }).map((_, i) => <span key={i} />)}
                  </span>
                  <span className="preset-name">{id}</span>
                  <span className="muted" style={{ fontSize: 10 }}>{note}</span>
                </button>
              )
            })}
          </div>
        </section>

        {/* Typography */}
        <section className="panel glass">
          <div className="panel-head"><h3>Typography</h3><span className="muted">choose a font</span></div>
          <div className="font-pick">
            {FONTS.map(f => (
              <button key={f.id} className={`font-card ${font === f.id ? 'on' : ''}`} onClick={() => setFont(f.id)} style={{ fontFamily: f.stack }}>
                <div>
                  <div className="font-name">{f.name}</div>
                  <div className="font-note">{f.note}</div>
                </div>
                <div className="font-spec">Aa 1 2 3</div>
              </button>
            ))}
          </div>
        </section>

        {/* Glass */}
        <section className="panel glass">
          <div className="panel-head"><h3>Glass</h3><span className="muted">surface feel</span></div>
          <div className="setting-row"><label>Blur strength · {blurAmount}px<input type="range" min="4" max="40" step="2" value={blurAmount} onChange={e => setBlurAmount(+e.target.value)} /></label></div>
          <div className="setting-row"><label>Surface opacity · {Math.round(surfaceAlpha * 100)}%<input type="range" min="0.2" max="0.9" step="0.05" value={surfaceAlpha} onChange={e => setSurfaceAlpha(+e.target.value)} /></label></div>
          <div className="setting-row"><label>Window gap · {panelGap}px<input type="range" min="4" max="36" step="2" value={panelGap} onChange={e => setPanelGap(+e.target.value)} /></label></div>
        </section>

        {/* Wallpaper */}
        <section className="panel glass">
          <div className="panel-head"><h3>Wallpaper</h3><span className="muted">cherry blossom</span></div>
          <div className="wp-preview">
            <LowPolyWallpaper src={wallpaper} cols={48} rows={27} />
          </div>
          <button className="btn ghost full" onClick={repalette}>↻ extract colour from wallpaper</button>
          <div className="muted small" style={{ marginTop: 8 }}>drag-and-drop your own wallpaper · coming soon</div>
        </section>

        {/* Account placeholder */}
        <section className="panel glass">
          <div className="panel-head"><h3>Account</h3><span className="muted">profile &amp; data</span></div>
          {['Profile & name','Email / password','Export data'].map((it, i) => (
            <div key={i} className="settings-row"><span>{it}</span><span className="muted">›</span></div>
          ))}
        </section>

        {/* Notifications placeholder */}
        <section className="panel glass">
          <div className="panel-head"><h3>Notifications</h3><span className="muted">coming soon</span></div>
          {['Daily digest','Event reminders','Journal nudge'].map((it, i) => (
            <div key={i} className="settings-row">
              <span>{it}</span>
              <span className="switch"><span className="dot" /></span>
            </div>
          ))}
        </section>

        {/* Sync payload */}
        <section className="panel glass" style={{ gridColumn: '1 / -1' }}>
          <div className="panel-head"><h3>Sync preferences</h3><span className="muted">JSON — ready for database</span></div>
          <pre className="json-dump">{JSON.stringify(exportPrefs(), null, 2)}</pre>
          <div className="setting-row" style={{ display: 'flex', gap: 8 }}>
            <button className="btn ghost" onClick={() => navigator.clipboard?.writeText(JSON.stringify(exportPrefs(), null, 2))}>copy JSON</button>
            <span className="muted small" style={{ alignSelf: 'center' }}>this is what gets saved to your database</span>
          </div>
        </section>
      </div>
    </div>
  )
}
```

## `src/App.jsx`

```jsx
import { useState, useEffect, useRef } from 'react'
import { supabase } from './lib/supabaseClient'
import { VIBE_PRESETS, SURFACE_PRESETS, DENSITY_PRESETS, FONTS, DEFAULT_PREFS } from './lib/constants'
import { extractPalette, applyPalette } from './lib/palette'
import NavRail from './components/NavRail'
import MobileDock from './components/MobileDock'
import HomePage from './pages/HomePage'
import CalendarPage from './pages/CalendarPage'
import JournalPage from './pages/JournalPage'
import SettingsPage from './pages/SettingsPage'
import defaultWallpaper from './assets/wallpaper.png'

const NAV_ORDER = ['home', 'calendar', 'journal', 'settings']

function toFCEvent(row) {
  return {
    id: row.id,
    title: row.title,
    start: row.start_time,
    end: row.end_time ?? undefined,
    allDay: row.all_day,
    tag: row.tag || 'ev-tag1',
  }
}

export default function App() {
  const [page, setPage] = useState('home')
  const [calView, setCalView] = useState('dayGridMonth')
  const [isMobile, setIsMobile] = useState(window.innerWidth < 880)

  const mainRef = useRef(null)
  const deltaRef = useRef(0)
  const cooldownRef = useRef(false)
  const prefsLoadedRef = useRef(false)
  const prefSaveTimer = useRef(null)
  const prefIdRef = useRef(null)

  const [events, setEvents] = useState([])
  const [tasks, setTasks] = useState([])

  const [font, setFont] = useState(DEFAULT_PREFS.font)
  const [vibe, setVibe] = useState(DEFAULT_PREFS.vibe)
  const [surface, setSurface] = useState(DEFAULT_PREFS.surface)
  const [density, setDensity] = useState(DEFAULT_PREFS.density)
  const [vibeDials, setVibeDialsState] = useState({ ...VIBE_PRESETS[DEFAULT_PREFS.vibe] })
  const [surfaceDials, setSurfaceDialsState] = useState({ ...SURFACE_PRESETS[DEFAULT_PREFS.surface] })
  const [accentBoost, setAccentBoost] = useState(DEFAULT_PREFS.accentBoost)
  const [blurAmount, setBlurAmount] = useState(DEFAULT_PREFS.blurAmount)
  const [surfaceAlpha, setSurfaceAlpha] = useState(DEFAULT_PREFS.surfaceAlpha)
  const [panelGap, setPanelGap] = useState(DEFAULT_PREFS.panelGap)
  const [prefId, setPrefId] = useState(null)
  const [lastPalette, setLastPalette] = useState(null)
  const [wallpaper, setWallpaper] = useState(defaultWallpaper)

  function setVibeDial(key, val) {
    setVibeDialsState(prev => ({ ...prev, [key]: val }))
  }
  function resetVibe() {
    setVibeDialsState({ ...VIBE_PRESETS[vibe] })
  }
  function setSurfaceDial(key, val) {
    setSurfaceDialsState(prev => ({ ...prev, [key]: val }))
  }
  function resetSurface() {
    setSurfaceDialsState({ ...SURFACE_PRESETS[surface] })
  }
  async function repalette() {
    try {
      const p = await extractPalette(wallpaper)
      setLastPalette(p)
      applyPalette(p)
    } catch (e) {
      console.error('palette error', e)
    }
  }

  // Wallpaper change → update CSS var + re-extract palette.
  // Lives in its own effect so swapping wallpapers (future drag/drop)
  // re-runs everything that depends on the image.
  useEffect(() => {
    document.documentElement.style.setProperty('--wallpaper-url', `url(${wallpaper})`)
    extractPalette(wallpaper).then(p => {
      setLastPalette(p)
      applyPalette(p)
    }).catch(console.error)
  }, [wallpaper])

  // Mount: data load, realtime subscriptions, resize
  useEffect(() => {
    supabase.from('events').select('*').order('start_time')
      .then(({ data }) => { if (data) setEvents(data.map(toFCEvent)) })

    supabase.from('tasks').select('*').order('created_at')
      .then(({ data }) => { if (data) setTasks(data) })

    supabase.from('user_preferences').select('*').limit(1).maybeSingle()
      .then(async ({ data }) => {
        if (data) {
          prefIdRef.current = data.id
          setPrefId(data.id)
          if (data.font) setFont(data.font)
          if (data.vibe) { setVibe(data.vibe); setVibeDialsState({ ...VIBE_PRESETS[data.vibe] }) }
          if (data.surface) { setSurface(data.surface); setSurfaceDialsState({ ...SURFACE_PRESETS[data.surface] }) }
          if (data.density) setDensity(data.density)
          if (data.vibe_dials) setVibeDialsState(data.vibe_dials)
          if (data.surface_dials) setSurfaceDialsState(data.surface_dials)
          if (data.accent_boost != null) setAccentBoost(data.accent_boost)
          if (data.blur_amount != null) setBlurAmount(data.blur_amount)
          if (data.surface_alpha != null) setSurfaceAlpha(data.surface_alpha)
          if (data.panel_gap != null) setPanelGap(data.panel_gap)
        } else {
          const { data: created } = await supabase.from('user_preferences').insert({}).select().single()
          if (created) { prefIdRef.current = created.id; setPrefId(created.id) }
        }
        prefsLoadedRef.current = true
      })

    const ch = supabase.channel('app-realtime')
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'events' },
        ({ new: r }) => setEvents(p => [...p, toFCEvent(r)]))
      .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'events' },
        ({ new: r }) => setEvents(p => p.map(e => e.id === r.id ? toFCEvent(r) : e)))
      .on('postgres_changes', { event: 'DELETE', schema: 'public', table: 'events' },
        ({ old: r }) => setEvents(p => p.filter(e => e.id !== r.id)))
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'tasks' },
        ({ new: r }) => setTasks(p => [...p, r]))
      .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'tasks' },
        ({ new: r }) => setTasks(p => p.map(t => t.id === r.id ? r : t)))
      .on('postgres_changes', { event: 'DELETE', schema: 'public', table: 'tasks' },
        ({ old: r }) => setTasks(p => p.filter(t => t.id !== r.id)))
      .subscribe()

    const onResize = () => setIsMobile(window.innerWidth < 880)
    window.addEventListener('resize', onResize)
    return () => {
      supabase.removeChannel(ch)
      window.removeEventListener('resize', onResize)
    }
  }, [])

  // Font → --font
  useEffect(() => {
    const f = FONTS.find(x => x.id === font)
    if (f) document.documentElement.style.setProperty('--font', f.stack)
  }, [font])

  // Vibe dials → CSS vars
  useEffect(() => {
    const r = document.documentElement
    r.style.setProperty('--vibe-sat-mult', vibeDials.satMult)
    r.style.setProperty('--vibe-glow-alpha', vibeDials.glowAlpha)
    r.style.setProperty('--vibe-glow-blur', `${vibeDials.glowBlur}px`)
    r.style.setProperty('--vibe-veil-alpha', vibeDials.veilAlpha)
  }, [vibeDials])

  // Surface dials → CSS vars (blur set here, overridden by blurAmount below)
  useEffect(() => {
    const r = document.documentElement
    r.style.setProperty('--surface-alpha-mult', surfaceDials.alphaMult)
    r.style.setProperty('--blur', `${surfaceDials.blur}px`)
    r.style.setProperty('--stroke-mult', surfaceDials.strokeMult)
    r.style.setProperty('--shadow-mult', surfaceDials.shadowMult)
    r.style.setProperty('--panel-tint', surfaceDials.panelTint ?? 0)
  }, [surfaceDials])

  // Density → CSS vars
  useEffect(() => {
    const d = DENSITY_PRESETS[density]
    const r = document.documentElement
    r.style.setProperty('--panel-pad', `${d.pad}px`)
    r.style.setProperty('--panel-gap', `${d.gap}px`)
    r.style.setProperty('--type-scale', d.scale)
    r.style.setProperty('--rad', `${d.radius}px`)
  }, [density])

  // Accent boost
  useEffect(() => {
    document.documentElement.style.setProperty('--accent-boost', accentBoost)
  }, [accentBoost])

  // Glass section blur override (wins over surfaceDials.blur)
  useEffect(() => {
    document.documentElement.style.setProperty('--blur', `${blurAmount}px`)
  }, [blurAmount])

  // Glass section surface opacity override (wins over surfaceDials.alphaMult)
  useEffect(() => {
    document.documentElement.style.setProperty('--surface-alpha-mult', surfaceAlpha)
  }, [surfaceAlpha])

  // Panel gap override
  useEffect(() => {
    document.documentElement.style.setProperty('--panel-gap', `${panelGap}px`)
  }, [panelGap])

  // Scroll-snap page navigation (desktop)
  useEffect(() => {
    if (isMobile) return
    const THRESHOLD = 420
    const COOLDOWN = 1100
    const IDLE_RESET_MS = 140
    const BOUNDARY_DWELL_MS = 220

    const lastWheelRef = { current: 0 }
    const boundaryEnterRef = { current: 0 }

    // Walk up from e.target looking for any internally scrollable ancestor
    // that is NOT at its boundary in the current scroll direction. If we
    // find one, the inner element should consume this wheel event and we
    // must not navigate (protects against momentum-carry from inner scroll
    // bleeding past its end into a tab switch).
    function innerScrollerBlocks(target, deltaY) {
      let el = target
      while (el && el !== document.body && el !== document.documentElement) {
        const cs = getComputedStyle(el)
        const oy = cs.overflowY
        if ((oy === 'auto' || oy === 'scroll') && el.scrollHeight > el.clientHeight + 1) {
          const atBottom = el.scrollTop + el.clientHeight >= el.scrollHeight - 2
          const atTop = el.scrollTop <= 2
          if ((deltaY > 0 && !atBottom) || (deltaY < 0 && !atTop)) return el
        }
        el = el.parentElement
      }
      return null
    }

    function onWheel(e) {
      if (cooldownRef.current) return
      const now = performance.now()

      // Decay accumulator if user stopped wheeling
      if (now - lastWheelRef.current > IDLE_RESET_MS) {
        deltaRef.current = 0
        boundaryEnterRef.current = 0
      }
      lastWheelRef.current = now

      // Reset on direction change
      if (deltaRef.current !== 0 && Math.sign(e.deltaY) !== Math.sign(deltaRef.current)) {
        deltaRef.current = 0
        boundaryEnterRef.current = 0
      }

      // Any nested scroller still in motion? absorb event.
      if (innerScrollerBlocks(e.target, e.deltaY)) {
        deltaRef.current = 0
        boundaryEnterRef.current = 0
        return
      }

      // Main scroll boundary check + dwell
      const main = mainRef.current
      if (main && main.scrollHeight > main.clientHeight + 2) {
        const atBottom = main.scrollTop + main.clientHeight >= main.scrollHeight - 8
        const atTop = main.scrollTop <= 8
        const atBoundary = (e.deltaY > 0 && atBottom) || (e.deltaY < 0 && atTop)
        if (!atBoundary) {
          deltaRef.current = 0
          boundaryEnterRef.current = 0
          return
        }
        if (boundaryEnterRef.current === 0) boundaryEnterRef.current = now
        if (now - boundaryEnterRef.current < BOUNDARY_DWELL_MS) return
      }

      deltaRef.current += e.deltaY
      if (Math.abs(deltaRef.current) < THRESHOLD) return

      const dir = deltaRef.current > 0 ? 1 : -1
      deltaRef.current = 0
      boundaryEnterRef.current = 0
      cooldownRef.current = true
      setTimeout(() => { cooldownRef.current = false }, COOLDOWN)

      setPage(prev => {
        const idx = NAV_ORDER.indexOf(prev)
        const next = idx + dir
        if (next < 0 || next >= NAV_ORDER.length) return prev
        return NAV_ORDER[next]
      })
    }

    window.addEventListener('wheel', onWheel, { passive: true })
    return () => window.removeEventListener('wheel', onWheel)
  }, [isMobile])

  // Touch-swipe page navigation (mobile)
  useEffect(() => {
    if (!isMobile) return
    let startX = 0, startY = 0, startT = 0, tracking = false
    const SWIPE_MIN = 60        // px horizontal
    const SWIPE_MAX_TIME = 600  // ms — quick swipes only
    const VERTICAL_TOL = 0.6    // |dy| must be < this * |dx|

    function onStart(e) {
      if (e.touches.length !== 1) { tracking = false; return }
      const t = e.touches[0]
      startX = t.clientX
      startY = t.clientY
      startT = performance.now()
      tracking = true
    }
    function onEnd(e) {
      if (!tracking) return
      tracking = false
      const t = e.changedTouches[0]
      const dx = t.clientX - startX
      const dy = t.clientY - startY
      const dt = performance.now() - startT
      if (dt > SWIPE_MAX_TIME) return
      if (Math.abs(dx) < SWIPE_MIN) return
      if (Math.abs(dy) > Math.abs(dx) * VERTICAL_TOL) return
      const dir = dx < 0 ? 1 : -1 // swipe left = next, right = prev
      setPage(prev => {
        const idx = NAV_ORDER.indexOf(prev)
        const next = idx + dir
        if (next < 0 || next >= NAV_ORDER.length) return prev
        return NAV_ORDER[next]
      })
    }

    window.addEventListener('touchstart', onStart, { passive: true })
    window.addEventListener('touchend', onEnd, { passive: true })
    return () => {
      window.removeEventListener('touchstart', onStart)
      window.removeEventListener('touchend', onEnd)
    }
  }, [isMobile])

  // Accent boost adjustment
  useEffect(() => {
    if (!lastPalette) return
    const hslRegex = /hsla?\((\d+\.?\d*),\s*(\d+\.?\d*)%,\s*(\d+\.?\d*)%/
    const match = lastPalette.accent.match(hslRegex)
    if (match) {
      const [, h, s, l] = match
      const newS = Math.min(100, Math.max(0, parseFloat(s) * accentBoost))
      const adjustedAccent = `hsl(${h}, ${newS.toFixed(0)}%, ${l})`
      document.documentElement.style.setProperty('--accent', adjustedAccent)
    }
  }, [accentBoost, lastPalette])

  // Auto-save preferences (debounced) — fires after initial load completes
  useEffect(() => {
    if (!prefsLoadedRef.current) return
    clearTimeout(prefSaveTimer.current)
    prefSaveTimer.current = setTimeout(async () => {
      const payload = {
        font, vibe, surface, density,
        vibe_dials: vibeDials,
        surface_dials: surfaceDials,
        accent_boost: accentBoost,
        blur_amount: blurAmount,
        surface_alpha: surfaceAlpha,
        panel_gap: panelGap,
        updated_at: new Date().toISOString(),
      }
      if (prefIdRef.current) {
        await supabase.from('user_preferences').update(payload).eq('id', prefIdRef.current)
      } else {
        const { data } = await supabase.from('user_preferences').insert(payload).select().single()
        if (data) { prefIdRef.current = data.id; setPrefId(data.id) }
      }
    }, 400)
    return () => clearTimeout(prefSaveTimer.current)
  }, [font, vibe, surface, density, vibeDials, surfaceDials, accentBoost, blurAmount, surfaceAlpha, panelGap])

  return (
    <div className={`app${isMobile ? ' is-mobile' : ''} vibe-${vibe} surface-${surface}`}>
      <div
        className="wallpaper"
        style={{ backgroundImage: `url(${wallpaper})` }}
      />
      <div className="wallpaper-veil" />
      <div className="vibe-glow" />

      {!isMobile && <NavRail page={page} setPage={setPage} />}

      <main className="app-main" ref={mainRef}>
        {page === 'home' && (
          <HomePage events={events} tasks={tasks} setTasks={setTasks} />
        )}
        {page === 'calendar' && (
          <CalendarPage events={events} calView={calView} setCalView={setCalView} />
        )}
        {page === 'journal' && <JournalPage />}
        {page === 'settings' && (
          <SettingsPage
            font={font} setFont={setFont}
            vibe={vibe} setVibe={v => { setVibe(v); setVibeDialsState({ ...VIBE_PRESETS[v] }) }}
            surface={surface} setSurface={s => { setSurface(s); setSurfaceDialsState({ ...SURFACE_PRESETS[s] }) }}
            density={density} setDensity={setDensity}
            vibeDials={vibeDials} setVibeDial={setVibeDial} resetVibe={resetVibe}
            surfaceDials={surfaceDials} setSurfaceDial={setSurfaceDial} resetSurface={resetSurface}
            accentBoost={accentBoost} setAccentBoost={setAccentBoost}
            blurAmount={blurAmount} setBlurAmount={setBlurAmount}
            surfaceAlpha={surfaceAlpha} setSurfaceAlpha={setSurfaceAlpha}
            panelGap={panelGap} setPanelGap={setPanelGap}
            repalette={repalette}
            prefId={prefId}
            wallpaper={wallpaper} setWallpaper={setWallpaper}
          />
        )}
      </main>

      {isMobile && <MobileDock page={page} setPage={setPage} />}
    </div>
  )
}
```

## `src/main.jsx`

```jsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
```

