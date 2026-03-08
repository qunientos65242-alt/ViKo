--[[
    ViKo Script - Versión Pro
    Cargado desde GitHub: https://github.com/qunientos65242-alt/ViKo
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "ViKo Hub " .. Fluent.Version,
    SubTitle = "por qunientos65242",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- Efecto de desenfoque moderno
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Tecla para ocultar la UI
})

-- Pestaña Principal
local Tabs = {
    Main = Window:AddTab({ Title = "Inicio", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Ajustes", Icon = "settings" })
}

-- Ejemplo de un Botón de prueba
Tabs.Main:AddButton({
    Title = "Avisar en Consola",
    Description = "Prueba si el script de GitHub carga bien",
    Callback = function()
        print("¡El script ViKo se está ejecutando desde GitHub!")
        Fluent:Notify({
            Title = "ViKo Hub",
            Content = "¡Conexión exitosa!",
            Duration = 5
        })
    end
})

-- Ejemplo de un Toggle (Interruptor)
Tabs.Main:AddToggle("WalkSpeedToggle", {Title = "Súper Velocidad", Default = false})

-- Lógica del Toggle
task.spawn(function()
    while true do
        if Fluent.Options.WalkSpeedToggle.Value then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
        task.wait(0.1)
    end
end)

-- Nueva Pestaña para Análisis
local ScanTab = Window:AddTab({ Title = "Analizador", Icon = "search" })

ScanTab:AddButton({
    Title = "Escanear Eventos del Juego",
    Description = "Busca RemoteEvents para crear funciones automáticas",
    Callback = function()
        print("--- Iniciando Escaneo de ViKo ---")
        local found = 0
        -- Buscamos en ReplicatedStorage (donde suelen estar los eventos)
        for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                print("Evento Encontrado: " .. obj.Name .. " | Ruta: " .. obj:GetFullName())
                found = found + 1
            end
        end
        
        Fluent:Notify({
            Title = "Escaneo Finalizado",
            Content = "Se encontraron " .. found .. " eventos. Revisa la consola (F9).",
            Duration = 5
        })
    end
})

ScanTab:AddButton({
    Title = "Listar Jugadores y Propiedades",
    Description = "Analiza la jerarquía de los jugadores actuales",
    Callback = function()
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            print("Jugador: " .. player.Name .. " | ID: " .. player.UserId)
        end
    end
})

Window:SelectTab(1)
