-- ============================================================
--  main.lua  |  ViKo Script Hub  v1.0.9
-- ============================================================

-- ── Load interface from repository ───────────────────────────
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"
))()

local Fluent      = UI.Fluent
local Window      = UI.Window
local Tabs        = UI.Tabs
local SaveManager = UI.SaveManager

-- ── Cargar Funciones Externas ────────────────────────────────
local Features = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/qunientos65242-alt/ViKo/refs/heads/main/features.lua"
))()

-- ── Constants ────────────────────────────────────────────────
local SCRIPT_VERSION = "1.0.9"
local URL_REPO       = "https://github.com/qunientos65242-alt/ViKo"
local URL_UI         = "https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"

-- ── Roblox Services ──────────────────────────────────────────
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local MarketService = game:GetService("MarketplaceService")
local StatsService  = game:GetService("Stats")

local player    = Players.LocalPlayer
local startTick = tick()

-- ════════════════════════════════════════════════════════════
--  HELPER FUNCTIONS
-- ════════════════════════════════════════════════════════════
local function try(fn, fallback)
    local ok, res = pcall(fn)
    if ok and res ~= nil then return res end
    return fallback
end

local function round(n) return math.floor(n + 0.5) end

local function getExecutor()
    local name = try(function() return identifyexecutor and identifyexecutor() or nil end, nil)
    if name then return tostring(name) end
    return "Unknown"
end

local function accountAge()
    local days = try(function() return player.AccountAge end, nil)
    return days and (days .. " days") or "N/A"
end

local function formatUptime(s)
    s = math.floor(s)
    if s < 60 then return s .. "s" end
    return ("%dm %ds"):format(math.floor(s/60), s%60)
end

-- ════════════════════════════════════════════════════════════
--  TAB: MAIN (Movement Enhancements)
-- ════════════════════════════════════════════════════════════
local MainSection = Tabs.Main:AddSection("Movement & Hacks")

-- SPEED
local SpeedToggle = Tabs.Main:AddToggle("SpeedToggle", { Title = "Speed Hack", Default = false, Callback = function(V) Features.Enabled = V end })
Tabs.Main:AddKeybind("SpeedKey", { Title = "Speed Keybind", Mode = "Toggle", Default = nil, Callback = function(Value) SpeedToggle:SetValue(Value) end })
Tabs.Main:AddSlider("WalkSpeed", { Title = "Walk Speed", Default = 16, Min = 0, Max = 100000, Rounding = 0, Callback = function(V) Features.WalkSpeedValue = V end })

-- FLY
local FlyToggle = Tabs.Main:AddToggle("FlyToggle", { Title = "Fly Mode", Default = false, Callback = function(V) Features.ToggleFly(V) end })
Tabs.Main:AddKeybind("FlyKey", { Title = "Fly Keybind", Mode = "Toggle", Default = nil, Callback = function(Value) FlyToggle:SetValue(Value) end })
Tabs.Main:AddSlider("FlySpeed", { Title = "Fly Speed", Default = 50, Min = 0, Max = 100000, Rounding = 0, Callback = function(V) Features.FlySpeed = V end })

-- OTHERS
local JumpToggle = Tabs.Main:AddToggle("InfJump", { Title = "Infinite Jump", Default = false, Callback = function(V) Features.InfJump = V end })
Tabs.Main:AddKeybind("JumpKey", { Title = "Jump Keybind", Mode = "Toggle", Default = nil, Callback = function(Value) JumpToggle:SetValue(Value) end })

local NoclipToggle = Tabs.Main:AddToggle("Noclip", { Title = "Noclip (Safe)", Default = false, Callback = function(V) Features.Noclip = V end })
Tabs.Main:AddKeybind("NoclipKey", { Title = "Noclip Keybind", Mode = "Toggle", Default = nil, Callback = function(Value) NoclipToggle:SetValue(Value) end })

-- ── WAYPOINT SYSTEM ─────────────────────────────────────────
local WaypointSection = Tabs.Main:AddSection("Waypoints System")

