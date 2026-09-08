export const TASK_STATUSES = [
  "not_started",
  "in_progress",
  "submitted",
  "revision_requested",
  "approved",
  "completed",
  "blocked",
] as const;

export type TaskStatus = (typeof TASK_STATUSES)[number] | "overdue";

export const TASK_STATUS_LABEL: Record<string, string> = {
  not_started: "Not Started",
  in_progress: "In Progress",
  submitted: "Submitted",
  revision_requested: "Revision Requested",
  approved: "Approved",
  completed: "Completed",
  blocked: "Blocked",
  overdue: "Overdue",
};

export const PRIORITIES = ["low", "medium", "high", "urgent"] as const;

export const BRAND_STATUSES = ["active", "on_hold", "completed", "archived"] as const;

export const ROLE_LABEL: Record<string, string> = {
  super_admin: "Super Admin",
  manager: "Manager",
  employee: "Employee",
};

export function isOverdue(deadline: string | null, status: string) {
  if (!deadline) return false;
  if (["approved", "completed"].includes(status)) return false;
  return new Date(deadline) < new Date(new Date().toISOString().slice(0, 10));
}

export function todayISO() {
  return new Date().toISOString().slice(0, 10);
}

export function initials(name: string | null | undefined) {
  if (!name) return "??";
  return name
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((p) => p[0]!.toUpperCase())
    .join("");
}

export function hoursBetween(start: string, end: string | null) {
  const a = new Date(start).getTime();
  const b = end ? new Date(end).getTime() : Date.now();
  return Math.max(0, (b - a) / 3_600_000);
}

export function formatHours(h: number) {
  const hours = Math.floor(h);
  const mins = Math.round((h - hours) * 60);
  return `${hours}h ${String(mins).padStart(2, "0")}m`;
}

export function toCSV(rows: Record<string, unknown>[]) {
  if (rows.length === 0) return "";
  const headers = Object.keys(rows[0]!);
  const escape = (v: unknown) => `"${String(v ?? "").replace(/"/g, '""')}"`;
  return [headers.join(","), ...rows.map((r) => headers.map((h) => escape(r[h])).join(","))].join("\n");
}

export function downloadCSV(filename: string, rows: Record<string, unknown>[]) {
  const blob = new Blob([toCSV(rows)], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}
