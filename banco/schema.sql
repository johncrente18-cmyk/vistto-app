-- ============================================================
-- Vistto Inspeções · banco de dados (Supabase / PostgreSQL)
-- Cole tudo no Supabase > SQL Editor > New query > Run.
-- Pode rodar de novo: o script apaga e recria as tabelas do app.
-- ============================================================

create extension if not exists pgcrypto;

drop table if exists public.ncs cascade;
drop table if exists public.inspecoes cascade;
drop table if exists public.fotos cascade;
drop table if exists public.profiles cascade;
drop table if exists public.checklist_itens cascade;
drop table if exists public.frentes cascade;
drop table if exists public.atividades cascade;
drop table if exists public.obras cascade;

-- ---------- Cadastros ----------
create table public.obras (
  id text primary key,
  nome text not null,
  meta_semanal int not null default 5,
  criado_em timestamptz not null default now()
);

create table public.atividades (
  id text primary key,
  nome text not null,
  risco text not null check (risco in ('Alto','Médio','Baixo')),
  modulos text[] not null default '{}',   -- módulos de checklist que a atividade adiciona
  ordem int not null default 0
);

create table public.frentes (
  id text primary key,
  obra_id text not null references public.obras(id) on delete cascade,
  parent_id text references public.frentes(id) on delete cascade,  -- null = frente (MAR); preenchido = subfrente
  codigo text not null,
  nome text not null,
  ordem int not null default 0,
  atividade_id text references public.atividades(id),  -- atividade programada atual
  lider_nome text,
  lider_telefone text,  -- com DDD, ex: 86999990000
  tecnico_id uuid,      -- técnico de segurança responsável pela área (MAR)
  ativo boolean not null default true
);

create table public.checklist_itens (
  id text primary key,
  tipo text not null check (tipo in ('caminhada','vivencia')),
  modulo text not null default 'base',   -- base | escavacao | eletrica | icamento | carga
  secao text,
  ordem int not null default 0,
  pergunta text not null,
  ativo boolean not null default true
);

-- ---------- Pessoas ----------
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nome text not null default '',
  email text,
  telefone text,
  papel text not null default 'engenheiro' check (papel in ('engenheiro','tecnico','gestor','admin')),
  obra_id text references public.obras(id),
  ativo boolean not null default true,
  criado_em timestamptz not null default now()
);

-- ---------- Registros ----------
create table public.fotos (
  id uuid primary key default gen_random_uuid(),
  dados text not null,          -- imagem JPEG comprimida (data URL)
  autor_id uuid default auth.uid(),
  criado_em timestamptz not null default now()
);

create table public.inspecoes (
  id uuid primary key default gen_random_uuid(),
  obra_id text not null references public.obras(id),
  frente_id text not null references public.frentes(id),
  tipo text not null check (tipo in ('caminhada','vivencia')),
  atividade_id text references public.atividades(id),
  autor_id uuid not null default auth.uid() references public.profiles(id),
  lider_nome text,
  respostas jsonb not null default '{}',   -- { "cb1": "C" | "NC" | "NA", ... }
  conformidade int,
  xp int not null default 0,
  foto_local_id uuid references public.fotos(id),
  observacoes text,
  criado_em timestamptz not null default now()
);

create table public.ncs (
  id uuid primary key default gen_random_uuid(),
  inspecao_id uuid not null references public.inspecoes(id) on delete cascade,
  obra_id text references public.obras(id),
  frente_id text references public.frentes(id),
  item_id text,
  pergunta text not null,
  descricao text,
  foto_id uuid references public.fotos(id),
  responsavel_nome text,
  responsavel_telefone text,
  prazo timestamptz,
  status text not null default 'aberta' check (status in ('aberta','vista','corrigida','encerrada')),
  token text not null unique default encode(gen_random_bytes(9),'hex'),  -- link público do líder
  foto_correcao_id uuid references public.fotos(id),
  comentario_correcao text,
  visto_em timestamptz,
  corrigido_em timestamptz,
  encerrado_em timestamptz,
  encerrado_por uuid references public.profiles(id),
  nota_encerramento text,
  autor_id uuid default auth.uid() references public.profiles(id),
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create index on public.frentes (obra_id, parent_id);
alter table public.frentes add constraint frentes_tecnico_fk foreign key (tecnico_id) references public.profiles(id) on delete set null;
create index on public.inspecoes (obra_id, criado_em desc);
create index on public.inspecoes (autor_id, criado_em desc);
create index on public.inspecoes (frente_id, criado_em desc);
create index on public.ncs (obra_id, status);
create index on public.ncs (frente_id);

-- ---------- Funções auxiliares ----------
create or replace function public.meu_papel() returns text
language sql stable security definer set search_path = public as $$
  select papel from public.profiles where id = auth.uid()
$$;

-- cria o perfil automaticamente quando alguém cria conta no app
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, nome, email, obra_id)
  values (new.id, coalesce(new.raw_user_meta_data->>'nome', split_part(new.email,'@',1)), new.email, 'ufv-paraiso')
  on conflict (id) do nothing;
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- só administrador muda papel/obra (o SQL Editor também pode)
create or replace function public.protege_papel() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if (new.papel is distinct from old.papel or new.obra_id is distinct from old.obra_id)
     and auth.uid() is not null and coalesce(public.meu_papel(),'') <> 'admin' then
    raise exception 'Somente administradores alteram papel ou obra';
  end if;
  return new;
