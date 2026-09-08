import type { ReactNode } from "react";
import { cn } from "@/lib/utils";
import { TASK_STATUS_LABEL } from "@/lib/atei";

const TONE: Record<string, string> = {
  not_started: "bg-white/5 text-muted-ink ring-line",
  in_progress: "bg-sky/12 text-sky ring-sky/25",
  submitted: "bg-amber/12 text-amber ring-amber/25",
  revision_requested: "bg-rose/12 text-rose ring-rose/25",
  approved: "bg-lime/12 text-lime ring-lime/25",
  completed: "bg-lime/12 text-lime ring-lime/25",
  blocked: "bg-viol/12 text-viol ring-viol/25",
  overdue: "bg-coral/12 text-coral ring-coral/25",
  draft: "bg-white/5 text-muted-ink ring-line",
  urgent: "bg-coral/12 text-coral ring-coral/25",
  high: "bg-amber/12 text-amber ring-amber/25",
  medium: "bg-sky/12 text-sky ring-sky/25",
  low: "bg-white/5 text-muted-ink ring-line",
  active: "bg-lime/12 text-lime ring-lime/25",
  on_hold: "bg-amber/12 text-amber ring-amber/25",
  archived: "bg-white/5 text-faint ring-line",
};

export function Pill({ value, label }: { value: string; label?: string }) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[11px] ring-1 whitespace-nowrap",
        TONE[value] ?? "bg-white/5 text-muted-ink ring-line",
      )}
    >
      <span className="size-1.5 rounded-full bg-current" />
      {label ?? TASK_STATUS_LABEL[value] ?? value.replace(/_/g, " ")}
    </span>
  );
}

export function Panel({
  title,
  subtitle,
  action,
  children,
  className,
}: {
  title?: string;
  subtitle?: string;
  action?: ReactNode;
  children: ReactNode;
  className?: string;
}) {
  return (
    <section className={cn("panel p-4", className)}>
      {(title || action) && (
        <div className="flex items-center justify-between gap-3 mb-3">
          <div className="min-w-0">
            {title && <h2 className="font-display font-bold text-[15px] tracking-tight">{title}</h2>}
            {subtitle && <p className="font-mono text-[10px] uppercase tracking-widest text-faint">{subtitle}</p>}
          </div>
          {action}
        </div>
      )}
      {children}
    </section>
  );
}

export function Kpi({
  label,
  value,
  hint,
  tone,
  progress,
}: {
  label: string;
  value: ReactNode;
  hint?: string;
  tone?: "pulse" | "coral" | "amber" | "lime" | "rose";
  progress?: number;
}) {
  const toneClass =
    tone === "coral"
      ? "text-coral"
      : tone === "amber"
        ? "text-amber"
        : tone === "lime"
          ? "text-lime"
          : tone === "rose"
            ? "text-rose"
            : "";
  return (
    <div className="panel p-4 transition hover:shadow-[inset_0_0_0_1px_var(--pulse)]">
      <p className="font-mono text-[10px] uppercase tracking-widest text-faint">{label}</p>
      <span className={cn("block font-display font-bold text-3xl tabular-nums mt-2", toneClass)}>{value}</span>
      {hint && <p className="text-[11px] text-muted-ink mt-1">{hint}</p>}
      {progress !== undefined && (
        <div className="h-1.5 rounded-full bg-white/5 mt-2 overflow-hidden">
          <div
            className="h-full rounded-full bg-gradient-to-r from-pulse to-viol"
            style={{ width: `${Math.min(100, Math.max(0, progress))}%` }}
          />
        </div>
      )}
    </div>
  );
}

export function Bar({ value }: { value: number }) {
  return (
    <div className="flex items-center gap-2 w-28">
      <div className="h-1.5 flex-1 rounded-full bg-white/5 overflow-hidden">
        <div className="h-full rounded-full bg-pulse" style={{ width: `${Math.min(100, value)}%` }} />
      </div>
      <span className="font-mono text-[11px] text-muted-ink tabular-nums">{value}%</span>
    </div>
  );
}

export function Empty({ children }: { children: ReactNode }) {
  return <p className="text-[13px] text-faint py-6 text-center">{children}</p>;
}
