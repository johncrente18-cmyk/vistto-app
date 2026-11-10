// Vistto · gerador de PDF (relatório de inspeção e evidência de fechamento de NC)
// Desenha cada página num canvas e monta o PDF (JPEG por página). Funciona sem bibliotecas.
(function () {
  const LOGO = "<svg viewBox=\"0 0 400 400\" width=\"400\" height=\"400\" xmlns=\"http://www.w3.org/2000/svg\"><defs><linearGradient id=\"g1\" x1=\"0\" y1=\"0\" x2=\"1\" y2=\"1\"><stop offset=\"0\" stop-color=\"#9184d9\"/><stop offset=\"1\" stop-color=\"#67e8f9\"/></linearGradient><linearGradient id=\"g3\" gradientUnits=\"userSpaceOnUse\" x1=\"200\" y1=\"20\" x2=\"330\" y2=\"90\"><stop offset=\"0\" stop-color=\"#67e8f9\" stop-opacity=\"0\"/><stop offset=\"1\" stop-color=\"#67e8f9\" stop-opacity=\".5\"/></linearGradient></defs><circle cx=\"200\" cy=\"200\" r=\"118\" fill=\"none\" stroke=\"#9184d9\" stroke-opacity=\".55\" stroke-width=\"2\" stroke-dasharray=\"3 9\"/><circle cx=\"200\" cy=\"200\" r=\"168\" fill=\"none\" stroke=\"#9184d9\" stroke-opacity=\".25\" stroke-width=\"1.2\"/><circle cx=\"200\" cy=\"200\" r=\"78\" fill=\"none\" stroke=\"url(#g1)\" stroke-width=\"22\"/><path d=\"M200 200 L200 8 A192 192 0 0 1 335.8 64.2 Z\" fill=\"url(#g3)\"/><path d=\"M200 200 L335.8 64.2\" stroke=\"#67e8f9\" stroke-width=\"2\"/><circle cx=\"200\" cy=\"200\" r=\"25\" fill=\"#f1f0f7\"/><g transform=\"translate(200.0 32.0)\"><circle r=\"24\" fill=\"#161826\" stroke=\"#67e8f9\" stroke-width=\"1.5\"/><g fill=\"none\" stroke=\"#67e8f9\" stroke-width=\"2.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M-11 4 C-11 -6 -5 -10 1 -10 C8 -10 12 -5 12 4\"/><path d=\"M-13 4 H12 Q17 4 18 7.5 H-13 Z\"/><path d=\"M0 -10 C-4 -6 -5 -1 -5 4\"/><path d=\"M4 -9.5 C2 -6 1.5 -1 1.5 4\"/></g></g><g transform=\"translate(298.7 64.1)\"><circle r=\"24\" fill=\"#161826\" stroke=\"#c4b5fd\" stroke-width=\"1.5\"/><g fill=\"none\" stroke=\"#c4b5fd\" stroke-width=\"2.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M-6 12 V-1 L-10 -5 M-6 -1 V-9 a2 2 0 0 1 4 0 V-1 M-2 -11 a2 2 0 0 1 4 0 V-1 M2 -10 a2 2 0 0 1 4 0 V-1 M6 -7 a2 2 0 0 1 4 0 V3 c0 5 -3 9 -8 9 H-6\"/><path d=\"M-6 12 H6\"/></g></g><g transform=\"translate(359.8 148.1)\"><circle r=\"24\" fill=\"#161826\" stroke=\"#67e8f9\" stroke-width=\"1.5\"/><g fill=\"none\" stroke=\"#67e8f9\" stroke-width=\"2.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M-14 -4 H-2 V1 a4 4 0 0 1 -4 4 H-10 a4 4 0 0 1 -4 -4 Z\"/><path d=\"M14 -4 H2 V1 a4 4 0 0 0 4 4 H10 a4 4 0 0 0 4 -4 Z\"/><path d=\"M-2 -2 Q0 -4 2 -2\"/><path d=\"M-14 -4 L-16 -6 M14 -4 L16 -6\"/></g></g><g transform=\"translate(359.8 251.9)\"><circle r=\"24\" fill=\"#161826\" stroke=\"#c4b5fd\" stroke-width=\"1.5\"/><g fill=\"none\" stroke=\"#c4b5fd\" stroke-width=\"2.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M-10 2 V-2 A10 10 0 0 1 10 -2 V2\"/><rect x=\"-14\" y=\"1\" width=\"7\" height=\"11\" rx=\"3\"/><rect x=\"7\" y=\"1\" width=\"7\" height=\"11\" rx=\"3\"/></g></g><g transform=\"translate(298.7 335.9)\"><circle r=\"24\" fill=\"#161826\" stroke=\"#67e8f9\" stroke-width=\"1.5\"/><g fill=\"none\" stroke=\"#67e8f9\" stroke-width=\"2.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M-6 -12 V2 M6 -12 V2 M-6 -5 H6 M-6 2 H6 M-6 2 L-9 12 M6 2 L9 12 M-9 7 H9\"/><circle cx=\"0\" cy=\"-9\" r=\"2.2\"/></g></g><g transform=\"translate(200.0 368.0)\"><circle r=\"24\" fill=\"#161826\" stroke=\"#c4b5fd\" stroke-width=\"1.5\"/><g fill=\"none\" stroke=\"#c4b5fd\" stroke-width=\"2.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M-10 -12 H-1 V1 L8 3 Q12 4 12 8 V11 H-10 Z\"/><path d=\"M-10 7.5 H12\"/><path d=\"M4 2 Q6 5 5 7.5\"/><path d=\"M-1 -7 H-4 M-1 -3 H-4\"/></g></g><g transform=\"translate(101.3 335.9)\"><circle r=\"24\" fill=\"#161826\" stroke=\"#67e8f9\" stroke-width=\"1.5\"/><g fill=\"none\" stroke=\"#67e8f9\" stroke-width=\"2.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M-5 -12 L-11 -8 V12 H-2 V-3 L0 -6 L2 -3 V12 H11 V-8 L5 -12 L0 -6 Z\"/><path d=\"M-11 2 H-2 M2 2 H11 M-11 6 H-2 M2 6 H11\"/></g></g><g transform=\"translate(40.2 251.9)\"><circle r=\"24\" fill=\"#161826\" stroke=\"#c4b5fd\" stroke-width=\"1.5\"/><g fill=\"none\" stroke=\"#c4b5fd\" stroke-width=\"2.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M-8 13 V-2 L-11 -6 M-8 -2 V-8 a2 2 0 0 1 4 0 V-3 M-4 -10 a2 2 0 0 1 4 0 V-3 M0 -9 a2 2 0 0 1 4 0 V-3 M4 -6 a2 2 0 0 1 4 0 V13\"/><path d=\"M-8 13 H8\"/><path d=\"M1 -1 L-3 5 H1 L-1 10\" stroke=\"#ffd166\"/></g></g><g transform=\"translate(40.2 148.1)\"><circle r=\"24\" fill=\"#161826\" stroke=\"#67e8f9\" stroke-width=\"1.5\"/><g fill=\"none\" stroke=\"#67e8f9\" stroke-width=\"2.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M-6 -2 a6 6 0 0 1 12 0 V12 H-6 Z\"/><path d=\"M-2.5 -11 H2.5 V-8 H-2.5 Z M0 -8 V-7.5\"/><path d=\"M2.5 -10 Q10 -10 10 -2 V2\"/><path d=\"M-6 3 H6\"/></g></g><g transform=\"translate(101.3 64.1)\"><circle r=\"24\" fill=\"#161826\" stroke=\"#c4b5fd\" stroke-width=\"1.5\"/><g fill=\"none\" stroke=\"#c4b5fd\" stroke-width=\"2.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M-3 -12 H3 L9 8 H-9 Z\"/><path d=\"M-12 8 H12 V11 H-12 Z\"/><path d=\"M-5.5 -3 H5.5 M-7 3 H7\" stroke=\"#ffad3b\"/></g></g></svg>";
  const S = 4, PW = 595, PH = 842, M = 32, CW = PW - 2 * M, FONT = 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
  const VI = '#6c5fd0', TEAL = '#19d3b0', ORG = '#ff8a1f', TXT = '#1b1d2a', MUT = '#5d6075', LINE = '#e6e4f0';
  const ST = { aberta: 'Enviada ao líder', vista: 'Vista pelo líder', corrigida: 'Corrigida · aguardando validação', encerrada: 'Encerrada' };
  const pad2 = n => String(n).padStart(2, '0');
  const fdt = v => { if (!v) return '—'; const d = new Date(v); return `${pad2(d.getDate())}/${pad2(d.getMonth() + 1)}/${d.getFullYear()} · ${pad2(d.getHours())}:${pad2(d.getMinutes())}`; };
  const loadImg = src => new Promise(res => { if (!src) return res(null); const im = new Image(); im.onload = () => res(im); im.onerror = () => res(null); im.src = src; });
  let logoP = null; const logo = () => logoP || (logoP = loadImg('data:image/svg+xml;charset=utf-8,' + encodeURIComponent(LOGO)));

  function doc() {
    const pages = []; let c, x; const D = { y: M };
    const nova = () => { c = document.createElement('canvas'); c.width = Math.round(PW * S); c.height = Math.round(PH * S); x = c.getContext('2d'); x.imageSmoothingEnabled = true; x.imageSmoothingQuality = 'high'; x.scale(S, S); x.fillStyle = '#fff'; x.fillRect(0, 0, PW, PH); pages.push(c); D.y = M; D.x = x; };
    nova();
    D.nova = nova; D.pages = pages;
    D.fnt = (sz, w) => { D.x.font = `${w || 400} ${sz}px ${FONT}`; };
    D.wrap = (txt, maxW) => { const out = []; String(txt == null ? '' : txt).split('\n').forEach(par => { let l = ''; par.split(/\s+/).forEach(w => { const tt = l ? l + ' ' + w : w; if (D.x.measureText(tt).width > maxW && l) { out.push(l); l = w; } else l = tt; }); out.push(l); }); return out; };
    D.rr = (X, Y, W, H, r) => { const x = D.x; x.beginPath(); x.moveTo(X + r, Y); x.arcTo(X + W, Y, X + W, Y + H, r); x.arcTo(X + W, Y + H, X, Y + H, r); x.arcTo(X, Y + H, X, Y, r); x.arcTo(X, Y, X + W, Y, r); x.closePath(); };
    D.sp = (txt, X, Y, gap, align) => { const x = D.x; let w = 0; for (const ch of txt) w += x.measureText(ch).width + gap; w -= gap; let cx = align === 'right' ? X - w : align === 'center' ? X - w / 2 : X; for (const ch of txt) { x.fillText(ch, cx, Y); cx += x.measureText(ch).width + gap; } return w; };
    D.grad = (x0, x1, a, b) => { const g = D.x.createLinearGradient(x0, 0, x1, 0); g.addColorStop(0, a); g.addColorStop(1, b); return g; };
    D.cabe = h => { if (D.y + h > PH - 44) nova(); };
    D.sec = nome => { D.cabe(90); const x = D.x; D.y += 8; D.fnt(7.6, 700); x.fillStyle = VI; D.sp(String(nome).toUpperCase(), M, D.y + 8, 1.6); x.fillStyle = D.grad(M, M + CW, '#9184d9', 'rgba(103,232,249,0)'); x.fillRect(M, D.y + 13, CW, 1.6); D.y += 22; };
    return D;
  }
  function cabecalho(D, lg, obra) {
    const x = D.x, y = D.y, HH = 74; x.save(); D.rr(M, y, CW, HH, 12); x.clip();
    x.fillStyle = '#12141f'; x.fillRect(M, y, CW, HH);
    let g = x.createRadialGradient(M, y, 0, M, y, 260); g.addColorStop(0, 'rgba(145,132,217,.5)'); g.addColorStop(1, 'rgba(145,132,217,0)'); x.fillStyle = g; x.fillRect(M, y, CW, HH);
    g = x.createRadialGradient(M + CW, y + HH, 0, M + CW, y + HH, 220); g.addColorStop(0, 'rgba(103,232,249,.25)'); g.addColorStop(1, 'rgba(103,232,249,0)'); x.fillStyle = g; x.fillRect(M, y, CW, HH);
    x.strokeStyle = 'rgba(145,132,217,.16)'; x.lineWidth = .5; for (let gx = M; gx < M + CW; gx += 14) { x.beginPath(); x.moveTo(gx, y); x.lineTo(gx, y + HH); x.stroke(); } for (let gy = y; gy < y + HH; gy += 14) { x.beginPath(); x.moveTo(M, gy); x.lineTo(M + CW, gy); x.stroke(); }
    x.fillStyle = D.grad(M + 20, M + CW / 2, 'rgba(103,232,249,0)', '#67e8f9'); x.fillRect(M + 20, y + HH - 2, (CW - 40) / 2, 2); x.fillStyle = D.grad(M + CW / 2, M + CW - 20, '#9184d9', 'rgba(145,132,217,0)'); x.fillRect(M + CW / 2, y + HH - 2, (CW - 40) / 2, 2);
    x.restore();
    if (lg) x.drawImage(lg, M + 12, y + 9, 56, 56);
    D.fnt(22, 800); x.fillStyle = '#d4ccff'; const wv = D.sp('VISTTO', M + 78, y + 35, 6.5);
    x.fillStyle = D.grad(M + 78, M + 78 + wv * .62, '#9184d9', '#67e8f9'); x.fillRect(M + 78, y + 40, wv * .62, 1.6);
    D.fnt(6.6, 500); x.fillStyle = '#a9acc4'; D.sp('INSPEÇÕES DE SEGURANÇA', M + 78, y + 53, 1.9);
    x.textAlign = 'right'; D.fnt(13, 700); x.fillStyle = '#fff'; x.fillText(obra || 'UFV Paraíso', M + CW - 16, y + 30);
    D.fnt(8.5, 400); x.fillStyle = '#c9cbe0'; x.fillText('Consórcio Solar Paraíso', M + CW - 16, y + 44); D.fnt(8, 400); x.fillStyle = '#8f92a8'; x.fillText('Paraíso das Águas · MS', M + CW - 16, y + 56); x.textAlign = 'left';
    D.y += HH + 20;
  }
  function titulo(D, tit, sub, reg) {
    const x = D.x; D.fnt(16, 700); x.fillStyle = TXT; const tl = D.wrap(tit, CW - 150); tl.forEach((l, k) => x.fillText(l, M + 2, D.y + 6 + k * 19)); D.y += 6 + (tl.length - 1) * 19;
    D.fnt(8.6, 400); x.fillStyle = MUT; x.fillText(sub, M + 2, D.y + 15);
    x.textAlign = 'right'; D.fnt(7.5, 400); x.fillText('Nº do registro', M + CW - 2, D.y - 4); D.fnt(9.5, 700); x.fillStyle = TXT; x.fillText(reg, M + CW - 2, D.y + 9); x.textAlign = 'left';
    D.y += 28;
  }
  function rodape(D, obra) {
    const ger = new Date(), gerTxt = `${pad2(ger.getDate())}/${pad2(ger.getMonth() + 1)}/${ger.getFullYear()} ${pad2(ger.getHours())}:${pad2(ger.getMinutes())}`;
    D.pages.forEach((pc, k) => { const z = pc.getContext('2d'); z.save(); z.setTransform(S, 0, 0, S, 0, 0); z.fillStyle = LINE; z.fillRect(M, PH - 30, CW, .8); z.font = `700 7px ${FONT}`; z.fillStyle = VI; let w = 0; for (const ch of 'VISTTO') { z.fillText(ch, M + w, PH - 18); w += z.measureText(ch).width + 1.6; }
      z.font = `400 7px ${FONT}`; z.fillStyle = '#8a8da3'; z.fillText(' · ' + (obra || 'UFV Paraíso') + ' · Consórcio Solar Paraíso · Gerado em ' + gerTxt, M + w + 2, PH - 18); z.textAlign = 'right'; z.fillText(`Página ${k + 1} de ${D.pages.length}`, M + CW, PH - 18); z.restore(); });
  }
  function montaPDF(pages) {
    const enc = new TextEncoder(), parts = [], offs = []; let len = 0;
    const add = d => { const u = typeof d === 'string' ? enc.encode(d) : d; parts.push(u); len += u.length; }; const obj = (n, body) => { offs[n] = len; add(`${n} 0 obj\n`); body(); add('\nendobj\n'); };
    const np = pages.length, kids = pages.map((_, k) => `${3 + k * 3} 0 R`).join(' ');
    add('%PDF-1.4\n%\xE2\xE3\xCF\xD3\n');
    obj(1, () => add('<< /Type /Catalog /Pages 2 0 R >>')); obj(2, () => add(`<< /Type /Pages /Kids [${kids}] /Count ${np} >>`));
    pages.forEach((pc, k) => { const jpg = pc.toDataURL('image/jpeg', .93), bin = atob(jpg.split(',')[1]), img = new Uint8Array(bin.length); for (let q = 0; q < bin.length; q++) img[q] = bin.charCodeAt(q);
      const p = 3 + k * 3, cs = `q ${PW} 0 0 ${PH} 0 0 cm /Im0 Do Q`;
      obj(p, () => add(`<< /Type /Page /Parent 2 0 R /MediaBox [0 0 ${PW} ${PH}] /Resources << /XObject << /Im0 ${p + 1} 0 R >> >> /Contents ${p + 2} 0 R >>`));
      obj(p + 1, () => { add(`<< /Type /XObject /Subtype /Image /Width ${pc.width} /Height ${pc.height} /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length ${img.length} >>\nstream\n`); add(img); add('\nendstream'); });
      obj(p + 2, () => add(`<< /Length ${cs.length} >>\nstream\n${cs}\nendstream`)); });
    const tot = 3 + np * 3, xref = len; add(`xref\n0 ${tot}\n0000000000 65535 f \n${Array.from({ length: tot - 1 }, (_, k) => String(offs[k + 1]).padStart(10, '0') + ' 00000 n \n').join('')}trailer\n<< /Size ${tot} /Root 1 0 R >>\nstartxref\n${xref}\n%%EOF`);
    return new Blob(parts, { type: 'application/pdf' });
  }
  const regDe = (id, quando) => { const dt = new Date(quando); return `VST-${dt.getFullYear()}${pad2(dt.getMonth() + 1)}${pad2(dt.getDate())}-${String(id).replace(/-/g, '').slice(0, 4).toUpperCase()}`; };
  const TW = 92, TH = 66;
  const desenhaFoto = (D, im, X, Y, w, h) => { const x = D.x; w = w || TW; h = h || TH; x.save(); D.rr(X, Y, w, h, 6); x.clip(); const r0 = Math.max(w / im.width, h / im.height), ww = im.width * r0, hh = im.height * r0; x.drawImage(im, X + (w - ww) / 2, Y + (h - hh) / 2, ww, hh); x.restore(); };

  // R: { id, titulo, grupo, tecnico, quando, local, lider, equipamento, conf, ncs, obs, fotoLocalId, obra, rows:[{sec,nome}|{q,kind,nome,ans,com,ncObj,ids}] }
  // imgs: { fotoId: dataURL }
  async function relatorio(R, fontes) {
    const ids = [R.fotoLocalId, ...R.rows.flatMap(r => r.ids || [])].filter(Boolean), imgs = {};
    await Promise.all(ids.map(async id => { imgs[id] = await loadImg(fontes[id]); }));
    const lg = await logo(), D = doc(), x0 = () => D.x;
    const dt = new Date(R.quando), dtTxt = fdt(R.quando);
    const qs = R.rows.filter(r => r.q), nC = qs.filter(r => r.kind === 'c').length, nN = qs.filter(r => r.kind === 'nc').length, nA = qs.filter(r => r.kind === 'na').length;
    const conf = R.conf != null ? R.conf : (nC + nN ? Math.round(100 * nC / (nC + nN)) : 100);
    cabecalho(D, lg, R.obra); titulo(D, R.titulo, [R.grupo, 'Relatório de inspeção'].filter(Boolean).join(' · '), regDe(R.id, R.quando));
    let x = x0(), y = D.y; const BH = 104; x.strokeStyle = LINE; x.lineWidth = 1; D.rr(M, y, 120, BH, 10); x.fillStyle = '#faf9ff'; x.fill(); x.stroke();
    const cx0 = M + 60, cy0 = y + 42, ra = 30; x.lineWidth = 10; x.lineCap = 'butt';
    x.strokeStyle = '#ffad3b'; x.beginPath(); x.arc(cx0, cy0, ra, 0, Math.PI * 2); x.stroke();
    x.strokeStyle = TEAL; x.beginPath(); x.arc(cx0, cy0, ra, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * conf / 100); x.stroke();
    x.textAlign = 'center'; D.fnt(13, 800); x.fillStyle = TXT; x.fillText(conf + '%', cx0, cy0 + 3); x.textAlign = 'left'; D.fnt(4.4, 600); x.fillStyle = MUT; D.sp('CONFORMIDADE', cx0, cy0 + 11.5, .3, 'center');
    const chipz = [['✔ ' + nC, '#d9f7f0', '#0b7a66'], ['✖ ' + nN, '#ffe9cf', '#b34f00'], ['N/A ' + nA, '#eceef4', MUT]]; D.fnt(7.5, 600);
    let chx = M + 60 - (chipz.reduce((a, k) => a + x.measureText(k[0]).width + 12, 0) + 8) / 2;
    chipz.forEach(([tx, bg, fg]) => { const w = x.measureText(tx).width + 12; D.rr(chx, y + 82, w, 13, 6.5); x.fillStyle = bg; x.fill(); x.fillStyle = fg; x.fillText(tx, chx + 6, y + 91.5); chx += w + 4; });
    const IX = M + 130, IW = CW - 130; x.strokeStyle = LINE; x.lineWidth = 1; D.rr(IX, y, IW, BH, 10); x.stroke();
    const nAb = (R.ncs || []).filter(n => n.status !== 'encerrada').length;
    const info = [['Técnico responsável', R.tecnico], ['Data e hora', dtTxt], ['Frente de serviço', R.local], ['Líder / encarregado', R.lider || '—'], ['Não conformidades', (R.ncs || []).length ? `${R.ncs.length} (${nAb} em aberto)` : (nN ? String(nN) : 'Nenhuma')], [R.equipamento ? 'Máquina / equipamento' : 'Itens respondidos', R.equipamento || String(qs.filter(r => r.kind !== 'none').length + ' de ' + qs.length)]];
    info.forEach(([l, v], k) => { const col = k % 2, row = Math.floor(k / 2), X = IX + 14 + col * (IW / 2), Y = y + 22 + row * 29; D.fnt(5.8, 600); x.fillStyle = '#8a8da3'; D.sp(l.toUpperCase(), X, Y, .8); D.fnt(9, 500); x.fillStyle = TXT; x.fillText(D.wrap(v, IW / 2 - 22)[0] || '', X, Y + 12); });
    D.y = y + BH + 14;
    let rows = R.rows; if (R.fotoLocalId && imgs[R.fotoLocalId]) rows = [{ sec: true, nome: 'Foto do local' }, { q: true, kind: 'foto', nome: '', ans: '', ids: [R.fotoLocalId] }].concat(rows);
    const COR = { c: TEAL, nc: ORG, na: '#b6b8c8', txt: '#9184d9', none: '#d6d4e2', foto: '#9184d9' };
    const BAD = { c: ['✔ CONFORME', '#d9f7f0', '#0b7a66'], nc: ['✖ NÃO CONFORME', '#ffe9cf', '#b34f00'], na: ['NÃO SE APLICA', '#eceef4', MUT] };
    rows.forEach(r => {
      if (r.sec) { D.sec(r.nome); return; }
      x = D.x; const IWd = CW - 22; D.fnt(8.8, 400); const ql = r.nome ? D.wrap(r.nome, IWd) : [];
      const fotos = (r.ids || []).map(id => imgs[id]).filter(Boolean), perRow = Math.max(1, Math.floor((IWd + 8) / (TW + 8))), frows = Math.ceil(fotos.length / perRow);
      D.fnt(8.6, 400); const cl = r.com ? D.wrap('Comentário: ' + r.com, IWd) : [];
      const n = r.ncObj, ncL = []; if (r.kind === 'nc') { D.fnt(8.2, 400); ncL.push(...D.wrap('Não conformidade · ' + (n ? (ST[n.status] || n.status) : 'aberta'), IWd - 16)); if (n && n.descricao && n.descricao !== r.com) ncL.push(...D.wrap('Descrição: ' + n.descricao, IWd - 16)); if (n && (n.responsavel_nome || n.prazo)) ncL.push(...D.wrap([n.responsavel_nome ? 'Responsável: ' + n.responsavel_nome : '', n.prazo ? 'Prazo: ' + fdt(n.prazo) : ''].filter(Boolean).join(' · '), IWd - 16)); if (n && n.comentario_correcao) ncL.push(...D.wrap('Correção: ' + n.comentario_correcao, IWd - 16)); }
      const ansH = r.kind === 'foto' ? 0 : 16, h = 10 + ql.length * 11.5 + ansH + cl.length * 11 + (ncL.length ? ncL.length * 10.5 + 12 : 0) + (frows ? frows * (TH + 6) + 4 : 0) + 6;
      D.cabe(h); x = D.x; const Y0 = D.y;
      D.rr(M, Y0, CW, h, 7); x.fillStyle = r.kind === 'nc' ? '#fffaf3' : '#fff'; x.fill(); x.strokeStyle = LINE; x.lineWidth = .8; x.stroke();
      x.save(); D.rr(M, Y0, CW, h, 7); x.clip(); x.fillStyle = COR[r.kind] || COR.none; x.fillRect(M, Y0, 3.5, h); x.restore();
      let yy = Y0 + 14; D.fnt(8.8, 400); x.fillStyle = '#2b2d3e';
      ql.forEach((l, k) => { if (k === 0) { const m = l.match(/^([\d.]+) · (.*)$/); if (m) { D.fnt(8.8, 700); x.fillStyle = VI; x.fillText(m[1], M + 12, yy); const w = x.measureText(m[1] + '  ').width; D.fnt(8.8, 400); x.fillStyle = '#2b2d3e'; x.fillText(m[2], M + 12 + w, yy); yy += 11.5; return; } } x.fillText(l, M + 12, yy); yy += 11.5; });
      if (r.kind !== 'foto') { const b = BAD[r.kind]; if (b) { D.fnt(7.4, 700); const w = x.measureText(b[0]).width + 12; D.rr(M + 12, yy - 6, w, 13, 4); x.fillStyle = b[1]; x.fill(); x.fillStyle = b[2]; x.fillText(b[0], M + 18, yy + 3.5); }
        else { D.fnt(9.2, 600); x.fillStyle = r.kind === 'none' ? '#9a9cae' : TXT; x.fillText(D.wrap(String(r.ans).replace(/^[✔✖] /, ''), IWd)[0] || '', M + 12, yy + 4); } yy += ansH; }
      if (cl.length) { D.fnt(8.6, 400); x.fillStyle = '#3a3c4f'; cl.forEach(l => { x.fillText(l, M + 12, yy + 2); yy += 11; }); }
      if (ncL.length) { const hh = ncL.length * 10.5 + 8; D.rr(M + 12, yy - 4, IWd, hh, 6); x.fillStyle = '#fff1e0'; x.fill(); x.strokeStyle = '#ffd3a3'; x.lineWidth = .8; x.stroke(); D.fnt(8.2, 400); ncL.forEach((l, k) => { x.fillStyle = k === 0 ? '#b34f00' : '#6b5a48'; x.fillText(l, M + 20, yy + 6 + k * 10.5); }); yy += hh + 4; }
      if (frows) fotos.forEach((im, k) => desenhaFoto(D, im, M + 12 + (k % perRow) * (TW + 8), yy + Math.floor(k / perRow) * (TH + 6)));
      D.y = Y0 + h + 5;
    });
    if (R.obs) { D.fnt(8.8, 400); const ol = D.wrap(R.obs, CW - 24); D.cabe(40 + ol.length * 11.5); D.sec('Observações da inspeção'); x = D.x; const hh = ol.length * 11.5 + 12; D.rr(M, D.y, CW, hh, 7); x.strokeStyle = LINE; x.stroke(); D.fnt(8.8, 400); x.fillStyle = TXT; ol.forEach((l, k) => x.fillText(l, M + 12, D.y + 15 + k * 11.5)); D.y += hh + 6; }
    assinaturas(D, [[R.tecnico, 'Técnico de Segurança do Trabalho'], [R.lider || '', 'Líder / encarregado']]);
    rodape(D, R.obra);
    return { blob: montaPDF(D.pages), paginas: D.pages.length };
  }
  function assinaturas(D, pares) {
    D.cabe(60); D.y += 34; const x = D.x, half = (CW - 30) / 2;
    pares.forEach(([nm, cg], k) => { const X = M + k * (half + 30); x.fillStyle = D.grad(X, X + half, '#9184d9', '#67e8f9'); x.fillRect(X, D.y, half, 1.2); x.textAlign = 'center'; D.fnt(9, 700); x.fillStyle = TXT; x.fillText(nm || ' ', X + half / 2, D.y + 13); D.fnt(7.8, 400); x.fillStyle = MUT; x.fillText(cg, X + half / 2, D.y + 24); x.textAlign = 'left'; });
  }

  // E: { nc, inspecao:{id,titulo,quando,tecnico,local,equipamento,lider}, validadoPor, obra }
  async function evidencia(E, fontes) {
    const n = E.nc, imgs = {}; await Promise.all([n.foto_id, n.foto_correcao_id].filter(Boolean).map(async id => { imgs[id] = await loadImg(fontes[id]); }));
    const lg = await logo(), D = doc(); let x = D.x;
    cabecalho(D, lg, E.obra); titulo(D, 'Evidência de fechamento de não conformidade', [E.inspecao.titulo, E.inspecao.equipamento].filter(Boolean).join(' · '), regDe(n.id, n.criado_em));
    // faixa de situação
    const enc = n.status === 'encerrada'; D.rr(M, D.y, CW, 26, 8); x.fillStyle = enc ? '#d9f7f0' : '#ffe9cf'; x.fill(); D.fnt(9.5, 700); x.fillStyle = enc ? '#0b7a66' : '#b34f00';
    x.fillText(enc ? `✔ NC ENCERRADA em ${fdt(n.encerrado_em)}${E.validadoPor ? ' · validada por ' + E.validadoPor : ''}` : `Situação: ${ST[n.status] || n.status}`, M + 12, D.y + 17); D.y += 38;
    const campos = [['Item / pergunta', n.pergunta], ['Descrição da NC', n.descricao || '—'], ['Máquina / equipamento', E.inspecao.equipamento || n.equipamento || '—'], ['Frente de serviço', E.inspecao.local || '—'],
      ['Técnico que abriu', E.inspecao.tecnico || '—'], ['Responsável pela correção', n.responsavel_nome || '—'], ['Aberta em', fdt(n.criado_em)], ['Prazo', fdt(n.prazo)], ['Vista pelo líder', fdt(n.visto_em)], ['Corrigida em', fdt(n.corrigido_em)]];
    D.fnt(9, 500); const IW = (CW - 28) / 2; let yy = D.y; const linhas = Math.ceil(campos.length / 2) ;
    const boxH = linhas * 30 + 12; x.strokeStyle = LINE; x.lineWidth = 1; D.rr(M, yy, CW, boxH, 10); x.stroke();
    campos.forEach(([l, v], k) => { const col = k % 2, row = Math.floor(k / 2), X = M + 14 + col * (IW + 14), Y = yy + 20 + row * 30; D.fnt(5.8, 600); x.fillStyle = '#8a8da3'; D.sp(l.toUpperCase(), X, Y, .8); D.fnt(9, 500); x.fillStyle = TXT; x.fillText(D.wrap(v, IW - 8)[0] || '', X, Y + 12); });
    D.y += boxH + 10;
    const blocoTexto = (tt, txt) => { if (!txt) return; D.sec(tt); x = D.x; D.fnt(9, 400); const ol = D.wrap(txt, CW - 24), hh = ol.length * 12 + 12; D.cabe(hh); x = D.x; D.rr(M, D.y, CW, hh, 7); x.strokeStyle = LINE; x.stroke(); x.fillStyle = TXT; ol.forEach((l, k) => x.fillText(l, M + 12, D.y + 16 + k * 12)); D.y += hh + 6; };
    blocoTexto('Comentário da correção', n.comentario_correcao); blocoTexto('Nota de encerramento', n.nota_encerramento);
    D.sec('Fotos: antes e depois'); x = D.x; const PWd = (CW - 16) / 2, PHt = 175; D.cabe(PHt + 30); x = D.x;
    [['ANTES · NÃO CONFORMIDADE', n.foto_id, '#b34f00'], ['DEPOIS · CORREÇÃO', n.foto_correcao_id, '#0b7a66']].forEach(([l, id, cor], k) => { const X = M + k * (PWd + 16); D.fnt(7, 700); x.fillStyle = cor; D.sp(l, X, D.y + 8, 1); const im = imgs[id];
      if (im) desenhaFoto(D, im, X, D.y + 14, PWd, PHt); else { D.rr(X, D.y + 14, PWd, PHt, 6); x.fillStyle = '#f3f2f8'; x.fill(); D.fnt(8.5, 400); x.fillStyle = '#9a9cae'; x.textAlign = 'center'; x.fillText('Sem foto', X + PWd / 2, D.y + 14 + PHt / 2); x.textAlign = 'left'; } });
    D.y += PHt + 24;
    assinaturas(D, [[n.responsavel_nome || '', 'Responsável pela correção'], [E.validadoPor || E.inspecao.tecnico || '', 'Validação (Técnico de Segurança)']]);
    rodape(D, E.obra);
    return { blob: montaPDF(D.pages), paginas: D.pages.length };
  }
  window.VisttoPDF = { relatorio, evidencia, ST };
})();
