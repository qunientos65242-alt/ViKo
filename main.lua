-- ============================================================
--  main.lua  |  ViKo Script Hub  v1.0.3
--  Logica principal. La interfaz se define en ui_library.lua.
--  Repositorio: https://github.com/qunientos65242-alt/ViKo
-- ============================================================

-- ── Cargar interfaz desde el repositorio ─────────────────────
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"
))()

local Fluent   = UI.Fluent
local Ventana  = UI.Ventana
local Pestanas = UI.Pestanas

-- ── Constantes ───────────────────────────────────────────────
local VERSION_SCRIPT = "1.0.3"
local URL_REPO       = "https://github.com/qunientos65242-alt/ViKo"
local URL_INTERFAZ   = "https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"

-- ── Servicios de Roblox ──────────────────────────────────────
local Jugadores     = game:GetService("Players")
local ServicioEje   = game:GetService("RunService")
local ServicioMerc  = game:GetService("MarketplaceService")

local jugador    = Jugadores.LocalPlayer
local tickInicio = tick()

-- ════════════════════════════════════════════════════════════
--  FUNCIONES AUXILIARES
-- ════════════════════════════════════════════════════════════

-- Ejecuta una funcion con seguridad; devuelve 'defecto' si falla
local function intentar(fn, defecto)
    local ok, res = pcall(fn)
    if ok and res ~= nil then return res end
    return defecto
end

-- Redondeo seguro (math.round no existe en Luau base)
local function redondear(n)
    return math.floor(n + 0.5)
end

-- Detecta el nombre del executor en uso
local function obtenerExecutor()
    local nombre = intentar(function()
        return identifyexecutor and identifyexecutor() or nil
    end, nil)
    if nombre then return tostring(nombre) end

    nombre = intentar(function()
        return getexecutorname and getexecutorname() or nil
    end, nil)
    if nombre then return tostring(nombre) end

    -- Deteccion por variables globales conocidas
    local firmas = {
        {"KRNL_LOADED","Krnl"}, {"syn","Synapse X"}, {"fluxus","Fluxus"},
        {"DELTA_VERSION","Delta"}, {"MACSPLOIT_VERSION","MacSploit"},
    }
    for _, f in ipairs(firmas) do
        if intentar(function() return rawget(_G, f[1]) ~= nil end, false) then
            return f[2]
        end
    end
    return "Desconocido"
end

-- Comprueba si el executor soporta una funcion especifica
local function soportaFuncion(nombre)
    if rawget(_G, nombre) ~= nil then return true end
    local ok, entorno = pcall(function()
        return type(getfenv) == "function" and getfenv() or nil
    end)
    return ok and entorno and entorno[nombre] ~= nil
end

-- Devuelve la antiguedad de la cuenta en formato legible
local function edadCuenta()
    local dias = intentar(function() return jugador.AccountAge end, nil)
    if not dias then return "N/D" end
    if dias < 1   then return "Hoy" end
    if dias < 30  then return dias .. " dia(s)" end
    if dias < 365 then return ("%.1f mes(es)"):format(dias / 30) end
    return ("%.1f anno(s)"):format(dias / 365)
end

-- Obtiene el nombre del juego actual de forma segura
local function nombreJuego()
    local info = intentar(function()
        return ServicioMerc:GetProductInfo(game.PlaceId)
    end, nil)
    return (info and info.Name) or tostring(game.PlaceId)
end

-- Devuelve la hora en que se inicio el script
local function horaDeInicio()
    return intentar(function()
        return os.date and os.date("%H:%M:%S") or nil
    end, "t=" .. tostring(redondear(tickInicio)))
end

-- Convierte segundos en formato legible hh mm ss
local function formatoTiempoActivo(s)
    s = math.floor(s)
    if s < 60   then return s .. "s" end
    if s < 3600 then return ("%dm %ds"):format(math.floor(s/60), s%60) end
    return ("%dh %dm %ds"):format(math.floor(s/3600), math.floor((s%3600)/60), s%60)
end

-- ════════════════════════════════════════════════════════════
--  PESTANA: PERFIL
-- ════════════════════════════════════════════════════════════
local idSesion = intentar(function() return tostring(game.JobId) end, "N/D")

-- Seccion Identidad
Pestanas.Perfil:AddParagraph({
    Title   = "Identidad",
    Content = table.concat({
        "Usuario      : " .. jugador.Name,
        "Nombre vis.  : " .. jugador.DisplayName,
        "ID de usuario: " .. tostring(jugador.UserId),
        "Antiguedad   : " .. edadCuenta(),
    }, "\n"),
})

