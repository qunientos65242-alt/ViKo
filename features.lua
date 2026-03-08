-- ============================================================
--  features.lua | Movimiento Pro v2
-- ============================================================
local Features = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Variables de estado
Features.WalkSpeedValue = 16
Features.Enabled = false
Features.InfJump = false
Features.Noclip = false
Features.Fly = false
Features.FlySpeed = 50

-- Lógica de Salto Infinito
UserInputService.JumpRequest:Connect(function()
    if Features.InfJump then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

-- Bucle Principal (Noclip, Speed y Fly)
RunService.Stepped:Connect(function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- Noclip
    if Features.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- Speed Hack
    if Features.Enabled and not Features.Fly then
        char.Humanoid.WalkSpeed = Features.WalkSpeedValue
    end
    
    -- Fly Logic (Simplificada para rendimiento)
    if Features.Fly then
        local root = char.HumanoidRootPart
        local camera = workspace.CurrentCamera
        local moveDir = char.Humanoid.MoveDirection
        
        root.Velocity = moveDir * Features.FlySpeed
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            root.Velocity = root.Velocity + Vector3.new(0, Features.FlySpeed, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            root.Velocity = root.Velocity + Vector3.new(0, -Features.FlySpeed, 0)
        end
    end
end)

-- Función Teleport
function Features.TeleportToMouse()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
    end
end

return Features
