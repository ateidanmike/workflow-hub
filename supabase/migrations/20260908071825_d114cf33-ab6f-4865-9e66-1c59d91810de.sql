
-- ROLES
CREATE TYPE public.app_role AS ENUM ('super_admin','manager','employee');

CREATE TABLE public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text NOT NULL DEFAULT '',
  email text NOT NULL DEFAULT '',
  job_title text,
  phone text,
  manager_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  status text NOT NULL DEFAULT 'active',
  avatar_url text,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role public.app_role NOT NULL,
  UNIQUE (user_id, role)
);
GRANT SELECT ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role)
$$;

CREATE OR REPLACE FUNCTION public.is_manager(_user_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role IN ('manager','super_admin'))
$$;

CREATE POLICY "profiles readable by authenticated" ON public.profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "own profile insert" ON public.profiles FOR INSERT TO authenticated WITH CHECK (id = auth.uid() OR public.has_role(auth.uid(),'super_admin'));
CREATE POLICY "own profile update" ON public.profiles FOR UPDATE TO authenticated USING (id = auth.uid() OR public.has_role(auth.uid(),'super_admin'));
CREATE POLICY "super admin delete profile" ON public.profiles FOR DELETE TO authenticated USING (public.has_role(auth.uid(),'super_admin'));

CREATE POLICY "roles readable by authenticated" ON public.user_roles FOR SELECT TO authenticated USING (true);
CREATE POLICY "super admin manages roles" ON public.user_roles FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'super_admin')) WITH CHECK (public.has_role(auth.uid(),'super_admin'));

-- signup trigger: profile + default employee role; first user becomes super admin
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE user_count int;
BEGIN
  INSERT INTO public.profiles (id, full_name, email)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name',''), COALESCE(NEW.email,''));
  SELECT count(*) INTO user_count FROM public.profiles;
  IF user_count <= 1 THEN
    INSERT INTO public.user_roles (user_id, role) VALUES (NEW.id, 'super_admin');
  ELSE
    INSERT INTO public.user_roles (user_id, role) VALUES (NEW.id, 'employee');
  END IF;
  RETURN NEW;
END; $$;

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- BRANDS / PROJECTS
CREATE TABLE public.brands (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  client_name text,
  description text,
  status text NOT NULL DEFAULT 'active',
  logo_url text,
  account_manager_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  start_date date,
  end_date date,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.brands TO authenticated;
GRANT ALL ON public.brands TO service_role;
ALTER TABLE public.brands ENABLE ROW LEVEL SECURITY;
CREATE POLICY "brands readable" ON public.brands FOR SELECT TO authenticated USING (true);
CREATE POLICY "managers write brands" ON public.brands FOR ALL TO authenticated
  USING (public.is_manager(auth.uid())) WITH CHECK (public.is_manager(auth.uid()));

CREATE TABLE public.projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id uuid NOT NULL REFERENCES public.brands(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  status text NOT NULL DEFAULT 'active',
  start_date date,
  end_date date,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.projects TO authenticated;
GRANT ALL ON public.projects TO service_role;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "projects readable" ON public.projects FOR SELECT TO authenticated USING (true);
CREATE POLICY "managers write projects" ON public.projects FOR ALL TO authenticated
  USING (public.is_manager(auth.uid())) WITH CHECK (public.is_manager(auth.uid()));

-- TASKS
CREATE TABLE public.tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  brand_id uuid REFERENCES public.brands(id) ON DELETE SET NULL,
  project_id uuid REFERENCES public.projects(id) ON DELETE SET NULL,
  assignee_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  assigned_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  priority text NOT NULL DEFAULT 'medium',
  status text NOT NULL DEFAULT 'not_started',
  start_date date,
  deadline date,
  estimated_hours numeric,
  progress int NOT NULL DEFAULT 0,
  deliverables text,
  locked boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.tasks TO authenticated;
GRANT ALL ON public.tasks TO service_role;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "tasks readable" ON public.tasks FOR SELECT TO authenticated USING (true);
CREATE POLICY "managers manage tasks" ON public.tasks FOR ALL TO authenticated
  USING (public.is_manager(auth.uid())) WITH CHECK (public.is_manager(auth.uid()));
CREATE POLICY "assignee updates own task" ON public.tasks FOR UPDATE TO authenticated
  USING (assignee_id = auth.uid() AND locked = false) WITH CHECK (assignee_id = auth.uid());

CREATE TABLE public.task_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id uuid NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
  author_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  kind text NOT NULL DEFAULT 'comment',
  body text NOT NULL,
  rating int,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.task_comments TO authenticated;
GRANT ALL ON public.task_comments TO service_role;
ALTER TABLE public.task_comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "comments readable" ON public.task_comments FOR SELECT TO authenticated USING (true);
CREATE POLICY "comments insert" ON public.task_comments FOR INSERT TO authenticated WITH CHECK (author_id = auth.uid());

CREATE TABLE public.task_progress_updates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id uuid NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  from_progress int,
  to_progress int,
  from_status text,
  to_status text,
  note text,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT ON public.task_progress_updates TO authenticated;
GRANT ALL ON public.task_progress_updates TO service_role;
ALTER TABLE public.task_progress_updates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "progress readable" ON public.task_progress_updates FOR SELECT TO authenticated USING (true);
CREATE POLICY "progress insert" ON public.task_progress_updates FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

-- DAILY LOGS
CREATE TABLE public.daily_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  log_date date NOT NULL DEFAULT (now() AT TIME ZONE 'utc')::date,
  status text NOT NULL DEFAULT 'draft',
  submitted_at timestamptz,
  reviewed_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  reviewed_at timestamptz,
  review_note text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, log_date)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.daily_logs TO authenticated;
GRANT ALL ON public.daily_logs TO service_role;
ALTER TABLE public.daily_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "logs readable by owner or manager" ON public.daily_logs FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.is_manager(auth.uid()));
CREATE POLICY "logs insert own" ON public.daily_logs FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "logs update own draft" ON public.daily_logs FOR UPDATE TO authenticated
  USING ((user_id = auth.uid() AND status IN ('draft','revision_requested')) OR public.is_manager(auth.uid()));
