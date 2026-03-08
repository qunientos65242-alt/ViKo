local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "ViKo Hub | Control Center",
    SubTitle = "v2.0 Professional Edition",
    TabWidth = 180,
    Size = UDim2.fromOffset(620, 480),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Variables de Usuario
local lp = game.Players.LocalPlayer
local stats = game:GetService("Stats")

local Tabs = {
    Config = Window:AddTab({ Title = "Configuración", Icon = "settings" })
}

-- SECCIÓN 1: PERFIL DETALLADO DEL JUGADOR
Tabs.Config:AddSection("Información del Perfil")

local ProfileInfo = Tabs.Config:AddParagraph({
    Title = "Datos del Usuario",
    Content = string.format(
        "Nombre: %s\nDisplay: %s\nUser ID: %d\nAntigüedad: %d días\nTipo de Cuenta: %s",
        lp.Name, lp.DisplayName, lp.UserId, lp.AccountAge, lp.MembershipType.Name
    )
})

-- SECCIÓN 2: ESTADÍSTICAS TÉCNICAS (Info exagerada)
Tabs.Config:AddSection("Estadísticas del Sistema")

local TechInfo = Tabs.Config:AddParagraph({
    Title = "Telemetría en Vivo",
    Content = "Cargando datos..."
})

-- Loop para actualizar info técnica en tiempo real
task.spawn(function()
    while task.wait(1) do
        local ping = stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
        local fps = math.floor(1 / task.wait())
        TechInfo:SetDesc(string.format(
            "Ping Actual: %s\nFPS: %d\nPosición: %.2f, %.2f, %.2f\nInstancia: %s",
            ping, fps, lp.Character.HumanoidRootPart.Position.X, lp.Character.HumanoidRootPart.Position.Y, lp.Character.HumanoidRootPart.Position.Z, game.JobId
        ))
    end
end)

-- SECCIÓN 3: APARIENCIA DE LA UI
Tabs.Config:AddSection("Personalización de Interfaz")

Tabs.Config:AddDropdown("ThemeDropdown", {
    Title = "Tema de la Interfaz",
    Values = {"Dark", "Light", "Amethyst", "Aqua"},
    Default = "Dark",
    Callback = function(Value)
        Window:SetTheme(Value)
    end
})

Tabs.Config:AddToggle("AcrylicToggle", {
    Title = "Efecto de Transparencia (Acrylic)",
    Default = true,
    Callback = function(Value)
        Window:SetAcrylic(Value)
    end
})

-- SECCIÓN 4: OPTIMIZACIÓN (Evitar Lag)
Tabs.Config:AddSection("Optimización de Rendimiento")

Tabs.Config:AddToggle("LagReducer", {
    Title = "Modo UI Optimizada",
    Description = "Elimina texturas pesadas para mejorar FPS",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
            end
            Fluent:Notify({Title = "Optimizado", Content = "Texturas del juego simplificadas."})
        end
    end
})

-- SECCIÓN 5: IDIOMA (Simulación de Traducción)
Tabs.Config:AddSection("Idioma y Localización")

local Languages = {
    Español = {Welcome = "Bienvenido", Config = "Configuración"},
    English = {Welcome = "Welcome", Config = "Configuration"},
    Portuguese = {Welcome = "Bem-vindo", Config = "Configuração"},
    French = {Welcome = "Bienvenue", Config = "Configuration"}
}

Tabs.Config:AddDropdown("LangDropdown", {
    Title = "Seleccionar Idioma",
    Values = {"Español", "English", "Portuguese", "French"},
    Default = "Español",
    Callback = function(Value)
        local data = Languages[Value]
        Window:SetTitle("ViKo Hub | " .. data.Config)
        Fluent:Notify({Title = "Idioma", Content = "Idioma cambiado a " .. Value})
    end
})

Window:SelectTab(1)
