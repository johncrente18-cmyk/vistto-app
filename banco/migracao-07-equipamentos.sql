-- Vistto · máquinas e equipamentos (identificação no cabeçalho das inspeções)
-- Rode UMA vez no Supabase > SQL Editor > New query > Run. Não apaga nada.
create table if not exists public.equipamentos (
  id text primary key,
  tipo text not null,          -- id do tipo de inspeção (checklist) a que a máquina pertence
  prefixo text,                -- ex.: EH-03
  modelo text,                 -- ex.: John Deere 210G
  serie text,                  -- nº de série / chassi
  descricao text not null,     -- texto original (ex.: "John Deere 210G / 1F92… / EH-03")
  ativo boolean not null default true,
  origem text,
  criado_em timestamptz not null default now()
);
alter table public.equipamentos enable row level security;
drop policy if exists ler on public.equipamentos;
create policy ler on public.equipamentos for select to authenticated using (true);
drop policy if exists admin_equip on public.equipamentos;
create policy admin_equip on public.equipamentos for all to authenticated using (public.meu_papel() = 'admin') with check (public.meu_papel() = 'admin');
alter table public.inspecoes add column if not exists equipamento_id text;
alter table public.inspecoes add column if not exists equipamento text;
alter table public.ncs add column if not exists equipamento text;
notify pgrst, 'reload schema';