CREATE POLICY "logs delete own draft" ON public.daily_logs FOR DELETE TO authenticated
  USING (user_id = auth.uid() AND status = 'draft');

CREATE TABLE public.daily_log_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  log_id uuid NOT NULL REFERENCES public.daily_logs(id) ON DELETE CASCADE,
  task_id uuid REFERENCES public.tasks(id) ON DELETE SET NULL,
  brand_id uuid REFERENCES public.brands(id) ON DELETE SET NULL,
  activity text NOT NULL,
  hours numeric NOT NULL DEFAULT 0,
  progress_before int,
  progress_after int,
  description text,
  challenges text,
  next_action text,
  link_url text,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.daily_log_items TO authenticated;
GRANT ALL ON public.daily_log_items TO service_role;
ALTER TABLE public.daily_log_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "log items readable" ON public.daily_log_items FOR SELECT TO authenticated
  USING (public.is_manager(auth.uid()) OR EXISTS (SELECT 1 FROM public.daily_logs l WHERE l.id = log_id AND l.user_id = auth.uid()));
CREATE POLICY "log items write own draft" ON public.daily_log_items FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.daily_logs l WHERE l.id = log_id AND l.user_id = auth.uid() AND l.status IN ('draft','revision_requested')))
  WITH CHECK (EXISTS (SELECT 1 FROM public.daily_logs l WHERE l.id = log_id AND l.user_id = auth.uid() AND l.status IN ('draft','revision_requested')));

CREATE TABLE public.log_photos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  log_item_id uuid REFERENCES public.daily_log_items(id) ON DELETE CASCADE,
  task_id uuid REFERENCES public.tasks(id) ON DELETE CASCADE,
  owner_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  storage_path text NOT NULL,
  caption text,
  latitude double precision,
  longitude double precision,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.log_photos TO authenticated;
GRANT ALL ON public.log_photos TO service_role;
ALTER TABLE public.log_photos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "photos readable" ON public.log_photos FOR SELECT TO authenticated
  USING (owner_id = auth.uid() OR public.is_manager(auth.uid()));
CREATE POLICY "photos insert own" ON public.log_photos FOR INSERT TO authenticated WITH CHECK (owner_id = auth.uid());
CREATE POLICY "photos delete own" ON public.log_photos FOR DELETE TO authenticated USING (owner_id = auth.uid());

-- ATTENDANCE
CREATE TABLE public.attendance_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  work_date date NOT NULL DEFAULT (now() AT TIME ZONE 'utc')::date,
  clock_in_at timestamptz NOT NULL DEFAULT now(),
  clock_out_at timestamptz,
  in_latitude double precision,
  in_longitude double precision,
  in_accuracy double precision,
  out_latitude double precision,
  out_longitude double precision,
  device text,
  ip_address text,
  late_reason text,
  correction_note text,
  correction_status text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, work_date)
);
GRANT SELECT, INSERT, UPDATE ON public.attendance_records TO authenticated;
GRANT ALL ON public.attendance_records TO service_role;
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "attendance readable" ON public.attendance_records FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.is_manager(auth.uid()));
CREATE POLICY "attendance insert own" ON public.attendance_records FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "attendance update" ON public.attendance_records FOR UPDATE TO authenticated
  USING (user_id = auth.uid() OR public.is_manager(auth.uid()));

-- protect attendance timestamps from employee edits
CREATE OR REPLACE FUNCTION public.protect_attendance()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF NOT public.is_manager(auth.uid()) THEN
    NEW.clock_in_at := OLD.clock_in_at;
    NEW.in_latitude := OLD.in_latitude;
    NEW.in_longitude := OLD.in_longitude;
    NEW.work_date := OLD.work_date;
    IF OLD.clock_out_at IS NOT NULL THEN
      NEW.clock_out_at := OLD.clock_out_at;
    ELSIF NEW.clock_out_at IS NOT NULL THEN
      NEW.clock_out_at := now();
    END IF;
  END IF;
  RETURN NEW;
END; $$;
CREATE TRIGGER attendance_protect BEFORE UPDATE ON public.attendance_records
FOR EACH ROW EXECUTE FUNCTION public.protect_attendance();

-- server-time clock-in
CREATE OR REPLACE FUNCTION public.force_server_clock_in()
RETURNS trigger LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  NEW.clock_in_at := now();
  NEW.work_date := (now() AT TIME ZONE 'utc')::date;
  NEW.clock_out_at := NULL;
  RETURN NEW;
END; $$;
CREATE TRIGGER attendance_server_time BEFORE INSERT ON public.attendance_records
FOR EACH ROW EXECUTE FUNCTION public.force_server_clock_in();

-- NOTIFICATIONS
CREATE TABLE public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title text NOT NULL,
  body text,
  link text,
  kind text NOT NULL DEFAULT 'info',
  read_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notifications TO authenticated;
GRANT ALL ON public.notifications TO service_role;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "notifications own" ON public.notifications FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "notifications insert" ON public.notifications FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "notifications update own" ON public.notifications FOR UPDATE TO authenticated USING (user_id = auth.uid());
