# ns-dynamic-island

A Noctalia plugin that renders a floating, morphing pill at the top of the
screen — a dynamic island — that reacts to media, notifications, screen
recording, battery, network, bluetooth, pomodoro, downloads, clipboard,
screenshots, CPU/thermals, mic/camera use, and OSD events (volume/brightness).

Inspired by [ActivSpot](https://github.com/Devvvmn/ActivSpot), rebuilt on
Noctalia / Quickshell so it works with any supported compositor (developed on
Niri; any Wayland layer-shell compositor should work).

## Bubbles

| Bubble        | Trigger                                                 |
|---------------|---------------------------------------------------------|
| Media         | Any MPRIS player. Scrubbable, dynamic accent ring.      |
| Notification  | Noctalia notification server. Stacked + actions.        |
| Recording     | gpu-screen-recorder / wf-recorder / obs / kooha process |
| Volume / Brightness OSD | IPC from your hotkeys (see below).            |
| Battery       | `/sys/class/power_supply/BAT*`. Peeks on change.        |
| Pomodoro      | IPC `pomodoroToggle`. Configurable work/break cycles.   |
| Timer         | IPC `timerStart <sec> <label>`.                         |
| Network       | nmcli, peeks on (dis)connect / SSID change.             |
| Bluetooth     | IPC fed.                                                |
| Keyboard      | IPC fed; peek on layout switch.                         |
| Workspace     | IPC fed; peek on workspace switch.                      |
| Clipboard     | IPC fed; truncated preview.                             |
| Screenshot    | IPC fed; thumbnail preview.                             |
| Download      | IPC fed; progress ring + bar.                           |
| CPU / temp    | Polled. Peeks on thermal critical.                      |
| Privacy dot   | Mic / camera in-use indicator (pactl + /dev/video*).    |
| Focus (DND)   | Status pip while DND is active.                         |
| Idle          | Clock (12/24h, optional seconds) + weather (wttr.in).   |

The island lives on its own layer-shell window (`WlrLayer.Overlay`,
`exclusionMode: Ignore`), so it floats without reserving screen space.

## Visual polish

Spring expand, critical glow halo, time-of-day idle tint, dynamic media accent
(deterministic per-track hue), soft drop shadow, fake-blur backdrop layers,
smoothed media position, icon micro-animations, configurable backdrop opacity
and corner radius, AMOLED / Light / Dark / system / match-wallpaper themes,
high-contrast outlines, large-text accessibility mode.

## Interaction

- **Left-click** play/pause (or dismiss notification when no media).
- **Middle-click** play/pause.
- **Right-click** open context menu (Pause / Mute app / Toggle DND / Stop pomodoro / Hide).
- **Hover** expand.
- **Swipe horizontally** skip media / cycle notifications.
- **Scrub** click-drag the media progress bar to seek.

## Install

```sh
ln -s /path/to/ns-dynamic-island ~/.config/noctalia/plugins/ns-dynamic-island
```

Enable from Noctalia's settings UI. Hot reload:

```sh
NOCTALIA_DEBUG=1 qs -c noctalia-shell
```

## IPC

```sh
# Visibility
qs -c noctalia-shell ipc call plugin:ns-dynamic-island peek
qs -c noctalia-shell ipc call plugin:ns-dynamic-island hide
qs -c noctalia-shell ipc call plugin:ns-dynamic-island toggle

# OSDs — bind to your hotkeys
qs -c noctalia-shell ipc call plugin:ns-dynamic-island showVolume 47
qs -c noctalia-shell ipc call plugin:ns-dynamic-island showVolume 47 true   # muted
qs -c noctalia-shell ipc call plugin:ns-dynamic-island showBrightness 80

# Pomodoro
qs -c noctalia-shell ipc call plugin:ns-dynamic-island pomodoroToggle
qs -c noctalia-shell ipc call plugin:ns-dynamic-island pomodoroPause
qs -c noctalia-shell ipc call plugin:ns-dynamic-island pomodoroResume
qs -c noctalia-shell ipc call plugin:ns-dynamic-island pomodoroSkip

# Timer
qs -c noctalia-shell ipc call plugin:ns-dynamic-island timerStart 300 "Tea"
qs -c noctalia-shell ipc call plugin:ns-dynamic-island timerStop

# Bluetooth (event = connected | disconnected | pairing)
qs -c noctalia-shell ipc call plugin:ns-dynamic-island bluetooth connected "WH-1000XM5"

# Keyboard / workspace
qs -c noctalia-shell ipc call plugin:ns-dynamic-island keyboardLayout us
qs -c noctalia-shell ipc call plugin:ns-dynamic-island workspace 3 Coding

# Clipboard / screenshot
qs -c noctalia-shell ipc call plugin:ns-dynamic-island clipboard "Some copied text" text
qs -c noctalia-shell ipc call plugin:ns-dynamic-island screenshot /tmp/shot.png

# Calendar peek (shown on hover when idle)
qs -c noctalia-shell ipc call plugin:ns-dynamic-island calendar "Standup" "10:00" "#3a86ff"

# Downloads
qs -c noctalia-shell ipc call plugin:ns-dynamic-island downloadStart "qt-creator.tar.xz"
qs -c noctalia-shell ipc call plugin:ns-dynamic-island downloadUpdate 0.42 850
qs -c noctalia-shell ipc call plugin:ns-dynamic-island downloadFinish

# DND
qs -c noctalia-shell ipc call plugin:ns-dynamic-island dnd true

# Notification queue
qs -c noctalia-shell ipc call plugin:ns-dynamic-island nextNotification
qs -c noctalia-shell ipc call plugin:ns-dynamic-island prevNotification
```

## Settings

Every feature has a toggle plus its own sub-options under
Settings → Plugins → Dynamic Island. Sections: Layout · Theme & accessibility ·
Visual polish · Interaction · Media · Notifications (with muted/pinned apps and
DND) · Recording · Idle (clock format, weather + cache) · Battery · OSD ·
Pomodoro · Timer · Privacy · Network · Bluetooth · Keyboard · Workspace ·
Clipboard / Screenshot · Calendar · Downloads · CPU/Thermal · Monitors.
