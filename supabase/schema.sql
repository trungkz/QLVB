-- Đã được áp dụng sẵn cho dự án Supabase QLVB. Chỉ cần chạy lại khi dùng dự án Supabase khác:
-- Supabase > SQL Editor > New query > dán toàn bộ file > Run (chạy lại nhiều lần vẫn an toàn).
-- Các bảng dùng tiền tố vb_ để không trùng với bảng khác trong dự án.

create table if not exists public.vb_documents (
  id          text primary key,
  doc_date    date not null,                         -- ngày đến
  doc_no      text not null,                         -- số văn bản
  doc_type    text not null default 'Công văn',      -- loại văn bản
  summary     text not null,                         -- nội dung tóm tắt
  officer     text not null default '',              -- cán bộ phụ trách
  mode        text not null default 'bc' check (mode in ('bc','ndb')), -- bc: có hạn báo cáo, ndb: nhận để biết
  handled     boolean not null default false,        -- đã hoàn thành xử lý
  periodic    boolean not null default false,        -- báo cáo định kỳ
  freq        text,                                  -- m/q/h/y: tháng/quý/6 tháng/năm
  pdf         text,                                  -- tên file PDF văn bản
  done_files  jsonb not null default '[]'::jsonb,    -- tệp đính kèm khi hoàn thành xử lý
  milestones  jsonb not null default '[]'::jsonb,    -- các mốc hạn báo cáo [{d,done,files}]
  created_by  uuid default auth.uid(),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index if not exists vb_documents_doc_date_idx on public.vb_documents (doc_date desc);

create table if not exists public.vb_staff (
  name       text primary key,
  created_at timestamptz not null default now()
);

create or replace function public.vb_set_updated_at() returns trigger
language plpgsql set search_path = '' as $$ begin new.updated_at = now(); return new; end $$;
drop trigger if exists vb_documents_updated_at on public.vb_documents;
create trigger vb_documents_updated_at before update on public.vb_documents
for each row execute function public.vb_set_updated_at();

-- Bảo mật (RLS): chỉ người đã đăng nhập mới đọc/ghi được
alter table public.vb_documents enable row level security;
alter table public.vb_staff     enable row level security;
drop policy if exists "vb_documents_all_authenticated" on public.vb_documents;
create policy "vb_documents_all_authenticated" on public.vb_documents
  for all to authenticated using (true) with check (true);
drop policy if exists "vb_staff_all_authenticated" on public.vb_staff;
create policy "vb_staff_all_authenticated" on public.vb_staff
  for all to authenticated using (true) with check (true);

-- Kho lưu tệp đính kèm (riêng tư)
insert into storage.buckets (id, name, public)
values ('vb-attachments', 'vb-attachments', false)
on conflict (id) do nothing;
drop policy if exists "vb_attachments_all_authenticated" on storage.objects;
create policy "vb_attachments_all_authenticated" on storage.objects
  for all to authenticated
  using (bucket_id = 'vb-attachments') with check (bucket_id = 'vb-attachments');

-- Đồng bộ thời gian thực giữa nhiều người dùng
do $$ begin alter publication supabase_realtime add table public.vb_documents; exception when duplicate_object then null; end $$;
do $$ begin alter publication supabase_realtime add table public.vb_staff;     exception when duplicate_object then null; end $$;
