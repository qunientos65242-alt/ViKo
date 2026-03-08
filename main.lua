-- Cargamos tu librería separada
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"))()

-- Inicializamos el Hub (Nombre y Subtítulo)
local Hub = UI:Init("ViKo Hub", "by qunientos")

-- Creamos pestañas estilo Windows 11
local MainTab = Hub:CreateTab("Principal", "home")
local PlayerTab = Hub:CreateTab("Jugador", "user")

-- Añadimos funciones a la pestaña Principal
MainTab:AddButton("Velocidad x100", "Corre como flash", function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
end)

-- Añadimos funciones a la pestaña Jugador
PlayerTab:AddButton("Salto Infinito", "Salta sin tocar el suelo", function()
    print("Salto activado")
    -- Tu lógica de salto aquí
end)
