local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"))()
local InstanceUI = UI:Init("ViKo Hub", "Windows 11 Edition")
local Tabs = InstanceUI:GetTabs()
local Fluent = InstanceUI:GetFluent()

local Player = game.Players.LocalPlayer

-- ==========================================
-- PESTAÑA DE INFORMACIÓN DE PERFIL (Doxeo)
-- ==========================================
Tabs.Profile:AddParagraph({
    Title = "Información del Usuario",
    Content = "Nombre: " .. Player.Name .. 
              "\nDisplayName: " .. Player.DisplayName ..
              "\nUserId: " .. Player.UserId ..
              "\nEdad de Cuenta: " .. Player.AccountAge .. " días" ..
              "\nMembership: " .. tostring(Player.MembershipType) ..
              "\nPaís (Región): " .. game:GetService("LocalizationService").RobloxLocaleId ..
              "\nPlatform: " .. (game:GetService("UserInputService"):GetPlatform() == Enum.Platform.Windows and "PC / Windows" or "Mobile/Other")
})

Tabs.Profile:AddParagraph({
    Title = "Datos de Red y Sistema",
    Content = "Ping:Calculando..." .. 
              "\nApp Version: " .. version() ..
              "\nPlaceId: " .. game.PlaceId ..
              "\nJobId: " .. game.JobId
})

-- ==========================================
-- PESTAÑA DE CONFIGURACIÓN
-- ==========================================
Tabs.Settings:AddKeybind("Keybind", {
    Title = "Tecla de Menú",
    Description = "Cambia la tecla para abrir/cerrar el Hub",
    Default = "LeftControl",
    ChangedCallback = function(NewKey)
        InstanceUI:GetWindow().MinimizeKey = NewKey
    end
})

Tabs.Settings:AddButton({
    Title = "Cerrar Interfaz",
    Description = "Elimina la UI por completo",
    Callback = function()
        Fluent:Destroy()
    end
})

Fluent:Notify({
    Title = "ViKo Hub",
    Content = "Módulo de Información y Configuración listos.",
    Duration = 5
})
