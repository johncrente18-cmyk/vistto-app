-- Vistto · grupos de inspeção (os 3 botões do Radar)
-- Rode UMA vez no Supabase > SQL Editor > New query > Run. Não apaga nada.
alter table public.tipos_inspecao add column if not exists grupo text;  -- veiculos | gerencia | campo
update public.tipos_inspecao set grupo = 'gerencia' where id in ('caminhada', 'vivencia') and grupo is null;
update public.tipos_inspecao set grupo = 'campo' where grupo is null;
notify pgrst, 'reload schema';
