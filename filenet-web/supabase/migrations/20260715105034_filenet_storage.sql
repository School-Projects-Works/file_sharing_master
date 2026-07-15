-- Private "files" bucket. Objects are stored at "{owner_id}/{file_id}/{version_id}.pdf"
-- so the top-level path segment doubles as an ownership check for inserts, and each
-- version gets its own immutable object.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('files', 'files', false, 26214400, array['application/pdf'])
on conflict (id) do nothing;

create policy files_bucket_select on storage.objects for select
  using (
    bucket_id = 'files'
    and (
      is_admin()
      or exists (
        select 1 from file_versions fv
        where fv.storage_path = storage.objects.name
          and (owns_file(fv.file_id) or file_shared_with_me(fv.file_id))
      )
    )
  );

create policy files_bucket_insert on storage.objects for insert
  with check (
    bucket_id = 'files'
    and is_active()
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy files_bucket_delete on storage.objects for delete
  using (
    bucket_id = 'files'
    and (
      is_admin()
      or (storage.foldername(name))[1] = auth.uid()::text
    )
  );
