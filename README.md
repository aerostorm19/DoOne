# DoOne

> A quieter way to plan the day.

DoOne is a personal productivity app that solves decision fatigue. Instead of showing everything on your to-do list, it uses a deterministic scoring engine to recommend exactly **one action** — the right thing to do right now.

---

## The Problem

Most productivity apps show you everything. But the real problem isn't managing tasks — it's deciding what to do next. Too many priorities, too many choices, and decision fatigue sets in before you even start.

---

## How It Works

DoOne combines:

- **Priority** — how important is this task?
- **Urgency** — how close is the deadline?
- **Time fit** — does this fit in your current available time?
- **Behavior patterns** — when are you historically most productive?
- **Momentum** — are you in a flow state right now?
- **Session progress** — how far along is this job?

Six factors. Fixed weights. One recommendation. AI doesn't make the decision — math does. AI only explains it in plain language.

---

## Features

- **NowCard** — single focused recommendation with a plain-language reason
- **Jobs & Sessions** — break large projects into AI-planned work sessions
- **Tasks** — quick one-off items with priority and deadlines
- **Calendar** — schedule and visualize your day
- **Journal** — daily did / plan / mood entries
- **Behavior Insights** — weekly AI summary of your productivity patterns
- **Theming** — vibe presets, wallpapers, glassmorphism UI, font picker

---

## Tech Stack

| Layer | Tech |
|---|---|
| Framework | Next.js 16 (App Router) |
| Frontend | React 19, Zustand |
| Database | Supabase (Postgres + Realtime + Auth) |
| AI | Anthropic Claude (Sonnet 4.6 + Haiku 4.5) |
| Styling | CSS custom properties, glassmorphism |
| Deployment | Vercel |

---

## AI Agents

| Agent | Model | Role |
|---|---|---|
| Planner | Claude Sonnet 4.6 | Breaks jobs into sessions with time-balanced planning |
| Formatter | Claude Haiku 4.5 | Writes one warm sentence explaining the suggestion |
| Insight | Claude Haiku 4.5 | Generates weekly productivity summary |
| Memory | Claude Haiku 4.5 | Turns behavior patterns into human-readable observations |

Every agent has a deterministic fallback — the app works even without an Anthropic key.

---

## Getting Started

### 1. Clone and install

```bash
git clone https://github.com/aerostorm19/DoOne.git
cd DoOne
npm install
```

### 2. Set up Supabase

1. Create a free project at [supabase.com](https://supabase.com)
2. Run the following SQL files in order via the SQL Editor:
   - `supabase-setup.sql`
   - `supabase-doone-schema.sql`
   - `supabase-migrate.sql`
3. In Authentication → Settings, disable **"Enable email confirmations"** for local dev

### 3. Configure environment

```bash
cp .env.example .env.local
```

Fill in `.env.local`:

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
ANTHROPIC_API_KEY=sk-ant-...   # optional — app works without it
```

### 4. Run locally

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

---

## Scoring Engine

The suggestion engine in `lib/suggestion-engine.js` scores every pending task and session deterministically:

| Factor | Weight | Logic |
|---|---|---|
| Priority | 30% | Linear scale from task.priority (1–5) |
| Urgency | 25% | Exponential decay based on hours until deadline |
| Time fit | 20% | How well estimated_minutes fits available time |
| Behavior | 10% | Historical completion rate at the current hour |
| Momentum | 10% | Recent completions in the last 2 hours |
| Session progress | 5% | Bonus for jobs already in progress |

---

## Project Structure

```
app/
  api/                  # Next.js API routes (serverless)
    suggestion/         # GET — scoring engine, returns one item
    actions/            # POST — log done/skip, trigger side effects
    behavior/           # POST — recompute behavior memory
    jobs/               # CRUD for jobs
    sessions/           # CRUD for sessions
    ai/
      breakdown/        # Planner agent — job → sessions
      format/           # Formatter agent — suggestion → sentence
      insights/         # Insight agent — weekly summary
      memory/           # Memory agent — pattern observations
  layout.jsx
  page.jsx
lib/
  suggestion-engine.js  # Pure deterministic scoring
  auth.js               # JWT validation
  supabase-server.js    # Service role + anon clients
  anthropic.js          # Anthropic singleton
src/
  App.jsx               # Main shell, routing, preferences, realtime
  views/                # HomePage, JobsPage, CalendarPage, etc.
  components/           # NowCard, TaskList, NavRail, etc.
  stores/               # Zustand: suggestion, jobs, insights
  lib/                  # authContext, palette, constants, journalStorage
```

---

## Deployment

Deploy to Vercel in one click:

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/aerostorm19/DoOne)

Set the same environment variables from `.env.local` in your Vercel project settings.

---

## License

MIT
