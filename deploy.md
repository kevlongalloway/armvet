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

### 2. Set the `SITE_DOMAIN` Environment Variable

The build system reads `SITE_DOMAIN` from a file on the server (`~/.armvet.env`).
This lets you change the domain at any time without touching the code.

**Using cPanel Terminal** (cPanel → Advanced → Terminal):

```bash
echo 'export SITE_DOMAIN=armvet.com' > ~/.armvet.env
```

Replace `armvet.com` with your actual domain. Every deploy will automatically
pick up whatever value is in this file.

**To update the domain later** (e.g. pointing to a staging server):

```bash
echo 'export SITE_DOMAIN=staging.armvet.com' > ~/.armvet.env
```

Then trigger a redeploy — see [Deploying Changes](#deploying-changes) below.

> The build script falls back to `armvet.com` if `~/.armvet.env` is missing,
> so deploys won't fail if the file hasn't been created yet.

### 3. Enable AutoSSL (HTTPS / SSL Certificate)

1. In cPanel, go to **SSL/TLS** → **AutoSSL**
2. Click **Run AutoSSL** — Bluehost will issue a free Let's Encrypt certificate
3. Once issued, verify HTTPS works by visiting `https://armvet.com`

> **After confirming HTTPS works**, uncomment the HSTS line in `.htaccess`
> and push the change:
> ```apache
> Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
> ```

---

## How Auto-Deploy Works

Every `git push` triggers automatic deployment via `.cpanel.yml`:

```
git push
  → cPanel detects new commit
  → sources ~/.armvet.env  (reads SITE_DOMAIN)
  → runs build.sh          (injects SITE_DOMAIN, compiles dist/)
  → copies dist/* to public_html/
```

No manual steps are needed after first-time setup.

---

## Deploying Changes

```bash
git add .
git commit -m "your message"
git push origin master
```

cPanel automatically runs the build and updates `public_html/`.

To verify deployment, go to **Git Version Control** in cPanel — it shows the
last deployed commit hash and timestamp.

**To redeploy without a code change** (e.g. after updating `SITE_DOMAIN`):

In cPanel → Git Version Control → click the repo → click **Update**.

---

## Changing the Domain / Test Server

1. SSH into Bluehost or open **cPanel → Terminal**
2. Update the env file:
   ```bash
   echo 'export SITE_DOMAIN=yournewdomain.com' > ~/.armvet.env
   ```
3. Trigger a redeploy via cPanel → Git Version Control → **Update**

The next build will inject the new domain into all meta tags, canonical URLs,
and Open Graph tags automatically — no code changes needed.

---

## What `.htaccess` Does

The `.htaccess` file is deployed alongside `index.html` and handles:

| Feature | Behavior |
|---|---|
| HTTP → HTTPS | All HTTP requests permanently redirect to HTTPS (301) |
| www → non-www | `www.armvet.com` redirects to `armvet.com` |
| SPA routing | Unknown paths fall back to `index.html` |
| Security headers | X-Frame-Options, XSS protection, content-type sniffing prevention |
| Gzip compression | HTML, CSS, JS, SVG, and fonts are compressed |
| Browser caching | Images/fonts cached 1 year; HTML not cached so updates deploy instantly |

---

## File Structure

```
armvet/
├── index.html        # Source – single-page app (edit this)
├── images/           # Static assets
├── build.sh          # Build script – reads SITE_DOMAIN, outputs dist/
├── .cpanel.yml       # cPanel Git auto-deploy config
├── .htaccess         # Apache config (SSL redirect, caching, routing)
└── render.yaml       # Legacy Render config (not used on Bluehost)
```

**Server-side only (not in git):**
```
~/.armvet.env         # Contains: export SITE_DOMAIN=armvet.com
```

---

## Troubleshooting

**Wrong domain injected into the site**
- Check the value on the server: open cPanel Terminal and run `cat ~/.armvet.env`
- Update it and trigger a redeploy (see [Changing the Domain](#changing-the-domain--test-server))

**Deploy didn't run after push**
- Go to cPanel → Git Version Control → click the repo → verify the Last Deployment commit matches your latest push
- Manually trigger by clicking **Update** in cPanel Git Version Control

**SSL certificate not working**
- Wait up to 24 hours for DNS propagation
- Re-run AutoSSL from cPanel → SSL/TLS → AutoSSL
- Ensure the domain's A record points to your Bluehost server IP

**Site shows old content after deploy**
- Hard refresh: `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac)
- HTML is intentionally not cached — if still stale, verify `.htaccess` deployed correctly

**500 Internal Server Error**
- Usually an `.htaccess` syntax issue — check that `mod_rewrite` is enabled in cPanel
- Contact Bluehost support to confirm `AllowOverride All` is set for your directory
