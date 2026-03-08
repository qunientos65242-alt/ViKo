-- Esperar a que el juego cargue completamente
if not game:IsLoaded() then game.Loaded:Wait() end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "ViKo Hub | Control Center",
    SubTitle = "v2.0 Professional Edition",
    TabWidth = 180,
    Size = UDim2.fromOffset(620, 480),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local lp = game.Players.LocalPlayer
local stats = game:GetService("Stats")

local Tabs = {
    Config = Window:AddTab({ Title = "Configuración", Icon = "settings" })
}

-- SECCIÓN: PERFIL
Tabs.Config:AddSection("Información del Perfil")

local accountType = lp.MembershipType == Enum.MembershipType.Premium and "Premium" or "Normal"

Tabs.Config:AddParagraph({
    Title = "Datos del Usuario",
    Content = string.format("Nombre: %s\nID: %d\nAntigüedad: %d días\nCuenta: %s", 
        lp.Name, lp.UserId, lp.AccountAge, accountType)
})

-- SECCIÓN: TELEMETRÍA (Con protección contra errores)
Tabs.Config:AddSection("Estadísticas del Sistema")
local TechInfo = Tabs.Config:AddParagraph({ Title = "Telemetría en Vivo", Content = "Iniciando sensores..." })

task.spawn(function()
    while task.wait(1) do
        pcall(function() -- El pcall evita que el script se rompa si algo falla
            local ping = stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
            local fps = math.floor(1 / task.wait())
            local pos = "N/A"
            
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local p = lp.Character.HumanoidRootPart.Position
                pos = string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)
            end
            
            TechInfo:SetDesc(string.format("Ping: %s\nFPS: %d\nPosición: %s", ping, fps, pos))
        end)
    end
end)

-- SECCIÓN: APARIENCIA
Tabs.Config:AddSection("Personalización")
Tabs.Config:AddDropdown("ThemeDropdown", {
    Title = "Tema de la Interfaz",
    Values = {"Dark", "Light", "Amethyst", "Aqua"},
    Default = "Dark",
    Callback = function(Value) Window:SetTheme(Value) end
})

-- SECCIÓN: OPTIMIZACIÓN
Tabs.Config:AddToggle("LagReducer", {
    Title = "Modo UI Optimizada",
    Description = "Baja la calidad gráfica para ganar FPS",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
            end
        end
    end
})

Window:SelectTab(1)
Fluent:Notify({Title = "ViKo Hub", Content = "Sistema de Control Cargado", Duration = 5})
