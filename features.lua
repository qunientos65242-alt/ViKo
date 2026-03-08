-- ============================================================
--  features.lua | Movimiento Pro Pulido v3
-- ============================================================
local Features = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Variables de estado
Features.WalkSpeedValue = 16
Features.Enabled = false
Features.InfJump = false
Features.Noclip = false
Features.Fly = false
Features.FlySpeed = 50

local bv, bg -- Objetos para el vuelo

-- Lógica de Salto Infinito
UserInputService.JumpRequest:Connect(function()
    if Features.InfJump then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

-- Bucle de Noclip y Speed
RunService.Stepped:Connect(function()
    local char = player.Character
    if not char then return end
    if Features.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    if Features.Enabled and not Features.Fly then
        char.Humanoid.WalkSpeed = Features.WalkSpeedValue
    end
end)

-- Vuelo Pulido (Sin caídas)
task.spawn(function()
    while true do
        task.wait()
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if Features.Fly and root then
            if not bv then
                bv = Instance.new("BodyVelocity", root)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bg = Instance.new("BodyGyro", root)
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bg.P = 9e4
            end
            
            local cam = workspace.CurrentCamera
            local dir = Vector3.new(0,0,0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
            
            bv.Velocity = dir * Features.FlySpeed
            bg.CFrame = cam.CFrame
        else
            if bv then bv:Destroy() bv = nil end
            if bg then bg:Destroy() bg = nil end
        end
    end
end)

-- Teletransporte por Coordenadas
function Features.TeleportTo(x, y, z)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
    end
end

return Features
