# Vistto Inspeções · como colocar no ar

Tempo estimado: 20 minutos. Tudo gratuito.

## O que tem nesta pasta

- `index.html`: o app inteiro (engenheiro, técnico, gestor, administrador e a página do líder).
- `config.json`: onde você cola as duas chaves do banco.
- `manifest.webmanifest`, `sw.js`, `icon-192.png`, `icon-512.png`: arquivos que permitem instalar o app no celular e usar sem internet.
- `banco/schema.sql`: o banco de dados (tabelas, segurança e a UFV Paraíso com MAR 1 a 8 e subfrentes 1.1 a 8.8).

## 1. Criar o banco (Supabase)

1. Crie uma conta em supabase.com e clique em **New project**. Escolha a região São Paulo.
2. No menu lateral, abra **SQL Editor** e clique em **New query**.
3. Abra o arquivo `banco/schema.sql`, copie tudo, cole no editor e clique em **Run**.
4. Vá em **Authentication > Sign In / Providers > Email** e desligue **Confirm email**. Assim cada pessoa entra logo depois de criar a conta. Se preferir manter ligado, ela confirma pelo e-mail antes do primeiro acesso.
5. Vá em **Project Settings > API** e copie:
   - **Project URL** (algo como `https://abcd1234.supabase.co`)
   - **anon public** key (um texto longo começando com `eyJ`)

## 2. Colar as chaves

Abra `config.json` num editor de texto e troque os dois valores:

```json
{
  "supabaseUrl": "https://abcd1234.supabase.co",
  "supabaseAnonKey": "eyJhbGciOi..."
}
```

A chave *anon* pode ficar pública. Quem protege os dados são as regras de segurança do `schema.sql`.

## 3. Publicar o app

O app precisa de um endereço https para instalar no celular e para o link do WhatsApp funcionar.

1. Acesse **app.netlify.com/drop** (pode entrar com a conta Google).
2. Arraste a pasta `vistto-app` inteira para a página.
3. Em segundos aparece um endereço, por exemplo `https://vistto-paraiso.netlify.app`. Dá para trocar o nome em **Site settings**.

Para atualizar o app depois, arraste a pasta de novo.

## 4. Instalar no celular

- **Android (Chrome):** abra o endereço e toque em **Instalar app** (ou ⋮ > **Adicionar à tela inicial**).
- **iPhone (Safari):** abra o endereço, toque em **Compartilhar** > **Adicionar à Tela de Início**.

## 5. Virar administrador

1. No app, toque em **Criar conta** e cadastre seu e-mail.
2. No Supabase > SQL Editor, rode (com o seu e-mail):

```sql
update public.profiles set papel = 'admin' where email = 'seu@email.com';
```

3. Saia e entre de novo no app. Em **Mais > Cadastro** você define:
   - líder e WhatsApp de cada MAR (aplica às 8 subfrentes de uma vez) ou de cada subfrente;
   - a atividade de cada subfrente, que define os itens de risco do checklist;
   - o papel de cada pessoa (engenheiro, técnico, gestor, administrador);
   - a meta semanal.

Os engenheiros instalam o app e criam a própria conta. Depois você define o papel de cada um em **Pessoas**.

## Como funciona sem internet

- Todas as inspeções, fotos e NCs ficam salvas no celular e sobem sozinhas quando volta o sinal. A faixa no topo mostra quantos registros estão aguardando.
- O primeiro acesso de cada pessoa precisa de internet. Depois, o app abre offline.
- O botão do WhatsApp abre a conversa com a mensagem pronta. O líder só consegue abrir o link depois que a NC foi sincronizada.

## Limites do plano gratuito do Supabase

- 500 MB de banco. As fotos são comprimidas (~80 KB cada), o que dá por volta de 5.000 fotos. Quando chegar perto, dá para mover as fotos para o Supabase Storage ou passar para o plano pago.
- Projetos gratuitos sem uso por 7 dias são pausados. Com uso diário isso não acontece.

## Testar antes

Abra o `index.html` e escolha **Testar sem banco (demonstração)**. O app carrega dados de exemplo, com os 9 engenheiros, o gestor e o administrador.
