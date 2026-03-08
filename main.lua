local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"))()
local InstanceUI = UI:Init("ViKo Hub", "Configuración de Sistema")

local Tabs = InstanceUI:GetTabs()
local Fluent = InstanceUI:GetFluent()
local Window = InstanceUI:GetWindow()

-- ==========================================
-- ÚNICA SECCIÓN: CONFIGURACIÓN
-- ==========================================

Tabs.Settings:AddKeybind("KeybindMenu", {
    Title = "Tecla de Apertura/Cierre",
    Description = "Haz clic y presiona cualquier tecla (Ej: F, G, RightControl)",
    Default = "LeftControl",
    ChangedCallback = function(NewKey)
        -- Forzamos la actualización en el motor de la UI
        Window.MinimizeKey = NewKey
        
        -- Feedback visual para confirmar que la tecla se registró
        Fluent:Notify({
            Title = "Sistema de Teclas",
            Content = "Tecla actualizada a: " .. tostring(NewKey):gsub("Enum.KeyCode.", ""),
            Duration = 3
        })
    end
})

Tabs.Settings:AddButton({
    Title = "Cerrar Script",
    Description = "Elimina la interfaz por completo",
    Callback = function()
        Fluent:Destroy()
    end
})

-- Notificación de seguridad
Fluent:Notify({
    Title = "ViKo Hub",
    Content = "Apartado de Perfil eliminado. Solo queda Configuración.",
    Duration = 5
})
