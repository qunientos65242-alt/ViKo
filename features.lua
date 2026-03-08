-- ============================================================
--  features.lua | Movimiento Pro (High IQ Edition) v4
-- ============================================================
local Features = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

Features.WalkSpeedValue = 16
Features.Enabled = false
Features.InfJump = false
Features.Noclip = false
Features.Fly = false
Features.FlySpeed = 50

local bv, bg
local flyConnection

-- Salto Infinito
UserInputService.JumpRequest:Connect(function()
    if Features.InfJump then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

-- Bucle de Noclip Inteligente (¡No tira la ropa!) y Speed
RunService.Stepped:Connect(function()
    local char = player.Character
    if not char then return end
    
    -- Noclip IQ: Solo afecta a las partes base del cuerpo, no a los accesorios
    if Features.Noclip then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
                part.CanCollide = false 
            end
        end
    end
    
    -- Speed
    if Features.Enabled and not Features.Fly then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Features.WalkSpeedValue end
    end
end)

-- Vuelo High IQ (PlatformStand + RenderStepped)
function Features.ToggleFly(state)
    Features.Fly = state
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if state and root and hum then
        hum.PlatformStand = true -- Evita animaciones raras y que te desarmes
        
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.zero
        bv.Parent = root

        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 9e4
        bg.CFrame = root.CFrame
        bg.Parent = root

        if flyConnection then flyConnection:Disconnect() end
        flyConnection = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local dir = Vector3.new(0,0,0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
            
            if dir.Magnitude > 0 then dir = dir.Unit end
            if bv and bg then
                bv.Velocity = dir * Features.FlySpeed
                bg.CFrame = cam.CFrame
            end
        end)
    else
        if hum then hum.PlatformStand = false end
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    end
end

-- Teletransporte Exacto
function Features.TeleportTo(x, y, z)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        -- Añadimos +3 en Y para evitar que te quedes atorado en el suelo
        root.CFrame = CFrame.new(tonumber(x), tonumber(y) + 3, tonumber(z))
    end
end

return Features
