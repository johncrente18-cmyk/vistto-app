// Vistto · envio automático do e-mail de Não Conformidade (Supabase Edge Function + Brevo)
// É chamada pelo Database Webhook "enviar-nc" a cada NC nova (INSERT em public.ncs).
// Segredos necessários (Supabase › Edge Functions › Secrets):
//   BREVO_API_KEY   chave de API da Brevo (SMTP & API › API keys)
//   REMETENTE_EMAIL e-mail confirmado como remetente na Brevo (Senders)
//   APP_URL         (opcional) endereço do app; padrão abaixo
import { createClient } from 'npm:@supabase/supabase-js@2';

const sb = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, { auth: { persistSession: false } });
const APP = (Deno.env.get('APP_URL') || 'https://johncrente18-cmyk.github.io/vistto-app/').replace(/#.*$/, '');
const esc = (v: unknown) => String(v ?? '').replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]!));
const dataBR = (v: string | null) => v ? new Date(v).toLocaleString('pt-BR', { timeZone: 'America/Sao_Paulo', day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : '—';

Deno.serve(async (req) => {
  try {
    const body = await req.json().catch(() => ({}));
    const nc = body.record ?? body;
    if (!nc?.id) return new Response('sem NC', { status: 400 });

    const { data: atual } = await sb.from('ncs').select('*').eq('id', nc.id).maybeSingle();
    if (!atual) return new Response('NC não encontrada', { status: 404 });
    if (atual.email_enviado_em) return new Response('já enviado');

    const [frR, pessoasR, insR, fotoR] = await Promise.all([
      sb.from('frentes').select('id,nome,parent_id,tecnico_id'),
      sb.from('profiles').select('id,nome,email,papel,ativo'),
      sb.from('inspecoes').select('id,tipo,criado_em').eq('id', atual.inspecao_id).maybeSingle(),
      atual.foto_id ? sb.from('fotos').select('dados').eq('id', atual.foto_id).maybeSingle() : Promise.resolve({ data: null }),
    ]);
    const frentes = frR.data || [], pessoas = (pessoasR.data || []).filter(p => p.ativo !== false && p.email);
    const frente = frentes.find(f => f.id === atual.frente_id);
    const mar = frente ? frentes.find(f => f.id === (frente.parent_id || frente.id)) : null;
    const porId = (id: string | null) => id ? pessoas.find(p => p.id === id) : undefined;

    // destinatários: responsável (para) + autor, técnico do MAR, supervisores e gestores (cópia)
    const resp = porId(atual.responsavel_id);
    const copia = [porId(atual.autor_id), porId(mar?.tecnico_id), ...pessoas.filter(p => p.papel === 'supervisor' || p.papel === 'gestor')].filter(Boolean) as typeof pessoas;
    const vistos = new Set<string>(), to: { email: string; name: string }[] = [], cc: { email: string; name: string }[] = [];
    const add = (lista: typeof to, p?: { email: string; nome: string }) => { if (!p?.email) return; const k = p.email.toLowerCase(); if (vistos.has(k)) return; vistos.add(k); lista.push({ email: p.email, name: p.nome || p.email }); };
    add(to, resp); copia.forEach(p => add(to.length ? cc : to, p));
    if (!to.length) { await sb.from('ncs').update({ email_erro: 'Sem destinatário com e-mail cadastrado' }).eq('id', atual.id); return new Response('sem destinatário'); }

    const link = `${APP}#/nc/${atual.token}`, autor = porId(atual.autor_id);
    const html = `<div style="font-family:Arial,Helvetica,sans-serif;max-width:620px;margin:auto;color:#1d1f2b">
      <div style="background:#c43a3a;color:#fff;padding:14px 18px;border-radius:8px 8px 0 0;font-size:18px;font-weight:bold">Não conformidade · Vistto Inspeções</div>
      <div style="border:1px solid #e3e5ee;border-top:0;border-radius:0 0 8px 8px;padding:18px">
        <p style="font-size:16px;margin:0 0 12px"><b>${esc(atual.pergunta)}</b></p>
        ${atual.descricao ? `<p style="margin:0 0 12px">${esc(atual.descricao)}</p>` : ''}
        <table style="font-size:14px;border-collapse:collapse;margin-bottom:14px">
          ${atual.equipamento ? `<tr><td style="padding:3px 12px 3px 0;color:#6b6f80">Máquina</td><td>${esc(atual.equipamento)}</td></tr>` : ''}
          <tr><td style="padding:3px 12px 3px 0;color:#6b6f80">Frente</td><td>${esc(frente?.nome || '—')}</td></tr>
          <tr><td style="padding:3px 12px 3px 0;color:#6b6f80">Responsável</td><td>${esc(atual.responsavel_nome || '—')}</td></tr>
          <tr><td style="padding:3px 12px 3px 0;color:#6b6f80">Prazo</td><td><b>${dataBR(atual.prazo)}</b></td></tr>
          <tr><td style="padding:3px 12px 3px 0;color:#6b6f80">Registrada por</td><td>${esc(autor?.nome || '—')} em ${dataBR(atual.criado_em)}</td></tr>
        </table>
        ${fotoR.data?.dados ? '<p style="font-size:13px;color:#6b6f80">A foto da não conformidade está anexada.</p>' : ''}
        <p style="margin:18px 0"><a href="${link}" style="background:#9184d9;color:#161826;text-decoration:none;font-weight:bold;padding:12px 18px;border-radius:8px;display:inline-block">Abrir a NC e enviar a foto da correção</a></p>
        <p style="font-size:12px;color:#6b6f80">Se o botão não abrir, copie o endereço: ${link}</p>
      </div></div>`;

    const anexo = typeof fotoR.data?.dados === 'string' && fotoR.data.dados.startsWith('data:') ? [{ name: 'nao-conformidade.jpg', content: fotoR.data.dados.split(',')[1] }] : undefined;
    const r = await fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: { 'api-key': Deno.env.get('BREVO_API_KEY')!, 'content-type': 'application/json', accept: 'application/json' },
      body: JSON.stringify({
        sender: { email: Deno.env.get('REMETENTE_EMAIL')!, name: 'Vistto Inspeções' },
        to, ...(cc.length ? { cc } : {}),
        subject: `NC${atual.equipamento ? ' · ' + atual.equipamento.split(' · ')[0] : ''} · ${frente?.nome || ''} · ${atual.pergunta}`.slice(0, 180),
        htmlContent: html, ...(anexo ? { attachment: anexo } : {}),
      }),
    });
    const para = [...to, ...cc].map(x => x.email).join(', ');
    if (!r.ok) { const erro = (await r.text()).slice(0, 300); await sb.from('ncs').update({ email_erro: `Brevo ${r.status}: ${erro}`, email_para: para }).eq('id', atual.id); return new Response(erro, { status: 502 }); }
    await sb.from('ncs').update({ email_enviado_em: new Date().toISOString(), email_para: para, email_erro: null }).eq('id', atual.id);
    return new Response('ok');
  } catch (e) {
    return new Response(String(e), { status: 500 });
  }
});
