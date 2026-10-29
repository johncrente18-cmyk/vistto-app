-- Vistto · papel "Supervisor"
-- Rode UMA vez no Supabase > SQL Editor > New query > Run.
-- Não apaga nada: só passa a aceitar o papel 'supervisor'.
alter table public.profiles drop constraint if exists profiles_papel_check;
alter table public.profiles add constraint profiles_papel_check check (papel in ('engenheiro','tecnico','supervisor','gestor','admin'));
