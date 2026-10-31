-- Vistto · formulários (estrutura no estilo Axyma: itens > subitens com tipos de campo)
-- Rode UMA vez no Supabase > SQL Editor > New query > Run. Não apaga nada.
alter table public.tipos_inspecao add column if not exists modo text not null default 'checklist';  -- checklist | formulario
alter table public.tipos_inspecao add column if not exists estrutura jsonb;                          -- itens/subitens do formulário
notify pgrst, 'reload schema';
-- Os formulários em si ficam em banco/formularios/*.json e são gravados na tabela tipos_inspecao (uma linha por formulário).
