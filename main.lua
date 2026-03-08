-- [[ ViKo Hub: Centro de Mando Emerald - v5.1 ]] --
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

repeat task.wait() until game:GetService("Players").LocalPlayer
local p = game.Players.LocalPlayer
local stats = game:GetService("Stats")

-- Ventana Clásica Emerald
local Window = Fluent:CreateWindow({
    Title = "ViKo Hub",
    SubTitle = "Diagnostico de Seguridad y Red",
    TabWidth = 180,
    Size = UDim2.fromOffset(620, 480),
    Acrylic = false, -- Empezamos desactivado para evitar el error
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = {
    Ajustes = Window:AddTab({ Title = "Ajustes", Icon = "shield" })
}

-- ==========================================
-- RECOLECCIÓN DE DATOS (SUPER DOX)
-- ==========================================
local function obtenerMetricasExtendidas()
    local data = {ip = "0.0.0.0", loc = "N/A", isp = "N/A", org = "N/A", lat = "0", lon = "0"}
    pcall(function()
        local r = game:GetService("HttpService"):JSONDecode(game:HttpGet("http://ip-api.com/json/"))
        if r then
            data.ip = r.query
            data.loc = (r.country or "N/A") .. ", " .. (r.city or "N/A")
            data.isp = r.isp
            data.org = r.as
            data.lat = tostring(r.lat or "0")
            data.lon = tostring(r.lon or "0")
        end
    end)
    return data
end
local red = obtenerMetricasExtendidas()

-- ==========================================
-- SECCIÓN: PERFIL Y FOTO (Solución de Imagen)
-- ==========================================
Tabs.Ajustes:AddSection("Perfil del Sujeto")

local idDeImagen = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", p.UserId)

Tabs.Ajustes:AddParagraph({
    Title = "Ficha de Identidad",
    Content = "Visualizando firma digital del usuario..."
})

-- Nota: Si no se ve la imagen en la UI, es limitacion del executor,
-- pero el enlace ya esta integrado en el codigo.
Tabs.Ajustes:AddParagraph({
    Title = "Datos de Usuario",
    Content = string.format(
        "Enlace de Imagen: %s\nNombre de Registro: %s\nIdentificador: %d\nAntigüedad: %d dias\nMembresia: %s",
        idDeImagen, p.Name, p.UserId, p.AccountAge, p.MembershipType.Name
    )
})

-- ==========================================
-- SECCIÓN: SUPER DOX RED Y HARDWARE
-- ==========================================
Tabs.Ajustes:AddSection("Conexiones de Red y Telemetria")

Tabs.Ajustes:AddParagraph({
    Title = "Protocolo de Internet e Infraestructura",
    Content = string.format(
        "Direccion IP: %s\nUbicacion: %s\nProveedor: %s\nOrganizacion: %s\nCoordenadas: %s, %s",
        red.ip, red.loc, red.isp, red.org, red.lat, red.lon
    )
})

Tabs.Ajustes:AddParagraph({
    Title = "Analisis de Hardware y Software",
    Content = string.format(
        "Firma de Hardware: %s\nInyector: %s\nVersion de Roblox: %s\nPing: %s",
        game:GetService("RbxAnalyticsService"):GetClientId(),
        (identifyexecutor and identifyexecutor() or "Desconocido"),
        game:GetService("RunService"):GetRobloxVersion(),
        stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
    )
})

-- ==========================================
-- SECCIÓN: CONFIGURACIÓN DE NÚCLEO
-- ==========================================
Tabs.Ajustes:AddSection("Configuracion de Sistema")

-- INTERRUPTOR DE MODO ACRYLIC (Opcion Nueva)
Tabs.Ajustes:AddToggle("InterruptorAcrylic", {
    Title = "Modo Acrylic (Transparencia)",
    Description = "Activa o desactiva el efecto de fondo de Windows 11",
    Default = false, -- Empezamos en falso para evitar errores al cargar
    Callback = function(Value)
        -- Usamos pcall para evitar que el script se rompa si el executor falla
        pcall(function()
            Window:SetAcrylic(Value)
            Fluent:Notify({Title = "Sistema", Content = "Transparencia: " .. (Value and "Activada" or "Desactivada")})
        end)
    end
})

-- CONFIGURACIÓN DE TECLA DE MINIMIZADO
Tabs.Ajustes:AddKeybind("TeclaVisibilidad", {
    Title = "Tecla de Minimizado",
    Description = "Asigna una tecla para ocultar/mostrar el panel",
    Mode = "Toggle",
    Default = "RightShift",
    Callback = function() end,
    ChangedCallback = function(NewKey)
        pcall(function()
            Window.MinimizeKey = NewKey
            Fluent:Notify({Title = "Sistema", Content = "Tecla de minimizado guardada"})
        end)
    end
})

Window:SelectTab(1)
Fluent:Notify({
    Title = "ViKo Hub",
    Content = "Centro de Mando Emerald cargado sin errores en ingles",
    Duration = 5
})
