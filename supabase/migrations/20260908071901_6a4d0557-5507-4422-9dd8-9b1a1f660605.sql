
CREATE POLICY "evidence upload own folder" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'work-evidence' AND (storage.foldername(name))[1] = auth.uid()::text);
CREATE POLICY "evidence read own or manager" ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'work-evidence' AND ((storage.foldername(name))[1] = auth.uid()::text OR public.is_manager(auth.uid())));
CREATE POLICY "evidence delete own" ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'work-evidence' AND (storage.foldername(name))[1] = auth.uid()::text);
