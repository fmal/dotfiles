rex.bind("alt+z", "pane.zoom")
rex.bind("shift+cmd+k", "com.superlogical.terminal.clear")
rex.bind("ctrl+cmd+left", "pane.resize", { direction = "left" })
rex.bind("ctrl+cmd+right", "pane.resize", { direction = "right" })
rex.bind("ctrl+cmd+up", "pane.resize", { direction = "up" })
rex.bind("ctrl+cmd+down", "pane.resize", { direction = "down" })

-- Open a coding agent in a new pane right of the focused one, in its directory.
-- The agent is typed into an interactive shell, because cc! and codex! are zsh
-- aliases. Quitting the agent closes the pane.
local terminal = "com.superlogical.terminal"

local function focused_dir(ctx)
  local r = rex.block.call(terminal, "pwd", { block_id = ctx.block_id })
  if not (r and r.pwd) then return nil end
  local path = r.pwd:gsub("^file://[^/]*", ""):gsub("%%(%x%x)", function(h)
    return string.char(tonumber(h, 16))
  end)
  return path
end

local function agent_action(name, title, program)
  rex.action{
    name = name,
    title = title,
    run = function(ctx)
      local _, err = rex.session.new_split{
        anchor_id = ctx.block_id,
        direction = "horizontal",
        side = "after",
        focus = true,
        layout = rex.layout.block{
          flavor = terminal .. ".shell",
          options = { cwd = focused_dir(ctx), initial_input = program .. "\n" },
        },
      }
      if err then error(err, 0) end
    end,
  }
end

agent_action("claude_pane", "Open Claude Code Pane", "cc!; exit")
agent_action("codex_pane", "Open Codex Pane", "codex!; exit")
rex.bind("ctrl+cmd+c", "claude_pane")
rex.bind("ctrl+cmd+x", "codex_pane")

-- Close session with confirmation: ctrl+cmd+w, then y. Escape or n cancels.
rex.mode("close-session", { exclusive = true })
rex.bind("ctrl+cmd+w", "client.mode.enter", { name = "close-session", once = true })
rex.bind("close-session/y", "session.close")
rex.bind("close-session/n", "client.mode.exit")
