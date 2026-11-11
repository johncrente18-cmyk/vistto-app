-- Vistto · inspeção de Carros Leves no padrão do cliente (migração 23)
-- Modelo: ObraSoft "Carros - SSO" · Inspeção mensal (Empreendimento SPGA - Máquinas e Equipamentos - IMP),
-- enviado pelo usuário em 11/11/2026. 5 seções, 19 itens, mesma ordem e redação do cliente.
-- As perguntas anteriores do tipo são desativadas (não apagadas): inspeções já feitas continuam iguais.

update public.checklist_itens set ativo = false where tipo = 'vme-carros-leve-e-4x4-csp' and ativo and id not like 'cli-car-%';

insert into public.checklist_itens (id, tipo, modulo, secao, ordem, pergunta, ativo) values
  ('cli-car-101', 'vme-carros-leve-e-4x4-csp', 'base', '1. Identificação e Controle', 101, '1.1 Existe identificação da empresa e do equipamento em local visível?', true),
  ('cli-car-102', 'vme-carros-leve-e-4x4-csp', 'base', '1. Identificação e Controle', 102, '1.2 Sistema de Telemetria Veicular', true),
  ('cli-car-201', 'vme-carros-leve-e-4x4-csp', 'base', '2. Segurança e Emergência', 201, '2.1 Cinto de Segurança', true),
  ('cli-car-202', 'vme-carros-leve-e-4x4-csp', 'base', '2. Segurança e Emergência', 202, '2.2 Kit Primeiros Socorros', true),
  ('cli-car-301', 'vme-carros-leve-e-4x4-csp', 'base', '3. Iluminação e Sinalização Sonora', 301, '3.1 Faróis', true),
  ('cli-car-302', 'vme-carros-leve-e-4x4-csp', 'base', '3. Iluminação e Sinalização Sonora', 302, '3.2 Luzes indicadoras - Direita/Esquerda', true),
  ('cli-car-303', 'vme-carros-leve-e-4x4-csp', 'base', '3. Iluminação e Sinalização Sonora', 303, '3.3 Luzes de Ré', true),
  ('cli-car-304', 'vme-carros-leve-e-4x4-csp', 'base', '3. Iluminação e Sinalização Sonora', 304, '3.4 Buzina', true),
  ('cli-car-401', 'vme-carros-leve-e-4x4-csp', 'base', '4. Cabine, Visibilidade e Conforto', 401, '4.1 Portas / Vidros Elétricos / Fechaduras', true),
  ('cli-car-402', 'vme-carros-leve-e-4x4-csp', 'base', '4. Cabine, Visibilidade e Conforto', 402, '4.2 Ar Condicionado', true),
  ('cli-car-403', 'vme-carros-leve-e-4x4-csp', 'base', '4. Cabine, Visibilidade e Conforto', 403, '4.3 Limpador de para-brisas', true),
  ('cli-car-404', 'vme-carros-leve-e-4x4-csp', 'base', '4. Cabine, Visibilidade e Conforto', 404, '4.4 Quebra-sol do motorista', true),
  ('cli-car-405', 'vme-carros-leve-e-4x4-csp', 'base', '4. Cabine, Visibilidade e Conforto', 405, '4.5 Retrovisores', true),
  ('cli-car-406', 'vme-carros-leve-e-4x4-csp', 'base', '4. Cabine, Visibilidade e Conforto', 406, '4.6 Luzes do painel', true),
  ('cli-car-407', 'vme-carros-leve-e-4x4-csp', 'base', '4. Cabine, Visibilidade e Conforto', 407, '4.7 Instrumentos do painel', true),
  ('cli-car-501', 'vme-carros-leve-e-4x4-csp', 'base', '5. Mecânica, Condução e Rodagem', 501, '5.1 Freio de pedal', true),
  ('cli-car-502', 'vme-carros-leve-e-4x4-csp', 'base', '5. Mecânica, Condução e Rodagem', 502, '5.2 Freio de mão', true),
  ('cli-car-503', 'vme-carros-leve-e-4x4-csp', 'base', '5. Mecânica, Condução e Rodagem', 503, '5.3 Embreagem', true),
  ('cli-car-504', 'vme-carros-leve-e-4x4-csp', 'base', '5. Mecânica, Condução e Rodagem', 504, '5.4 Pneus', true)
on conflict (id) do update set secao = excluded.secao, ordem = excluded.ordem, pergunta = excluded.pergunta, ativo = true;

notify pgrst, 'reload schema';
