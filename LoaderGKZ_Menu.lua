--[[
   GKZ Loader Menu (Remote - upload to GitHub)
   Contains version selection and loading logic
   File: LoaderGKZ_Menu.lua
--]]

-- GitHub URLs for each version
local REMOTE_ENHANCED = "https://raw.githubusercontent.com/Mobaxane/GKZ/refs/heads/main/GeigerKembar.lua"
local REMOTE_BASIC = "https://raw.githubusercontent.com/Mobaxane/GKZ/refs/heads/main/GeigerKembar_Basic.lua"

-- Local fallbacks
local LOCAL_ENHANCED = "GeigerKembar.lua"
local LOCAL_BASIC = "GeigerKembar_Basic.lua"

-- Script folder
local scriptFolder = ""
if os.getenv("LOCALAPPDATA") then
    scriptFolder = os.getenv("LOCALAPPDATA"):gsub([[\]], [[\\]]) .. "\\Growtopia\\scripts\\"
else
    scriptFolder = "storage/emulated/0/Android/media/com.rtsoft.growtopia/scripts/"
end

local function fileExists(p)
    local f = io.open(p, "r")
    if f then io.close(f) return true end
    return false
end

local function executeContent(content, source)
    local func, err = load(content)
    if not func then
        SendVariantList({[0] = "OnTextOverlay", [1] = "`9Error: " .. tostring(err)})
        return false
    end
    SendVariantList({[0] = "OnTextOverlay", [1] = "`9Loading " .. source .. "..."})
    func()
    SendVariantList({[0] = "OnTextOverlay", [1] = "`2" .. source .. " loaded!"})
    return true
end

local function loadRemote(url, version)
    local resp = MakeRequest(url, "GET")
    if resp and resp.status == 200 and resp.content then
        return executeContent(resp.content, version .. " (GitHub)")
    end
    return false
end

local function loadLocal(filename, version)
    local f = io.open(scriptFolder .. filename, "r")
    if not f then return false end
    local content = f:read("*a")
    f:close()
    return executeContent(content, version .. " (local)")
end

local function loadVersion(version, remoteUrl, localFile)
    RemoveHooks("gkz_version_menu")

    -- Try remote first
    if loadRemote(remoteUrl, version) then
        return true
    end

    -- Fallback to local
    if loadLocal(localFile, version) then
        return true
    end

    SendVariantList({[0] = "OnTextOverlay", [1] = "`9Failed to load " .. version})
    return false
end

-- Version selection
local available = {}
table.insert(available, { name = "Enhanced", url = REMOTE_ENHANCED, file = LOCAL_ENHANCED })
table.insert(available, { name = "Basic", url = REMOTE_BASIC, file = LOCAL_BASIC })

if #available > 1 then
    AddHook("OnDraw", "gkz_version_menu", function()
        if not ImGui or not ImGui.Begin then return end

        if ImGui.Begin("GKZ Version Selector") then
            ImGui.TextColored(0xFF8B0015, "Select GeigerKembar Version")
            ImGui.Spacing()
            ImGui.Separator()

            for i, v in ipairs(available) do
                if ImGui.Button(v.name .. " Version", 200, 30) then
                    loadVersion(v.name, v.url, v.file)
                end
            end

            ImGui.Spacing()
            if ImGui.Button("Cancel", 100, 30) then
                RemoveHooks("gkz_version_menu")
                SendVariantList({[0] = "OnTextOverlay", [1] = "`7Loader cancelled"})
            end
        end
        ImGui.End()
    end)
else
    local v = available[1]
    loadVersion(v.name, v.url, v.file)
end
