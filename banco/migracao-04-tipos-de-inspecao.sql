-- Vistto · tipos de inspeção cadastráveis
-- Rode UMA vez no Supabase > SQL Editor > New query > Run.
-- Não apaga nada: cria a tabela de tipos (com Caminhada e Vivência) e libera tipos novos.
create table if not exists public.tipos_inspecao (
  id text primary key,
  nome text not null,
  descricao text,
  usa_atividade boolean not null default false,  -- soma os itens de risco da atividade do dia
  ordem int not null default 0,
  ativo boolean not null default true
);
alter table public.tipos_inspecao enable row level security;
drop policy if exists ler on public.tipos_inspecao;
create policy ler on public.tipos_inspecao for select to authenticated using (true);
drop policy if exists admin_tipos on public.tipos_inspecao;
create policy admin_tipos on public.tipos_inspecao for all to authenticated using (public.meu_papel() = 'admin') with check (public.meu_papel() = 'admin');
insert into public.tipos_inspecao (id, nome, descricao, usa_atividade, ordem) values
  ('caminhada', 'Caminhada de segurança', 'Ferramentas, EPI, documentação e os riscos da atividade do dia', true, 1),
  ('vivencia', 'Área de vivência (Meta 01)', 'Documentação e estrutura da área de vivência', false, 2)
on conflict (id) do nothing;
alter table public.checklist_itens drop constraint if exists checklist_itens_tipo_check;
alter table public.inspecoes drop constraint if exists inspecoes_tipo_check;
notify pgrst, 'reload schema';
