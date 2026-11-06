-- Vistto · página pública da NC passa a mostrar a máquina/equipamento (só leitura; não muda regras de acesso)
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
    'foto', ft.dados, 'comentario_correcao', n.comentario_correcao, 'equipamento', n.equipamento)
  into r
  from public.ncs n
  left join public.frentes f on f.id = n.frente_id
  left join public.obras o on o.id = n.obra_id
  left join public.profiles p on p.id = n.autor_id
  left join public.fotos ft on ft.id = n.foto_id
  where n.token = p_token;
  return r;
end $$;
notify pgrst, 'reload schema';
