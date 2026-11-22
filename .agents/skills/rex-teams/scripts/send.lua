-- Paste a one-line message into another agent's Rex terminal and submit it.
--
--   rex do <skill>/scripts/send.lua session=SESSION block=BLOCK message='MESSAGE'
--
-- BLOCK is the block ID of the other agent's terminal. team.lua prints this
-- command, filled in, for each agent in your session.
-- The message arrives as
--   [from <your name>, who can't see this screen. <rule> Reply by running: <command>] MESSAGE
-- so the other agent knows who wrote and how to answer, even if it has never
-- heard of this skill. Without "can't see this screen", agents tend to answer
-- in their own pane, where nobody reads it.
local lib = dofile(debug.getinfo(1, "S").source:gsub("^@", ""):match("^(.*[/\\])") .. "lib.lua")
local session, block = rex.args.session, rex.args.block
local message = tostring(assert(rex.args.message, "usage: send.lua session=SESSION block=BLOCK message='MESSAGE'"))
-- A newline would submit half the message.
assert(not message:find("[\r\n]"), "the message must be one line; put longer text in a file and send its path")

local header = lib.header(lib.me())
lib.attach(session)
lib.paste_line(session, block, header .. message)
