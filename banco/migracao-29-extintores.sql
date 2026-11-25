-- Vistto · cadastro de extintores (migração 29)
-- Cada extintor é identificado pela numeração gravada no fundo do cilindro + marca.
-- O cadastro nasce na primeira inspeção feita no app; as inspeções seguintes atualizam
-- local, recarga e teste hidrostático. A inspeção guarda o extintor em equipamento_id / equipamento.
--   • A equipe lê e cadastra.
--   • Técnico só atualiza o que é conferido na inspeção (local, tipo, capacidade, recarga,
--     hidrostático, última inspeção). Número, marca, observação e desativar: só administrador.
-- Não apaga nem altera nenhum dado existente.

create table if not exists public.extintores (
  id text primary key,                   -- 'ext:<obra>:<numero>:<marca>' ou 'ext:prov:<código>' (numeração ilegível)
  obra_id text references public.obras(id),
  numero text not null,                  -- como foi digitado (ou PROV-xxxx quando ilegível)
  numero_norm text generated always as (upper(regexp_replace(numero, '[^0-9A-Za-z]', '', 'g'))) stored,
  marca text,
  ilegivel boolean not null default false,
  agente text,                           -- ÁGUA PRESSURIZADA, PQS - ABC, PQS - BC, LGE, CO²
  capacidade text,                       -- 4 kg, 6 kg, 10 L ...
  local text,
  recarga_mes text,                      -- 'AAAA-MM' do vencimento da recarga
  hidro_ano int,                         -- ano do último teste hidrostático
  foto_id uuid,                          -- foto da numeração (primeira inspeção)
  ultima_inspecao_id uuid,
  ultima_inspecao_em timestamptz,
  ultima_inspecao_por uuid,
  obs text,
  ativo boolean not null default true,
  criado_por uuid default auth.uid() references public.profiles(id),
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create index if not exists extintores_num_idx on public.extintores (obra_id, numero_norm);

create or replace function public.extintores_protege() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  new.atualizado_em := now();
  if coalesce(public.meu_papel(), '') <> 'admin' then
    new.numero := old.numero; new.marca := old.marca; new.ilegivel := old.ilegivel;
    new.obra_id := old.obra_id; new.obs := old.obs; new.ativo := old.ativo;
    new.criado_por := old.criado_por; new.criado_em := old.criado_em;
    new.foto_id := coalesce(old.foto_id, new.foto_id);
  end if;
  return new;
end $$;
drop trigger if exists extintores_protege on public.extintores;
create trigger extintores_protege before update on public.extintores
  for each row execute function public.extintores_protege();

alter table public.extintores enable row level security;
drop policy if exists ler on public.extintores;
create policy ler on public.extintores for select to authenticated using (public.e_equipe());
drop policy if exists cadastrar on public.extintores;
create policy cadastrar on public.extintores for insert to authenticated with check (public.e_equipe());
drop policy if exists atualizar on public.extintores;
create policy atualizar on public.extintores for update to authenticated using (public.e_equipe()) with check (public.e_equipe());

notify pgrst, 'reload schema';
