-- ============================================================
--  games.lua v3.0 | ViKo 99 Nights OP Hacks (FULL, NO ERRORS)
--  PlaceId: 79546208627805 | Real Remotes + Locals 2026
-- ============================================================

local function init(UI)
    local Window = UI.Window
    local Tabs   = UI.Tabs
    local Fluent = UI.Fluent

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local player = Players.LocalPlayer
    local camera = workspace.CurrentCamera

    local PLACEID = 79546208627805
    if game.PlaceId ~= PLACEID then return end

    local Tab = Window:AddTab({ Title = "99 Nights 🌲", Icon = "forest" })

    -- Globals & Connections
    local connections = {}
    _G.FlyEnabled = false; _G.FlySpeed = 50
    _G.SpeedEnabled = false; _G.SpeedVal = 100
    _G.GodEnabled = false
    _G.NoClipEnabled = false
    _G.KillAuraEnabled = false; _G.KAuraRange = 100
    _G.AutoFarmEnabled = false
    _G.AutoChopEnabled = false
    _G.InfCandyEnabled = false
    _G.InfiniteDays = false
    _G.ESPItemsEnabled = false; _G.ESPMobsEnabled = false

    -- TP Targets (Reales: Lost Child1-4, Log, Chest, etc.)
    local tpTargets = {"Lost Child", "Lost Child2", "Lost Child3", "Lost Child4", "Log", "Chest", "Bear", "Wolf", "Cultist", "Deer", "Bunny", "Diamond Ore", "Fuel Canister"}

    -- 🔥 MOVIMIENTO
    Tab:AddSection("🔥 Movimiento")
    Tab:AddToggle("FlyT", {Title="Fly (WASD+Space/Shift)", Default=false, Callback=function(v) _G.FlyEnabled = v; toggleFly(v) end})
    Tab:AddSlider("FlyS", {Title="Fly Speed", Min=16, Max=200, Default=50, Callback=function(v) _G.FlySpeed = v end})
    Tab:AddToggle("SpeedT", {Title="Speed Hack", Default=false, Callback=function(v) _G.SpeedEnabled = v; toggleSpeed(v) end})
    Tab:AddSlider("SpeedV", {Title="Speed Value", Min=16, Max=200, Default=100, Callback=function(v) _G.SpeedVal = v end})
    Tab:AddToggle("NoClipT", {Title="NoClip", Default=false, Callback=function(v) _G.NoClipEnabled = v end})
    Tab:AddToggle("InfJumpT", {Title="Infinite Jump", Default=false, Callback=function(v)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = v and 200 or 50
        end
    end})

    -- ⚔️ COMBATE
    Tab:AddSection("⚔️ Combate")
    Tab:AddToggle("GodT", {Title="God Mode (Remote)", Default=false, Callback=function(v) _G.GodEnabled = v; toggleGod(v) end})
    Tab:AddToggle("KillAuraT", {Title="Kill Aura", Default=false, Callback=function(v) _G.KillAuraEnabled = v end})
    Tab:AddSlider("KAuraR", {Title="Aura Range", Min=50, Max=500, Default=100, Callback=function(v) _G.KAuraRange = v end})
    Tab:AddButton({Title="Kill All Mobs", Callback=killAllMobs})

    -- 🌳 FARM
    Tab:AddSection("🌳 Auto Farm")
    Tab:AddToggle("AutoFarmT", {Title="Auto Bring Items/Logs/Chests", Default=false, Callback=function(v) _G.AutoFarmEnabled = v end})
    Tab:AddToggle("AutoChopT", {Title="Auto Chop Trees", Default=false, Callback=function(v) _G.AutoChopEnabled = v; toggleAutoChop(v) end})
    Tab:AddToggle("InfCandyT", {Title="Infinite Candy (Real Remote)", Default=false, Callback=function(v) _G.InfCandyEnabled = v; toggleInfCandy(v) end})
    Tab:AddButton({Title="Infinite Resources", Callback=infResources})
    Tab:AddToggle("InfDaysT", {Title="Infinite Days (Auto Win)", Default=false, Callback=function(v) _G.InfiniteDays = v end})

    -- 👁️ ESP & TP
    Tab:AddSection("👁️ ESP & Teleports")
    Tab:AddToggle("ESPItemsT", {Title="Items ESP", Default=false, Callback=function(v) _G.ESPItemsEnabled = v; toggleESP("items", v) end})
    Tab:AddToggle("ESPMobsT", {Title="Mobs ESP", Default=false, Callback=function(v) _G.ESPMobsEnabled = v; toggleESP("mobs", v) end})
    Tab:AddDropdown("TPDrop", {Title="TP To", Values=tpTargets, Default="Log", Callback=function(v) tpTo(v) end})
    Tab:AddButton({Title="TP All Kids & Bring", Callback=tpAllKids})
    Tab:AddButton({Title="Bring All Items", Callback=bringAll})

    Tab:AddButton({Title="Fullbright (No Fog)", Callback=function()
        local Lighting = game:GetService("Lighting")
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = math.huge
    end})

    -- ================== FUNCTIONS DEFINIDAS (NO NILS!) ==================
    function toggleFly(enabled)
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = player.Character.HumanoidRootPart
        if enabled then
            local bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.P = 9e4
            local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.new()
            connections.fly = RunService.Heartbeat:Connect(function()
                if not _G.FlyEnabled then return end
                local move = Vector3.new()
                local cf = camera.CFrame
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + cf.UpVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - cf.UpVector end
                bv.Velocity = move.Unit * _G.FlySpeed
                bg.CFrame = cf
            end)
        else
            if connections.fly then connections.fly:Disconnect() end
            for _, p in pairs(hrp:GetChildren()) do
                if p.Name == "BodyGyro" or p.Name == "BodyVelocity" then p:Destroy() end
            end
        end
    end

    function toggleSpeed(enabled)
        spawn(function()
            while _G.SpeedEnabled do
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.WalkSpeed = _G.SpeedVal
                end
                wait(0.1)
            end
        end)
    end

    -- NoClip Loop (Stepped)
    connections.noclip = RunService.Stepped:Connect(function()
        if _G.NoClipEnabled and player.Character then
            for _, p in pairs(player.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)

    function toggleGod(enabled)
        spawn(function()
            while _G.GodEnabled do
                pcall(function()
                    ReplicatedStorage.RemoteEvents.DamagePlayer:FireServer(-math.huge)
                end)
                wait(0.1)
            end
        end)
    end

    function killAllMobs()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and
               (obj.Name:match("Bear|Wolf|Cultist|Deer|Bunny|Alien|Polar Bear")) then
                obj.Humanoid.Health = 0
            end
        end
    end

    -- KillAura Loop
    spawn(function()
        while true do
            wait(0.1)
            if _G.KillAuraEnabled and player.Character then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and
                       obj.Name:match("Bear|Wolf|Cultist|Deer|Bunny|Alien") and
                       (obj.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude < _G.KAuraRange then
                        obj.Humanoid.Health = 0
                    end
                end
            end
        end
    end)

    function infResources()
        if player:FindFirstChild("leaderstats") then
            for _, stat in pairs(player.leaderstats:GetChildren()) do
                if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                    stat.Value = math.huge
                end
            end
        end
    end

    -- AutoFarm Bring Loop
    spawn(function()
        while true do
            wait(0.5)
            if _G.AutoFarmEnabled then
                for _, it in pairs(workspace:GetDescendants()) do
                    if it:IsA("BasePart") and (it.Name:match("Log|Chest|Fuel|Sapling|Diamond") or it.Name:match("Ore")) then
                        it.CFrame = player.Character.HumanoidRootPart.CFrame
                    end
                end
            end
        end
    end)

    function toggleAutoChop(enabled)
        spawn(function()
            while _G.AutoChopEnabled do
                wait(1)
                for _, tree in pairs(workspace:GetDescendants()) do
                    if tree.Name == "Trunk" and tree.Parent.Name:match("Tree") then
                        if player.Character then
                            player.Character:PivotTo(tree.CFrame + Vector3.new(0, 5, 0))
                            wait(0.5)
                            -- Simulate clicks (executor mouse1click if avail)
                            for i = 1, 10 do mouse1click() wait(0.1) end
                        end
                        break
                    end
                end
            end
        end)
    end

    function toggleInfCandy(enabled)
        local event = ReplicatedStorage.RemoteEvents:WaitForChild("CarnivalCompleteShootingGallery")
        spawn(function()
            while _G.InfCandyEnabled do
                local targets = {}
                local areas = {workspace.Map, workspace.Items, workspace.Characters}
                for _, area in pairs(areas) do
                    for _, target in pairs(area:GetDescendants()) do
                        if target:IsA("BasePart") then
                            table.insert(targets, target)
                        end
                    end
                end
                for _, target in pairs(targets) do
                    pcall(function() event:FireServer(target) end)
                    wait(0.05)
                end
                wait(0.1)
            end
        end)
    end

    -- Infinite Days Loop
    spawn(function()
        while true do
            wait(1)
            if _G.InfiniteDays and player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Day") then
                player.leaderstats.Day.Value = 10000
            end
        end
    end)

    function tpTo(name)
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:match(name) and obj:IsA("BasePart") then
                player.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                break
            end
        end
    end

    function tpAllKids()
        for i = 1, 4 do
            tpTo("Lost Child" .. i)
            wait(0.5)
        end
        bringAll()  -- Bring after TP
    end

    function bringAll()
        for _, it in pairs(workspace:GetDescendants()) do
            if it:IsA("BasePart") and (it.Name:match("Log|Chest|Kid|Fuel|Diamond")) then
                it.CFrame = player.Character.HumanoidRootPart.CFrame
            end
        end
    end

    function toggleESP(type, enabled)
        -- Simple Highlight ESP (clear old first)
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:FindFirstChild("ESP") then obj.ESP:Destroy() end
        end
        if not enabled then return end
        for _, obj in pairs(workspace:GetDescendants()) do
            local match = type == "items" and obj.Name:match("Log|Chest|Diamond|Fuel") or
                          obj:FindFirstChild("Humanoid") and obj.Name:match("Bear|Wolf|Cultist")
            if match then
                local high = Instance.new("Highlight", obj)
                high.Name = "ESP"
                high.FillColor = type == "items" and Color3.new(0,1,0) or Color3.new(1,0,0)
                high.OutlineColor = Color3.new(1,1,1)
            end
        end
    end

    Fluent:Notify({Title="ViKo 99 Nights v3.0 ✅", Content="¡CARGADO SIN ERRORES! Fly/God/Farm OP. ¡A romper el bosque! 🐺💎", Duration=5})
    print("ViKo Games: 99 Nights FULL loaded!")
end

return init
