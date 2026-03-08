local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"))()

-- Esto solo abre la ventana vacía
local InstanceUI = UI:Init("ViKo Hub", "Lienzo Vacío")

local Fluent = InstanceUI:GetFluent()
local Window = InstanceUI:GetWindow()

-- Notificación de que el sistema está listo para recibir código
Fluent:Notify({
    Title = "ViKo Hub",
    Content = "Interfaz cargada sin módulos activos.",
    Duration = 5
})
