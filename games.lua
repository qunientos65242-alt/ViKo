-- ============================================================
--  games.lua  |  ViKo Game-Specific Hacks
--  Modular: Carga tabs por PlaceId. Empieza con 99 Nights in the Forest.
--  Repo: https://github.com/qunientos65242-alt/ViKo
-- ============================================================

local function init(UI)
    local Window = UI.Window
    local Tabs   = UI.Tabs
    local Fluent = UI.Fluent

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer

    local PLACEID_99NIGHTS = 79546208627805  -- 99 Nights in the Forest

    if game.PlaceId ~= PLACEID_99NIGHTS then return end  -- Solo carga en el juego

    local Tab99 = Window:AddTab({ Title = "99 Nights", Icon = "forest" })  -- Icon custom si querés

    -- ── Globals pa toggles ─────────────────────────────────────
    _G.FlyEnabled = false
    _G.SpeedEnabled = false
    _G.GodEnabled = false
    _G.NoClipEnabled = false
    _G.KillAuraEnabled = false
    _G.AutoWoodEnabled = false
    _G.AutoDiamondEnabled = false
    _G.InfiniteDaysEnabled = false
    -- Más...

    -- ── SECCIÓN MOVIMIENTO ─────────────────────────────────────
    Tab99:AddSection("🔥 Movimiento")

    Tab99:AddToggle("FlyToggle", {
        Title = "Fly (F para toggle)",
        Default = false,
        Callback = function(enabled)
            _G.FlyEnabled = enabled
            local char = player.Character
            if not char then return end
            local mouse = player:GetMouse()
            _G.FlySpeed = 50
            spawn(function()
                while _G.FlyEnabled do
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (mouse.Hit.LookVector * _G.FlySpeed / 100)
                    end
                    wait()
                end
            end)
        end
    })

    Tab99:AddSlider("FlySpeed", {
        Title = "Fly Speed",
        Min = 16,
        Max = 100,
        Default = 50,
        Callback = function(value)
            _G.FlySpeed = value
        end
    })

    Tab99:AddToggle("SpeedToggle", {
        Title = "Speed x100",
        Default = false,
        Callback = function(enabled)
            _G.SpeedEnabled = enabled
            spawn(function()
                while _G.SpeedEnabled do
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.WalkSpeed = enabled and 100 or 16
                    end
                    wait(0.1)
                end
            end)
        end
    })

    Tab99:AddToggle("NoClipToggle", {
        Title = "NoClip",
        Default = false,
        Callback = function(enabled)
            _G.NoClipEnabled = enabled
            spawn(function()
                while _G.NoClipEnabled do
                    if player.Character then
                        for _, part in pairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end
                    wait()
                end
            end)
        end
    })

    Tab99:AddButton({
        Title = "TP to Kids",
        Callback = function()
            for _, kid in pairs(workspace:GetChildren()) do
                if kid.Name:find("Kid") and kid:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = kid.HumanoidRootPart.CFrame * CFrame.new(0,5,0)
                end
            end
        end
    })

    -- ── SECCIÓN COMBATE ────────────────────────────────────────
    Tab99:AddSection("⚔️ Combate")

    Tab99:AddToggle("GodToggle", {
        Title = "God Mode",
        Default = false,
        Callback = function(enabled)
            _G.GodEnabled = enabled
            spawn(function()
                while _G.GodEnabled do
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.Health = math.huge
                    end
                    wait(0.1)
                end
            end)
        end
    })

    Tab99:AddToggle("KillAuraToggle", {
        Title = "Kill Aura (50 studs)",
        Default = false,
        Callback = function(enabled)
            _G.KillAuraEnabled = enabled
            spawn(function()
                while _G.KillAuraEnabled do
                    for _, mob in pairs(workspace:GetChildren()) do
                        if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Name ~= player.Name then
                            local dist = (mob.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                            if dist < 50 then mob.Humanoid.Health = 0 end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    })

    Tab99:AddButton({
        Title = "Kill All Mobs",
        Callback = function()
            for _, mob in pairs(workspace:GetChildren()) do
                if mob:FindFirstChild("Humanoid") and mob.Name:find("Deer") or mob.Name:find("Owl") or mob.Name:find("Cultist") then
                    mob.Humanoid.Health = 0
                end
            end
        end
    })

    -- ── SECCIÓN FARM ──────────────────────────────────────────
    Tab99:AddSection("🌳 Auto Farm")

    Tab99:AddToggle("AutoWoodToggle", {
        Title = "Auto Chop Wood",
        Default = false,
        Callback = function(enabled)
            _G.AutoWoodEnabled = enabled
            -- Ajusta remote si cambia: usa SimpleSpy
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            spawn(function()
                while _G.AutoWoodEnabled do
                    pcall(function()
                        ReplicatedStorage.RemoteEvents.ChopTree:FireServer()  -- Generic, chequea con spy
                    end)
                    wait(0.1)
                end
            end)
        end
    })

    Tab99:AddToggle("AutoDiamondToggle", {
        Title = "Auto Farm Diamonds",
        Default = false,
        Callback = function(enabled)
            _G.AutoDiamondEnabled = enabled
            spawn(function()
                while _G.AutoDiamondEnabled do
                    pcall(function()
                        game.ReplicatedStorage.RemoteEvents.MineDiamond:FireServer()
                    end)
                    wait(0.05)
                end
            end)
        end
    })

    Tab99:AddButton({
        Title = "Infinite Resources",
        Callback = function()
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                for _, stat in pairs(leaderstats:GetChildren()) do
                    if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                        stat.Value = math.huge
                    end
                end
            end
        end
    })

    Tab99:AddToggle("InfiniteDaysToggle", {
        Title = "Infinite Days (Win Auto)",
        Default = false,
        Callback = function(enabled)
            _G.InfiniteDaysEnabled = enabled
            spawn(function()
                while _G.InfiniteDaysEnabled do
                    local leaderstats = player:FindFirstChild("leaderstats")
                    if leaderstats and leaderstats:FindFirstChild("Day") then
                        leaderstats.Day.Value = 10000
                    end
                    wait(1)
                end
            end)
        end
    })

    -- ── MISC / VISUALES ───────────────────────────────────────
    Tab99:AddSection("👁️ ESP & Misc")

    Tab99:AddToggle("FullbrightToggle", {
        Title = "Fullbright",
        Default = false,
        Callback = function(enabled)
            local Lighting = game:GetService("Lighting")
            if enabled then
                Lighting.Brightness = 3
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
            else
                Lighting.Brightness = 1
                Lighting.ClockTime = 12  -- Night default?
                Lighting.FogEnd = 100
            end
        end
    })

    Tab99:AddButton({
        Title = "Bring All Items",
        Callback = function()
            for _, item in pairs(workspace:GetChildren()) do
                if item:IsA("Model") or item:IsA("Part") and item.Name:find("Wood") or item.Name:find("Diamond") then
                    item.CFrame = player.Character.HumanoidRootPart.CFrame
                end
            end
        end
    })

    Tab99:AddButton({
        Title = "Auto Rescue Kids",
        Callback = function()
            pcall(function()
                game.ReplicatedStorage.RemoteEvents.RescueKid:FireServer()
            end)
        end
    })

    Fluent:Notify({
        Title = "ViKo Loaded!",
        Content = "99 Nights hacks activados. ¡Farméa como dios! 🐺",
        Duration = 5
    })

    print("ViKo Games: 99 Nights tab loaded!")
end

return init
