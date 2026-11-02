-- Vistto · papel "Usuário (sem acesso)": toda conta nova entra nele até o administrador definir o perfil.
-- Contas que já existem não mudam.
alter table public.profiles drop constraint if exists profiles_papel_check;
alter table public.profiles add constraint profiles_papel_check check (papel in ('engenheiro','tecnico','supervisor','gestor','admin','lider','usuario'));
alter table public.profiles alter column papel set default 'usuario';
notify pgrst, 'reload schema';
