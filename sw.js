const CACHE = 'vistto-v28';
const CORE = ['./', './index.html', './checklist.html', './supabase.js', './manifest.webmanifest', './icon-192.png', './icon-512.png'];
self.addEventListener('install', e => { e.waitUntil(caches.open(CACHE).then(c => Promise.all(CORE.map(u => fetch(u, { cache: 'no-cache' }).then(r => r.ok && c.put(u, r)).catch(() => {})))).then(() => self.skipWaiting())); });
self.addEventListener('activate', e => { e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim())); });
const guarda = (req, r) => { if (r && r.ok) { const c = r.clone(); caches.open(CACHE).then(x => x.put(req, c)); } return r; };
self.addEventListener('fetch', e => {
  const u = new URL(e.request.url);
  if (e.request.method !== 'GET' || u.origin !== location.origin) return; // Supabase e WhatsApp passam direto
  // páginas, config e dados: sempre a versão nova quando há internet (revalida com o servidor); sem internet, a cópia salva
  if (e.request.mode === 'navigate' || /\.(html|json)$/.test(u.pathname) || u.pathname.endsWith('/')) {
    const raiz = new URL('./', location.href).pathname;
    const chave = u.pathname === raiz ? './index.html' : e.request;
    e.respondWith(fetch(e.request.url, { cache: 'no-cache' }).then(r => guarda(chave, r))
      .catch(() => caches.match(chave, { ignoreSearch: true }).then(h => h || caches.match('./index.html'))));
    return;
  }
  // demais arquivos (ícones, biblioteca): cópia salva primeiro, atualiza por trás
  e.respondWith(caches.match(e.request).then(hit => { const net = fetch(e.request).then(r => guarda(e.request, r)).catch(() => hit); return hit || net; }));
});