end $$;
create trigger profiles_protege_papel before update on public.profiles
  for each row execute function public.protege_papel();

create or replace function public.toca_atualizado() returns trigger language plpgsql as $$
begin new.atualizado_em = now(); return new; end $$;
create trigger ncs_atualizado before update on public.ncs
  for each row execute function public.toca_atualizado();

-- ---------- Segurança (RLS) ----------
alter table public.obras enable row level security;
alter table public.atividades enable row level security;
alter table public.frentes enable row level security;
alter table public.checklist_itens enable row level security;
alter table public.profiles enable row level security;
alter table public.fotos enable row level security;
alter table public.inspecoes enable row level security;
alter table public.ncs enable row level security;

-- leitura: qualquer usuário logado
create policy ler on public.obras for select to authenticated using (true);
create policy ler on public.atividades for select to authenticated using (true);
create policy ler on public.frentes for select to authenticated using (true);
create policy ler on public.checklist_itens for select to authenticated using (true);
create policy ler on public.profiles for select to authenticated using (true);
create policy ler on public.fotos for select to authenticated using (true);
create policy ler on public.inspecoes for select to authenticated using (true);
create policy ler on public.ncs for select to authenticated using (true);

-- cadastros: administrador (frentes também o gestor)
create policy admin_obras on public.obras for all to authenticated using (public.meu_papel() = 'admin') with check (public.meu_papel() = 'admin');
create policy admin_ativ on public.atividades for all to authenticated using (public.meu_papel() = 'admin') with check (public.meu_papel() = 'admin');
create policy admin_itens on public.checklist_itens for all to authenticated using (public.meu_papel() = 'admin') with check (public.meu_papel() = 'admin');
create policy admin_frentes_ins on public.frentes for insert to authenticated with check (public.meu_papel() = 'admin');
create policy admin_frentes_del on public.frentes for delete to authenticated using (public.meu_papel() = 'admin');
-- engenheiro/técnico atualizam a atividade do dia; gestor/admin editam líder e telefone
create policy editar_frentes on public.frentes for update to authenticated using (true) with check (true);

create policy perfil_proprio on public.profiles for update to authenticated
  using (id = auth.uid() or public.meu_papel() = 'admin')
  with check (id = auth.uid() or public.meu_papel() = 'admin');

create policy criar_foto on public.fotos for insert to authenticated with check (true);

create policy criar_insp on public.inspecoes for insert to authenticated with check (autor_id = auth.uid());
create policy editar_insp on public.inspecoes for update to authenticated
  using (autor_id = auth.uid() or public.meu_papel() in ('gestor','admin'));
create policy apagar_insp on public.inspecoes for delete to authenticated using (public.meu_papel() = 'admin');

create policy criar_nc on public.ncs for insert to authenticated with check (true);
create policy editar_nc on public.ncs for update to authenticated using (true) with check (true);
create policy apagar_nc on public.ncs for delete to authenticated using (public.meu_papel() = 'admin');

-- ---------- Link público do líder (sem login) ----------
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
    'foto', ft.dados, 'comentario_correcao', n.comentario_correcao)
  into r
  from public.ncs n
  left join public.frentes f on f.id = n.frente_id
  left join public.obras o on o.id = n.obra_id
  left join public.profiles p on p.id = n.autor_id
  left join public.fotos ft on ft.id = n.foto_id
  where n.token = p_token;
  return r;
end $$;

create or replace function public.nc_responder(p_token text, p_foto text, p_comentario text default null) returns boolean
language plpgsql security definer set search_path = public as $$
declare fid uuid;
begin
  if p_foto is null or length(p_foto) > 3000000 then raise exception 'Foto inválida'; end if;
  if not exists (select 1 from public.ncs where token = p_token and status in ('aberta','vista')) then return false; end if;
  insert into public.fotos (dados, autor_id) values (p_foto, null) returning id into fid;
  update public.ncs set status = 'corrigida', foto_correcao_id = fid,
         comentario_correcao = p_comentario, corrigido_em = now()
   where token = p_token;
  return true;
end $$;

grant execute on function public.nc_publica(text) to anon, authenticated;
grant execute on function public.nc_responder(text, text, text) to anon, authenticated;

