import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";

export type Role = "super_admin" | "manager" | "employee";

export function useSession() {
  return useQuery({
    queryKey: ["session"],
    queryFn: async () => {
      const { data } = await supabase.auth.getUser();
      const user = data.user;
      if (!user) return null;
      const [{ data: profile }, { data: roles }] = await Promise.all([
        supabase.from("profiles").select("*").eq("id", user.id).maybeSingle(),
        supabase.from("user_roles").select("role").eq("user_id", user.id),
      ]);
      const roleList = (roles ?? []).map((r) => r.role as Role);
      const role: Role = roleList.includes("super_admin")
        ? "super_admin"
        : roleList.includes("manager")
          ? "manager"
          : "employee";
      return { user, profile, role, isManager: role !== "employee", isSuperAdmin: role === "super_admin" };
    },
    staleTime: 60_000,
  });
}
