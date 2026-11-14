# SETUP GUIDE — WhatsApp AI Automation Website

Total time: **2 minutes**. There is nothing to configure: no token, no API key, no phone numbers.

---

## Step 1 — Run the server

```bash
cd whatsapp-bot-qr
npm install
npm start
```

You should see:

```
╔══════════════════════════════════════════════════════════════════╗
║  Meesam Edits — WhatsApp AI Automation                           ║
╚══════════════════════════════════════════════════════════════════╝
  Site       : http://localhost:3000
  AI         : zero-config chain → pollinations → local
  Bot        : ON
```

> **Important:** open **http://localhost:3000** in the browser.
> Double-clicking `public/index.html` opens a *file*, not the running site — the page then can't reach
> the backend and you only see an offline notice. That is exactly the "stuck spinner" symptom.

---

## Step 2 — Scan the QR

1. On the website, the **Connect WhatsApp** card shows a live QR.
2. Phone → **WhatsApp → Settings → Linked devices → Link a device**.
3. Point the camera at the QR. The chip changes to **Connected · +92…**.

Notes:
- The QR rotates every ~20 seconds. If it expires, press **🔄 New QR**.
- The session is stored in `data/auth/`, so a server restart does **not** require re-scanning.
- **Unlink** in the card removes the device (useful if WhatsApp says the device was logged out).
- On a headless server (SSH only) run `npm run qr` — the QR prints in the terminal instead.

---

## Step 3 — Test it

**Without WhatsApp:** type in **Test as a customer** (on the page):

| Type | You get |
|---|---|
| `hi` | Welcome + 3 options |
| `price` | Full price list |
| `kitne din mein delivery hogi` | Turnaround |
| `aap kahan se hain?` | Location + hours |
| `order` | Order flow starts |
| `4` | Human handover (AI stops replying) |

**With WhatsApp:** from any other phone, message your linked number — replies arrive in a couple of
seconds and appear in the **Live WhatsApp chat stream**.

---

## Step 4 — Control

- **AI ON/OFF** (top of the live stream): pauses auto-replies. Messages still show in the feed, so you
  can answer them personally from the WhatsApp app.
- **⚡ Test AI** — shows which provider answered and the latency.
- **Ask AI** — ask anything without WhatsApp.
- **View prompt** — the exact system prompt the assistant uses.

While the bot is in **human handover** for a chat, it stays silent. The customer types `menu` to bring
it back.

---

## How the AI works (nothing to configure)

The server tries, in order, until one answers:

1. **GitHub Models (DeepSeek)** — only used if a token happens to exist in the server `.env`
   (`GITHUB_TOKEN=…`). No UI, no prompt to paste. Optional.
2. **Free keyless LLM** endpoint — works out of the box with no account. The anonymous tier allows
   roughly one reply every 45 seconds per IP, so under load it will cool down.
3. **Built-in knowledge brain** — `src/localbrain.js`: 15 intents (pricing, delivery, payment,
   portfolio, revisions, footage, order, human…) over the real prices in `src/config.js`. Instant,
   offline, unlimited. This is what guarantees a reply when the free tier is busy.

The live feed shows the provider behind each reply (`AI reply · pollinations` vs `AI reply · local`).

Want unlimited LLM replies? Add a GitHub token to the server `.env` and restart:
`GITHUB_TOKEN=github_pat_…` → the chain silently upgrades to DeepSeek. Everything else stays the same.

---

## Change the business details

`src/config.js` — services, prices, delivery times, revisions, payment terms, FAQs, portfolio links.
Both the AI prompt and the built-in brain read from this file, so a price change is a one-line edit
plus a restart.

The prompt template lives in `prompts/system-prompt.md` (placeholders `{{BUSINESS_NAME}}`,
`{{OWNER_NAME}}`, `{{CITY}}`, `{{KNOWLEDGE}}`).

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| “Backend se connect nahi ho raha” notice | You opened the HTML file directly. Run `npm start` and use the `http://localhost:3000` URL |
| QR spinner never ends | Check the terminal for errors; `BAILEYS_LOG=info npm start` for detail. Some offices/college networks block WhatsApp WebSockets — try a mobile hotspot |
| “Couldn't link device” on the phone | QR expired — press **New QR** and scan immediately |
| Connection closed (401) | Session invalid → **Unlink**, then **New QR** |
| Connection closed (515) | Normal right after pairing; the server reconnects in a few seconds |
| Bot doesn't answer, feed shows messages | AI ON/OFF is off, or that chat is in human handover — type `menu` from the customer side |
| AI replies look “template-y” | That's the built-in brain answering while the free LLM tier is rate-limited. Add `GITHUB_TOKEN` for unlimited LLM replies |
| Nothing in `data/leads.csv` | Docker without a volume — mount `-v $(pwd)/data:/app/data` |
| Need to reset the WhatsApp session | Delete `data/auth/` (or press Unlink) and scan again |

---

## Deploy 24-7

```bash
# VPS
npm install -g pm2
pm2 start src/server.js --name wa-ai && pm2 save && pm2 startup

# Docker
docker build -t wa-ai .
docker run -d --restart=always -p 3000:3000 -v $(pwd)/data:/app/data --env-file .env wa-ai
```

Keep the machine awake: if it sleeps, the socket drops and messages sent during that window are lost.

---

## Risk note

Baileys is an unofficial implementation of the WhatsApp Web protocol. Use it to reply to your own
inbound customers (that is what it's built for). Cold/bulk marketing can get a number banned.
For guaranteed uptime, templates and a green tick, move the same `src/flow.js` onto the official
WhatsApp Cloud API (see `../whatsapp-video-editor-bot/`).
