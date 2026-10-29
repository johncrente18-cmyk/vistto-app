-- Vistto · cadastro de pessoas (matrícula, nome de usuário e foto)
-- Rode UMA vez no Supabase > SQL Editor > New query > Run.
-- Não apaga nada: só acrescenta colunas e a função de login por usuário.
alter table public.profiles add column if not exists matricula text;
alter table public.profiles add column if not exists usuario text;
alter table public.profiles add column if not exists foto text;
create unique index if not exists profiles_usuario_uniq on public.profiles (lower(usuario)) where usuario is not null;
create or replace function public.email_por_usuario(p_usuario text) returns text
language sql stable security definer set search_path = public as $$
  select email from public.profiles where lower(usuario) = lower(trim(p_usuario)) and ativo limit 1
$$;
grant execute on function public.email_por_usuario(text) to anon, authenticated;
notify pgrst, 'reload schema';
