// Client-side mock of app/server.js's business logic, for the GitHub Pages static demo
// ONLY. GitHub Pages serves static files and cannot run app/server.js's real Node backend
// (auth, IDOR checks including the D96 fix, FX conversion, approval chain) — this file ports
// the SAME logic so the static demo is a faithful walkthrough, not a hollow shell that only
// ever shows the login screen. The real SUT for `security-surface`/`perf-check`/`automate`
// (which need a live server to mean anything) stays `node app/server.js` locally — this mock
// exists only for `usability-heuristic-review`/`a11y-audit`/`visual-check`, which review
// rendered UI, not backend behavior. Clearly a fixture: never presented as the real backend.
(function () {
  const NOW = () => Date.now();
  const DAY = 24 * 3600 * 1000;

  const FX = {
    USD: { '2026-07-20': 0.92, '2026-07-21': 0.921, '2026-07-24': 0.919 },
    GBP: { '2026-07-20': 1.17, '2026-07-21': 1.171, '2026-07-24': 1.169, '2026-07-25': 1.168 },
  };
  function fxRate(currency, isoDate) {
    if (currency === 'EUR') return { rate: 1, stale: false };
    const table = FX[currency];
    if (!table) return null;
    if (table[isoDate]) return { rate: table[isoDate], stale: false };
    const dates = Object.keys(table).filter((d) => d <= isoDate).sort();
    if (dates.length === 0) return null;
    return { rate: table[dates[dates.length - 1]], stale: true };
  }

  function freshState() {
    return {
      users: {
        'employee@demo': { pw: 'demo1234', role: 'employee', id: 'u1', manager: 'manager@demo', name: 'Elie Employee' },
        'manager@demo': { pw: 'demo1234', role: 'manager', id: 'u2', manager: 'finance@demo', name: 'Mona Manager' },
        'finance@demo': { pw: 'demo1234', role: 'finance', id: 'u3', manager: 'director@demo', name: 'Fio Finance' },
        'director@demo': { pw: 'demo1234', role: 'director', id: 'u4', manager: null, name: 'Dara Director' },
      },
      reports: [],
      audit: [],
      seq: 1,
    };
  }
  let db = freshState();
  const tokens = {};

  function audit(action, who, detail) { db.audit.push({ action, who, detail, at: NOW() }); }
  function userById(id) { return Object.values(db.users).find((u) => u.id === id); }

  const HIERARCHY = ['manager', 'finance', 'director'];
  function chainFor(totalEur) {
    if (totalEur < 500) return ['manager'];
    if (totalEur <= 5000) return ['manager', 'finance'];
    return ['manager', 'finance', 'director'];
  }
  function nextApproverRole(report) {
    const chain = chainFor(report.totalEur).slice();
    const submitter = userById(report.submitterId);
    const idx = chain.indexOf(submitter.role);
    if (idx !== -1) {
      const escalated = HIERARCHY[HIERARCHY.indexOf(submitter.role) + 1];
      if (escalated && !chain.includes(escalated)) chain.splice(idx, 1, escalated);
      else chain.splice(idx, 1);
    }
    for (const role of chain) {
      if (report.approvals.some((a) => a.role === role)) continue;
      return role;
    }
    return null;
  }
  function recomputeTotal(report) {
    let totalEur = 0; let rateStale = false; let error = null;
    for (const line of report.lines) {
      const fx = fxRate(report.currency, line.date);
      if (!fx) { error = 'no exchange rate available for ' + report.currency + ' on ' + line.date; break; }
      if (fx.stale) rateStale = true;
      totalEur += Math.round(line.amount * fx.rate * 100) / 100;
    }
    report.totalEur = Math.round(totalEur * 100) / 100;
    report.rateStale = rateStale;
    return error;
  }
  function validateLines(lines, currency) {
    for (const l of lines) {
      if (!l.category || typeof l.amount !== 'number' || l.amount <= 0 || !l.date) return 'each line needs a category, a positive amount and a date';
      const ageDays = Math.floor((NOW() - new Date(l.date + 'T00:00:00Z').getTime()) / DAY);
      if (ageDays > 90) return 'line "' + l.category + '" dated ' + l.date + ' is more than 90 days old and is blocked at submission';
      const fx = fxRate(currency, l.date);
      if (!fx) return 'no exchange rate available for ' + currency + ' on ' + l.date;
      const eurEquivalent = Math.round(l.amount * fx.rate * 100) / 100;
      if (eurEquivalent >= 25 && !l.receipt) return 'line "' + l.category + '" (EUR-equivalent ' + eurEquivalent + ' >= 25) requires an attached receipt';
    }
    return null;
  }

  // Same read-path visibility rule as the real backend's D96 fix: owner always, an approver
  // only once submitted and currently awaiting their role.
  function canRead(rpt, user) {
    if (!rpt) return false;
    if (rpt.submitterId === user.id) return true;
    return rpt.status === 'submitted' && rpt.submitterId !== user.id && nextApproverRole(rpt) === user.role;
  }

  async function handle(path, opts = {}) {
    const method = opts.method || 'GET';
    const bodyData = opts.body ? JSON.parse(opts.body) : {};
    const authHeader = (opts.headers && opts.headers.Authorization) || '';
    const token = authHeader.replace('Bearer ', '');
    const auth = tokens[token] ? { email: tokens[token], user: db.users[tokens[token]] } : null;
    const [, , base, id, sub] = path.split('?')[0].split('/'); // '', 'api', 'reports', ':id', 'submit'|'decide'

    if (path === '/api/reset' && method === 'POST') { db = freshState(); for (const k in tokens) delete tokens[k]; return { ok: true, status: 200, data: { ok: true } }; }

    if (path === '/api/login' && method === 'POST') {
      const user = db.users[bodyData.email];
      if (!user || user.pw !== bodyData.password) { audit('login_failed', bodyData.email, {}); return { ok: false, status: 401, data: { error: 'invalid credentials' } }; }
      const tok = 'tok-' + (db.seq++); tokens[tok] = bodyData.email; audit('login', bodyData.email, {});
      return { ok: true, status: 200, data: { token: tok, role: user.role, name: user.name } };
    }

    if (base === 'reports' && !id && method === 'POST') {
      if (!auth) return { ok: false, status: 401, data: { error: 'unauthenticated' } };
      const rpt = { id: 'r' + (db.seq++), submitterId: auth.user.id, status: 'draft', currency: 'EUR', lines: [], approvals: [], history: [] };
      rpt.history.push({ event: 'created', who: auth.email, at: NOW() });
      db.reports.push(rpt); audit('create_draft', auth.email, { id: rpt.id });
      return { ok: true, status: 201, data: { report: rpt } };
    }

    if (base === 'reports' && id && !sub && method === 'PUT') {
      if (!auth) return { ok: false, status: 401, data: { error: 'unauthenticated' } };
      const rpt = db.reports.find((r) => r.id === id);
      if (!rpt || rpt.submitterId !== auth.user.id) return { ok: false, status: 404, data: { error: 'report not found' } };
      if (rpt.status !== 'draft') return { ok: false, status: 409, data: { error: 'only a draft report can be edited' } };
      if (bodyData.currency) rpt.currency = bodyData.currency;
      if (bodyData.lines) rpt.lines = bodyData.lines;
      return { ok: true, status: 200, data: { report: rpt } };
    }

    if (base === 'reports' && id && sub === 'submit' && method === 'POST') {
      if (!auth) return { ok: false, status: 401, data: { error: 'unauthenticated' } };
      const rpt = db.reports.find((r) => r.id === id);
      if (!rpt || rpt.submitterId !== auth.user.id) return { ok: false, status: 404, data: { error: 'report not found' } };
      if (rpt.status !== 'draft') return { ok: false, status: 409, data: { error: 'only a draft report can be submitted' } };
      if (rpt.lines.length === 0) return { ok: false, status: 422, data: { error: 'a report needs at least one line item' } };
      const lineErr = validateLines(rpt.lines, rpt.currency);
      if (lineErr) return { ok: false, status: 422, data: { error: lineErr } };
      const fxErr = recomputeTotal(rpt);
      if (fxErr) return { ok: false, status: 422, data: { error: fxErr } };
      rpt.status = 'submitted'; rpt.approvals = [];
      rpt.history.push({ event: 'submitted', who: auth.email, at: NOW(), totalEur: rpt.totalEur, rateStale: rpt.rateStale });
      audit('submit', auth.email, { id: rpt.id, totalEur: rpt.totalEur });
      return { ok: true, status: 200, data: { report: rpt } };
    }

    if (base === 'reports' && id && sub === 'decide' && method === 'POST') {
      if (!auth) return { ok: false, status: 401, data: { error: 'unauthenticated' } };
      const rpt = db.reports.find((r) => r.id === id);
      if (!rpt) return { ok: false, status: 404, data: { error: 'report not found' } };
      if (rpt.status !== 'submitted') return { ok: false, status: 409, data: { error: 'only a submitted report can be decided' } };
      if (rpt.submitterId === auth.user.id) return { ok: false, status: 403, data: { error: 'cannot approve your own report' } };
      const expectedRole = nextApproverRole(rpt);
      if (!expectedRole) return { ok: false, status: 409, data: { error: 'report already fully approved' } };
      if (auth.user.role !== expectedRole) return { ok: false, status: 403, data: { error: 'report awaits approval from: ' + expectedRole } };
      if ((bodyData.decision === 'reject' || bodyData.decision === 'changes-requested') && (!bodyData.comment || bodyData.comment.trim().length < 10)) {
        return { ok: false, status: 422, data: { error: 'a comment of at least 10 characters is required for this decision' } };
      }
      if (bodyData.decision === 'approve') {
        rpt.approvals.push({ role: auth.user.role, who: auth.email, at: NOW() });
        rpt.history.push({ event: 'approved', who: auth.email, role: auth.user.role, at: NOW() });
        audit('approve', auth.email, { id: rpt.id, role: auth.user.role });
        if (!nextApproverRole(rpt)) { rpt.status = 'approved'; rpt.history.push({ event: 'fully-approved', at: NOW() }); }
        return { ok: true, status: 200, data: { report: rpt } };
      }
      if (bodyData.decision === 'reject') {
        rpt.status = 'rejected';
        rpt.history.push({ event: 'rejected', who: auth.email, at: NOW(), comment: bodyData.comment });
        audit('reject', auth.email, { id: rpt.id, comment: bodyData.comment });
        return { ok: true, status: 200, data: { report: rpt } };
      }
      if (bodyData.decision === 'changes-requested') {
        rpt.status = 'draft'; rpt.approvals = [];
        rpt.history.push({ event: 'changes-requested', who: auth.email, at: NOW(), comment: bodyData.comment });
        audit('changes-requested', auth.email, { id: rpt.id, comment: bodyData.comment });
        return { ok: true, status: 200, data: { report: rpt } };
      }
      return { ok: false, status: 400, data: { error: 'unknown decision' } };
    }

    if (base === 'reports' && !id && method === 'GET') {
      if (!auth) return { ok: false, status: 401, data: { error: 'unauthenticated' } };
      const url = new URL('http://x' + path);
      const scope = url.searchParams.get('scope') || 'mine';
      if (scope === 'mine') return { ok: true, status: 200, data: { reports: db.reports.filter((r) => r.submitterId === auth.user.id) } };
      if (scope === 'inbox') {
        const inbox = db.reports.filter((r) => r.status === 'submitted' && r.submitterId !== auth.user.id && nextApproverRole(r) === auth.user.role);
        return { ok: true, status: 200, data: { reports: inbox } };
      }
      return { ok: false, status: 400, data: { error: 'unknown scope' } };
    }

    if (base === 'reports' && id && !sub && method === 'GET') {
      if (!auth) return { ok: false, status: 401, data: { error: 'unauthenticated' } };
      const rpt = db.reports.find((r) => r.id === id);
      if (!canRead(rpt, auth.user)) return { ok: false, status: 404, data: { error: 'report not found' } };
      return { ok: true, status: 200, data: { report: rpt } };
    }

    return { ok: false, status: 404, data: { error: 'unknown mock route: ' + method + ' ' + path } };
  }

  window.__mockBackend = { handle };
})();
