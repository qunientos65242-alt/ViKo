-- ============================================================
--  features.lua | Funciones de Movimiento
-- ============================================================
local Features = {}

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Variables de estado
Features.WalkSpeedValue = 16 -- Velocidad por defecto de Roblox
Features.Enabled = false

-- Función para aplicar la velocidad
local function applySpeed()
    if not Features.Enabled then return end
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    if humanoid then
        humanoid.WalkSpeed = Features.WalkSpeedValue
    end
end

-- Bucle para asegurar que la velocidad se mantenga (por si el juego la resetea)
task.spawn(function()
    while task.wait(0.5) do
        if Features.Enabled then
            applySpeed()
        end
    end
end)

-- Resetear cuando el personaje reaparece
player.CharacterAdded:Connect(function()
    task.wait(1) -- Esperar a que cargue bien
    if Features.Enabled then
        applySpeed()
    end
end)

return Features
