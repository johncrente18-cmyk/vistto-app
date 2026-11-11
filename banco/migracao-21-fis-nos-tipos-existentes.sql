-- Vistto · ajuste da migração 20 (migração 21)
-- Oito das fichas FIS correspondem a tipos que já existiam no app, mas estavam sem perguntas
-- (Furadeira, Lixadeira, Policorte, Perfuratriz, Cinto paraquedista, Acessório de guindar,
--  Martelete elétrico/pneumático e Caminhão bomba lança). As perguntas passam para esses tipos,
-- e os tipos duplicados criados na migração 20 são desativados (nada é apagado).

update public.checklist_itens set tipo = 'vme-cinto-paraquedista'            where tipo = 'vme-cinto-de-seguranca';
update public.checklist_itens set tipo = 'vme-acessorio-de-guindar'          where tipo = 'vme-acessorios-de-icamento';
update public.checklist_itens set tipo = 'vme-lixadeira'                     where tipo = 'vme-lixadeira-esmerilhadeira';
update public.checklist_itens set tipo = 'vme-furadeira'                     where tipo = 'vme-furadeira-manual';
update public.checklist_itens set tipo = 'vme-policorte'                     where tipo = 'vme-serra-policorte';
update public.checklist_itens set tipo = 'vme-perfuratriz'                   where tipo = 'vme-perfuratriz-sonda';
update public.checklist_itens set tipo = 'vme-caminhao-bomba-lanca'          where tipo = 'vme-bomba-de-concreto';
-- Martelete elétrico/pneumático: ficha 015 (elétrico) + itens próprios da ficha 014 (pneumático)
update public.checklist_itens set tipo = 'vme-mantelete-eletrico-pneumatico' where tipo in ('vme-martelete-rompedor-eletrico', 'vme-martelete-pneumatico');
update public.checklist_itens set secao = 'Martelete pneumático', ordem = 12 + (case id when 'f014-02' then 1 else 2 end)
 where id in ('f014-02', 'f014-03');
update public.checklist_itens set ativo = false
 where id like 'f014-%' and id not in ('f014-02', 'f014-03');

update public.tipos_inspecao set ativo = false
 where id in ('vme-cinto-de-seguranca', 'vme-acessorios-de-icamento', 'vme-lixadeira-esmerilhadeira', 'vme-furadeira-manual',
              'vme-serra-policorte', 'vme-perfuratriz-sonda', 'vme-bomba-de-concreto', 'vme-martelete-rompedor-eletrico', 'vme-martelete-pneumatico');

notify pgrst, 'reload schema';
