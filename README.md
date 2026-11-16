# Greenpoint Ambient

An ambient TV screensaver for a home in Greenpoint, Brooklyn: art and photography, live weather, the next G train, subway status, NYC events picked by an AI editor, free museum days, holiday countdowns, and fun facts.

Live page: https://idrisolo.github.io/greenpoint-ambient/

## How it runs on the TV

The Fire TV Stick (Fire OS 6) uses a small custom app, **Greenpoint Ambient** (`firetv-app/`), as its system screensaver. After 1 minute idle the dashboard appears; any remote button returns to what you were doing.

One-time setup (already done) from a computer on the same Wi-Fi, with ADB Debugging on:

```bash
cd firetv-app && ./build.sh
adb connect <fire-stick-ip>:5555
adb install -r greenpoint-ambient.apk
adb shell pm grant com.greenpoint.ambient android.permission.WRITE_SECURE_SETTINGS
adb shell settings put secure screensaver_components com.greenpoint.ambient/.DashboardDream
adb shell settings put secure contextual_screen_off_timeout 60000    # start after 1 min (Amazon's timer)
adb shell settings put system screen_off_timeout 60000
adb shell settings put secure sleep_timeout 2700000                  # sleep 45 min after the last button press
```

The app re-applies the screensaver setting after reboots and updates. If the TV itself still switches off, check the Vizio's **Settings > Timers** (Sleep Timer, Auto Power Off).

### Private settings

Never committed (git-ignored), baked into the app, and passed to the page after `#` so they never reach a server:

- `firetv-app/personal.txt`: first line is the first name used in greetings.
- `firetv-app/private.txt`: `tm=` Ticketmaster key (enables concerts), `wifi_ssid=`, `wifi_pass=`, `wifi_type=WPA` (enables the guest Wi-Fi card). See `private.txt.example`.

Rebuild and reinstall the app after changing them.

## What's on screen

- Clock, weather with line icons, 5-day forecast, severe weather alerts (Open-Meteo, NWS).
- Live next G trains at Greenpoint Av and a calm subway status that only speaks up for problems near home (MTA real-time feeds).
- Cards: morning and evening briefings, AI editor's pick of the day and picks, NYC Parks events and street festivals citywide, concerts (with a Ticketmaster key), free museum days, Real Madrid matches, countdowns, guest Wi-Fi, and fun facts every 5th card.
- Gallery of paintings (with museum wall labels) and photos, matched to weather, time of day, and season (holiday imagery from mid-November).
- Modes: gallery-only breaks, late night (midnight to 6 AM, dim paintings only), matchday (Real Madrid white and gold), rain and snow window effect.
- QR codes on cards open details or directions on a phone.

## Content that updates itself

- **AI editor, every morning ~6:30 AM**: a scheduled Claude routine researches NYC and writes `data/editor.json` (format in `data/README.md`).
- **Refresh, 1st and 15th**: a scheduled Claude routine updates seasonal picks (`PICKS`, with `until` dates), checks free museum days (`FREE`), and adds verified facts (`FACTS`).
- The page reloads itself when a new version is published, and daily at 4 AM.

## Editing

- `index.html`: settings (`CFG`), curated `PICKS`, `FREE` days, `FACTS`, `COUNTDOWNS`.
- `gallery.js`: images. `kind: "art"` (framed, museum label) or `"photo"`; `moods` (night, rain, snow, sunrise, sunset, cold, sunny, cloudy, holiday).
- Before pushing, validate: extract the inline `<script>` blocks and run `node --check`.
