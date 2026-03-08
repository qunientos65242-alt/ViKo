-- ============================================================
--  main.lua  |  ViKo Script Hub  v1.0.5
-- ============================================================

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"))()
local Fluent      = UI.Fluent
local Window      = UI.Window
local Tabs        = UI.Tabs
local SaveManager = UI.SaveManager

local Features = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/refs/heads/main/features.lua"))()

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local player     = Players.LocalPlayer
local startTick  = tick()

-- ════════════════════════════════════════════════════════════
--  TAB: MAIN (Movement Enhancements)
-- ════════════════════════════════════════════════════════════
local MainSection = Tabs.Main:AddSection("Movement Enhancements")

-- 1. SPEED HACK
Tabs.Main:AddToggle("SpeedToggle", {
    Title = "Speed Hack",
    Default = false,
    Callback = function(Value) Features.Enabled = Value end
})

Tabs.Main:AddSlider("SpeedSlider", {
    Title = "Speed Value",
    Default = 16, Min = 16, Max = 300, Rounding = 0,
    Callback = function(Value) Features.WalkSpeedValue = Value end
})

-- 2. FLY HACK
Tabs.Main:AddToggle("FlyToggle", {
    Title = "Fly Mode",
    Description = "Use Space to go up, Shift to go down",
    Default = false,
    Callback = function(Value) Features.Fly = Value end
})

Tabs.Main:AddSlider("FlySpeedSlider", {
    Title = "Fly Speed",
    Default = 50, Min = 10, Max = 300, Rounding = 0,
    Callback = function(Value) Features.FlySpeed = Value end
})

-- 3. INF JUMP & NOCLIP
Tabs.Main:AddToggle("JumpToggle", { Title = "Infinite Jump", Default = false, Callback = function(Value) Features.InfJump = Value end })
Tabs.Main:AddToggle("NoclipToggle", { Title = "Noclip", Default = false, Callback = function(Value) Features.Noclip = Value end })

-- 4. TELEPORT (CON TECLA)
Tabs.Main:AddKeybind("TeleportKey", {
    Title = "Teleport to Mouse Key",
    Mode = "Always", -- Se activa al presionar
    Default = "T", -- TECLA POR DEFECTO
    Callback = function()
        Features.TeleportToMouse()
    end,
    ChangedCallback = function(New)
        print("Teleport key changed to: " .. New.Name)
    end
})

-- ════════════════════════════════════════════════════════════
--  TABS: PROFILE & INFO (Resumido para ahorrar espacio)
-- ════════════════════════════════════════════════════════════
local networkParagraph = Tabs.Profile:AddParagraph({ Title = "Network", Content = "Loading..." })
local characterParagraph = Tabs.Profile:AddParagraph({ Title = "Character", Content = "Loading..." })

-- ════════════════════════════════════════════════════════════
--  LIVE UPDATE LOOP
-- ════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        local fps = math.floor(1/dt)
        local ping = math.floor(player:GetNetworkPing() * 1000)
        networkParagraph:SetDesc("FPS: " .. fps .. " | Ping: " .. ping .. "ms")
        
        local hum = player.Character and player.Character:FindFirstChild("Humanoid")
        if hum then
            characterParagraph:SetDesc("Health: " .. math.floor(hum.Health) .. " | Speed: " .. math.floor(hum.WalkSpeed))
        end
    end)
end)

Window:SelectTab(1)
Fluent:Notify({Title = "ViKo Hub", Content = "Hacks loaded! Press T to Teleport", Duration = 5})
