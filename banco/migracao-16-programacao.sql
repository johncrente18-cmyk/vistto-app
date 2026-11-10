-- Vistto · programação do mês (migração 16)
-- Guarda o que cada técnico deve inspecionar no mês (Mais › Programação do mês).
--   • Todos da equipe leem; só administrador e supervisor criam, mudam ou tiram itens.
--   • "Tirar" um item só marca ativo = false; nada é apagado.
-- Não apaga nem altera nenhum dado existente.

create table if not exists public.programacao (
  id uuid primary key default gen_random_uuid(),
  obra_id text references public.obras(id),
  mes text not null,                 -- 'AAAA-MM'
  tecnico_id uuid not null references public.profiles(id),
  tipo text not null,                -- id do tipo de inspeção
  equipamento_id text,               -- máquina (opcional)
  frente_id text,
  data date not null,                -- dia previsto
  ativo boolean not null default true,
  criado_por uuid default auth.uid() references public.profiles(id),
  criado_em timestamptz not null default now()
);
create index if not exists programacao_mes_idx on public.programacao (mes, tecnico_id);

alter table public.programacao enable row level security;
drop policy if exists ler on public.programacao;
create policy ler on public.programacao for select to authenticated using (public.e_equipe());
drop policy if exists gerir on public.programacao;
create policy gerir on public.programacao for all to authenticated
  using (public.meu_papel() in ('admin', 'supervisor')) with check (public.meu_papel() in ('admin', 'supervisor'));

notify pgrst, 'reload schema';
