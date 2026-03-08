-- ============================================================
--  main.lua  |  ViKo Script Hub  v1.0.9
--  Main logic. Interface is defined in ui_library.lua.
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

local function round(n)
    return math.floor(n + 0.5)
end

local function getExecutor()
    local name = try(function() return identifyexecutor and identifyexecutor() or nil end, nil)
    if name then return tostring(name) end
    name = try(function() return getexecutorname and getexecutorname() or nil end, nil)
    if name then return tostring(name) end
    return "Unknown"
end

local function supports(name)
    if rawget(_G, name) ~= nil then return true end
    local ok, env = pcall(function() return type(getfenv) == "function" and getfenv() or nil end)
    return ok and env and env[name] ~= nil
end

local function accountAge()
    local days = try(function() return player.AccountAge end, nil)
    if not days then return "N/A" end
    if days < 1   then return "Today" end
    if days < 365 then return ("%.1f month(s)"):format(days / 30) end
    return ("%.1f year(s)"):format(days / 365)
end

local function gameName()
    local info = try(function() return MarketService:GetProductInfo(game.PlaceId) end, nil)
    return (info and info.Name) or tostring(game.PlaceId)
end

local function formatUptime(s)
    s = math.floor(s)
    if s < 60   then return s .. "s" end
    if s < 3600 then return ("%dm %ds"):format(math.floor(s/60), s%60) end
    return ("%dh %dm %ds"):format(math.floor(s/3600), math.floor((s%3600)/60), s%60)
end

-- ════════════════════════════════════════════════════════════
--  TAB: MAIN (Movement Enhancements)
-- ════════════════════════════════════════════════════════════
local MainSection = Tabs.Main:AddSection("Movement & Hacks")

-- SPEED
local SpeedToggle = Tabs.Main:AddToggle("SpeedToggle", { Title = "Speed Hack", Default = false, Callback = function(V) Features.Enabled = V end })
Tabs.Main:AddKeybind("SpeedKey", { Title = "Keybind: Speed", Mode = "Toggle", Default = nil, Callback = function(V) SpeedToggle:SetValue(V) end })
Tabs.Main:AddSlider("WalkSpeed", { Title = "Walk Speed", Default = 16, Min = 16, Max = 1000, Rounding = 0, Callback = function(V) Features.WalkSpeedValue = V end })

-- FLY
local FlyToggle = Tabs.Main:AddToggle("FlyToggle", { Title = "Fly Mode (High IQ)", Default = false, Callback = function(V) Features.ToggleFly(V) end })
Tabs.Main:AddKeybind("FlyKey", { Title = "Keybind: Fly", Mode = "Toggle", Default = nil, Callback = function(V) FlyToggle:SetValue(V) end })
Tabs.Main:AddSlider("FlySpeed", { Title = "Fly Speed", Default = 50, Min = 10, Max = 1000, Rounding = 0, Callback = function(V) Features.FlySpeed = V end })

-- OTHERS
local JumpToggle = Tabs.Main:AddToggle("InfJump", { Title = "Infinite Jump", Default = false, Callback = function(V) Features.InfJump = V end })
Tabs.Main:AddKeybind("JumpKey", { Title = "Keybind: Inf Jump", Mode = "Toggle", Default = nil, Callback = function(V) JumpToggle:SetValue(V) end })

local NoclipToggle = Tabs.Main:AddToggle("Noclip", { Title = "Noclip (Safe)", Default = false, Callback = function(V) Features.Noclip = V end })
Tabs.Main:AddKeybind("NoclipKey", { Title = "Keybind: Noclip", Mode = "Toggle", Default = nil, Callback = function(V) NoclipToggle:SetValue(V) end })

-- ── WAYPOINT SYSTEM ─────────────────────────────────────────
local WaypointSection = Tabs.Main:AddSection("Waypoints System")

