# Deploy Asset Flow to Hostinger (nexvoltsolutions.com subdomain)

Use a **subdomain** (e.g. `app.nexvoltsolutions.com` or `assets.nexvoltsolutions.com`) to host your Flutter web app on Hostinger.

---

## Step 1: Build the Flutter web app

From the project root, run:

```bash
flutter clean
flutter pub get
flutter build web --release
```

Output is in **`build/web/`**. You will upload the **contents** of this folder (not the folder itself).

**If you use a path (e.g. `nexvoltsolutions.com/app/`):**

```bash
flutter build web --release --base-href /app/
```

For a **subdomain at root** (e.g. `https://app.nexvoltsolutions.com/`), the default base href `/` is correct; no need to change it.

---

## Step 2: Create the subdomain in Hostinger

1. Log in to **hPanel** (Hostinger).
2. Go to **Domains** → select **nexvoltsolutions.com**.
3. Open **Subdomains** (or **DNS / DNS Zone**).
4. Add a subdomain, e.g.:
   - **Subdomain:** `app` (or `assets`, `flow`, etc.)
   - **Document root:** e.g. `public_html/app` or leave default.
5. Save. DNS may take a few minutes to propagate.

Your app will be at: **https://app.nexvoltsolutions.com** (or whatever subdomain you chose).

---

## Step 3: Upload the built files

Upload **everything inside** `build/web/` to the **document root** of the subdomain.

**Option A – File Manager (Hostinger)**  
1. In hPanel, open **File Manager**.  
2. Go to the subdomain folder (e.g. `public_html/app` or the folder shown as document root for the subdomain).  
3. Upload all files and folders from `build/web/`, e.g.:
   - `index.html` (in root of subdomain)
   - `flutter.js` (or `flutter_bootstrap.js`)
   - `main.dart.js`
   - `assets/` (folder)
   - `canvaskit/` or `flutter.js` assets (if present)
   - `icons/`, `manifest.json`, `favicon.png`, etc.

**Option B – FTP (FileZilla, etc.)**  
1. Get FTP details from Hostinger (host, username, password).  
2. Connect and go to the subdomain document root.  
3. Upload the same contents of `build/web/` there.

**Option C – Drag and drop**  
Zip the **contents** of `build/web/` (not the `web` folder itself), upload the zip in File Manager, then extract in the subdomain root.

---

## Step 4: SPA routing (required for Flutter web)

Flutter web is a single-page app. All paths (e.g. `/dashboard`) must serve `index.html`. Hostinger usually runs **Apache**; use `.htaccess` in the subdomain root.

A file **`web/.htaccess`** is included in this project. When you run `flutter build web`, it is copied into `build/web/` automatically, so upload the contents of `build/web/` and `.htaccess` will be included. If your host ignores dot-files, create `.htaccess` manually in the subdomain root with this content:

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule ^(.*)$ index.html?url=$1 [L,QSA]
</IfModule>
```

So in the subdomain root you should have at least:
- `index.html`
- `.htaccess`
- JS/CSS and asset folders from `build/web/`

---

## Step 5: HTTPS (SSL)

1. In hPanel go to **SSL** (or **Security**).
2. Select the subdomain (e.g. `app.nexvoltsolutions.com`).
3. Install the free SSL (e.g. Let’s Encrypt) and enable **Force HTTPS** if offered.

---

## Checklist

- [ ] `flutter build web --release` completed
- [ ] Subdomain created for nexvoltsolutions.com (e.g. `app`)
- [ ] All contents of `build/web/` uploaded to subdomain document root
- [ ] `.htaccess` in subdomain root for SPA routing
- [ ] SSL enabled and HTTPS forced
- [ ] Visit `https://app.nexvoltsolutions.com` (or your subdomain) and test login/navigation

---

## Troubleshooting

- **Blank page:** Check browser console (F12). Ensure all JS/assets are uploaded and paths are correct (base href is `/` for subdomain root).
- **404 on refresh:** `.htaccess` not in place or `mod_rewrite` not enabled; ask Hostinger to enable it.
- **Old version:** Clear browser cache or do a hard refresh (Ctrl+Shift+R / Cmd+Shift+R).
