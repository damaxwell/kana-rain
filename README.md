# Kana Rain

A falling-character drill for hiragana and katakana. Characters fall; type the romaji before they land. Characters you miss or answer slowly come back more often.

Plain static files, no build step. Works offline and installs to a phone's home screen.

## Deploying

1. Upload the files to any HTTPS static host (all paths are relative, so any subfolder works). GitHub Pages works.
2. Open the page on a phone.
   - iPhone: Share > Add to Home Screen.
   - Android (Chrome): menu > Install app.

### Installing into another site repo

```sh
make install DEST=../my-site/kana-rain
```

Or put `DEST = ../my-site/kana-rain` in `local.mk` (git-ignored) and just run `make install`. It copies only the app files, and refuses if files changed but `VERSION` in `sw.js` wasn't bumped. Commit and push the site repo yourself afterward.

## Updating

After changing `index.html` (or any other file), bump `VERSION` in `sw.js` (e.g. `kana-rain-v1` → `kana-rain-v2`). Installed copies pick up the new version the next time they're opened; sometimes it takes two launches.

## Local testing

```sh
python3 -m http.server 8000
```

Then open http://localhost:8000. A phone on the same network can load http://<your-mac's-ip>:8000. The game works there, but offline mode only switches on over HTTPS or localhost.

## Notes

Progress is saved per device, in the browser, under the storage key `kanaRain.v1`. On iPhone the home-screen app keeps its progress separately from Safari.
