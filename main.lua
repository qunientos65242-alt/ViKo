-- [[ ViKo Hub: Command Center Edition ]] --
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "ViKo Hub | " .. "Centro de Mando",
    SubTitle = "v3.0 Ultra-Interface",
    TabWidth = 180,
    Size = UDim2.fromOffset(620, 480),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Variables de Sistema
local lp = game.Players.LocalPlayer
local stats = game:GetService("Stats")

local Tabs = {
    Settings = Window:AddTab({ Title = "Configuración", Icon = "settings" })
}

-- ==========================================
-- SECCIÓN: PERFIL (Información Exagerada)
-- ==========================================
Tabs.Settings:AddSection("Información de Identidad")

local function GetAccountType()
    return lp.MembershipType == Enum.MembershipType.Premium and "💎 Premium" or "👤 Standard"
end

Tabs.Settings:AddParagraph({
    Title = "Ficha del Sujeto",
    Content = string.format(
        "● Usuario: %s\n● ID Global: %d\n● Display: %s\n● Antigüedad: %d días\n● Estatus: %s\n● Región: %s",
        lp.Name, lp.UserId, lp.DisplayName, lp.AccountAge, GetAccountType(), game:GetService("HttpService"):JSONDecode(game:HttpGet("http://ip-api.com/json/")).country or "Desconocida"
    )
})

-- ==========================================
-- SECCIÓN: APARIENCIA (Personalización Total)
-- ==========================================
Tabs.Settings:AddSection("Personalización Visual")

Tabs.Settings:AddDropdown("ThemeDropdown", {
    Title = "Tema Maestro",
    Description = "Cambia el estilo visual de la UI",
    Values = {"Dark", "Light", "Amethyst", "Aqua", "Rose"},
    Default = "Dark",
    Callback = function(Value)
        Window:SetTheme(Value)
    end
})

Tabs.Settings:AddToggle("AcrylicToggle", {
    Title = "Modo Transparencia (Acrylic)",
    Description = "Activa el efecto de desenfoque de Windows 11",
    Default = true,
    Callback = function(Value)
        Window:SetAcrylic(Value)
    end
})

-- ==========================================
-- SECCIÓN: OPTIMIZACIÓN (FPS Boost)
-- ==========================================
Tabs.Settings:AddSection("Rendimiento y Optimización")

Tabs.Settings:AddToggle("LagReducer", {
    Title = "Modo UI Optimizada",
    Description = "Elimina texturas y sombras para máximo rendimiento",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Fuerza bruta para quitar lag
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                end
            end
            settings().Rendering.QualityLevel = 1
            Fluent:Notify({Title = "Optimización", Content = "Modo Alto Rendimiento Activado", Duration = 3})
        end
    end
})

-- ==========================================
-- SECCIÓN: LOCALIZACIÓN (Idiomas)
-- ==========================================
Tabs.Settings:AddSection("Idioma / Localization")

local Translations = {
    ["Español"] = "Centro de Mando",
    ["English"] = "Command Center",
    ["Português"] = "Centro de Comando",
    ["Français"] = "Centre de Commande",
    ["Deutsch"] = "Kommandozentrale"
}

Tabs.Settings:AddDropdown("LangDropdown", {
    Title = "Idioma Global",
    Description = "Traducción instantánea de la interfaz",
    Values = {"Español", "English", "Português", "Français", "Deutsch"},
    Default = "Español",
    Callback = function(Value)
        Window:SetTitle("ViKo Hub | " .. Translations[Value])
        Fluent:Notify({
            Title = "Sistema",
            Content = "Idioma cambiado a " .. Value,
            Duration = 2
        })
    end
})

Window:SelectTab(1)
Fluent:Notify({
    Title = "ViKo Hub",
    Content = "Centro de Mando iniciado correctamente.",
    Duration = 5
})
