-- 建立 profiles 資料表 (與 auth.users 同步)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  monthly_limit INTEGER DEFAULT 3,
  current_usage INTEGER DEFAULT 0,
  last_reset_date TIMESTAMPTZ DEFAULT NOW(),
  is_pro BOOLEAN DEFAULT FALSE
);

-- 建立 summary_tasks 資料表
DO $$ BEGIN
    CREATE TYPE task_status AS ENUM ('processing', 'success', 'error');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS public.summary_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  video_url TEXT NOT NULL,
  video_id TEXT NOT NULL,
  status task_status DEFAULT 'processing',
  content TEXT,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

-- 設定 RLS (Row Level Security)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.summary_tasks ENABLE ROW LEVEL SECURITY;

-- 開放匿名服務寫入 (因為後端目前沒有傳遞 JWT Context)
DO $$ BEGIN
    CREATE POLICY "Allow anon insert to summary_tasks" ON public.summary_tasks FOR ALL USING (true) WITH CHECK (true);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE POLICY "Allow anon access to profiles" ON public.profiles FOR ALL USING (true) WITH CHECK (true);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 只有本人可以讀取自己的 profile
DO $$ BEGIN
    CREATE POLICY "Users can read own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 只有本人可以讀取自己的任務
DO $$ BEGIN
    CREATE POLICY "Users can read own tasks" ON public.summary_tasks FOR SELECT USING (auth.uid() = user_id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
