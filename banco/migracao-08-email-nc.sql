-- Vistto · e-mail automático das NCs
-- Rode UMA vez no Supabase > SQL Editor > New query > Run. Não apaga nada.
-- 1) papel "Líder / encarregado" e responsável cadastrado na NC
alter table public.profiles drop constraint if exists profiles_papel_check;
alter table public.profiles add constraint profiles_papel_check check (papel in ('engenheiro','tecnico','supervisor','gestor','admin','lider'));
alter table public.ncs add column if not exists responsavel_id uuid;
alter table public.ncs add column if not exists email_enviado_em timestamptz;
alter table public.ncs add column if not exists email_para text;
alter table public.ncs add column if not exists email_erro text;
-- 2) a cada NC nova, chama a função enviar-nc (que manda o e-mail pela Brevo)
create extension if not exists pg_net;
create or replace function public.nc_email_trigger() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  perform net.http_post(
    url := 'https://mqtsxcbgcwajudatudkr.supabase.co/functions/v1/enviar-nc',
    body := jsonb_build_object('record', to_jsonb(new)),
    headers := jsonb_build_object('Content-Type', 'application/json', 'Authorization', 'Bearer ' || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1xdHN4Y2JnY3dhanVkYXR1ZGtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE4MzQ2MTQsImV4cCI6MjEwNzQxMDYxNH0.LM-3L2lZOakG84cPxQuav2ORugz9sHLcVF6uYXc9Yd0'));
  return new;
end $$;
drop trigger if exists ncs_email on public.ncs;
create trigger ncs_email after insert on public.ncs for each row execute function public.nc_email_trigger();
notify pgrst, 'reload schema';
