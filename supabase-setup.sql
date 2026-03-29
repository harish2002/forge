-- ═══════════════════════════════════════════════
--  FORGE Workout Tracker — Supabase Schema Setup
--  Run this in: Supabase Dashboard → SQL Editor
-- ═══════════════════════════════════════════════

-- Workouts (full workout objects stored as JSONB)
create table if not exists forge_workouts (
  id text primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  data jsonb not null,
  workout_date timestamptz,
  created_at timestamptz default now()
);

-- Body weight + body fat entries
create table if not exists forge_body (
  id bigserial primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  date text not null,
  weight numeric,
  bf numeric,
  unique(user_id, date)
);

-- Daily logs: meals, water, soreness per day
create table if not exists forge_daily (
  user_id uuid references auth.users(id) on delete cascade not null,
  date text not null,
  meals jsonb default '[]',
  water integer default 0,
  soreness jsonb default '{}',
  primary key(user_id, date)
);

-- Sleep logs
create table if not exists forge_sleep (
  id bigserial primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  date text not null,
  hours numeric,
  quality integer,
  created_at timestamptz default now()
);

-- Body measurements
create table if not exists forge_measurements (
  id bigserial primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  date text not null,
  waist numeric, chest numeric, arms numeric, thighs numeric, hips numeric,
  created_at timestamptz default now()
);

-- Personal records per exercise
create table if not exists forge_prs (
  user_id uuid references auth.users(id) on delete cascade not null,
  exercise_id text not null,
  data jsonb,
  updated_at timestamptz default now(),
  primary key(user_id, exercise_id)
);

-- User settings, custom exercises, custom templates
create table if not exists forge_userdata (
  user_id uuid references auth.users(id) on delete cascade primary key,
  custom_exercises jsonb default '[]',
  custom_templates jsonb default '[]',
  settings jsonb default '{}',
  updated_at timestamptz default now()
);

-- ── Enable Row Level Security ──
alter table forge_workouts    enable row level security;
alter table forge_body        enable row level security;
alter table forge_daily       enable row level security;
alter table forge_sleep       enable row level security;
alter table forge_measurements enable row level security;
alter table forge_prs         enable row level security;
alter table forge_userdata    enable row level security;

-- ── RLS Policies (users can only touch their own data) ──
create policy "own" on forge_workouts    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own" on forge_body        for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own" on forge_daily       for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own" on forge_sleep       for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own" on forge_measurements for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own" on forge_prs         for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own" on forge_userdata    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ── Done! ──
-- Tables created. Go back to the app and sign in with your email.
