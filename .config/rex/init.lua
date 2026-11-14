rex.bind("alt+z", "pane.zoom")
rex.bind("shift+cmd+k", "com.superlogical.terminal.clear")

-- Close session with confirmation: ctrl+cmd+w, then y. Escape or n cancels.
rex.mode("close-session", { exclusive = true })
rex.bind("ctrl+cmd+w", "client.mode.enter", { name = "close-session", once = true })
rex.bind("close-session/y", "session.close")
rex.bind("close-session/n", "client.mode.exit")
