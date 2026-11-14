rex.bind("alt+z", "pane.zoom")
rex.bind("shift+cmd+k", "com.superlogical.terminal.clear")
rex.bind("ctrl+cmd+left", "pane.resize", { direction = "left" })
rex.bind("ctrl+cmd+right", "pane.resize", { direction = "right" })
rex.bind("ctrl+cmd+up", "pane.resize", { direction = "up" })
rex.bind("ctrl+cmd+down", "pane.resize", { direction = "down" })

-- Close session with confirmation: ctrl+cmd+w, then y. Escape or n cancels.
rex.mode("close-session", { exclusive = true })
rex.bind("ctrl+cmd+w", "client.mode.enter", { name = "close-session", once = true })
rex.bind("close-session/y", "session.close")
rex.bind("close-session/n", "client.mode.exit")
