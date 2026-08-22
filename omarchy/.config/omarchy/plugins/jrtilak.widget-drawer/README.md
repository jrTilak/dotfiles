# Widget Drawer

An Omarchy bar widget that renders other registered bar widgets inside a
collapsible inline drawer. Hover to reveal it, move away to hide it, or
left-click the chevron to pin/unpin it.

Each `contains` entry has the same shape as a normal `bar.layout` entry. The
original widget component receives the real Omarchy bar object, its own id,
and its inline settings, preserving its native appearance and interactions.

```json
{
  "id": "jrtilak.widget-drawer",
  "includeTray": true,
  "animationDuration": 320,
  "hoverCloseDelay": 200,
  "contains": [
    { "id": "omarchy.tailscale", "refreshIntervalSec": 30 },
    { "id": "omarchy.agents" },
    { "id": "omarchy.monitor" }
  ]
}
```

`includeTray` is enabled by default. The drawer renders status-notifier icons
itself; do not add `omarchy.tray` to either `bar.layout` or `plugins`. To remove
the built-in implementation completely, keep `omarchy.tray` in
`disabledPlugins` as in the installed configuration.

Third-party widgets contained by the drawer must also have an `{ "id": ... }`
entry in the top-level `plugins` array. Keeping mirrors there for every child
also lets native calls to `shell.updateEntryInline()` persist widget settings.
