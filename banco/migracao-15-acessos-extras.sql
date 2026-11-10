-- Vistto · acessos extras por pessoa (migração 15)
-- O administrador pode liberar, para uma pessoa específica, áreas além das do papel dela
-- (ex.: um líder que também precisa ver o Mapa e as Máquinas). Os papéis continuam iguais.
--   • profiles.extras: lista do que foi liberado, ex.: {"itens": ["t:mapa", "t:maq", "s:bi"]}
--   • Só o administrador consegue mudar os extras de alguém (nem a própria pessoa consegue).
--   • Quem recebe algum extra passa a ler os dados da equipe no banco (inspeções, NCs, fotos),
--     porque as telas liberadas precisam deles.
-- Não apaga nem altera nenhum dado.

alter table public.profiles add column if not exists extras jsonb not null default '{}'::jsonb;

-- só administrador muda papel, obra ou acessos extras
create or replace function public.protege_papel() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if (new.papel is distinct from old.papel or new.obra_id is distinct from old.obra_id or new.extras is distinct from old.extras)
     and auth.uid() is not null and coalesce(public.meu_papel(),'') <> 'admin' then
    raise exception 'Somente administradores alteram papel, obra ou acessos extras';
  end if;
  return new;
end $$;

create or replace function public.tem_extras() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and coalesce(ativo, true)
                 and jsonb_typeof(extras->'itens') = 'array' and jsonb_array_length(extras->'itens') > 0)
$$;
create or replace function public.tem_acesso() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and papel <> 'usuario' and coalesce(ativo, true)) or public.tem_extras()
$$;
create or replace function public.e_equipe() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and papel not in ('usuario', 'lider') and coalesce(ativo, true)) or public.tem_extras()
$$;
grant execute on function public.tem_extras() to authenticated;
grant execute on function public.tem_acesso() to authenticated;
grant execute on function public.e_equipe() to authenticated;

notify pgrst, 'reload schema';