-- ============================================================
-- Dados iniciais
-- ============================================================
insert into public.obras (id, nome) values ('ufv-paraiso', 'UFV Paraíso');

insert into public.atividades (id, nome, risco, modulos, ordem) values
  ('escavacao',     'Escavação de vala',           'Alto',  '{escavacao}',        1),
  ('reaterro',      'Reaterro e compactação',      'Médio', '{escavacao}',        2),
  ('cabos',         'Lançamento de cabos',         'Médio', '{carga}',            3),
  ('terminacao',    'Terminação elétrica',         'Alto',  '{eletrica}',         4),
  ('energizacao',   'Comissionamento / energização','Alto', '{eletrica}',         5),
  ('cravacao',      'Cravação de estacas',         'Alto',  '{icamento}',         6),
  ('estruturas',    'Montagem de estruturas',      'Médio', '{icamento,carga}',   7),
  ('modulos',       'Montagem de módulos',         'Médio', '{carga}',            8),
  ('apoio',         'Área de vivência / apoio',    'Baixo', '{}',                 9);

-- Frentes MAR 1 a 8
insert into public.frentes (id, obra_id, codigo, nome, ordem)
select 'mar-' || m, 'ufv-paraiso', 'MAR ' || m, 'MAR ' || m, m * 100
from generate_series(1, 8) m;

-- Subfrentes 1.1 a 8.8
insert into public.frentes (id, obra_id, parent_id, codigo, nome, ordem)
select 'mar-' || m || '-' || s, 'ufv-paraiso', 'mar-' || m, m || '.' || s, 'MAR ' || m || ' · ' || m || '.' || s, m * 100 + s
from generate_series(1, 8) m, generate_series(1, 8) s;

insert into public.checklist_itens (id, tipo, modulo, secao, ordem, pergunta) values
  -- Caminhada de segurança · base
  ('cb1','caminhada','base','Ferramentas',1,'Ferramentas em bom estado (sem improviso, trinca ou cabo solto)'),
  ('cb2','caminhada','base','Ferramentas',2,'Check-list diário ou cor do mês das ferramentas em dia'),
  ('cb3','caminhada','base','Ferramentas',3,'Ferramenta correta para a atividade'),
  ('cb4','caminhada','base','EPI',4,'Equipe usando EPI básico e específico do risco'),
  ('cb5','caminhada','base','EPI',5,'EPIs íntegros, limpos e com CA válido'),
  ('cb6','caminhada','base','Documentação',6,'APR e PT da atividade preenchidas e assinadas'),
  -- módulos por risco da atividade
  ('ce1','caminhada','escavacao','Escavação',10,'Vala escorada ou com talude adequado'),
  ('ce2','caminhada','escavacao','Escavação',11,'Material escavado a mais de 0,6 m da borda'),
  ('ce3','caminhada','escavacao','Escavação',12,'Vala sinalizada e isolada'),
  ('cl1','caminhada','eletrica','Eletricidade',20,'Bloqueio e etiquetagem (LOTO) aplicados'),
  ('cl2','caminhada','eletrica','Eletricidade',21,'Teste de ausência de tensão registrado'),
  ('cl3','caminhada','eletrica','Eletricidade',22,'Ferramentas isoladas da classe correta'),
  ('ci1','caminhada','icamento','Içamento',30,'Plano de rigging disponível'),
  ('ci2','caminhada','icamento','Içamento',31,'Área de giro isolada e sinalizada'),
  ('ci3','caminhada','icamento','Içamento',32,'Cintas, manilhas e cabos inspecionados'),
  ('cc1','caminhada','carga','Movimentação de carga',40,'Peso por pessoa dentro do limite'),
  ('cc2','caminhada','carga','Movimentação de carga',41,'Rota livre e sem obstáculos'),
  -- Meta 01 · área de vivência
  ('v1','vivencia','base','Documentação',1,'APR e PT/PTE disponíveis e preenchidas'),
  ('v2','vivencia','base','Documentação',2,'DDS realizado e registrado'),
  ('v3','vivencia','base','Documentação',3,'Equipe com credencial SSO aprovada'),
  ('v4','vivencia','base','Área de vivência',4,'Água potável, lixeira, mesa e cadeiras disponíveis'),
  ('v5','vivencia','base','Área de vivência',5,'Ferramentas, EPIs e mochilas guardados corretamente'),
  ('v6','vivencia','base','Área de vivência',6,'Tenda estaiada e aterrada'),
  ('v7','vivencia','base','Área de vivência',7,'Kit de mitigação ambiental na tenda'),
  ('v8','vivencia','base','Área de vivência',8,'Extintor disponível e dentro da validade');

-- ============================================================
-- Depois de criar SUA conta no app, rode esta linha trocando o e-mail
-- para virar administrador:
-- update public.profiles set papel = 'admin' where email = 'seu@email.com';
-- ============================================================
