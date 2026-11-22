-- List the agents in your Rex session, each with the command that messages it.
--
--   rex do <skill>/scripts/team.lua
--
-- Tabs prefixed with a possibly indented ↳ are subagents. Teammates are the other labeled tabs
-- and panes.
local lib = dofile(debug.getinfo(1, "S").source:gsub("^@", ""):match("^(.*[/\\])") .. "lib.lua")

local session, me = lib.me()
for _, b in ipairs(lib.blocks(session)) do
  print(lib.name(b) .. "  " .. (b.id == me and "(you)" or lib.send_command(session, b.id, "<message>")))
  local process = rex.call("block.method", { session_id = session, block_id = b.id, method = "process", args = {} })
  local cwd = process and process.foreground and process.foreground.cwd
  local worktree = cwd and lib.worktree(cwd)
  if worktree then
    print("  branch: " .. worktree.branch)
    print("  worktree: " .. worktree.path)
  end
end
