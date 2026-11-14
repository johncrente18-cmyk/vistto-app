-- Vistto · página pública da NC (link do e-mail/WhatsApp) passa a mostrar o checklist inteiro da inspeção.
-- Só leitura: amplia o que a função devolve; não muda tabelas, dados nem regras de acesso.
-- Devolve também: item_id da NC, dados da inspeção, as respostas do checklist e o status das outras NCs
-- da mesma inspeção (sem os links/tokens delas).
create or replace function public.nc_publica(p_token text) returns json
language plpgsql security definer set search_path = public as $$
declare r json;
begin
  update public.ncs set status = 'vista', visto_em = now()
   where token = p_token and status = 'aberta';
  select json_build_object(
    'id', n.id, 'pergunta', n.pergunta, 'descricao', n.descricao, 'status', n.status,
    'prazo', n.prazo, 'responsavel_nome', n.responsavel_nome,
    'frente', f.codigo, 'frente_nome', f.nome, 'obra', o.nome, 'autor', p.nome,
    'foto', ft.dados, 'comentario_correcao', n.comentario_correcao, 'equipamento', n.equipamento,
    'item_id', n.item_id,
    'inspecao', json_build_object(
      'tipo', i.tipo, 'tipo_nome', t.nome, 'modo', t.modo, 'data', i.criado_em,
      'lider_nome', i.lider_nome, 'conformidade', i.conformidade, 'observacoes', i.observacoes,
      'estrutura', case when t.modo = 'formulario' then t.estrutura end,
      'respostas', case when t.modo = 'formulario' then i.respostas end),
    'itens', (select coalesce(json_agg(json_build_object('id', c.id, 'secao', c.secao, 'pergunta', c.pergunta,
                     'resposta', i.respostas ->> c.id) order by c.ordem, c.id), '[]'::json)
                from public.checklist_itens c
               where c.tipo = i.tipo and i.respostas ? c.id),
    'ncs', (select coalesce(json_agg(json_build_object('item_id', x.item_id, 'pergunta', x.pergunta,
                   'status', x.status, 'esta', x.id = n.id)), '[]'::json)
              from public.ncs x where x.inspecao_id = n.inspecao_id))
  into r
  from public.ncs n
  left join public.inspecoes i on i.id = n.inspecao_id
  left join public.tipos_inspecao t on t.id = i.tipo
  left join public.frentes f on f.id = n.frente_id
  left join public.obras o on o.id = n.obra_id
  left join public.profiles p on p.id = n.autor_id
  left join public.fotos ft on ft.id = n.foto_id
  where n.token = p_token;
  return r;
end $$;
notify pgrst, 'reload schema';
