-- ============================================================
--  main.lua | v1.1.1 - CATEGORIES FIXED
-- ============================================================
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"))()
local Fluent, Window, Tabs = UI.Fluent, UI.Window, UI.Tabs

local Features = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/refs/heads/main/features.lua"))()

local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local startTick = tick()

-- ── SECCIÓN MOVIMIENTO (Pestaña Main) ───────────────────────
local MSection = Tabs.Main:AddSection("Movement & Keybinds")

local SToggle = Tabs.Main:AddToggle("SpeedT", { Title = "Speed Hack", Default = false, Callback = function(v) Features.Enabled = v end })
Tabs.Main:AddKeybind("SpeedK", { Title = "Speed Key", Mode = "Toggle", Callback = function(v) SToggle:SetValue(v) end })
Tabs.Main:AddSlider("SpeedS", { Title = "Walk Speed", Default = 16, Min = 16, Max = 1000, Rounding = 0, Callback = function(v) Features.WalkSpeedValue = v end })

local FToggle = Tabs.Main:AddToggle("FlyT", { Title = "Fly Mode (Stable)", Default = false, Callback = function(v) Features.ToggleFly(v) end })
Tabs.Main:AddKeybind("FlyK", { Title = "Fly Key", Mode = "Toggle", Callback = function(v) FToggle:SetValue(v) end })
Tabs.Main:AddSlider("FlyS", { Title = "Fly Speed", Default = 50, Min = 10, Max = 1000, Rounding = 0, Callback = function(v) Features.FlySpeed = v end })

-- ── WAYPOINTS (Pestaña Main) ────────────────────────────────
local WSection = Tabs.Main:AddSection("Waypoints System")
local savedPoints, pointNames, selectedPoint, counter = {}, {}, "None", 1
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

Tabs.Main:AddButton({ Title = "Teleport / Delete Selected", Callback = function()
    if selectedPoint and savedPoints[selectedPoint] then
        local p = savedPoints[selectedPoint]
        Features.TeleportTo(p.X, p.Y, p.Z)
    end
end})

-- ── PESTAÑA PROFILE (Identidad) ──────────────────────────────
local PSection = Tabs.Profile:AddSection("Player Data")
Tabs.Profile:AddParagraph({ Title = "Username", Content = player.Name .. " (" .. player.UserId .. ")" })
local charStats = Tabs.Profile:AddParagraph({ Title = "Live Stats", Content = "Loading..." })

-- ── PESTAÑA FULL INFO (Sistema) ─────────────────────────────
local ISection = Tabs.FullInfo:AddSection("Execution Info")
local systemPara = Tabs.FullInfo:AddParagraph({ Title = "System", Content = "Checking..." })

-- ── BUCLE DE ACTUALIZACIÓN ──────────────────────────────────
RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        local fps = math.floor(1/dt)
        local ping = math.floor(player:GetNetworkPing() * 1000)
        systemPara:SetDesc("FPS: "..fps.."\nPing: "..ping.."ms\nUptime: "..math.floor(tick()-startTick).."s")
        
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            charStats:SetDesc("Health: "..math.floor(hum.Health).."\nSpeed: "..math.floor(hum.WalkSpeed))
        end
    end)
end)

Window:SelectTab(1)
Fluent:Notify({Title = "ViKo Hub", Content = "Categorías reparadas exitosamente", Duration = 5})
