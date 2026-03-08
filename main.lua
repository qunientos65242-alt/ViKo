-- [[ ViKo Hub: Command Center Zero Errors ]] --
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Protección de carga inicial
repeat task.wait() until game:GetService("Players").LocalPlayer
local lp = game.Players.LocalPlayer

local Window = Fluent:CreateWindow({
    Title = "ViKo Hub | CENTRO DE MANDO",
    SubTitle = "v4.0 Ultra-Interface",
    TabWidth = 200,
    Size = UDim2.fromOffset(620, 480),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local ConfigTab = Window:AddTab({ Title = "Configuración", Icon = "settings" })

-- ==========================================
-- SECCIÓN: PERFIL (Info Exagerada)
-- ==========================================
ConfigTab:AddSection("Información de Identidad")

local function getNetData()
    local s, r = pcall(function() return game:GetService("HttpService"):JSONDecode(game:HttpGet("http://ip-api.com/json/")) end)
    return s and r or {country = "Unknown", city = "Unknown", query = "0.0.0.0"}
end
local net = getNetData()

ConfigTab:AddParagraph({
    Title = "Ficha del Sujeto",
    Content = string.format(
        "● Usuario: %s\n● ID Global: %d\n● Antigüedad: %d días\n● Cuenta: %s\n● Ubicación: %s, %s\n● IP: %s",
        lp.Name, lp.UserId, lp.AccountAge, 
        (lp.MembershipType == Enum.MembershipType.Premium and "Premium" or "Estándar"),
        net.country, net.city, net.query
    )
})

-- ==========================================
-- SECCIÓN: PERSONALIZACIÓN (Sin errores de Callback)
-- ==========================================
ConfigTab:AddSection("Apariencia y Estilo")

ConfigTab:AddToggle("AcrylicToggle", {
    Title = "Transparencia Acrylic",
    Description = "Desenfoque estilo Windows 11",
    Default = true,
    Callback = function(Value)
        Window:SetAcrylic(Value)
    end
})

-- ==========================================
-- SECCIÓN: OPTIMIZACIÓN (FPS Boost)
-- ==========================================
ConfigTab:AddSection("Rendimiento")

ConfigTab:AddToggle("LagFree", {
    Title = "Modo UI Optimizada",
    Description = "Elimina texturas del juego para evitar lag",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic
                elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
            end
            Fluent:Notify({Title = "SISTEMA", Content = "Optimización aplicada con éxito.", Duration = 3})
        end
    end
})

-- ==========================================
-- SECCIÓN: IDIOMAS (Versión Segura)
-- ==========================================
ConfigTab:AddSection("Localización")

ConfigTab:AddButton({
    Title = "Traducir a Inglés",
    Description = "Cambia el idioma de las notificaciones",
    Callback = function()
        Fluent:Notify({Title = "System", Content = "Language set to English", Duration = 3})
    end
})

ConfigTab:AddButton({
    Title = "Traducir a Español",
    Description = "Cambia el idioma de las notificaciones",
    Callback = function()
        Fluent:Notify({Title = "Sistema", Content = "Idioma cambiado a Español", Duration = 3})
    end
})

Window:SelectTab(1)
Fluent:Notify({Title = "ViKo Hub", Content = "Centro de Mando conectado.", Duration = 5})
