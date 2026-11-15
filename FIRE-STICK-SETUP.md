# Greenpoint Ambient: Fire Stick setup

The dashboard is a web page (`index.html` plus `gallery.js`). The Fire Stick needs a URL to open it from, then a browser that can show it full screen.

## 1. Put the page online

The Fire Stick can't open files from your Mac, so the page needs a web address. Free option: GitHub Pages (Claude can set this up for you with your GitHub account). You end up with a URL like:

    https://idrisolo.github.io/greenpoint-ambient/

Any change pushed to the repo shows up on the TV within a day (the page reloads itself at 4 AM), or right away if you restart the app.

## 2. Install a kiosk browser on the Fire Stick (recommended: Fully Kiosk Browser)

1. On the Fire Stick: **Settings → My Fire TV → Developer Options → Install unknown apps**, and allow **Downloader**.
   (If Developer Options is hidden: Settings → My Fire TV → About, click the device name 7 times.)
2. Install **Downloader** from the Amazon Appstore.
3. In Downloader, go to `fully-kiosk.com`, download the Fire TV / Android APK, and install it.
4. Open Fully Kiosk Browser and set:
   - **Start URL**: your dashboard URL
   - **Device Management → Launch on boot**: ON (the dashboard comes up whenever the TV/stick powers on)
   - **Web Content Settings → Autoplay / Keep screen on**: ON
   - **Toolbars & Appearance → Hide everything / Fullscreen mode**: ON

Simpler but less polished alternative: open the URL in the **Silk Browser**, bookmark it, and use the menu to go full screen. Silk doesn't launch on boot.

## 3. Make it the "idle" screen

Amazon doesn't let third-party apps replace the Fire Stick's built-in screensaver. The practical setup:

- **Settings → Display & Sounds → Screen Saver → Start Time → Never**, so Amazon's screensaver doesn't cover the dashboard.
- When you're done watching, press **Home** and open Fully Kiosk (or with Launch on boot, it's there whenever the TV turns on). The dashboard *is* the screensaver: the background changes every 50 seconds, the layout shifts a few pixels every few minutes to avoid burn-in, every fifth card it hides the info for a 2-minute gallery-only break, and it dims itself from 1 to 6 AM.
- The Vizio will still turn itself off on its own timer, which is fine.

## Customizing

Settings live near the top of the `<script>` in `index.html`:

- `CFG`: location, which subway lines to watch, card and photo timing, the gallery-only break, and night dimming hours (1 to 6 AM by default).
- `PICKS`: curated Greenpoint / Brooklyn / NYC ideas. `months: [11, 12]` limits a card to those months; `days: [0, 6]` to weekends.
- `FREE`: recurring free museum days. Hours change, so each card says to check or book ahead. Edit when you learn of new ones.
- `gallery.js`: the background images (paintings and photos). Add any image URL as `{kind: "photo" or "art", title, credit, url}`. "art" shows the whole painting framed; "photo" fills the screen with a slow zoom.

The location is set by hand (Greenpoint). To use somewhere else without editing code, add it to the URL:
`...?lat=40.7128&lon=-74.0060&place=Lower%20Manhattan&lines=4,5,6&alertLines=4,5,6`

## Data sources (all free, no keys, refreshed automatically)

- Weather: Open-Meteo, every 15 minutes. Severe weather warnings: National Weather Service.
- Subway: MTA live service alerts, every 2 minutes. G, L, and 7 status in the bottom strip; G and L problems also get a full card.
- Events: NYC Parks events (ranked by distance from home) and NYC street-event permits for Greenpoint and Williamsburg, hourly.
- Real Madrid: next match and recent result from TheSportsDB, every 3 hours. A chip shows on match day.
- Images: Wikimedia Commons (public-domain paintings and Creative Commons photos, credited on screen).
