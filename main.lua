-- ============================================================
--  main.lua | ViKo Script Hub v1.1.0 - FIXED CATEGORIES
-- ============================================================

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"))()
local Fluent, Window, Tabs = UI.Fluent, UI.Window, UI.Tabs

local Features = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/refs/heads/main/features.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local player = Players.LocalPlayer
local startTick = tick()

-- ── FUNCIONES DE AYUDA ──────────────────────────────────────
local function round(n) return math.floor(n + 0.5) end
local function formatUptime(s)
    s = math.floor(s)
    if s < 60 then return s.."s" end
    if s < 3600 then return math.floor(s/60).."m ".. (s%60).."s" end
    return math.floor(s/3600).."h "..math.floor((s%3600)/60).."m"
end

-- ════════════════════════════════════════════════════════════
--  CATEGORÍA: MAIN (MOVIMIENTO)
-- ════════════════════════════════════════════════════════════
local MSection = Tabs.Main:AddSection("Movement Enhancements")

local SToggle = Tabs.Main:AddToggle("SpeedT", { Title = "Speed Hack", Default = false, Callback = function(v) Features.Enabled = v end })
Tabs.Main:AddKeybind("SpeedK", { Title = "Key: Speed", Mode = "Toggle", Callback = function(v) SToggle:SetValue(v) end })
Tabs.Main:AddSlider("SpeedS", { Title = "Speed Value", Default = 16, Min = 16, Max = 1000, Rounding = 0, Callback = function(v) Features.WalkSpeedValue = v end })

local FToggle = Tabs.Main:AddToggle("FlyT", { Title = "Fly Mode", Default = false, Callback = function(v) Features.ToggleFly(v) end })
Tabs.Main:AddKeybind("FlyK", { Title = "Key: Fly", Mode = "Toggle", Callback = function(v) FToggle:SetValue(v) end })
Tabs.Main:AddSlider("FlyS", { Title = "Fly Speed", Default = 50, Min = 10, Max = 1000, Rounding = 0, Callback = function(v) Features.FlySpeed = v end })

local JToggle = Tabs.Main:AddToggle("JumpT", { Title = "Inf Jump", Default = false, Callback = function(v) Features.InfJump = v end })
Tabs.Main:AddKeybind("JumpK", { Title = "Key: Jump", Mode = "Toggle", Callback = function(v) JToggle:SetValue(v) end })

local NToggle = Tabs.Main:AddToggle("NoclipT", { Title = "Noclip", Default = false, Callback = function(v) Features.Noclip = v end })
Tabs.Main:AddKeybind("NoclipK", { Title = "Key: Noclip", Mode = "Toggle", Callback = function(v) NToggle:SetValue(v) end })

-- ── WAYPOINTS ───────────────────────────────────────────────
local WSection = Tabs.Main:AddSection("Waypoints (Max 10)")
local savedPoints, pointNames, selectedPoint, counter = {}, {}, nil, 1

local WDropdown = Tabs.Main:AddDropdown("WDrop", { Title = "Saved Locations", Values = pointNames, Callback = function(v) selectedPoint = v end })

Tabs.Main:AddButton({ Title = "Save Current Location", Callback = function()
    if #pointNames >= 10 then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local name = "Point #"..counter
        savedPoints[name] = {x = root.Position.X, y = root.Position.Y, z = root.Position.Z}
        table.insert(pointNames, name)
        counter = counter + 1
        WDropdown:SetValues(pointNames)
        WDropdown:SetValue(name)
    end
end})

Tabs.Main:AddButton({ Title = "Teleport to Selected", Callback = function()
    local c = savedPoints[selectedPoint]
    if c then Features.TeleportTo(c.x, c.y, c.z) end
end})

Tabs.Main:AddButton({ Title = "Delete Point", Callback = function()
    if not selectedPoint then return end
    savedPoints[selectedPoint] = nil
    local new = {}
    for _, n in ipairs(pointNames) do if n ~= selectedPoint then table.insert(new, n) end end
    pointNames = new
    if #pointNames == 0 then
        WDropdown:SetValues({"None"})
        WDropdown:SetValue("None")
    else
        WDropdown:SetValues(pointNames)
        WDropdown:SetValue(pointNames[1])
    end
end})

-- ════════════════════════════════════════════════════════════
--  CATEGORÍA: PROFILE
-- ════════════════════════════════════════════════════════════
local PSection = Tabs.Profile:AddSection("User Info")
Tabs.Profile:AddParagraph({ Title = "Identity", Content = "User: "..player.Name.."\nID: "..player.UserId })
local charPara = Tabs.Profile:AddParagraph({ Title = "Character Stats", Content = "Loading..." })

-- ════════════════════════════════════════════════════════════
--  CATEGORÍA: FULL INFO
-- ════════════════════════════════════════════════════════════
local ISection = Tabs.FullInfo:AddSection("System Details")
local runPara = Tabs.FullInfo:AddParagraph({ Title = "Runtime", Content = "Loading..." })

-- ════════════════════════════════════════════════════════════
--  CATEGORÍA: SETTINGS
-- ════════════════════════════════════════════════════════════
Tabs.Settings:AddDropdown("Theme", { Title = "Theme", Values = {"Dark", "Light", "Aqua", "Amethyst"}, Default = "Dark", Callback = function(v) Fluent:SetTheme(v) end })

-- ── LOOP DE ACTUALIZACIÓN ───────────────────────────────────
RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        local fps = round(1/dt)
        local ping = round(player:GetNetworkPing()*1000)
        runPara:SetDesc("Uptime: "..formatUptime(tick()-startTick).."\nFPS: "..fps.."\nPing: "..ping.."ms")
        
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            charPara:SetDesc("Health: "..round(hum.Health).."\nSpeed: "..round(hum.WalkSpeed))
        end
    end)
end)

Window:SelectTab(1)
Fluent:Notify({Title = "ViKo Hub", Content = "All categories FIXED!", Duration = 5})
