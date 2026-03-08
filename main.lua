local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"))()
local Fluent, Window, Tabs = UI.Fluent, UI.Window, UI.Tabs

-- Carga de funciones externas (asegúrate de que este link sea correcto)
local Features = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/refs/heads/main/features.lua"))()

local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local startTick = tick()

-- SECCIÓN MAIN: MOVIMIENTO
local MSection = Tabs.Main:AddSection("Movement & Keybinds")

local SToggle = Tabs.Main:AddToggle("SpeedT", { Title = "Speed Hack", Default = false, Callback = function(v) Features.Enabled = v end })
Tabs.Main:AddKeybind("SpeedK", { Title = "Speed Keybind", Mode = "Toggle", Callback = function(v) SToggle:SetValue(v) end })
Tabs.Main:AddSlider("SpeedS", { Title = "Walk Speed", Default = 16, Min = 16, Max = 1000, Rounding = 0, Callback = function(v) Features.WalkSpeedValue = v end })

local FToggle = Tabs.Main:AddToggle("FlyT", { Title = "Fly Mode", Default = false, Callback = function(v) Features.ToggleFly(v) end })
Tabs.Main:AddKeybind("FlyK", { Title = "Fly Keybind", Mode = "Toggle", Callback = function(v) FToggle:SetValue(v) end })
Tabs.Main:AddSlider("FlyS", { Title = "Fly Speed", Default = 50, Min = 10, Max = 1000, Rounding = 0, Callback = function(v) Features.FlySpeed = v end })

-- SECCIÓN MAIN: WAYPOINTS
local WSection = Tabs.Main:AddSection("Waypoints System")
local savedPoints, pointNames, selectedPoint, counter = {}, {}, {}, 1
local Dropdown = Tabs.Main:AddDropdown("WDrop", { Title = "Saved Locations", Values = {"None"}, Callback = function(v) selectedPoint = v end })

Tabs.Main:AddButton({ Title = "Save Current Location", Callback = function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root and #pointNames < 10 then
        local name = "Point #" .. counter
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
        local newNames = {}
        for _, n in ipairs(pointNames) do if n ~= selectedPoint then table.insert(newNames, n) end end
        pointNames = newNames
        if #pointNames == 0 then
            Dropdown:SetValues({"None"})
            Dropdown:SetValue("None")
        else
            Dropdown:SetValues(pointNames)
            Dropdown:SetValue(pointNames[1])
        end
    end
end})

-- SECCIÓN PROFILE (Restaurada de tu archivo original)
local PSection = Tabs.Profile:AddSection("Identity & Session")
Tabs.Profile:AddParagraph({ Title = "User", Content = "Name: " .. player.Name .. "\nID: " .. player.UserId })
local charPara = Tabs.Profile:AddParagraph({ Title = "Character Stats", Content = "Loading..." })

-- SECCIÓN FULL INFO (Restaurada de tu archivo original)
local ISection = Tabs.FullInfo:AddSection("Execution Details")
local runPara = Tabs.FullInfo:AddParagraph({ Title = "Runtime Stats", Content = "Loading..." })

-- BUCLE DE ACTUALIZACIÓN
RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        local fps = math.floor(1/dt)
        local ping = math.floor(player:GetNetworkPing() * 1000)
        runPara:SetDesc("FPS: " .. fps .. "\nPing: " .. ping .. "ms\nUptime: " .. math.floor(tick()-startTick) .. "s")
        
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            charPara:SetDesc("Health: " .. math.floor(hum.Health) .. "\nSpeed: " .. math.floor(hum.WalkSpeed))
        end
    end)
end)

Window:SelectTab(1)
Fluent:Notify({Title = "ViKo Hub", Content = "Categorías reparadas", Duration = 5})
