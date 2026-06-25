-- ============================================================
-- DoOne Demo Data Cleanup
-- Run in Supabase SQL Editor AFTER the demo
-- Wipes all demo data for user abhijitrai
-- ============================================================

do $$
declare
  uid uuid := 'd76058cc-10c2-4ef1-8e53-8766b23de294';
begin
  delete from public.events          where user_id = uid;
  delete from public.actions         where user_id = uid;
  delete from public.sessions        where user_id = uid;
  delete from public.jobs            where user_id = uid;
  delete from public.tasks           where user_id = uid;
  delete from public.behavior_memory where user_id = uid;
  delete from public.insights        where user_id = uid;
  delete from public.journal_entries where user_id = uid;
  delete from public.user_preferences where user_id = uid;
end $$;
