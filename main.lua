-- Cargamos la UI desde tu repositorio
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"))()

-- Creamos la interfaz
local Window = Library:CreateWindow("ViKo Hub | Versión 2026")

-- Aquí agregas tus hacks por separado
Window:AddButton("Velocidad x100", function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
end)

Window:AddButton("Salto Infinito", function()
    -- Lógica de salto
end)
