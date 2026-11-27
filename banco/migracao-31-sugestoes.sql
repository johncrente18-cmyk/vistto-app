-- Vistto · Sugestões da equipe (migração 31)
-- Qualquer pessoa da equipe sugere (alterar/nova/remover pergunta, novo checklist, melhoria, problema),
-- todos veem e apoiam (👍); só o administrador muda o status e responde.
-- Quando o administrador responde, "visto_autor" vira false e o app avisa quem sugeriu.
-- Não altera nenhuma tabela existente.

create table if not exists public.sugestoes (
  id uuid primary key,
  obra_id text references public.obras(id),
  autor_id uuid not null default auth.uid() references public.profiles(id),
  tipo text not null check (tipo in ('alterar', 'nova', 'remover', 'checklist', 'app', 'problema')),
  tipo_inspecao text,                -- checklist citado (quando veio de uma pergunta)
  tipo_nome text,
  item_id text,                      -- pergunta citada
  pergunta text,
  texto text not null check (length(trim(texto)) > 0),
  foto_id uuid,
  status text not null default 'nova' check (status in ('nova', 'analise', 'feita', 'recusada')),
  resposta text,
  respondido_por uuid references public.profiles(id),
  respondido_em timestamptz,
  visto_autor boolean not null default true,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create index if not exists sugestoes_criado_idx on public.sugestoes (criado_em desc);

create table if not exists public.sugestao_apoios (
  id text primary key,               -- '<sugestao_id>:<user_id>'
  sugestao_id uuid not null references public.sugestoes(id) on delete cascade,
  user_id uuid not null default auth.uid() references public.profiles(id),
  ativo boolean not null default true,
  criado_em timestamptz not null default now()
);
create index if not exists sugestao_apoios_sug_idx on public.sugestao_apoios (sugestao_id);

-- quem não é administrador só pode marcar "já vi a resposta"; status e resposta são do administrador
create or replace function public.sugestoes_protege() returns trigger
language plpgsql security definer set search_path = public as $$
declare visto boolean := new.visto_autor;
begin
  if coalesce(public.meu_papel(), '') <> 'admin' then
    new := old;
    if old.autor_id = auth.uid() then new.visto_autor := visto; end if;
  elsif new.status is distinct from old.status or new.resposta is distinct from old.resposta then
    new.respondido_por := auth.uid(); new.respondido_em := now(); new.visto_autor := false;
  end if;
  new.atualizado_em := now();
  return new;
end $$;
drop trigger if exists sugestoes_protege on public.sugestoes;
create trigger sugestoes_protege before update on public.sugestoes
  for each row execute function public.sugestoes_protege();

alter table public.sugestoes enable row level security;
drop policy if exists ler on public.sugestoes;
create policy ler on public.sugestoes for select to authenticated using (public.e_equipe());
drop policy if exists sugerir on public.sugestoes;
create policy sugerir on public.sugestoes for insert to authenticated
  with check (public.e_equipe() and autor_id = auth.uid() and status = 'nova');
drop policy if exists atualizar on public.sugestoes;
create policy atualizar on public.sugestoes for update to authenticated
  using (public.e_equipe() and (autor_id = auth.uid() or public.meu_papel() = 'admin'))
  with check (public.e_equipe());
drop policy if exists apagar on public.sugestoes;
create policy apagar on public.sugestoes for delete to authenticated using (public.meu_papel() = 'admin');

alter table public.sugestao_apoios enable row level security;
drop policy if exists ler on public.sugestao_apoios;
create policy ler on public.sugestao_apoios for select to authenticated using (public.e_equipe());
drop policy if exists apoiar on public.sugestao_apoios;
create policy apoiar on public.sugestao_apoios for insert to authenticated
  with check (public.e_equipe() and user_id = auth.uid() and id = sugestao_id::text || ':' || auth.uid()::text);
drop policy if exists mudar on public.sugestao_apoios;
create policy mudar on public.sugestao_apoios for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

notify pgrst, 'reload schema';
