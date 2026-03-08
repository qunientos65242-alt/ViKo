-- ============================================================
--  main.lua  |  ViKo Script Hub  v1.0.7 (High IQ Edition)
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

local TargetCords = {x = 0, y = 0, z = 0}

-- ════════════════════════════════════════════════════════════
--  TAB: MAIN (Movement & Teleport)
-- ════════════════════════════════════════════════════════════
local MainSection = Tabs.Main:AddSection("Professional Movement")

Tabs.Main:AddToggle("FlyToggle", { Title = "Fly Mode (High IQ)", Default = false, Callback = function(V) Features.ToggleFly(V) end })
Tabs.Main:AddSlider("FlySpeed", { Title = "Fly Speed", Default = 50, Min = 10, Max = 500, Rounding = 0, Callback = function(V) Features.FlySpeed = V end })
Tabs.Main:AddToggle("SpeedToggle", { Title = "Speed Hack", Default = false, Callback = function(V) Features.Enabled = V end })
Tabs.Main:AddSlider("WalkSpeed", { Title = "Walk Speed", Default = 16, Min = 16, Max = 500, Rounding = 0, Callback = function(V) Features.WalkSpeedValue = V end })
Tabs.Main:AddToggle("InfJump", { Title = "Infinite Jump", Default = false, Callback = function(V) Features.InfJump = V end })
Tabs.Main:AddToggle("Noclip", { Title = "Noclip (Safe)", Default = false, Callback = function(V) Features.Noclip = V end })

-- ── TELEPORT POR COORDENADAS ────────────────────────────────
local TPSection = Tabs.Main:AddSection("Coordinate Master")

local CurrentPosLabel = Tabs.Main:AddParagraph({ Title = "Current Position", Content = "Loading..." })

local InputX = Tabs.Main:AddInput("InputX", { Title = "X", Default = "0", Callback = function(v) TargetCords.x = v end })
local InputY = Tabs.Main:AddInput("InputY", { Title = "Y", Default = "0", Callback = function(v) TargetCords.y = v end })
local InputZ = Tabs.Main:AddInput("InputZ", { Title = "Z", Default = "0", Callback = function(v) TargetCords.z = v end })

Tabs.Main:AddButton({
    Title = "Execute Teleport",
    Description = "Teleport to the X Y Z coordinates above",
    Callback = function() Features.TeleportTo(TargetCords.x, TargetCords.y, TargetCords.z) end
})

-- BOTÓN MAGICO DE PEGAR Y TELETRANSPORTAR
Tabs.Main:AddButton({
    Title = "Paste Coords & Auto-Teleport",
    Description = "Copies from clipboard, fills inputs and teleports instantly",
    Callback = function()
        local clip = getclipboard and getclipboard() or ""
        -- Busca 3 números en el texto copiado (ej: "12.5, 40.1, -100.2")
        local x, y, z = string.match(clip, "([%-%.%d]+)[^%-%.%d]+([%-%.%d]+)[^%-%.%d]+([%-%.%d]+)")
        
        if x and y and z then
            InputX:SetValue(x)
            InputY:SetValue(y)
            InputZ:SetValue(z)
            Features.TeleportTo(x, y, z)
            Fluent:Notify({Title = "Success!", Content = "Teleported to: " .. x .. ", " .. y .. ", " .. z, Duration = 3})
        else
            Fluent:Notify({Title = "Error", Content = "No valid coordinates found in clipboard.", Duration = 3})
        end
    end
})

Tabs.Main:AddButton({
    Title = "Copy My Coordinates",
    Callback = function()
        local p = player.Character.HumanoidRootPart.Position
        setclipboard(string.format("%.2f, %.2f, %.2f", p.X, p.Y, p.Z))
        Fluent:Notify({ Title = "Copied!", Content = "Coordinates saved to clipboard", Duration = 2 })
    end
})

-- ── HISTORIAL INTELIGENTE ───────────────────────────────────
local HistorySection = Tabs.Main:AddSection("Coordinates History")
local historyCount = 0

Tabs.Main:AddButton({ 
    Title = "Save Current Position to History", 
    Callback = function()
        local p = player.Character.HumanoidRootPart.Position
        local cordsStr = string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)
        historyCount = historyCount + 1
        
        Tabs.Main:AddButton({
            Title = "#" .. historyCount .. " | Pos: " .. cordsStr,
            Description = "Click to teleport instantly",
            Callback = function() Features.TeleportTo(p.X, p.Y, p.Z) end
        })
        Fluent:Notify({Title = "Saved", Content = "Location added to history!", Duration = 2})
    end 
})

-- ════════════════════════════════════════════════════════════
--  LIVE UPDATE LOOP (Posición en vivo)
-- ════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    pcall(function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local p = root.Position
            CurrentPosLabel:SetDesc(string.format("X: %.1f | Y: %.1f | Z: %.1f", p.X, p.Y, p.Z))
        end
    end)
end)

Window:SelectTab(1)
Fluent:Notify({Title = "ViKo Hub", Content = "High IQ Movement Loaded!", Duration = 5})
