from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import RedirectResponse, HTMLResponse
import os, hashlib, time
from .ddb import put_mapping, get_mapping

app = FastAPI()

@app.get("/", response_class=HTMLResponse)
def index():
    return """
<!doctype html>
<html lang=\"en\">
  <head>
    <meta charset=\"utf-8\" />
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
    <title>URL Shortener</title>
    <style>
      body { font-family: -apple-system, system-ui, Segoe UI, Roboto, Helvetica, Arial, sans-serif; margin: 0; padding: 2rem; background: linear-gradient(135deg, #cfeaff 0%, #b7f7d0 100%); }
      .card { max-width: 640px; margin: 0 auto; background: #fff; border-radius: 12px; padding: 24px; box-shadow: 0 6px 24px rgba(0,0,0,0.06); }
      h1 { margin: 0 0 12px; font-size: 24px; }
      p { color: #555; margin-top: 0; }
      form { display: flex; gap: 8px; margin-top: 16px; }
      input[type=url] { flex: 1; padding: 12px 14px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px; }
      button { padding: 12px 16px; border: none; border-radius: 8px; background: linear-gradient(135deg, #8bbcff, #6ee7b7); color: #0a0f1a; cursor: pointer; font-weight: 700; box-shadow: 0 8px 18px rgba(110,231,183,0.35); }
      button:disabled { opacity: .6; cursor: not-allowed; }
      .result { margin-top: 16px; font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
      .error { color: #b00020; margin-top: 12px; }
      .history { max-width: 640px; margin: 16px auto 0; }
      .history h2 { font-size: 16px; color: #222; margin: 8px 0; }
      .list { display: flex; flex-direction: column; gap: 8px; }
      .item { background: #fff; border: 1px solid #eee; border-radius: 10px; padding: 12px; display: grid; grid-template-columns: 1fr auto; gap: 8px; align-items: center; box-shadow: 0 2px 8px rgba(0,0,0,0.04); }
      .item .meta { font-size: 12px; color: #666; }
      .item .meta .label { max-width: 100%; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: inline-block; vertical-align: bottom; }
      .item .links { display: flex; gap: 8px; align-items: center; }
      .short { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
      .btn-icon { position: relative; background: #f4f6ff; color: #38488f; border-radius: 8px; padding: 8px 10px; font-weight: 600; }
      .btn-icon:hover { background: #e8ecff; }
      .menu { position: absolute; top: calc(100% + 6px); right: 0; background: #fff; border: 1px solid #e6e6e6; border-radius: 8px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); display: none; min-width: 160px; z-index: 10; }
      .menu a { display: block; padding: 8px 10px; text-decoration: none; color: #1b1b1b; font-size: 14px; }
      .menu a:hover { background: #f6f8ff; }
      .btn-wrap { position: relative; }
      .btn-wrap:hover .menu { display: block; }
    </style>
  </head>
  <body>
    <div class=\"card\">
      <h1>URL Shortener</h1>
      <p>Enter a long URL to generate a short link.</p>
      <form id=\"shorten-form\">
        <input id=\"url\" type=\"url\" placeholder=\"https://example.com/very/long/path\" required />
        <button id=\"submit\" type=\"submit\">Shorten</button>
      </form>
      <div id=\"result\" class=\"result\"></div>
      <div id=\"error\" class=\"error\"></div>
    </div>
    <div class="history">
      <h2>History</h2>
      <div id="history-list" class="list"></div>
    </div>
    <script>
      const form = document.getElementById('shorten-form');
      const urlInput = document.getElementById('url');
      const resultEl = document.getElementById('result');
      const errorEl = document.getElementById('error');
      const submitBtn = document.getElementById('submit');
      const historyList = document.getElementById('history-list');

      const STORAGE_KEY = 'shortener_history_v1';

      function readHistory() {
        try { return JSON.parse(localStorage.getItem(STORAGE_KEY)) || []; } catch { return []; }
      }

      function writeHistory(items) {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(items.slice(0, 100)));
      }

      function fmtDate(ts) {
        const d = new Date(ts * 1000);
        return d.toLocaleString();
      }

      function makeShortUrl(short) { return window.location.origin + '/' + short; }

      function deriveLabel(u) {
        try {
          const parsed = new URL(u);
          const host = parsed.hostname;
          const parts = parsed.pathname.split('/').filter(Boolean);
          const last = parts.length ? parts[parts.length - 1] : '/';
          return `${host} • ${last}`;
        } catch {
          return u;
        }
      }

      function copyToClipboard(text) {
        if (navigator.clipboard && navigator.clipboard.writeText) {
          return navigator.clipboard.writeText(text);
        }
        const ta = document.createElement('textarea');
        ta.value = text; document.body.appendChild(ta); ta.select(); document.execCommand('copy'); document.body.removeChild(ta);
        return Promise.resolve();
      }

      function renderHistory() {
        const items = readHistory();
        historyList.innerHTML = '';
        if (!items.length) {
          const empty = document.createElement('div');
          empty.className = 'item';
          empty.innerHTML = '<div>No links yet. Shorten one above.</div>';
          historyList.appendChild(empty);
          return;
        }
        for (const it of items) {
          const div = document.createElement('div');
          div.className = 'item';
          const shortUrl = makeShortUrl(it.short);
          div.innerHTML = `
            <div>
              <div class="short"><a href="${shortUrl}" target="_blank" rel="noopener">${shortUrl}</a></div>
              <div class="meta" title="${it.url}"><span class="label">${deriveLabel(it.url)}</span> · ${fmtDate(it.ts)}</div>
            </div>
            <div class="links">
              <button class="btn-icon" data-action="copy" data-short="${it.short}">Copy</button>
              <button class="btn-icon" data-action="open" data-short="${it.short}">Open</button>
            </div>
          `;
          const copyBtn = div.querySelector('button[data-action="copy"]');
          copyBtn.addEventListener('click', async (e) => {
            e.preventDefault();
            await copyToClipboard(shortUrl);
            copyBtn.textContent = 'Copied!';
            setTimeout(() => { copyBtn.textContent = 'Copy'; }, 1200);
          });
          const openBtn = div.querySelector('button[data-action="open"]');
          openBtn.addEventListener('click', (e) => {
            e.preventDefault();
            window.open(shortUrl, '_blank', 'noopener');
          });
          historyList.appendChild(div);
        }
      }

      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        resultEl.textContent = '';
        errorEl.textContent = '';
        submitBtn.disabled = true;
        try {
          const resp = await fetch(window.location.origin + '/shorten', {
            method: 'POST',
            headers: { 'content-type': 'application/json' },
            body: JSON.stringify({ url: urlInput.value })
          });
          if (!resp.ok) {
            const txt = await resp.text();
            throw new Error(txt || ('HTTP ' + resp.status));
          }
          const data = await resp.json();
          const shortUrl = window.location.origin + '/' + data.short;
          resultEl.innerHTML = `Short link: <a href="${shortUrl}" target="_blank" rel="noopener">${shortUrl}</a>`;

          const items = readHistory();
          items.unshift({ short: data.short, url: urlInput.value, ts: Math.floor(Date.now()/1000) });
          writeHistory(items);
          renderHistory();
        } catch (err) {
          errorEl.textContent = 'Error: ' + (err && err.message ? err.message : err);
        } finally {
          submitBtn.disabled = false;
        }
      });

      renderHistory();
    </script>
  </body>
</html>
"""

@app.get("/healthz")
def health():
    return {"status": "ok", "ts": int(time.time())}

@app.post("/shorten")
async def shorten(req: Request):
    body = await req.json()
    url = body.get("url")
    if not url:
        raise HTTPException(400, "url required")
    short = hashlib.sha256(url.encode()).hexdigest()[:8]
    put_mapping(short, url)
    return {"short": short, "url": url}

@app.get("/{short_id}")
def resolve(short_id: str):
    item = get_mapping(short_id)
    if not item:
        raise HTTPException(404, "not found")
    return RedirectResponse(item["url"])
# Test comment
# Test comment
