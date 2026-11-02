-- Vistto · cadastro completo pelo app: telefone, nome de usuário, matrícula e foto de perfil
-- 1) a conta nova já grava os dados preenchidos no cadastro
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
declare m jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb); u text := nullif(lower(trim(m->>'usuario')), '');
begin
  if u is not null and exists (select 1 from public.profiles where lower(usuario) = u) then u := null; end if;
  insert into public.profiles (id, nome, email, obra_id, telefone, usuario, matricula)
  values (new.id, coalesce(nullif(trim(m->>'nome'), ''), split_part(new.email,'@',1)), new.email, 'ufv-paraiso',
          nullif(trim(m->>'telefone'), ''), u, nullif(trim(m->>'matricula'), ''))
  on conflict (id) do nothing;
  return new;
end $$;
-- 2) foto de perfil enviada logo após criar a conta (só vale para conta recém-criada e ainda sem foto)
create or replace function public.foto_cadastro(p_email text, p_foto text) returns boolean
language plpgsql security definer set search_path = public as $$
begin
  if p_foto is null or p_foto not like 'data:image/%' or length(p_foto) > 400000 then return false; end if;
  update public.profiles set foto = p_foto
   where lower(email) = lower(trim(p_email)) and foto is null and criado_em > now() - interval '15 minutes';
  return found;
end $$;
grant execute on function public.foto_cadastro(text, text) to anon, authenticated;
notify pgrst, 'reload schema';
