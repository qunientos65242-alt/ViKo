-- main.lua (Este es el que conectas a GitHub)
local UI = loadstring(game:HttpGet("TU_URL_DE_GITHUB_DE_LA_LIBRERIA"))()

local Window = UI:CreateWindow("ViKo Hub | Beta")

-- AQUÍ AGREGAS TUS OPCIONES SIN TOCAR EL DISEÑO
Window:AddButton("Activar Fly", function()
    print("El usuario activó Vuelo")
    -- Aquí pones tu código de Fly
end)

Window:AddButton("Velocidad x100", function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
end)

Window:AddButton("Infinito Salto", function()
    -- Tu lógica de salto aquí
end)
