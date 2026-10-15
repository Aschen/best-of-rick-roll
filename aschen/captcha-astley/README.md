# Captcha Astley

A link that looks like a European tech news article. It opens on a "Just a moment..." bot check, and clicking "I'm not a robot" starts Rick Astley. Live at [tech-insider.eu](https://tech-insider.eu/a/8f3k2x).

## Files

| File                           | Role                                                                            |
| ------------------------------ | ------------------------------------------------------------------------------- |
| `index.html`                   | The whole rickroll: one self-contained page, no dependency                      |
| `og.png`                       | The 1200×630 link preview image                                                 |
| `server/tech-insider.eu`       | Final nginx vhost: HTTPS, catch-all routing                                     |
| `server/tech-insider.eu.http`  | HTTP-only bootstrap vhost, so certbot can answer the ACME challenge             |
| `server/setup-tech-insider.sh` | Installs the bootstrap vhost, gets the certificate, then swaps in the final one |

The video is not in the repo: `index.html` plays `https://aschen.ovh/proverbe.mp4`. Point `<video src>` at your own copy.

## What it does

### 1. The bait: a link preview that gives nothing away

- Open Graph and Twitter Card tags make the link unfurl as **Tech Insider — European tech news** on Slack, Discord, WhatsApp, LinkedIn, Facebook and X, with a branded share card (`og.png`, `summary_large_image`).
- Title, description and image are deliberately generic: the preview says "news site", never what the article is about, so nobody can guess where the link goes.
- `robots: nosnippet, max-image-preview:none` keeps Google from showing an excerpt.
- The nginx vhost serves the same page for **every path**, so any made-up article URL works: `/a/8f3k2x`, `/articles/eu-bans-javascript.html`, whatever fits the conversation.

### 2. The gate: a fake bot check

- A white "Just a moment..." screen that looks like the anti-bot interstitials everyone clicks through without reading: "Checking if the site connection is secure", an "I'm not a robot" checkbox, a random verification ID in the footer.
- The heading shows the visitor's own host. When the page is embedded in an iframe, it reads `location.ancestorOrigins` and shows the **top-level** site's host instead of the frame's, so the check looks like it comes from the page the visitor thinks they are on.
- The click on the checkbox is the user gesture that browsers require before playing audio, which is why the gate exists at all.

### 3. The show

- The video plays **unmuted** in the background, dimmed to 35% opacity.
- Five floating mini windows, macOS-style title bar with traffic lights and a neon glow, each rendering the live video into a `<canvas>`.
- The windows dance through five formations — orbit, figure-eight snake chase, wave, implode/explode star, DVD-logo bounce — morphing smoothly from one to the next every 7 seconds.
- **Beat-synced** at 113.34 BPM, first beat at 0.365 s, measured on the audio track by onset detection. On every beat the windows snap to their next position, pop, tilt and flash, and the background pulses. The animation follows `video.currentTime`, so it stays in sync even if playback stalls.
- After 30 seconds, a link to this repo slides in at the bottom right.

### 4. The trap: making it hard to leave

| Escape attempt                           | What happens                                                                                                                                                                                           |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Press Escape                             | The page goes fullscreen and calls the Keyboard Lock API: Escape has to be **held for 2 seconds** to exit (Chromium, desktop only)                                                                     |
| Press Back                               | Three dummy history entries absorb it, then a fake browser dialog asks "Are you sure you want to stop being rickrolled?". Both buttons keep you on the page, re-arm the trap and go back to fullscreen |
| Pause the video                          | It resumes immediately                                                                                                                                                                                 |
| Media keys, lock screen, OS media widget | The Media Session shows "Never Gonna Give You Up — Rick Astley". Pause plays; stop, next, previous and seek all restart the song from the top                                                          |
| Close the tab                            | The browser's "Leave site?" confirmation shows up                                                                                                                                                      |

## Limits

- **iPhone**: Safari (and every iOS browser, Chrome included) only allows fullscreen on a video, not on a page, so there is no fullscreen and no Keyboard Lock.
- **Firefox and Safari**: no Keyboard Lock, so one press of Escape exits fullscreen.
- **Mobile**: closing a tab never shows a confirmation, and nothing can stop it.
- **Chrome**: history entries pushed without a user gesture are skipped by the Back button, so the Back trap is only armed from clicks.
- When the video loops back to the start, the windows jump back to their opening formation.

## Deploy

Assumes a Debian-style nginx with certbot, and two snippets that already exist on the server: `snippets/letsencrypt.conf` (serves `/.well-known/acme-challenge/` from `/var/www/html`) and `snippets/ssl-params.conf`.

1. Point the domain's `A` record (and `www`) at the server.
2. Copy the page and the share image to the web root:

   ```bash
   mkdir -p /var/apps/tech-insider.eu/public /var/apps/tech-insider.eu/log
   cp index.html og.png /var/apps/tech-insider.eu/public/
   ```

3. Run the setup script as root from `server/`:

   ```bash
   sudo ./setup-tech-insider.sh
   ```

   It installs the HTTP-only vhost, gets the certificate with `certbot --webroot`, then installs the final vhost and reloads nginx.

To reuse it under another domain, replace `tech-insider.eu` in the three server files and in the `canonical`, `og:url` and `og:image` tags of `index.html`.
