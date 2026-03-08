-- ============================================================
--  main.lua  |  Script principal
--  Versión   : 1.0.0
--  Requiere  : ui_library.lua (mismo repositorio)
-- ============================================================

-- ── URLs del repositorio (¡actualiza con tu usuario/repo!) ───
local REPO_USUARIO    = "qunientos65242-alt"
local REPO_NOMBRE     = "ViKo"
local RAMA            = "main"

local BASE_URL = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/",
    REPO_USUARIO, REPO_NOMBRE, RAMA
)

local URL_LIBRERIA = BASE_URL .. "ui_library.lua"
local URL_REPO     = string.format(
    "https://github.com/%s/%s", REPO_USUARIO, REPO_NOMBRE
)

local VERSION_SCRIPT = "1.0.0"

-- ── Carga segura de la librería UI ───────────────────────────
local function cargarLibreria()
    local ok, contenido = pcall(function()
        return game:HttpGet(URL_LIBRERIA, true)
    end)

    if not ok or type(contenido) ~= "string" or contenido == "" then
        error(string.format(
            "[ScriptHub] No se pudo descargar ui_library.lua.\n" ..
            "URL: %s\nError: %s",
            URL_LIBRERIA, tostring(contenido)
        ))
    end

    local fn, err = loadstring(contenido)
    if not fn then
        error("[ScriptHub] Error al compilar ui_library.lua: " .. tostring(err))
    end

    return fn()
end

local UiLibrary = cargarLibreria()

-- ── Servicios ────────────────────────────────────────────────
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local jugador    = Players.LocalPlayer
local tickInicio = tick()

-- ── Helpers ──────────────────────────────────────────────────
local function obtenerExecutor()
    if identifyexecutor then
        local ok, nombre = pcall(identifyexecutor)
        if ok and nombre then return tostring(nombre) end
    end
    -- Fallbacks por firmas conocidas
    if KRNL_LOADED             then return "Krnl" end
    if syn                     then return "Synapse X" end
    if fluxus                  then return "Fluxus" end
    if getexecutorname         then
        local ok, n = pcall(getexecutorname)
        if ok and n then return tostring(n) end
    end
    return "Desconocido"
end

local function soportaCapacidad(nombre)
    return type(_G[nombre]) ~= "nil" or type(getfenv()[nombre]) ~= "nil"
end

local function soportaFuncion(nombre)
    -- Revisión en el entorno global del executor
    local ok = pcall(function()
        local fn = getfenv and getfenv()[nombre] or _G[nombre]
        assert(fn ~= nil)
    end)
    return ok
end

local function edadCuenta()
    -- AccountAge en días
    local ok, edad = pcall(function()
        return jugador.AccountAge
    end)
    if not ok then return "N/A" end
    if edad < 30  then return string.format("%d día(s)", edad) end
    if edad < 365 then return string.format("%.1f mes(es)", edad / 30) end
    return string.format("%.1f año(s)", edad / 365)
end

local function formatoUptime(segundos)
    local s = math.floor(segundos)
    if s < 60  then return string.format("%ds", s) end
    if s < 3600 then
        return string.format("%dm %ds", math.floor(s/60), s % 60)
    end
    return string.format("%dh %dm %ds",
        math.floor(s/3600),
        math.floor((s % 3600)/60),
        s % 60
    )
end

local function colorEstado(activo)
    return activo
        and UiLibrary.COLORES.Exito
        or  UiLibrary.COLORES.Error
end

-- ── Construcción de la UI ─────────────────────────────────────
local ui = UiLibrary.new(
    "⚡  Script Hub",
    "v" .. VERSION_SCRIPT .. "  ·  " .. obtenerExecutor()
)

-- ════════════════════════════════════════════════════════════
--  TAB 1 — PERFIL DEL JUGADOR
-- ════════════════════════════════════════════════════════════
local tabPerfil = ui:CrearTab("Perfil", "👤")

-- Sección: Identidad
local secIdentidad = ui:CrearSeccion(tabPerfil, "Identidad")

local itemNombre      = secIdentidad:AgregarEtiqueta("Nombre de usuario",  jugador.Name)
local itemDisplay     = secIdentidad:AgregarEtiqueta("Nombre visible",     jugador.DisplayName)
local itemUserId      = secIdentidad:AgregarEtiqueta("User ID",            tostring(jugador.UserId))
local itemEdad        = secIdentidad:AgregarEtiqueta("Antigüedad",         edadCuenta())

-- Sección: Sesión actual
local secSesion = ui:CrearSeccion(tabPerfil, "Sesión Actual")

local itemServidor    = secSesion:AgregarEtiqueta("Servidor (Job ID)",
    string.sub(game.JobId, 1, 20) .. "…")
