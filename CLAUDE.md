# Day Planner — CLAUDE.md

## What This Project Is

Personal daily planner web app, glassmorphism UI. Interactive calendar (FullCalendar), task mgmt, focus progress ring, AI agent tools layer for LLM-driven scheduling.

## Tech Stack

| Layer | Tech |
|---|---|
| Frontend | React 19, Vite 8 |
| Calendar | FullCalendar 6 (daygrid, timegrid, interaction plugins) |
| Backend / DB | Supabase (PostgreSQL + Realtime) |
| Icons | lucide-react |
| Styling | Plain CSS3, glassmorphism |
| Language | JavaScript (JSX) |

## Project Structure

```
src/
  App.jsx             # Root layout — 3-column grid (sidebar | calendar | sidebar)
  App.css             # Layout, cards, focus ring, quote styles
  index.css           # Global styles + FullCalendar overrides
  components/
    Planner.jsx       # FullCalendar wrapper — event CRUD + Supabase Realtime
  lib/
    supabaseClient.js # Supabase singleton client
  ai-agent/
    tools.js          # LLM-callable tools (create/update/delete/search/free-slot detection)
supabase-setup.sql    # DB schema + RLS policies (run once in Supabase SQL editor)
.env.example          # Copy to .env and fill in Supabase credentials
```

## Environment Setup

Copy `.env.example` to `.env`, fill:
```
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
```

## Dev Commands

```bash
npm install      # install deps
npm run dev      # start dev server (Vite)
npm run build    # production build
npm run preview  # preview production build
npm run lint     # ESLint
```

## Database

Schema in `supabase-setup.sql`. Run once in Supabase SQL editor — creates `events` table, enables Realtime.

Table: `public.events` — `id (uuid)`, `title (text)`, `start_time (timestamptz)`, `end_time (timestamptz)`, `all_day (boolean)`, `created_at (timestamptz)`

RLS enabled, policies permissive (no auth) — demo mode.

## Architecture Notes

- **Events**: Persisted in Supabase. `Planner.jsx` subscribes to Postgres changes, refetches on INSERT/UPDATE/DELETE — calendar stays live.
- **Tasks**: Hardcoded in `App.jsx` local state — not persisted.
- **AI Tools** (`src/ai-agent/tools.js`): Standalone async fns for LLM agents. Event CRUD, fuzzy search, conflict checking, free-slot finding. Not wired to UI.
- **Focus Ring**: SVG `stroke-dashoffset` driven by ratio of completed tasks. Circumference 314px.

## Design System

- Font: `Outfit` (Google Fonts, weights 300–700)
- Glassmorphism: `backdrop-filter: blur()`, semi-transparent white bg, 1px white borders
- Palette: Pink/magenta bg, white text, glass cards ~10–30% opacity
- Border radius: 16–24px cards, 12px buttons
- FullCalendar heavily restyled in `index.css` to match glass theme

## Known Gaps / TODOs

- Task persistence (no Supabase table, state hardcoded)
- User auth (RLS wide-open)
- Mobile responsiveness (fixed 3-column grid)
- LLM UI integration (tools.js exists, no UI entry point)
