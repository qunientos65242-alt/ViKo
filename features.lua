-- ============================================================
--  features.lua | v1.1.0 - HIGH IQ & FIXED
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

-- Bucle Noclip y Speed
RunService.Stepped:Connect(function()
    local char = player.Character
    if not char then return end
    
    if Features.Noclip then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
                part.CanCollide = false 
            end
        end
    end
    
    if Features.Enabled and not Features.Fly then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Features.WalkSpeedValue end
    end
end)

-- Vuelo Pulido
function Features.ToggleFly(state)
    Features.Fly = state
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if state and root and hum then
        hum.PlatformStand = true
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
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
            if dir.Magnitude > 0 then dir = dir.Unit end
            bv.Velocity = dir * Features.FlySpeed
            bg.CFrame = cam.CFrame
        end)
    else
        if hum then hum.PlatformStand = false end
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    end
end

function Features.TeleportTo(x, y, z)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(tonumber(x), tonumber(y) + 3, tonumber(z))
    end
end

return Features
