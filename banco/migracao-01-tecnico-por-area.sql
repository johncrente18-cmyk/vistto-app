-- Vistto · técnico responsável por área (MAR)
-- Rode UMA vez no Supabase > SQL Editor > New query > Run.
-- Não apaga nada: só acrescenta a coluna nova.
alter table public.frentes add column if not exists tecnico_id uuid references public.profiles(id) on delete set null;
notify pgrst, 'reload schema';
