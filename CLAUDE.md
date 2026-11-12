# Kana Rain

A falling-character drill for learning hiragana and katakana. A kana falls; the player types its romaji before it reaches the bottom. Built for one learner (the repo owner) who knows the kana but reads slowly; the goal is **recognition speed**, not first exposure. Installed on phones as a PWA from the owner's static site; also shared with others.

## Files

- `index.html` — the whole app: markup, CSS, and JS in one file. No build step, no dependencies besides Google Fonts. Keep it that way unless there's a real reason.
- `sw.js` — service worker for offline use (stale-while-revalidate cache).
- `manifest.webmanifest`, `icons/` — PWA install metadata and icons (192, 512, maskable 512, 180 apple-touch).
- `README.md` — deploy, update and local-testing instructions for humans.

All paths are relative so the folder works under any subpath.

## Rules for every change

- **Bump `VERSION` in `sw.js`** (`kana-rain-v1` → `v2` …) whenever `index.html` or any cached file changes. Otherwise installed phones keep serving the old copy.
- **Never rename the storage key `kanaRain.v1`** or change the shape of saved stats without a migration. It holds every player's progress (per device, per origin). If the schema must change, read the old key and convert.
- Wrap all `localStorage` access in try/catch (already done; keep it).
- Test on a real iPhone when touching layout, input, or viewport code. Desktop and emulators did not reproduce the bugs below.

## Design decisions and why (don't undo these without reason)

### Custom on-screen keyboard on touch devices
On phones (`pointer: coarse`) the game shows its own QWERTY keyboard and the text field is `readOnly` with `inputmode="none"`, so the system keyboard never opens. Desktop uses the real keyboard.

Why: with the iOS system keyboard, the keyboard overlays the page instead of resizing it. iOS reported the new visible height late, scrolled the page to reveal the input, and pushed the top of the game (score bar plus the first part of the fall) off-screen. Characters spent seconds falling out of sight, which also inflated recorded answer times. Several viewport-measuring fixes only half-worked. The custom keyboard removes the whole class of problem and also drops autocorrect and the suggestion bar.

- All 26 letters are shown and active (the owner found missing keys confusing). Romaji only needs a e i o u k s t n h m y r w c f; other letters simply count as wrong keystrokes.
- Keys fire on `pointerdown`, not click, for speed.
- Leftover viewport code (`fit()`, `alignTop()`, per-frame visualViewport checks, the "freeze while resizing" logic in `loop`) is still present from those attempts. It's harmless; it could be simplified, but test on iOS if you touch it.

### Reduce Motion
The owner's iPhone has Reduce Motion on. Originally `prefers-reduced-motion` cut all animations to near-zero, which made correct answers vanish instantly and froze the start-screen demo. Now under reduced motion only the **shakes** (miss shake, wrong-key shake) are removed; fades and the demo stay, because the fades carry the feedback.

### Answer feedback
- Correct: the character stops where it was, turns green with a glow, shows its romaji above it, fades over ~1.1 s. Other characters keep falling.
- Miss: it lands at the bottom in red, shows romaji, shakes (unless reduced motion), fades over ~1.6 s, costs a life.

### Start of a game
A ~1.2 s "Get ready" hold before anything falls, then "Level N" flashes.

## Game mechanics

- Modes: hiragana, katakana, mixed (toggle on start screen). 46 basic characters per script.
- Optional sets (start-screen toggles, saved as `dakuten` / `youon`): dakuten/handakuten (25 per script) and combos/youon (21 per script). Dakuten combos (ぎゃ, じゃ, びゃ, ぴゃ) appear only when both are on. Sets live in `SETS`; combos are two cells wide and take two lanes. ぢゃ/ぢゅ/ぢょ are left out.
- Accepted spellings: shi/si, chi/ti, tsu/tu, fu/hu, wo/o (を), n/nn (ん), ji/zi (じ), ji/di (ぢ), zu/du (づ), sha/sya, cha/tya/cya, ja/zya/jya (and the u/o forms). Matching is instant, no Enter. When the typed text exactly matches one character but is also a prefix of another on screen (e.g. `n` with ん and な both falling), it waits up to 800 ms for more input.
- With several characters matching, the lowest one pops.
- Lives: 5. Level up every 12 correct answers.
- Level parameters (`params(l)`): fall time = max(2.4, 8.5 − 0.55·(l−1)) s; max on screen = min(1 + floor((l−1)/2), 6); spawn gap derived from those. Levels 1–15 selectable as a start level.
- **Stay at this level** toggle: disables leveling up. Added because auto-advance outpaced the owner and ending the game broke flow.

### Smart repetition
Per-character stats are saved: `{ n, hit, miss, err, ms }`.
- `err` is a moving error rate: hit → `err *= 0.7`; miss → `err = err*0.7 + 0.3`; a wrong keystroke while only one character is on screen nudges it up a little.
- `ms` is a moving average of answer time (70/30). Answer time = time since the character appeared, or since the previous correct answer if that was later.
- Pick weight = `0.5 + 3·err + slowness`, where slowness scales 0–1.5 from 1.1 s to 2.5 s average. Unseen characters weigh 2.2. The last 3 picks aren't repeated.
- "Your characters" screen shows a color-coded grid per script (solid / getting there / needs work / not seen) with average times, plus a two-tap reset.

## Visual design
Single dark "indigo" look (it deliberately ignores light mode). Tokens are on `:root`: indigo background, lantern-yellow accent, teal for hits, coral for misses. The falling field has a faint grid like genkō yōshi manuscript paper. Fonts: Zen Kaku Gothic New (kana), Sora (UI), JetBrains Mono (romaji), loaded from Google Fonts and cached by the service worker.

## Ideas not yet built
- Falling short words (ねこ, テレビ) at higher levels: the step from reading characters to reading.
- A practice mode with no lives: misses show the answer but the game never ends.
- Lookalike drill (シ/ツ, ソ/ン, ぬ/め, わ/れ/ね, る/ろ, さ/ち).
- Optional audio of each sound.
