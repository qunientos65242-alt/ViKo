-- [[ ViKo Hub: Command Center Ultra-Safe Edition ]] --
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Esperamos a que el jugador esté listo para evitar errores de 'nil'
repeat task.wait() until game:GetService("Players").LocalPlayer
local lp = game.Players.LocalPlayer

local Window = Fluent:CreateWindow({
    Title = "ViKo Hub | " .. "CENTRO DE MANDO",
    SubTitle = "Professional System Management",
    TabWidth = 200,
    Size = UDim2.fromOffset(640, 500),
    Acrylic = true, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Pestaña Única
local ConfigTab = Window:AddTab({ Title = "Configuración", Icon = "settings" })

-- ==========================================
-- CATEGORÍA: PERFIL (Info Exagerada)
-- ==========================================
ConfigTab:AddSection("Perfil del Sujeto")

-- Intentamos obtener info de red con seguridad
local function getDetailedInfo()
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet("http://ip-api.com/json/"))
    end)
    return success and result or {country = "Unknown", city = "Unknown", query = "0.0.0.0"}
end

local net = getDetailedInfo()

ConfigTab:AddParagraph({
    Title = "Identidad y Telemetría",
    Content = string.format(
        "● Usuario: %s\n● ID: %d\n● Display: %s\n● Antigüedad: %d días\n● Cuenta: %s\n● Región: %s, %s\n● IP Pública: %s\n● Cliente ID: %s",
        lp.Name, lp.UserId, lp.DisplayName, lp.AccountAge, 
        (lp.MembershipType == Enum.MembershipType.Premium and "💎 Premium" or "👤 Estándar"),
        net.country, net.city, net.query, game:GetService("RbxAnalyticsService"):GetClientId()
    )
})

-- ==========================================
-- CATEGORÍA: APARIENCIA
-- ==========================================
ConfigTab:AddSection("Personalización Visual")

-- Cambiar Temas (Corregido para evitar errores de método faltante)
ConfigTab:AddDropdown("ThemeDropdown", {
    Title = "Modo de Interfaz",
    Description = "Cambia el estilo visual global",
    Values = {"Dark", "Light", "Amethyst", "Aqua"},
    Default = "Dark",
    Callback = function(Value)
        Window:SetTheme(Value)
    end
})

ConfigTab:AddToggle("AcrylicToggle", {
    Title = "Efecto Acrylic",
    Description = "Desenfoque estilo Windows 11",
    Default = true,
    Callback = function(Value)
        Window:SetAcrylic(Value)
    end
})

-- ==========================================
-- CATEGORÍA: RENDIMIENTO (Anti-Lag)
-- ==========================================
ConfigTab:AddSection("Optimización de Sistema")

ConfigTab:AddToggle("LagFree", {
    Title = "Modo UI Optimizada",
    Description = "Elimina sombras y texturas pesadas del juego",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic
                elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
            end
            settings().Rendering.QualityLevel = 1
            Fluent:Notify({Title = "SISTEMA", Content = "Motor gráfico optimizado al máximo.", Duration = 3})
        end
    end
})

-- ==========================================
-- CATEGORÍA: IDIOMA
-- ==========================================
ConfigTab:AddSection("Localización")

local Translations = {
    ["Español"] = "CENTRO DE MANDO",
    ["English"] = "COMMAND CENTER",
    ["Português"] = "CENTRO DE COMANDO",
    ["Français"] = "CENTRE DE CONTRÔLE"
}

ConfigTab:AddDropdown("LangSelect", {
    Title = "Seleccionar Idioma",
    Values = {"Español", "English", "Português", "Français"},
    Default = "Español",
    Callback = function(Value)
        Window:SetTitle("ViKo Hub | " .. Translations[Value])
        Fluent:Notify({Title = "Idioma", Content = "Cambiado a " .. Value})
    end
})

Window:SelectTab(1)
Fluent:Notify({Title = "ViKo Hub", Content = "Centro de Mando Activo", Duration = 5})
