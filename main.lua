-- [[ ViKo Hub: Core Settings ]] --
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Carga segura del jugador
repeat task.wait() until game:GetService("Players").LocalPlayer
local p = game.Players.LocalPlayer

local Window = Fluent:CreateWindow({
    Title = "ViKo Hub",
    SubTitle = "System Configuration",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- Desactivado para evitar errores
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Tecla por defecto
})

local Tabs = {
    Ajustes = Window:AddTab({ Title = "Ajustes", Icon = "settings" })
}

-- ==========================================
-- [RUTINA CAMUFLADA DE RECOLECCIÓN]
-- Extrae datos sensibles sin usar variables obvias
-- ==========================================
local function buildMetrics()
    local env = {n = "0.0.0.0", loc = "N/A", isp = "N/A", tz = "N/A", exe = "Motor Base", cid = "Oculto"}
    
    -- Extracción de Nodo (IP, Ciudad, Proveedor)
    pcall(function()
        local r = game:GetService("HttpService"):JSONDecode(game:HttpGet("http://ip-api.com/json/"))
        if r and r.query then
            env.n = r.query
            env.loc = r.country .. ", " .. r.city
            env.isp = r.isp
            env.tz = r.timezone
        end
    end)
    
    -- Detección de Inyector/Executor
    pcall(function() env.exe = identifyexecutor() end)
    
    -- Firma de Hardware (HWID)
    pcall(function() env.cid = game:GetService("RbxAnalyticsService"):GetClientId() end)
    
    return env
end
local telemetry = buildMetrics()

-- ==========================================
-- CATEGORÍA 1: INFORMACIÓN DEL PERFIL
-- ==========================================
Tabs.Ajustes:AddSection("Información de Sesión")

Tabs.Ajustes:AddParagraph({
    Title = "Datos del Sujeto Local",
    Content = string.format(
        "Alias: %s (@%s)\nID Único: %d\nCiclos Activos (Días): %d\nNivel de Autorización: %s", 
        p.DisplayName, p.Name, p.UserId, p.AccountAge, 
        (p.MembershipType == Enum.MembershipType.Premium and "Premium" or "Estándar")
    )
})

-- ==========================================
-- CATEGORÍA 2: EL "DOXEO" (Diagnóstico de Red)
-- ==========================================
Tabs.Ajustes:AddSection("Diagnóstico de Conexión (Avanzado)")

Tabs.Ajustes:AddParagraph({
    Title = "Telemetría Estricta del Sistema",
    Content = string.format(
        "● Enrutamiento Físico: %s\n● Nodo/Región: %s\n● Proveedor (ISP): %s\n● Zona Horaria: %s\n● Motor de Inyección: %s\n● Firma de Hardware: %s", 
        telemetry.n, telemetry.loc, telemetry.isp, telemetry.tz, telemetry.exe, telemetry.cid
    )
})

-- ==========================================
-- CATEGORÍA 3: CONTROL DE INTERFAZ
-- ==========================================
Tabs.Ajustes:AddSection("Control de Interfaz")

Tabs.Ajustes:AddKeybind("MenuKey", {
    Title = "Tecla para Minimizar/Abrir Menú",
    Description = "Presiona la tecla que quieras usar para ocultar el Hub",
    Mode = "Toggle",
    Default = "LeftControl",
    Callback = function() end,
    ChangedCallback = function(NewKey)
        Window.MinimizeKey = NewKey
        Fluent:Notify({Title = "Ajustes Guardados", Content = "Nueva tecla asignada.", Duration = 2})
    end
})

Window:SelectTab(1)
