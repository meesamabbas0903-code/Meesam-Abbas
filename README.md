# WhatsApp AI Automation — Website + Live Dashboard

A **complete, live-working** WhatsApp AI automation app, in the style of ConvortAI:

- one clean product website with a **single “Connect WhatsApp” Linked Devices QR**
- a **built-in AI assistant** that works with **no token, no API key, no billing**
- a **live chat monitor** and a **1-click AI on/off switch**

```
npm install && npm start        →      http://localhost:3000
```

> ⚠️ Open the **server URL** (`http://localhost:3000`), never the raw `public/index.html` file.
> Opened as a file, the browser cannot reach the backend, so no QR can be generated.

---

## What's on the page

| Section | Behaviour |
|---|---|
| **Connect card** (top right) | Real Baileys pairing QR, auto-refreshing. Status chip: `starting → scan now → connected · +92…`. “New QR” and “Unlink” buttons. If the backend is unreachable it shows an explicit *“server URL se kholein”* notice + Retry instead of a dead spinner. |
| **Features / How it works / Before-After** | Product site sections — no configuration, purely informational. |
| **Live WhatsApp chat stream** | Incoming messages, AI replies (tagged with which provider answered) and system events, streamed over SSE. |
| **AI ON/OFF** | Pause or resume auto-replies instantly. Messages keep arriving while paused. |
| **Assistant status** | WhatsApp state, linked number, active AI provider + latency, replies sent. **⚡ Test AI**, **Ask AI**, view the resolved prompt. |
| **Test as a customer** | Runs the exact production pipeline (toggle → menus → AI) without a phone. |

Removed on purpose (per your request): the customer-shareable QR card, all phone-number inputs, and
every manual token/API-key field.

---

## Zero-config AI (nothing to paste)

`src/ai.js` runs an automatic provider chain — the first working one answers the message:

| # | Provider | Needs | Notes |
|---|---|---|---|
| 1 | **GitHub Models · DeepSeek** | a token in the **server** env (optional) | silently used if `GITHUB_TOKEN` is present — no UI, nothing to configure |
| 2 | **Free keyless LLM** (Pollinations, OpenAI-compatible) | nothing | works out of the box; anonymous tier is rate-limited (~1 reply / 45 s per IP) |
| 3 | **Built-in knowledge brain** (`src/localbrain.js`) | nothing | 15 intents + FAQ overlap over your real prices; instant, offline, unlimited |

So a customer message is **never** left unanswered: when the free endpoint is cooling down, the
built-in brain replies with grounded answers (prices, delivery time, payment, portfolio, revisions,
footage sharing, order flow, human handover). The live feed shows which provider answered each message.

Want unlimited LLM calls instead of the shared free tier? Put a token in the server's `.env`
(`GITHUB_TOKEN=…`) and restart — the chain silently upgrades to DeepSeek. No UI work needed.

---

## Conversation engine

Menus are rendered as WhatsApp-friendly numbered lists (the unofficial API doesn't reliably render
native buttons); replies are mapped back to option ids.

```
hi → welcome + 3 options
1  → services list            2 → pricing           3 → start order
4  → human handover (AI goes silent; type "menu" to resume)
free text → AI chain (LLM → built-in brain)
order: service → name → phone → city → brief → deadline → confirm → order ID
```

Orders are appended to `data/leads.csv` (+ `leads.jsonl`).

---

## API reference

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/` | The website |
| GET | `/api/status` | WhatsApp + AI + bot state |
| GET | `/api/events` | SSE stream (status + chat frames) |
| GET | `/api/qr.png` | Pairing QR as PNG |
| POST | `/api/connect` | Start/reconnect · `?forceNew=1` for a fresh QR |
| POST | `/api/logout` | Unlink the device |
| POST | `/api/bot/toggle` | `{enabled:true|false}` |
| GET/POST | `/api/settings` | Bot flag, group replies, temperature, system prompt (no secrets) |
| GET | `/api/ai/status` | Provider chain health |
| POST | `/api/ai/test` | Probe the chain |
| POST | `/api/ai/probe` | One-off question |
| GET | `/api/ai/prompt` | Resolved system prompt |
| POST | `/api/chat/test` | Full pipeline without WhatsApp |
| GET | `/api/chat/history` | Last 150 monitor events |
| GET | `/health` | Uptime/monitor probe |

---

## Files

```
src/
  server.js     Express: website, SSE, QR, settings, bot toggle, message bridge
  baileys.js    WhatsApp multi-device socket, QR → data URL, auto-reconnect
  flow.js       Conversation engine (menus, order capture, handover) — pure functions
  ai.js         Zero-config provider chain (github → pollinations → local)
  localbrain.js Offline knowledge brain (English + Roman Urdu intents)
  settings.js   Runtime store → data/settings.json (bot flag, tone, prompt)
  config.js     ⭐ Your business data: services, prices, FAQs, payment terms
  leads.js      CSV/JSONL lead capture
public/
  index.html    Product website + connect card + live monitor
  simulator.html Optional phone-style simulator
scripts/
  selftest.js   End-to-end checks: brain, AI chain, order flow, handover, settings
  qr-terminal.js Headless terminal QR (VPS/SSH)
  simulate.js   Interactive terminal chat
prompts/system-prompt.md  Editable prompt template ({{BUSINESS_NAME}} / {{KNOWLEDGE}})
```

---

## Verified in this workspace

```
health            → whatsapp: qr · bot: on · aiProvider: pollinations
/api/status       → chain: github (off) → pollinations → local ; qr: true
POST /api/ai/test → {"ok":true,"provider":"pollinations","latencyMs":5616}
POST /api/ai/probe→ grounded pricing answer (built-in brain while the free tier cools down)
POST /api/chat/test → {"replied":true,"ai":true,"state":"MENU"}
/api/customer-qr.png → 404 (removed as requested)
npm run selftest  → ✅ 20/20 checks (brain, AI chain, order flow, handover, settings)
npm test          → ✅ conversation flow checks
```

---

## Customise

Everything about the business (services, prices, turnaround, payment terms, FAQs) lives in
**`src/config.js`**. The AI reads it, the built-in brain reads it, the menus read it. Change prices
there, restart, done — no prompt editing required.

Optional advanced tweaks in `.env`: `AI_MODEL`, `POLLINATIONS_MODEL`, `AI_TEMPERATURE`,
`AI_TIMEOUT_MS`, `REPLY_IN_GROUPS`, `PORT`, and (optional) `GITHUB_TOKEN`.

---

## Deploy / run 24-7

```bash
# VPS with pm2
npm install && pm2 start src/server.js --name wa-ai && pm2 save && pm2 startup

# Docker (mount data/ so the WhatsApp session survives restarts)
docker build -t wa-ai . && docker run -d --restart=always -p 3000:3000 \
  -v $(pwd)/data:/app/data --env-file .env wa-ai
```

Keep the host awake — a sleeping container breaks the socket (it reconnects, but messages sent while
offline are lost). The `data/auth` folder holds the WhatsApp session, so you only scan once.

---

## Risk note

This uses **Baileys** (unofficial WhatsApp Web multi-device protocol), not the official Cloud API.
Great for replying to inbound customers on your own number; bulk/cold marketing can get a number
banned. For guaranteed uptime + templates + a green tick, migrate to the official Cloud API —
the same `src/flow.js` is used by the sibling project `../whatsapp-video-editor-bot/`.
