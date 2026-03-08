-- ============================================================
--  main.lua  |  ViKo Script Hub  v1.0.6
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

-- Variables para Teleport
local TargetCords = {x = 0, y = 0, z = 0}

-- ════════════════════════════════════════════════════════════
--  TAB: MAIN (Movement & Teleport)
-- ════════════════════════════════════════════════════════════
local MainSection = Tabs.Main:AddSection("Professional Movement")

Tabs.Main:AddToggle("FlyToggle", { Title = "Fly Mode (Stable)", Default = false, Callback = function(V) Features.Fly = V end })
Tabs.Main:AddSlider("FlySpeed", { Title = "Fly Speed", Default = 50, Min = 10, Max = 500, Rounding = 0, Callback = function(V) Features.FlySpeed = V end })
Tabs.Main:AddToggle("SpeedToggle", { Title = "Speed Hack", Default = false, Callback = function(V) Features.Enabled = V end })
Tabs.Main:AddSlider("WalkSpeed", { Title = "Walk Speed", Default = 16, Min = 16, Max = 500, Rounding = 0, Callback = function(V) Features.WalkSpeedValue = V end })
Tabs.Main:AddToggle("InfJump", { Title = "Infinite Jump", Default = false, Callback = function(V) Features.InfJump = V end })
Tabs.Main:AddToggle("Noclip", { Title = "Noclip", Default = false, Callback = function(V) Features.Noclip = V end })

-- ── TELEPORT POR COORDENADAS ────────────────────────────────
local TPSection = Tabs.Main:AddSection("Coordinate Master")

local CurrentPosLabel = Tabs.Main:AddParagraph({ Title = "Current Position", Content = "X: 0 | Y: 0 | Z: 0" })

Tabs.Main:AddInput("InputX", { Title = "Coordinate X", Default = "0", Callback = function(v) TargetCords.x = v end })
Tabs.Main:AddInput("InputY", { Title = "Coordinate Y", Default = "0", Callback = function(v) TargetCords.y = v end })
Tabs.Main:AddInput("InputZ", { Title = "Coordinate Z", Default = "0", Callback = function(v) TargetCords.z = v end })

Tabs.Main:AddButton({
    Title = "Execute Teleport",
    Description = "Teleport to manual coordinates",
    Callback = function()
        Features.TeleportTo(TargetCords.x, TargetCords.y, TargetCords.z)
    end
})

Tabs.Main:AddButton({
    Title = "Copy My Coordinates",
    Callback = function()
        local pos = player.Character.HumanoidRootPart.Position
        setclipboard(string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z))
        Fluent:Notify({ Title = "Copied!", Content = "Coords saved to clipboard", Duration = 2 })
    end
})

-- ── HISTORIAL ───────────────────────────────────────────────
local HistorySection = Tabs.Main:AddSection("Coordinates History")

local function AddToHistory()
    local pos = player.Character.HumanoidRootPart.Position
    local c = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
    
    Tabs.Main:AddButton({
        Title = "Pos: " .. c,
        Description = "Click to Teleport back",
        Callback = function() Features.TeleportTo(pos.X, pos.Y, pos.Z) end
    })
end

Tabs.Main:AddButton({ Title = "Save Current Position to History", Callback = AddToHistory })

-- ════════════════════════════════════════════════════════════
--  LIVE UPDATE LOOP
-- ════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    pcall(function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local p = root.Position
            CurrentPosLabel:SetDesc(string.format("X: %.2f | Y: %.2f | Z: %.2f", p.X, p.Y, p.Z))
        end
    end)
end)

Window:SelectTab(1)
Fluent:Notify({Title = "ViKo Hub", Content = "System Updated v1.0.6", Duration = 5})
