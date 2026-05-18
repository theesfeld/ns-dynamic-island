# ns-dynamic-island

A Noctalia plugin that renders a floating, morphing pill at the top of the
screen — a dynamic island — reacting to media playback, notifications, and
screen recording.

Inspired by [ActivSpot](https://github.com/Devvvmn/ActivSpot), rebuilt on
Noctalia / Quickshell so it works with any supported compositor (developed on
Niri; any Wayland layer-shell compositor should work).

## What it does

- **Media bubble** — Album art + title + artist; expands to show progress bar
  and play/prev/next controls. Fed by Noctalia's `MediaService` (any MPRIS
  player).
- **Notification peek** — Pops the latest notification from Noctalia's own
  notification server, auto-hides after a configurable duration.
- **Recording indicator** — Pulsing red `REC` pill while `gpu-screen-recorder`,
  `wf-recorder`, `obs`, or `kooha` is running.
- **Idle state** — Clock (optional weather via wttr.in).
- **Dual bubbles** — Media + notification or media + recording can show
  side-by-side when `dualBubble` is enabled.

The island lives on its own layer-shell window (`WlrLayer.Overlay`,
`exclusionMode: Ignore`), so it floats over the bar without reserving space.

## Install

```sh
# Symlink into Noctalia's plugin dir (good for development)
ln -s /path/to/ns-dynamic-island ~/.config/noctalia/plugins/ns-dynamic-island

# Or copy
cp -r /path/to/ns-dynamic-island ~/.config/noctalia/plugins/
```

Then enable the plugin from Noctalia's settings UI. Hot reload:

```sh
NOCTALIA_DEBUG=1 qs -c noctalia-shell
```

## Mouse

- **Left click** — toggle play/pause (or dismiss notification peek when no media).
- **Middle click** — toggle play/pause (always).
- **Right click** — dismiss notification peek.
- **Hover** — expand to show artist + transport controls (and notification body).

## IPC

```sh
qs -c noctalia-shell ipc call plugin:ns-dynamic-island peek
qs -c noctalia-shell ipc call plugin:ns-dynamic-island hide
qs -c noctalia-shell ipc call plugin:ns-dynamic-island toggle
```

Bind `peek` or `toggle` to a Niri keybind for manual summoning.

## Not in v1

- Discord/voice call bubble (ActivSpot uses a custom daemon — needs a portable
  source; skipped for now).
- App launcher morph — Noctalia already ships a launcher.
- Clipboard viewer, pet character — use dedicated plugins (`clipper`,
  `tamagotchi`).

## Settings

All settings live under Settings → Plugins → Dynamic Island. Key knobs:
position (top/bottom), compact/expanded widths, height, corner radius,
hide delay, per-monitor toggle, and per-source auto-show.
