import { Link, useNavigate, useRouterState } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import type { ReactNode } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useSession } from "@/lib/session";
import { ROLE_LABEL, initials } from "@/lib/atei";
import { cn } from "@/lib/utils";

type NavItem = { to: string; label: string; managerOnly?: boolean; superOnly?: boolean };

const NAV: NavItem[] = [
  { to: "/dashboard", label: "Overview" },
  { to: "/tasks", label: "Tasks" },
  { to: "/daily-log", label: "Daily Log" },
  { to: "/attendance", label: "Attendance" },
  { to: "/approvals", label: "Approvals", managerOnly: true },
  { to: "/brands", label: "Brands", managerOnly: true },
  { to: "/people", label: "People", superOnly: true },
  { to: "/reports", label: "Reports", managerOnly: true },
];

export function AppShell({ title, subtitle, children }: { title: string; subtitle?: string; children: ReactNode }) {
  const { data: session } = useSession();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const pathname = useRouterState({ select: (s) => s.location.pathname });

  const { data: unread } = useQuery({
    queryKey: ["unread-count", session?.user.id],
    enabled: !!session,
    queryFn: async () => {
      const { count } = await supabase
        .from("notifications")
        .select("id", { count: "exact", head: true })
        .is("read_at", null);
      return count ?? 0;
    },
    refetchInterval: 60_000,
  });

  const items = NAV.filter(
    (i) => (!i.managerOnly || session?.isManager) && (!i.superOnly || session?.isSuperAdmin),
  );

  async function signOut() {
    await queryClient.cancelQueries();
    queryClient.clear();
    await supabase.auth.signOut();
    navigate({ to: "/auth", replace: true });
  }

  return (
    <div className="relative min-h-screen bg-canvas text-ink text-sm overflow-hidden">
      <div className="pointer-events-none absolute -top-40 -left-32 size-[520px] rounded-full bg-pulse/10 blur-[120px]" />
      <div className="pointer-events-none absolute -bottom-40 right-0 size-[480px] rounded-full bg-viol/10 blur-[130px]" />

      <div className="relative flex">
        <aside className="hidden md:flex w-56 shrink-0 flex-col gap-1 p-3 sticky top-0 h-screen border-r border-line backdrop-blur-xl bg-surface">
          <div className="flex items-center gap-2 px-3 py-2 mb-2">
            <div className="size-7 rounded-md bg-gradient-to-br from-pulse to-viol grid place-items-center font-display font-bold text-canvas text-xs">
              A
            </div>
            <div className="leading-tight">
              <p className="font-display font-bold text-[15px]">Atei</p>
              <p className="font-mono text-[9px] text-muted-ink tracking-widest">DEVOPS OPS</p>
            </div>
          </div>
          <p className="px-3 text-[9px] font-mono uppercase tracking-widest text-faint mb-1">Workspace</p>
          <nav className="flex flex-col gap-0.5">
            {items.map((item) => {
              const active = pathname === item.to;
              return (
                <Link
                  key={item.to}
                  to={item.to}
                  className={cn(
                    "flex items-center gap-2.5 px-3 py-2 rounded-lg transition",
                    active
                      ? "bg-surface-2 text-ink ring-1 ring-white/5"
                      : "text-muted-ink hover:text-ink hover:bg-surface-2",
                  )}
                >
                  <span className={cn("size-1.5 rounded-full", active ? "bg-pulse" : "bg-faint")} />
                  {item.label}
                </Link>
              );
            })}
          </nav>
          <p className="px-3 pt-2 text-[9px] font-mono uppercase tracking-widest text-faint mb-1">Role</p>
          <div className="flex items-center justify-between px-3 py-1.5">
            <span className="font-mono text-[10px] text-muted-ink">
              {ROLE_LABEL[session?.role ?? "employee"]}
            </span>
            <button onClick={signOut} className="text-[9px] font-mono text-faint hover:text-coral">
              SIGN OUT
            </button>
          </div>
          <div className="mt-auto p-3 rounded-lg bg-surface-2 ring-1 ring-white/5">
            <p className="font-mono text-[9px] text-faint mb-1.5">ACCOUNT</p>
            <p className="text-[12px] truncate">{session?.profile?.full_name || session?.user.email}</p>
            <p className="font-mono text-[10px] text-faint truncate">{session?.profile?.job_title || "Team member"}</p>
          </div>
        </aside>

        <main className="flex-1 min-w-0 p-4 md:p-6 pb-24 md:pb-6">
          <header className="rise flex items-center gap-3 mb-5">
            <div className="min-w-0">
              <h1 className="font-display font-bold text-xl md:text-2xl tracking-tight text-balance">{title}</h1>
              {subtitle && <p className="font-mono text-[11px] text-muted-ink">{subtitle}</p>}
            </div>
            <div className="ml-auto flex items-center gap-2">
              <Link
                to="/notifications"
                className="relative size-9 rounded-lg bg-surface backdrop-blur-xl ring-1 ring-line grid place-items-center"
              >
                <span className="font-mono text-[11px] text-muted-ink">
                  {initials(session?.profile?.full_name || session?.user.email)}
                </span>
                {!!unread && <span className="absolute -top-1 -right-1 size-2.5 rounded-full bg-coral ring-2 ring-canvas" />}
              </Link>
            </div>
          </header>
          {children}
        </main>
      </div>

      <nav className="md:hidden fixed bottom-0 inset-x-0 z-20 flex justify-around border-t border-line bg-canvas/95 backdrop-blur-xl px-1 py-2">
        {items.slice(0, 5).map((item) => (
          <Link
            key={item.to}
            to={item.to}
            className={cn(
              "flex-1 text-center text-[11px] py-2 rounded-lg",
              pathname === item.to ? "text-pulse bg-surface-2" : "text-muted-ink",
            )}
          >
            {item.label}
          </Link>
        ))}
      </nav>
    </div>
  );
}
