local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"))()
local InstanceUI = UI:Init("ViKo Hub", "Edición Windows 11")
local Tabs = InstanceUI:GetTabs()
local Fluent = InstanceUI:GetFluent()
local Window = InstanceUI:GetWindow()

local Player = game.Players.LocalPlayer

-- ==========================================
-- SECCIÓN DE PERFIL (TRADUCIDO)
-- ==========================================
local ProfileParagraph = Tabs.Profile:AddParagraph({
    Title = "Información del Usuario",
    Content = "Nombre de Usuario: " .. Player.Name .. 
              "\nNombre de Pantalla: " .. Player.DisplayName ..
              "\nID de Usuario: " .. Player.UserId ..
              "\nAntigüedad: " .. Player.AccountAge .. " días" ..
              "\nMembresía: " .. (tostring(Player.MembershipType):gsub("Enum.MembershipType.", "")) ..
              "\nIdioma/País: " .. game:GetService("LocalizationService").RobloxLocaleId ..
              "\nPlataforma: " .. (game:GetService("UserInputService"):GetPlatform() == Enum.Platform.Windows and "Computadora (Windows)" or "Dispositivo Móvil/Otro")
})

Tabs.Profile:AddParagraph({
    Title = "Datos de Red y Sistema",
    Content = "Servidor Actual (JobId): \n" .. game.JobId ..
              "\nID del Juego (PlaceId): " .. game.PlaceId ..
              "\nVersión del Cliente: " .. version()
})

-- ==========================================
-- SECCIÓN DE CONFIGURACIÓN (TECLA ARREGLADA)
-- ==========================================
Tabs.Settings:AddKeybind("MenuKeybind", {
    Title = "Tecla del Menú",
    Description = "Presiona una tecla para cambiar el acceso rápido",
    Default = "LeftControl",
    ChangedCallback = function(NewKey)
        -- Corregimos el problema de la tecla aquí:
        Window.MinimizeKey = NewKey
        Fluent:Notify({
            Title = "Configuración",
            Content = "Nueva tecla asignada: " .. tostring(NewKey):gsub("Enum.KeyCode.", ""),
            Duration = 3
        })
    end
})

Tabs.Settings:AddButton({
    Title = "Cerrar Completamente",
    Description = "Elimina la interfaz de la memoria",
    Callback = function()
        Fluent:Destroy()
    end
})

-- Notificación inicial en español
Fluent:Notify({
    Title = "ViKo Hub",
    Content = "Sistema iniciado correctamente. Usa Ctrl Izquierdo para minimizar.",
    Duration = 5
})