local itemJuego       = secSesion:AgregarEtiqueta("Nombre del juego",
    game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
local itemPlaceId     = secSesion:AgregarEtiqueta("Place ID",
    tostring(game.PlaceId))
local itemPing        = secSesion:AgregarEtiqueta("Ping estimado", "Midiendo…")

-- Sección: Personaje
local secPersonaje = ui:CrearSeccion(tabPerfil, "Personaje")

local function actualizarDatosPersonaje()
    local char = jugador.Character
    if not char then
        itemPing:Actualizar("Sin personaje")
        return
    end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        -- Mostrar equipo si existe
        local equipo = jugador.Team
        local nombreEquipo = equipo and equipo.Name or "Sin equipo"
        -- Actualizar ping usando Stats si está disponible
        local stats = Players:GetService and nil
        pcall(function()
            local pingValor = jugador:GetNetworkPing and
                math.round(jugador:GetNetworkPing() * 1000) or "N/A"
            itemPing:Actualizar(tostring(pingValor) .. " ms")
        end)
    end
end

local itemEquipo = secPersonaje:AgregarEtiqueta("Equipo",
    (jugador.Team and jugador.Team.Name) or "Sin equipo")
local itemHumanoidDesc = secPersonaje:AgregarEtiqueta("Avatar cargado",
    jugador.Character and "Sí" or "No",
    jugador.Character and UiLibrary.COLORES.Exito or UiLibrary.COLORES.Error)

-- ════════════════════════════════════════════════════════════
--  TAB 2 — INFO FULL (sin controles, solo datos técnicos)
-- ════════════════════════════════════════════════════════════
local tabInfo = ui:CrearTab("Info Full", "🖥")

-- ── Sección: Executor ─────────────────────────────────────────
local secExecutor = ui:CrearSeccion(tabInfo, "Executor")

local itemNombreExec  = secExecutor:AgregarEtiqueta("Nombre detectado",   obtenerExecutor())
local itemVersionLib  = secExecutor:AgregarEtiqueta("Versión UI Library",
    UiLibrary.ObtenerVersionLibreria())
local itemVersionScript = secExecutor:AgregarEtiqueta("Versión script",   VERSION_SCRIPT)

-- ── Sección: Repositorio ──────────────────────────────────────
local secRepo = ui:CrearSeccion(tabInfo, "Repositorio")

local itemUrlRepo     = secRepo:AgregarTextoLargo("URL del repositorio",   URL_REPO)
local itemUrlLib      = secRepo:AgregarTextoLargo("URL de la librería UI", URL_LIBRERIA)

-- ── Sección: Capacidades del Executor ───────────────────────
local secCapacidades = ui:CrearSeccion(tabInfo, "Capacidades del Executor")

-- Lista de funciones a verificar
local capacidades = {
    { "request / http_request", "request"       },
    { "writefile",              "writefile"      },
    { "readfile",               "readfile"       },
    { "loadstring",             "loadstring"     },
    { "hookfunction",           "hookfunction"   },
    { "getgc",                  "getgc"          },
    { "debug.getinfo",          "debug"          },
    { "Drawing",                "Drawing"        },
    { "gethui",                 "gethui"         },
}

local badgesCapacidades = {}
for _, cap in ipairs(capacidades) do
    local nombre, fn = cap[1], cap[2]
    local soportada  = soportaFuncion(fn)
    local badge      = secCapacidades:AgregarBadge(nombre, nil, soportada)
    table.insert(badgesCapacidades, badge)
end

-- ── Sección: Uptime ───────────────────────────────────────────
local secUptime = ui:CrearSeccion(tabInfo, "Tiempo de Ejecución")

local itemUptime      = secUptime:AgregarEtiqueta("Uptime del script",    "0s")
local itemFPS         = secUptime:AgregarEtiqueta("FPS actual",           "–")
local itemHora        = secUptime:AgregarEtiqueta("Hora de inicio",
    tostring(os.date and os.date("%H:%M:%S") or "N/A"))

-- ════════════════════════════════════════════════════════════
--  Loop de actualización
-- ════════════════════════════════════════════════════════════
local contadorActualizar = 0

RunService.Heartbeat:Connect(function(dt)
    contadorActualizar = contadorActualizar + dt

    -- Actualizar cada 1 segundo
    if contadorActualizar >= 1 then
        contadorActualizar = 0

        -- Uptime
        local uptime = tick() - tickInicio
        itemUptime:Actualizar(formatoUptime(uptime))

        -- FPS
        local fps = math.round(1 / dt)
        local colorFps = fps >= 55 and UiLibrary.COLORES.Exito
            or fps >= 30 and UiLibrary.COLORES.Advertencia
            or UiLibrary.COLORES.Error
        itemFPS:Actualizar(tostring(fps) .. " fps", colorFps)

        -- Ping
        pcall(function()
            if jugador.GetNetworkPing then
                local ms = math.round(jugador:GetNetworkPing() * 1000)
                local cPing = ms < 80 and UiLibrary.COLORES.Exito
                    or ms < 150 and UiLibrary.COLORES.Advertencia
                    or UiLibrary.COLORES.Error
                itemPing:Actualizar(tostring(ms) .. " ms", cPing)
            end
        end)

        -- Avatar cargado
        local tieneChar = jugador.Character ~= nil
        itemHumanoidDesc:Actualizar(
            tieneChar and "Sí" or "No",
            tieneChar and UiLibrary.COLORES.Exito or UiLibrary.COLORES.Error
        )

        -- Equipo
        itemEquipo:Actualizar(
            (jugador.Team and jugador.Team.Name) or "Sin equipo"
        )
    end
end)

-- ── Fin de carga ──────────────────────────────────────────────
print(string.format(
    "[ScriptHub] ✓ Cargado correctamente | Script v%s | UI Library v%s | Executor: %s",
    VERSION_SCRIPT,
    UiLibrary.ObtenerVersionLibreria(),
    obtenerExecutor()
))
