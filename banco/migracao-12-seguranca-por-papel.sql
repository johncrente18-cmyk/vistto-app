-- Vistto · segurança por papel (migração 12)
-- Antes: qualquer conta logada lia e gravava tudo pelo banco (inclusive "Usuário (sem acesso)").
-- Agora:
--   • Usuário (sem acesso) e contas desativadas: só leem o próprio perfil. Não leem nem gravam mais nada.
--   • Líder / encarregado: lê cadastros (obra, frentes, tipos…) e só as NCs em que ele é o responsável.
--     A correção continua pelo link da NC (função nc_responder), como hoje.
--   • Equipe (engenheiro, técnico, supervisor, gestor, admin): continua como antes.
-- Não apaga nem altera nenhum dado.

create or replace function public.tem_acesso() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and papel <> 'usuario' and coalesce(ativo, true))
$$;
create or replace function public.e_equipe() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and papel not in ('usuario', 'lider') and coalesce(ativo, true))
$$;
grant execute on function public.tem_acesso() to authenticated;
grant execute on function public.e_equipe() to authenticated;

-- leitura dos cadastros: quem tem acesso (equipe e líder)
drop policy if exists ler on public.obras;           create policy ler on public.obras           for select to authenticated using (public.tem_acesso());
drop policy if exists ler on public.atividades;      create policy ler on public.atividades      for select to authenticated using (public.tem_acesso());
drop policy if exists ler on public.frentes;         create policy ler on public.frentes         for select to authenticated using (public.tem_acesso());
drop policy if exists ler on public.checklist_itens; create policy ler on public.checklist_itens for select to authenticated using (public.tem_acesso());
drop policy if exists ler on public.tipos_inspecao;  create policy ler on public.tipos_inspecao  for select to authenticated using (public.tem_acesso());
drop policy if exists ler on public.equipamentos;    create policy ler on public.equipamentos    for select to authenticated using (public.tem_acesso());

-- pessoas: o próprio perfil sempre; os demais só para quem tem acesso
drop policy if exists ler on public.profiles; create policy ler on public.profiles for select to authenticated using (id = auth.uid() or public.tem_acesso());

-- inspeções e fotos: só a equipe (o líder vê a foto da NC pelo link)
drop policy if exists ler on public.inspecoes; create policy ler on public.inspecoes for select to authenticated using (public.e_equipe());
drop policy if exists ler on public.fotos;     create policy ler on public.fotos     for select to authenticated using (public.e_equipe() or autor_id = auth.uid());

-- NCs: a equipe vê todas; o líder só as dele
drop policy if exists ler on public.ncs; create policy ler on public.ncs for select to authenticated using (public.e_equipe() or responsavel_id = auth.uid());

-- gravação: só a equipe
drop policy if exists criar_foto on public.fotos;        create policy criar_foto on public.fotos for insert to authenticated with check (public.e_equipe());
drop policy if exists criar_insp on public.inspecoes;    create policy criar_insp on public.inspecoes for insert to authenticated with check (autor_id = auth.uid() and public.e_equipe());
drop policy if exists criar_nc on public.ncs;            create policy criar_nc on public.ncs for insert to authenticated with check (public.e_equipe());
drop policy if exists editar_nc on public.ncs;           create policy editar_nc on public.ncs for update to authenticated using (public.e_equipe()) with check (public.e_equipe());
drop policy if exists editar_frentes on public.frentes;  create policy editar_frentes on public.frentes for update to authenticated using (public.e_equipe()) with check (public.e_equipe());

notify pgrst, 'reload schema';