local savedPoints = {}
local pointNames = {}
local selectedPoint = nil
local pointCounter = 1

local Dropdown = Tabs.Main:AddDropdown("WaypointSelect", {
    Title = "Saved Locations",
    Values = {"None"},
    Multi = false,
    Default = "None",
    Callback = function(Value) selectedPoint = Value end
})

Tabs.Main:AddButton({
    Title = "Save Current Location",
    Callback = function()
        if #pointNames >= 10 then return Fluent:Notify({Title="Limit", Content="Max 10 points", Duration=2}) end
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local p = root.Position
            local name = "Point #" .. pointCounter
            pointCounter = pointCounter + 1
            savedPoints[name] = {x = p.X, y = p.Y, z = p.Z}
            table.insert(pointNames, name)
            Dropdown:SetValues(pointNames)
            Dropdown:SetValue(name)
        end
    end
})

Tabs.Main:AddButton({
    Title = "Teleport to Selected",
    Callback = function()
        if selectedPoint and savedPoints[selectedPoint] then
            local c = savedPoints[selectedPoint]
            Features.TeleportTo(c.x, c.y, c.z)
        end
    end
})

Tabs.Main:AddButton({
    Title = "Delete Selected Point",
    Callback = function()
        if selectedPoint and savedPoints[selectedPoint] then
            savedPoints[selectedPoint] = nil
            local newNames = {}
            for _, n in ipairs(pointNames) do if n ~= selectedPoint then table.insert(newNames, n) end end
            pointNames = newNames
            
            if #pointNames == 0 then
                Dropdown:SetValues({"None"})
                Dropdown:SetValue("None")
                selectedPoint = nil
            else
                Dropdown:SetValues(pointNames)
                Dropdown:SetValue(pointNames[1])
            end
        end
    end
})

-- ════════════════════════════════════════════════════════════
--  TABS: PROFILE & INFO (Restaurado Completo)
-- ════════════════════════════════════════════════════════════
local sessionId = try(function() return tostring(game.JobId) end, "N/A")

Tabs.Profile:AddParagraph({
    Title = "Identity",
    Content = "User: "..player.Name.."\nID: "..player.UserId.."\nAge: "..accountAge()
})

local characterParagraph = Tabs.Profile:AddParagraph({ Title = "Character", Content = "Loading..." })
local networkParagraph = Tabs.Profile:AddParagraph({ Title = "Network", Content = "Loading..." })

Tabs.FullInfo:AddParagraph({
    Title = "System Info",
    Content = "Executor: "..getExecutor().."\nScript: v"..SCRIPT_VERSION
})

local runtimeParagraph = Tabs.FullInfo:AddParagraph({ Title = "Runtime Stats", Content = "Loading..." })

-- ════════════════════════════════════════════════════════════
--  TAB: SETTINGS
-- ════════════════════════════════════════════════════════════
Tabs.Settings:AddSection("Interface")
Tabs.Settings:AddDropdown("Theme", {
    Title = "UI Theme", Values = { "Dark", "Light", "Darker", "Aqua", "Amethyst" }, Default = "Dark",
    Callback = function(v) Fluent:SetTheme(v) end,
})

-- ════════════════════════════════════════════════════════════
--  LIVE UPDATE LOOP
-- ════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        local fps = round(1/dt)
        local ping = round(player:GetNetworkPing() * 1000)
        local hum = player.Character and player.Character:FindFirstChild("Humanoid")
        
        runtimeParagraph:SetDesc("Uptime: "..formatUptime(tick()-startTick).."\nFPS: "..fps.."\nPing: "..ping.."ms")
        networkParagraph:SetDesc("FPS: "..fps.." | Ping: "..ping.."ms")
        
        if hum then
            characterParagraph:SetDesc("Health: "..round(hum.Health).."/"..round(hum.MaxHealth).."\nSpeed: "..round(hum.WalkSpeed))
        end
    end)
end)

Window:SelectTab(1)
Fluent:Notify({ Title = "ViKo Hub", Content = "V1.0.9 Unleashed Ready!", Duration = 5 })
