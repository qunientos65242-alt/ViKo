-- ============================================================
--  features.lua | Movimiento Pro
-- ============================================================
local Features = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Features.InfJump then
        local char = player.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

-- Lógica de Noclip y Velocidad (Bucle principal)
RunService.Stepped:Connect(function()
    local char = player.Character
    if not char then return end

    -- Noclip
    if Features.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Velocidad constante
    if Features.Enabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Features.WalkSpeedValue end
    end
end)

-- Función Teleport (Click para teletransportarse)
function Features.TeleportToMouse()
    local char = player.Character
    if char and mouse.Hit then
        char:MoveTo(mouse.Hit.p)
    end
end

return Features
