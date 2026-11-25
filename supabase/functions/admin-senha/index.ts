// Vistto · troca de senha de um usuário pelo administrador (botão "Alterar senha" no Painel › Pessoas)
// Só funciona se quem chama estiver logado E for administrador ativo (profiles.papel = 'admin').
// Usa a chave de serviço que o próprio Supabase já entrega à função (SUPABASE_SERVICE_ROLE_KEY):
// nenhum segredo novo precisa ser cadastrado, e a chave nunca sai do servidor.
import { createClient } from 'npm:@supabase/supabase-js@2';

const URL = Deno.env.get('SUPABASE_URL')!;
const ANON = Deno.env.get('SUPABASE_ANON_KEY')!;
const SERVICE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
const resp = (status: number, corpo: Record<string, unknown>) =>
  new Response(JSON.stringify(corpo), { status, headers: { ...CORS, 'Content-Type': 'application/json' } });

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') return resp(405, { erro: 'Use POST.' });
  try {
    const auth = req.headers.get('Authorization') || '';
    if (!auth.startsWith('Bearer ')) return resp(401, { erro: 'Faça login de novo.' });

    // 1) quem está pedindo?
    const comoUsuario = createClient(URL, ANON, { global: { headers: { Authorization: auth } }, auth: { persistSession: false } });
    const { data: eu, error: eEu } = await comoUsuario.auth.getUser();
    if (eEu || !eu?.user) return resp(401, { erro: 'Sessão vencida. Faça login de novo.' });

    const adm = createClient(URL, SERVICE, { auth: { persistSession: false } });
    const { data: perfil } = await adm.from('profiles').select('papel, ativo').eq('id', eu.user.id).maybeSingle();
    if (!perfil || perfil.papel !== 'admin' || perfil.ativo === false) return resp(403, { erro: 'Somente administradores podem alterar a senha de outra pessoa.' });

    // 2) o que trocar?
    const b = await req.json().catch(() => ({}));
    const alvo = String(b.user_id || ''), senha = String(b.senha || ''), trocar = b.trocar !== false;
    if (!/^[0-9a-f-]{36}$/i.test(alvo)) return resp(400, { erro: 'Usuário inválido.' });
    if (senha.length < 6) return resp(400, { erro: 'A senha precisa ter pelo menos 6 caracteres.' });
    if (senha.length > 72) return resp(400, { erro: 'A senha pode ter no máximo 72 caracteres.' });

    const { data: atual, error: eAlvo } = await adm.auth.admin.getUserById(alvo);
    if (eAlvo || !atual?.user) return resp(404, { erro: 'Usuário não encontrado.' });

    // 3) troca a senha; "trocar_senha" faz o app pedir uma senha nova no próximo login
    const meta = { ...(atual.user.user_metadata || {}), trocar_senha: trocar };
    const { error: eUp } = await adm.auth.admin.updateUserById(alvo, { password: senha, user_metadata: meta });
    if (eUp) return resp(400, { erro: 'Não foi possível trocar: ' + eUp.message });

    console.log(`senha alterada · alvo=${alvo} · por=${eu.user.id} · trocar_no_login=${trocar}`);
    return resp(200, { ok: true, trocar });
  } catch (e) {
    console.error(e);
    return resp(500, { erro: 'Erro inesperado. Tente de novo.' });
  }
});
