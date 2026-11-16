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

-- Open $EDITOR in the focused pane's directory. The Rex server has no EDITOR,
-- so an interactive zsh reads it from .zshrc. The command drops -w, because
-- code -w replaces the last active window when given a folder. Rex kills a
-- rex.exec.start process when the action returns, so rex.exec runs sh, which
-- starts zsh in the background and exits. Output goes to /dev/null, since
-- zsh -i startup warnings would otherwise raise SIGPIPE.
rex.action{
  name = "open_editor",
  title = "Open Editor Here",
  run = function(ctx)
    local dir = focused_dir(ctx)
    if not dir then error("pane has no working directory", 0) end
    local cmd = [[/bin/zsh -ic '${${=EDITOR}:#(-w|--wait)} .' </dev/null >/dev/null 2>&1 &]]
    local _, err = rex.exec({ "/bin/sh", "-c", cmd }, { cwd = dir })
    if err then error(err, 0) end
  end,
}
rex.bind("ctrl+cmd+e", "open_editor")

-- Close session with confirmation: ctrl+cmd+w, then y. Escape or n cancels.
rex.mode("close-session", { exclusive = true })
rex.bind("ctrl+cmd+w", "client.mode.enter", { name = "close-session", once = true })
rex.bind("close-session/y", "session.close")
rex.bind("close-session/n", "client.mode.exit")
