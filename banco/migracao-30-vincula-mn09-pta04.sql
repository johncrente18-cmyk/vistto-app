-- Vistto · liga 2 inspeções feitas como "Outros" às máquinas certas (migração 30)
-- Elas foram feitas antes de MN-09 e PTA-04 entrarem no cadastro (atualização do ObraSoft em 25/11).
-- Mexe só nessas 2 inspeções, e só se ainda estiverem sem máquina. Não têm NCs.
update public.inspecoes set equipamento_id = 'eq-b300020674', equipamento = 'PTA-04 · JLG 450AJ · B300020674'
 where id = '81e1c195-2802-4510-99b9-daeb8c391047' and equipamento_id is null and tipo = 'vme-pemt-csp';
update public.inspecoes set equipamento_id = 'eq-1bz620gapnd000552', equipamento = 'MN-09 · JOHN DEERE 620G · 1BZ620GAPND000552'
 where id = '54f79510-9940-446a-b016-953fe0cfb0f6' and equipamento_id is null and tipo = 'vme-motoniveladora-csp';
select id, tipo, equipamento_id, equipamento from public.inspecoes
 where id in ('81e1c195-2802-4510-99b9-daeb8c391047', '54f79510-9940-446a-b016-953fe0cfb0f6');
