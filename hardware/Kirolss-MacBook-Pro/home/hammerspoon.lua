local lastCmdQ = 0
local interval = 1.5

local function quit()
    local elapsed = hs.timer.secondsSinceEpoch() - lastCmdQ
    lastCmdQ = hs.timer.secondsSinceEpoch()
    if elapsed < interval then
        local res = hs.application.frontmostApplication():selectMenuItem("^Quit.*$")
    else
      hs.alert("Press ⌘+q again to quit",interval)
    end
end

cmdQ = hs.hotkey.bind({"cmd"},"q", quit)
