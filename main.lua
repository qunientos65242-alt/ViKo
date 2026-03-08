-- ============================================================
--  main.lua | ViKo Script Hub v1.1.2 - RESTAURACIÓN COMPLETA
-- ============================================================
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"))()
local Fluent, Window, Tabs, SaveManager = UI.Fluent, UI.Window, UI.Tabs, UI.SaveManager

local Features = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/refs/heads/main/features.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketService = game:GetService("MarketplaceService")
local StatsService = game:GetService("Stats")
local player = Players.LocalPlayer
local startTick = tick()

-- ── FUNCIONES DE AYUDA (Originales) ────────────────
local function try(f, fb) local ok, res = pcall(f) return (ok and res ~= nil) and res or fb end
local function round(n) return math.floor(n + 0.5) end
local function formatUptime(s)
    s = math.floor(s)
    if s < 60 then return s.."s" end
    if s < 3600 then return math.floor(s/60).."m "..(s%60).."s" end
    return math.floor(s/3600).."h "..math.floor((s%3600)/60).."m"
end

-- ════════════════════════════════════════════════════════════
--  TAB: MAIN (Movimiento y Waypoints)
-- ════════════════════════════════════════════════════════════
local MSection = Tabs.Main:AddSection("Movement & Keybinds")

local SToggle = Tabs.Main:AddToggle("SpeedT", { Title = "Speed Hack", Default = false, Callback = function(v) Features.Enabled = v end })
Tabs.Main:AddKeybind("SpeedK", { Title = "Speed Key", Mode = "Toggle", Callback = function(v) SToggle:SetValue(v) end })
Tabs.Main:AddSlider("SpeedS", { Title = "Walk Speed", Default = 16, Min = 16, Max = 1000, Rounding = 0, Callback = function(v) Features.WalkSpeedValue = v end })

local FToggle = Tabs.Main:AddToggle("FlyT", { Title = "Fly Mode", Default = false, Callback = function(v) Features.ToggleFly(v) end })
Tabs.Main:AddKeybind("FlyK", { Title = "Fly Key", Mode = "Toggle", Callback = function(v) FToggle:SetValue(v) end })
Tabs.Main:AddSlider("FlyS", { Title = "Fly Speed", Default = 50, Min = 10, Max = 1000, Rounding = 0, Callback = function(v) Features.FlySpeed = v end })

local WSection = Tabs.Main:AddSection("Waypoints System")
local savedPoints, pointNames, selectedPoint, counter = {}, {}, nil, 1
local Dropdown = Tabs.Main:AddDropdown("WDrop", { Title = "Locations", Values = {"None"}, Callback = function(v) selectedPoint = v end })

Tabs.Main:AddButton({ Title = "Save Current Location", Callback = function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root and #pointNames < 10 then
        local name = "Point #"..counter
        savedPoints[name] = root.Position
        table.insert(pointNames, name)
        counter = counter + 1
        Dropdown:SetValues(pointNames)
        Dropdown:SetValue(name)
    end
end})

Tabs.Main:AddButton({ Title = "Teleport to Selected", Callback = function()
    if selectedPoint and savedPoints[selectedPoint] then
        local p = savedPoints[selectedPoint]
        Features.TeleportTo(p.X, p.Y, p.Z)
    end
end})

Tabs.Main:AddButton({ Title = "Delete Selected", Callback = function()
    if selectedPoint and savedPoints[selectedPoint] then
        savedPoints[selectedPoint] = nil
        local new = {}
        for _, n in ipairs(pointNames) do if n ~= selectedPoint then table.insert(new, n) end end
        pointNames = new
        Dropdown:SetValues(#pointNames == 0 and {"None"} or pointNames)
        Dropdown:SetValue(#pointNames == 0 and "None" or pointNames[1])
    end
end})

-- ════════════════════════════════════════════════════════════
--  TAB: PROFILE (RESTAURADO)
-- ════════════════════════════════════════════════════════════
Tabs.Profile:AddParagraph({
    Title = "Identity",
    Content = "  Username: "..player.Name.."\n  Display Name: "..player.DisplayName.."\n  User ID: "..player.UserId
})

local characterParagraph = Tabs.Profile:AddParagraph({ Title = "Character", Content = "Loading..." })
local networkParagraph = Tabs.Profile:AddParagraph({ Title = "Network & Performance", Content = "Loading..." })

-- ════════════════════════════════════════════════════════════
--  TAB: FULL INFO (RESTAURADO)
-- ════════════════════════════════════════════════════════════
Tabs.FullInfo:AddParagraph({
    Title = "System Info",
    Content = "  Executor: "..try(function() return identifyexecutor() end, "Unknown").."\n  Script: v1.1.2\n  UI: Fluent"
})

local runtimeParagraph = Tabs.FullInfo:AddParagraph({ Title = "Runtime Stats", Content = "Loading..." })

-- ════════════════════════════════════════════════════════════
--  ACTUALIZACIÓN EN VIVO (LOOP ORIGINAL)
-- ════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        local fps = round(1/dt)
        local ping = round(player:GetNetworkPing() * 1000)
        
        runtimeParagraph:SetDesc("  Uptime: "..formatUptime(tick()-startTick).."\n  FPS: "..fps.."\n  Ping: "..ping.."ms")
        networkParagraph:SetDesc("  FPS: "..fps.."\n  Ping: "..ping.."ms")
        
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            characterParagraph:SetDesc("  Health: "..round(hum.Health).."/"..round(hum.MaxHealth).."\n  WalkSpeed: "..round(hum.WalkSpeed))
        end
    end)
end)

Window:SelectTab(1)
Fluent:Notify({Title = "ViKo Hub", Content = "Todo restaurado y funcional", Duration = 5})
