-- ============================================================
-- DoOne Demo Data Insert
-- User: abhijitrai | ID: d76058cc-10c2-4ef1-8e53-8766b23de294
-- Run in Supabase SQL Editor before the demo
-- ============================================================

do $$
declare
  uid        uuid := 'd76058cc-10c2-4ef1-8e53-8766b23de294';
  job1_id    uuid := gen_random_uuid();
  job2_id    uuid := gen_random_uuid();
  job3_id    uuid := gen_random_uuid();
begin

-- ── TASKS ────────────────────────────────────────────────────
insert into public.tasks (user_id, title, priority, estimated_minutes, deadline, done)
values
  (uid, 'Send Scalio Application',        5, 30,  now() + interval '0 days', false),
  (uid, 'Finish Binary Search Leetcode Set', 5, 60, now() + interval '1 day',  false),
  (uid, 'Review System Design Notes',     4, 45,  now() + interval '3 days', false),
  (uid, 'Push Portfolio Updates',         3, 20,  now() + interval '7 days', false);

-- ── JOB 1: Scalio Founder Office Application ─────────────────
insert into public.jobs (id, user_id, title, total_time, priority, status)
values (job1_id, uid, 'Scalio Founder Office Application', 360, 5, 'active');

insert into public.sessions (job_id, user_id, title, duration, order_index, status)
values
  (job1_id, uid, 'Research Scalio Reviews',    60,  0, 'completed'),
  (job1_id, uid, 'Analyze Retention Signals',  90,  1, 'pending'),
  (job1_id, uid, 'Write Final Application',    120, 2, 'pending');

-- ── JOB 2: DSA Interview Preparation ─────────────────────────
insert into public.jobs (id, user_id, title, total_time, priority, status)
values (job2_id, uid, 'DSA Interview Preparation', 480, 4, 'active');

insert into public.sessions (job_id, user_id, title, duration, order_index, status)
values
  (job2_id, uid, 'Arrays & Hashing Revision', 90,  0, 'completed'),
  (job2_id, uid, 'Binary Search Problems',    120, 1, 'pending'),
  (job2_id, uid, 'Graphs Practice',           180, 2, 'pending');

-- ── JOB 3: Deploy Personal Portfolio ─────────────────────────
insert into public.jobs (id, user_id, title, total_time, priority, status)
values (job3_id, uid, 'Deploy Personal Portfolio', 240, 3, 'active');

insert into public.sessions (job_id, user_id, title, duration, order_index, status)
values
  (job3_id, uid, 'Homepage Design',        60, 0, 'completed'),
  (job3_id, uid, 'Project Showcase Section', 90, 1, 'pending'),
  (job3_id, uid, 'Deployment & Testing',   60, 2, 'pending');

-- ── BEHAVIOR MEMORY (10 AM peak productivity pattern) ────────
insert into public.behavior_memory (user_id, pattern_type, pattern_data, summary_text)
values
  (uid, 'hourly_completion',
   '[0.1,0.1,0.0,0.0,0.0,0.1,0.3,0.6,0.85,0.92,0.90,0.88,0.6,0.5,0.4,0.3,0.2,0.2,0.1,0.1,0.1,0.0,0.0,0.0]',
   'You do your best deep work between 9 AM and 12 PM. Completion rate drops sharply after lunch.'),
  (uid, 'daily_completion',
   '[0.4,0.85,0.90,0.88,0.82,0.5,0.3]',
   'You are most productive Tuesday through Friday. Weekends are rest days.'),
  (uid, 'skip_pattern',
   '{"skip_rate": 0.12, "common_skip_hours": [13, 14, 21]}',
   'You rarely skip tasks. When you do, it is usually right after lunch or late at night.'),
  (uid, 'preferred_duration',
   '{"avg_duration": 52, "sweet_spot_min": 30, "sweet_spot_max": 90}',
   'You consistently finish 30–90 min sessions. Longer sessions tend to get abandoned.')
on conflict (user_id, pattern_type) do update
  set pattern_data  = excluded.pattern_data,
      summary_text  = excluded.summary_text;

-- ── USER PREFERENCES ─────────────────────────────────────────
insert into public.user_preferences (user_id, vibe_dials, font)
values (
  uid,
  '{"satMult": 1.05, "lightShift": 0.04, "glowAlpha": 0.10, "glowBlur": 80, "veilAlpha": 0.18}',
  'Inter'
)
on conflict (user_id) do update
  set vibe_dials = excluded.vibe_dials,
      font       = excluded.font;

end $$;