local savedPoints = {}
local pointNames = {}
local selectedPoint = nil
local pointCounter = 1

local Dropdown = Tabs.Main:AddDropdown("WaypointSelect", {
    Title = "Saved Locations",
    Values = pointNames,
    Multi = false,
    Default = nil,
    Callback = function(Value) selectedPoint = Value end
})

Tabs.Main:AddButton({
    Title = "Save Current Location",
    Callback = function()
        if #pointNames >= 10 then return Fluent:Notify({Title="Limit", Content="Max 10 waypoints", Duration=3}) end
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
            
            -- FIX BUG: Si no quedan puntos, poner "None"
            if #pointNames == 0 then
                Dropdown:SetValues({"None"})
                Dropdown:SetValue("None")
                selectedPoint = nil
            else
                Dropdown:SetValues(pointNames)
                Dropdown:SetValue(pointNames[1])
            end
            Fluent:Notify({Title = "Deleted", Content = "Waypoint removed.", Duration = 2})
        end
    end
})

-- ════════════════════════════════════════════════════════════
--  TABS: PROFILE, FULL INFO & SETTINGS (RESTAURADOS)
-- ════════════════════════════════════════════════════════════
-- [Aquí se mantiene exactamente el código de Perfil, Executor Info y Config que ya teníamos]
local sessionId = try(function() return tostring(game.JobId) end, "N/A")

Tabs.Profile:AddParagraph({
    Title   = "Identity",
    Content = "  Username: " .. player.Name .. "\n  Display Name: " .. player.DisplayName .. "\n  User ID: " .. tostring(player.UserId) .. "\n  Account Age: " .. accountAge()
})

local characterParagraph = Tabs.Profile:AddParagraph({ Title = "Character", Content = "Loading..." })
local networkParagraph = Tabs.Profile:AddParagraph({ Title = "Network & Performance", Content = "Loading..." })

Tabs.FullInfo:AddParagraph({
    Title   = "System Info",
    Content = "  Executor: " .. getExecutor() .. "\n  Script: v" .. SCRIPT_VERSION .. "\n  UI: Fluent"
})

local runtimeParagraph = Tabs.FullInfo:AddParagraph({ Title = "Runtime Stats", Content = "Loading..." })

Tabs.Settings:AddSection("Interface")
Tabs.Settings:AddDropdown("Theme", {
    Title = "UI Theme", Values = { "Dark", "Light", "Darker", "Aqua", "Amethyst" }, Default = "Dark",
    Callback = function(value) Fluent:SetTheme(value) end,
})

-- ════════════════════════════════════════════════════════════
--  LIVE UPDATE LOOP
-- ════════════════════════════════════════════════════════════
local accumulator = 0
RunService.Heartbeat:Connect(function(dt)
    accumulator = accumulator + dt
    if accumulator < 1 then return end
    accumulator = 0

    pcall(function()
        local fps = round(1/dt)
        local ping = try(function() return round(player:GetNetworkPing() * 1000) end, 0)
        local mem = try(function() return round(StatsService:GetTotalMemoryUsageMb()) end, 0)

        runtimeParagraph:SetDesc("  Uptime: " .. formatUptime(tick() - startTick) .. "\n  FPS: " .. fps .. "\n  Ping: " .. ping .. "ms\n  Mem: " .. mem .. "MB")
        networkParagraph:SetDesc("  FPS: " .. fps .. "\n  Ping: " .. ping .. "ms")

        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            characterParagraph:SetDesc("  Health: " .. round(hum.Health) .. "/" .. round(hum.MaxHealth) .. "\n  WalkSpeed: " .. round(hum.WalkSpeed))
        end
    end)
end)

Window:SetSubtitle("v" .. SCRIPT_VERSION .. " · " .. getExecutor())
Window:SelectTab(1)
Fluent:Notify({ Title = "ViKo loaded", Content = "Movement Hacks & Keybinds Ready!", Duration = 5 })
