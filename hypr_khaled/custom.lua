require("default.hypr.helpers")

hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 3,
    border_size = 2,
  },

  input = {
    follow_mouse = 0,
  },

  misc = {
    mouse_move_focuses_monitor = 0,
  },
})

-- Replace Omarchy's defaults
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")

-- Window navigation
o.bind("SUPER + H", "Move window focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + L", "Move window focus right", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + K", "Move window focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + J", "Move window focus down", hl.dsp.focus({ direction = "d" }))

-- Window swapping
o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))

-- Full width
o.bind("SUPER + Z", "Full width (Maximized)", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Applications
o.bind("SUPER + B", "Web Browser", {
  omarchy = "browser",
})

o.bind("SUPER + M", "Email", {
  webapp = "https://mail.google.com",
})
