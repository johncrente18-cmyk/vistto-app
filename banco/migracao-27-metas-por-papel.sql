-- Vistto · metas da semana separadas para Técnico e Engenheiro, por grupo de inspeção
-- Só acrescenta uma coluna na obra; não apaga nem altera nada existente.
-- Formato: {"tecnico": {"gerencia": 8, "auditoria": 1}, "engenheiro": {"gerencia": 3}}
-- Grupos: veiculos (máquinas e veículos), gerencia (caminhada e vivência), campo (TSTs), auditoria.
alter table public.obras add column if not exists metas jsonb;
notify pgrst, 'reload schema';
