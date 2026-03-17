# Deployment Guide – Armvet LLC (Bluehost)

## Prerequisites

- Bluehost hosting account with cPanel access
- GitHub repository access (this repo)
- Domain pointed to Bluehost nameservers

---

## First-Time Setup

### 1. Connect the Repository to Bluehost

1. Log in to **Bluehost cPanel**
2. Under the **Files** category, click **Git Version Control**
3. Click **Create**
4. Fill in the form:
   - **Clone URL**: `https://github.com/kevlongalloway/armvet.git`
   - **Repository Path**: `/home/<your-username>/public_html`
   - **Repository Name**: `armvet`
5. Click **Create** — Bluehost will clone the repo

### 2. Enable AutoSSL (HTTPS / SSL Certificate)

1. In cPanel, go to **SSL/TLS** → **AutoSSL**
2. Click **Run AutoSSL** — Bluehost will issue a free Let's Encrypt certificate
3. Once issued, verify HTTPS works by visiting `https://armvet.com`

> **After confirming HTTPS works**, uncomment the HSTS line in `.htaccess`:
> ```apache
> Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
> ```

---

## How Auto-Deploy Works

Every `git push` to this repo triggers automatic deployment via `.cpanel.yml`:

```
git push → cPanel detects push → runs build.sh → copies dist/* to public_html/
```

The build script:
1. Injects `armvet.com` as the site domain
2. Outputs compiled files to `dist/`
3. Copies `.htaccess` into `dist/` for Apache config

No manual steps are needed after the initial setup.

---

## Deploying Changes

```bash
git add .
git commit -m "your message"
git push origin master
```

cPanel will automatically run the build and push files to `public_html/`.

To verify deployment, check **Git Version Control** in cPanel — it shows the last deployed commit.

---

## What `.htaccess` Does

The `.htaccess` file is deployed alongside `index.html` and handles:

| Feature | Behavior |
|---|---|
| HTTP → HTTPS | All HTTP requests permanently redirect to HTTPS (301) |
| www → non-www | `www.armvet.com` redirects to `armvet.com` |
| SPA routing | Unknown paths fall back to `index.html` |
| Security headers | X-Frame-Options, XSS protection, content-type sniffing prevention |
| Gzip compression | HTML, CSS, JS, SVG, fonts are compressed |
| Browser caching | Images/fonts cached 1 year; HTML not cached so updates deploy instantly |

---

## File Structure

```
armvet/
├── index.html        # Source – single-page app (edit this)
├── images/           # Static assets
├── build.sh          # Build script (runs on deploy)
├── .cpanel.yml       # cPanel Git auto-deploy config
├── .htaccess         # Apache config (SSL redirect, caching, routing)
└── render.yaml       # Legacy Render config (not used on Bluehost)
```

---

## Troubleshooting

**Deploy didn't run after push**
- Check cPanel → Git Version Control → click the repo → verify Last Deployment matches your latest commit
- Manually trigger by clicking **Update** in cPanel Git Version Control

**SSL certificate not working**
- Wait up to 24 hours for DNS propagation
- Re-run AutoSSL from cPanel → SSL/TLS → AutoSSL
- Ensure the domain's A record points to your Bluehost server IP

**Site shows old content after deploy**
- Hard refresh the browser: `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac)
- HTML is intentionally not cached — if still stale, check that `.htaccess` deployed correctly

**500 Internal Server Error**
- Usually an `.htaccess` syntax issue — check that `mod_rewrite` is enabled in cPanel
- Contact Bluehost support to confirm `AllowOverride All` is set for your directory
