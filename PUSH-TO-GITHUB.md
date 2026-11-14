# Push this project to GitHub (`meesamabbas0903-code`)

The full project is committed locally in this folder (`.git`, 1 commit, 25 tracked files).
Two ways to get it onto GitHub — **A** is fastest, **B** is terminal-only.

---

## A. Upload the ZIP (no git needed)

1. Download **`whatsapp-bot-qr-live.zip`** from the workspace.
2. On GitHub: **github.com/meesamabbas0903-code** → **+** → **New repository**
   → Name: `whatsapp-ai-automation` → **Private** or Public → **Create repository**.
3. On the new repo page click **uploading an existing file**.
4. Unzip on your computer, then drag the **contents of `whatsapp-bot-qr/`** (not the folder itself)
   into the upload box → **Commit changes**.
5. Done — the repo now has the whole app (node_modules excluded, that's correct).

---

## B. Push with git (2 commands)

Create an empty repo at **github.com/new** named `whatsapp-ai-automation`, then:

```bash
cd whatsapp-bot-qr
git remote add origin https://github.com/meesamabbas0903-code/whatsapp-ai-automation.git
git branch -M main
git push -u origin main
```

GitHub will ask for a username + **password = Personal Access Token**
(Profile → Settings → Developer settings → Personal access tokens → Tokens (classic) →
Generate new token → tick **repo** → Generate). Paste the `ghp_…` token as the password.

> The same PAT also works for the AI: put it in `.env` as `GITHUB_TOKEN=ghp_…`
> and the bot's AI chain upgrades to **GitHub Models · DeepSeek-V3 / R1** instantly.

---

## What is committed

```
server.js                  entry point (node server.js)
src/server.js              Express: site, SSE, QR, CORS, bot toggle, chat bridge
src/baileys.js             WhatsApp multi-device socket + QR
src/ai.js                  AI chain: Pollinations (free) → DeepSeek → GitHub Models → local brain
src/localbrain.js          offline knowledge brain (15 intents, real prices)
src/flow.js                conversation engine (menus, orders, handover)
src/settings.js            runtime settings (bot flag, prompt)
src/config.js              ⭐ your services, prices, FAQs
src/leads.js               order capture → data/leads.csv
public/index.html          product website + connect QR + live feed
public/dashboard.html      live console (QR, chat stream, AI status)
public/preview-live.html   static snapshot with an embedded QR (for preview panes)
prompts/system-prompt.md   editable AI persona (English + Roman Urdu)
scripts/                   selftest, terminal QR, simulator
Dockerfile · render.yaml · .env.example · README.md · SETUP-GUIDE.md
```

## After cloning on any machine

```bash
npm install
cp .env.example .env      # optional: add GITHUB_TOKEN / DEEPSEEK_API_KEY
node server.js            # or: nohup node server.js > server.log 2>&1 &
```

Open `http://localhost:3000` → scan the QR → done. No API key is required.