-- Seccion Sesion Actual
Pestanas.Perfil:AddParagraph({
    Title   = "Sesion Actual",
    Content = table.concat({
        "Juego    : " .. nombreJuego(),
        "Place ID : " .. tostring(game.PlaceId),
        "ID Serv. : " .. (#idSesion > 24 and idSesion:sub(1,22).."..." or idSesion),
    }, "\n"),
})

-- Seccion Personaje (se actualiza en vivo)
local parrafoPersonaje = Pestanas.Perfil:AddParagraph({
    Title   = "Personaje",
    Content = "Cargando...",
})

-- ════════════════════════════════════════════════════════════
--  PESTANA: INFO FULL
-- ════════════════════════════════════════════════════════════

-- Seccion Executor
Pestanas.InfoFull:AddParagraph({
    Title   = "Executor",
    Content = table.concat({
        "Nombre      : " .. obtenerExecutor(),
        "Libreria UI : Fluent v" .. tostring(Fluent.Version or "ultima"),
        "Version     : v" .. VERSION_SCRIPT,
    }, "\n"),
})

-- Seccion Repositorio
Pestanas.InfoFull:AddParagraph({
    Title   = "Repositorio",
    Content = table.concat({
        "Script Hub : " .. URL_REPO,
        "Interfaz   : " .. URL_INTERFAZ,
    }, "\n"),
})

-- Seccion Capacidades del Executor
local capacidades = {
    {"Peticiones HTTP  (request)",    "request"     },
    {"Escribir archivo (writefile)",  "writefile"   },
    {"Leer archivo     (readfile)",   "readfile"    },
    {"Compilar codigo  (loadstring)", "loadstring"  },
    {"Hooking          (hookfunction)","hookfunction"},
    {"Recolector GC    (getgc)",      "getgc"       },
    {"Biblioteca debug (debug)",      "debug"       },
    {"API de dibujo    (Drawing)",    "Drawing"     },
    {"GUI oculta       (gethui)",     "gethui"      },
    {"Portapapeles     (setclipboard)","setclipboard"},
    {"Synapse request  (syn)",        "syn"         },
}

local lineasCapacidades = {}
for _, cap in ipairs(capacidades) do
    local disponible = intentar(function() return soportaFuncion(cap[2]) end, false)
    table.insert(lineasCapacidades, (disponible and "[SI]  " or "[NO]  ") .. cap[1])
end

Pestanas.InfoFull:AddParagraph({
    Title   = "Capacidades del Executor",
    Content = table.concat(lineasCapacidades, "\n"),
})

-- Seccion Tiempo de Ejecucion (se actualiza en vivo)
local parrafoTiempo = Pestanas.InfoFull:AddParagraph({
    Title   = "Tiempo de Ejecucion",
    Content = "Iniciando...",
})

-- ════════════════════════════════════════════════════════════
--  BUCLE DE ACTUALIZACION EN TIEMPO REAL
-- ════════════════════════════════════════════════════════════
local acumulador = 0

ServicioEje.Heartbeat:Connect(function(dt)
    acumulador = acumulador + dt
    if acumulador < 1 then return end
    acumulador = 0

    -- Actualizar tiempo de ejecucion, FPS y ping
    pcall(function()
        local fps  = redondear(dt > 0 and (1/dt) or 0)
        local ping = intentar(function()
            return redondear(jugador:GetNetworkPing() * 1000)
        end, 0)

        parrafoTiempo:SetDesc(table.concat({
            "Tiempo activo : " .. formatoTiempoActivo(tick() - tickInicio),
            "FPS           : " .. fps  .. " fps",
            "Ping          : " .. ping .. " ms",
            "Hora de inicio: " .. horaDeInicio(),
        }, "\n"))
    end)

    -- Actualizar datos del personaje
    pcall(function()
        local personaje = jugador.Character
        local equipo    = jugador.Team and jugador.Team.Name or "Sin equipo"
        local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
        local vida      = humanoide
            and (tostring(redondear(humanoide.Health)) .. " / " .. tostring(redondear(humanoide.MaxHealth)))
            or "N/D"

        parrafoPersonaje:SetDesc(table.concat({
            "Avatar cargado : " .. (personaje and "Si" or "No"),
            "Equipo         : " .. equipo,
            "Vida           : " .. vida,
        }, "\n"))
    end)
end)

-- ── Ajustes finales de la ventana ────────────────────────────
Ventana:SetSubtitle("v" .. VERSION_SCRIPT .. " · " .. obtenerExecutor())
Ventana:SelectTab(1)

-- Notificacion de bienvenida
Fluent:Notify({
    Title    = "ViKo cargado correctamente",
    Content  = "Version " .. VERSION_SCRIPT .. " · " .. obtenerExecutor(),
    Duration = 5,
})

print(("[ViKo] v%s iniciado | Executor: %s"):format(VERSION_SCRIPT, obtenerExecutor()))
