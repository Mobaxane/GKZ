-- playerlist.lua  — remote test script, PUBLIC repo, opens a window
-- Opens its own ImGui window AND hides the loader (one-window rule).
loaderVisible = false
AddHook("OnDraw", "PlayerList", function()
    if ImGui.Begin("Players", true, ImGui.WindowFlags.AlwaysAutoResize) then
        for _, plr in pairs(GetPlayerList()) do
            ImGui.Text(("%s @ %d, %d"):format(plr.name, plr.pos.x, plr.pos.y))
        end
        if ImGui.Button("close") then
            RemoveHook("PlayerList")
            loaderVisible = true
        end
    end
    ImGui.End()
end)
