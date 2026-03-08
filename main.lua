-- ============================================================
--  main.lua  |  ViKo Script Hub  v1.0.4
--  Main logic. Interface is defined in ui_library.lua.
--  Repository: https://github.com/qunientos65242-alt/ViKo
-- ============================================================

-- ── Load interface from repository ───────────────────────────
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"
))()

local Fluent      = UI.Fluent
local Window      = UI.Window
local Tabs        = UI.Tabs
local SaveManager = UI.SaveManager

-- ── Cargar Funciones Externas (Features) ─────────────────────
local Features = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/refs/heads/main/features.lua"))()

-- ── Constants ────────────────────────────────────────────────
local SCRIPT_VERSION = "1.0.4"
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
    local name = try(function()
        return identifyexecutor and identifyexecutor() or nil
    end, nil)
    if name then return tostring(name) end
    return "Unknown"
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
local MainSection = Tabs.Main:AddSection("Movement Enhancements")

-- 1. SPEED HACK
Tabs.Main:AddToggle("SpeedToggle", {
    Title = "Enable Speed Hack",
    Default = false,
    Callback = function(Value)
        Features.Enabled = Value
        if not Value then
            pcall(function() player.Character.Humanoid.WalkSpeed = 16 end)
        end
    end
})

Tabs.Main:AddSlider("SpeedSlider", {
    Title = "Walk Speed Value",
    Description = "Default is 16",
    Default = 16,
    Min = 16,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        Features.WalkSpeedValue = Value
    end
})

-- 2. INF JUMP
Tabs.Main:AddToggle("JumpToggle", {
    Title = "Infinite Jump",
    Description = "Jump as many times as you want",
    Default = false,
    Callback = function(Value)
        Features.InfJump = Value
    end
})

-- 3. NOCLIP
Tabs.Main:AddToggle("NoclipToggle", {
    Title = "Noclip",
    Description = "Walk through walls",
    Default = false,
    Callback = function(Value)
        Features.Noclip = Value
    end
})

-- 4. TELEPORT
Tabs.Main:AddButton({
    Title = "Teleport to Mouse",
    Description = "Teleports you to where you are looking",
    Callback = function()
        Features.TeleportToMouse()
    end
})

-- ════════════════════════════════════════════════════════════
--  TAB: PROFILE
-- ════════════════════════════════════════════════════════════
local sessionId = try(function() return tostring(game.JobId) end, "N/A")

Tabs.Profile:AddParagraph({
    Title   = "Identity",
    Content = "  Username: " .. player.Name .. "\n  User ID: " .. tostring(player.UserId)
})

local networkParagraph = Tabs.Profile:AddParagraph({
    Title   = "Network & Performance",
    Content = "Loading..."
})

local characterParagraph = Tabs.Profile:AddParagraph({
    Title   = "Character Stats",
    Content = "Loading..."
})

-- ════════════════════════════════════════════════════════════
--  TAB: FULL INFO
-- ════════════════════════════════════════════════════════════
Tabs.FullInfo:AddParagraph({
    Title   = "System Info",
    Content = "  Executor: " .. getExecutor() .. "\n  Version: " .. SCRIPT_VERSION
})

local runtimeParagraph = Tabs.FullInfo:AddParagraph({
    Title   = "Runtime Stats",
    Content = "Loading..."
})

-- ════════════════════════════════════════════════════════════
--  TAB: SETTINGS
-- ════════════════════════════════════════════════════════════
Tabs.Settings:AddSection("Config Management")
Tabs.Settings:AddDropdown("Theme", {
    Title   = "UI Theme",
    Values  = { "Dark", "Light", "Darker", "Aqua", "Amethyst" },
    Default = "Dark",
    Callback = function(value) Fluent:SetTheme(value) end,
})

-- ════════════════════════════════════════════════════════════
--  LIVE UPDATE LOOP
-- ════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        local fps = round(1/dt)
        local ping = round(player:GetNetworkPing() * 1000)
        
        runtimeParagraph:SetDesc("  Uptime: " .. formatUptime(tick() - startTick) .. "\n  FPS: " .. fps .. "\n  Ping: " .. ping .. "ms")
        networkParagraph:SetDesc("  FPS: " .. fps .. "\n  Ping: " .. ping .. "ms")
        
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            characterParagraph:SetDesc("  Health: " .. round(hum.Health) .. "/" .. round(hum.MaxHealth) .. "\n  Speed: " .. round(hum.WalkSpeed))
        end
    end)
end)

Window:SelectTab(1)
Fluent:Notify({Title = "ViKo loaded", Content = "Movement hacks ready", Duration = 5})
