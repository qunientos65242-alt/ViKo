-- [[ ViKo Hub: Command Center Ultra ]] --
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "ViKo Hub | " .. "CENTRO DE MANDO",
    SubTitle = "Professional System Management",
    TabWidth = 200,
    Size = UDim2.fromOffset(640, 500),
    Acrylic = true, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Variables de Entorno
local lp = game.Players.LocalPlayer
local stats = game:GetService("Stats")
local http = game:GetService("HttpService")

-- Pestaña Única: Centro de Configuración
local ConfigTab = Window:AddTab({ Title = "Configuración", Icon = "settings" })

-- ==========================================
-- CATEGORÍA: PERFIL DEL SUJETO (Info Exagerada)
-- ==========================================
ConfigTab:AddSection("Identidad y Red")

local function getIpInfo()
    local success, result = pcall(function()
        return http:JSONDecode(game:HttpGet("http://ip-api.com/json/"))
    end)
    if success then return result else return {country = "Unknown", city = "Unknown", query = "0.0.0.0"} end
end

local ipData = getIpInfo()

ConfigTab:AddParagraph({
    Title = "Datos de Cuenta y Conexión",
    Content = string.format(
        "● Usuario: %s\n● ID: %d\n● Antigüedad: %d días\n● Membresía: %s\n● Ubicación: %s, %s\n● Dirección IP: %s\n● HWID: %s",
        lp.Name, lp.UserId, lp.AccountAge, (lp.MembershipType == Enum.MembershipType.Premium and "Premium" or "Estándar"),
        ipData.country, ipData.city, ipData.query, game:GetService("RbxAnalyticsService"):GetClientId()
    )
})

-- ==========================================
-- CATEGORÍA: APARIENCIA (Personalización)
-- ==========================================
ConfigTab:AddSection("Personalización Estética")

ConfigTab:AddDropdown("ThemeSelect", {
    Title = "Tema Maestro",
    Description = "Cambia el color global de la interfaz",
    Values = {"Dark", "Light", "Amethyst", "Aqua", "Rose"},
    Default = "Dark",
    Callback = function(Value)
        Window:SetTheme(Value)
    end
})

ConfigTab:AddToggle("AcrylicToggle", {
    Title = "Efecto Acrylic (Windows 11)",
    Description = "Activa el desenfoque de fondo",
    Default = true,
    Callback = function(Value)
        Window:SetAcrylic(Value)
    end
})

-- ==========================================
-- CATEGORÍA: OPTIMIZACIÓN (FPS Boost)
-- ==========================================
ConfigTab:AddSection("Rendimiento del Sistema")

ConfigTab:AddToggle("OptimizeUI", {
    Title = "Modo UI Optimizada",
    Description = "Elimina elementos visuales pesados para evitar lag",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Fuerza bruta de optimización
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                end
            end
            settings().Rendering.QualityLevel = 1
            Fluent:Notify({Title = "SISTEMA", Content = "Optimización de motor aplicada.", Duration = 3})
        end
    end
})

-- ==========================================
-- CATEGORÍA: IDIOMA (Traducción Simulada)
-- ==========================================
ConfigTab:AddSection("Localización / Language")

local LangMap = {
    ["Español"] = "CENTRO DE MANDO",
    ["English"] = "COMMAND CENTER",
    ["Português"] = "CENTRO DE COMANDO",
    ["Français"] = "CENTRE DE CONTRÔLE",
    ["日本語"] = "コマンドセンター"
}

ConfigTab:AddDropdown("LanguageSelect", {
    Title = "Idioma Global",
    Description = "Cambia el lenguaje de las etiquetas",
    Values = {"Español", "English", "Português", "Français", "日本語"},
    Default = "Español",
    Callback = function(Value)
        Window:SetTitle("ViKo Hub | " .. LangMap[Value])
        Fluent:Notify({
            Title = "Language Update",
            Content = "Interfaz sincronizada a: " .. Value,
            Duration = 2
        })
    end
})

Window:SelectTab(1)
Fluent:Notify({Title = "ViKo Hub", Content = "Centro de Mando Iniciado", Duration = 5})
