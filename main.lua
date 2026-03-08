-- ============================================================
--  main.lua  |  Script principal  v1.0.1 (bugfix)
--  Requiere  : ui_library.lua (mismo repositorio)
-- ============================================================

-- ── URLs del repositorio ─────────────────────────────────────
local REPO_USUARIO = "TU_USUARIO"       -- ← cambia esto
local REPO_NOMBRE  = "TU_REPOSITORIO"   -- ← cambia esto
local RAMA         = "main"

local BASE_URL     = ("https://raw.githubusercontent.com/%s/%s/%s/")
    :format(REPO_USUARIO, REPO_NOMBRE, RAMA)

local URL_LIBRERIA = BASE_URL .. "ui_library.lua"
local URL_REPO     = ("https://github.com/%s/%s"):format(REPO_USUARIO, REPO_NOMBRE)
local VERSION_SCRIPT = "1.0.1"

-- ── Carga segura de la libreria UI ───────────────────────────
local function cargarLibreria()
    -- Validar que la URL fue configurada
    if REPO_USUARIO == "TU_USUARIO" or REPO_NOMBRE == "TU_REPOSITORIO" then
        error(
            "[ScriptHub] CONFIGURACION PENDIENTE\n" ..
            "Edita main.lua y reemplaza:\n" ..
            "  REPO_USUARIO = 'TU_USUARIO'   →  tu usuario de GitHub\n" ..
            "  REPO_NOMBRE  = 'TU_REPOSITORIO' →  nombre de tu repo\n" ..
            "URL actual (invalida): " .. URL_LIBRERIA
        )
    end

    local contenido
    local ok, err = pcall(function()
        contenido = game:HttpGet(URL_LIBRERIA, true)
    end)

    if not ok then
        error("[ScriptHub] HttpGet fallo: " .. tostring(err) ..
              "\nURL: " .. URL_LIBRERIA)
    end

    -- Detectar respuesta vacia
    if type(contenido) ~= "string" or #contenido < 20 then
        error("[ScriptHub] Respuesta vacia desde: " .. URL_LIBRERIA)
    end

    -- Detectar pagina de error de GitHub (404, 401, etc.)
    -- Las respuestas de error HTML empiezan con "<!DOCTYPE" o "<html"
    -- Los 404 de raw.githubusercontent devuelven "404: Not Found\n"
    local inicioContenido = contenido:sub(1, 60):lower()
    if inicioContenido:find("<!doctype")
    or inicioContenido:find("<html")
    or inicioContenido:find("^404")
    or inicioContenido:find("not found")
    or inicioContenido:find("400 bad request")
    then
        error(
            "[ScriptHub] GitHub devolvio un error (probablemente 404).\n" ..
            "Verifica que el archivo exista en la rama '" .. RAMA .. "'.\n" ..
            "URL: " .. URL_LIBRERIA .. "\n" ..
            "Respuesta: " .. contenido:sub(1, 80)
        )
    end

    local fn, compErr = loadstring(contenido)
    if not fn then
        error("[ScriptHub] Error al compilar ui_library.lua: " .. tostring(compErr))
    end

    local libOk, lib = pcall(fn)
    if not libOk then
        error("[ScriptHub] Error al ejecutar ui_library.lua: " .. tostring(lib))
    end
    return lib
end

local UiLibrary = cargarLibreria()

-- ── Servicios ────────────────────────────────────────────────
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local MarketService  = game:GetService("MarketplaceService")

local jugador    = Players.LocalPlayer
local tickInicio = tick()

-- ── Utilidad: math.round seguro ──────────────────────────────
-- math.round no existe en Luau base de Roblox
local function redondear(n)
    return math.floor(n + 0.5)
end

-- ── Utilidad: pcall con valor por defecto ────────────────────
local function intentar(fn, defecto)
    local ok, res = pcall(fn)
    if ok and res ~= nil then return res end
    return defecto
end

-- ── Detectar executor ────────────────────────────────────────
local function obtenerExecutor()
    local nombre = intentar(function()
        return identifyexecutor and identifyexecutor() or nil
    end, nil)
    if nombre then return tostring(nombre) end

    nombre = intentar(function()
        return getexecutorname and getexecutorname() or nil
    end, nil)
    if nombre then return tostring(nombre) end

    local firmas = {
        { var = "KRNL_LOADED",       nombre = "Krnl"        },
        { var = "syn",               nombre = "Synapse X"    },
        { var = "fluxus",            nombre = "Fluxus"       },
        { var = "DELTA_VERSION",     nombre = "Delta"        },
        { var = "MACSPLOIT_VERSION", nombre = "MacSploit"    },
    }
    for _, firma in ipairs(firmas) do
        local encontrado = intentar(function()
            return rawget(_G, firma.var) ~= nil
        end, false)
        if encontrado then return firma.nombre end
    end

    return "Desconocido"
end

-- ── Verificar capacidad del executor ─────────────────────────
local function soportaFuncion(nombre)
    if rawget(_G, nombre) ~= nil then return true end

    local tieneGetfenv = intentar(function()
        return type(getfenv) == "function"
    end, false)

    if tieneGetfenv then
        local entorno = intentar(getfenv, {})
        if entorno and entorno[nombre] ~= nil then return true end
    end

    return false
end

-- ── Edad de cuenta formateada ─────────────────────────────────
local function edadCuenta()
    local dias = intentar(function() return jugador.AccountAge end, nil)
    if not dias then return "N/A" end
    if dias < 1   then return "Hoy" end
    if dias < 30  then return dias .. " dia(s)" end
    if dias < 365 then return ("%.1f mes(es)"):format(dias / 30) end
    return ("%.1f anno(s)"):format(dias / 365)
end

-- ── Nombre del juego (seguro) ────────────────────────────────
local function nombreJuego()
    local info = intentar(function()
        return MarketService:GetProductInfo(game.PlaceId)
    end, nil)
    if info and info.Name then return info.Name end
    return tostring(game.PlaceId)
end

-- ── Hora de inicio (os.date puede no existir) ────────────────
local function horaInicio()
    local hora = intentar(function()
        return os.date and os.date("%H:%M:%S") or nil
    end, nil)
    return hora or ("tick: " .. tostring(redondear(tickInicio)))
end

-- ── Formato de uptime ────────────────────────────────────────
local function formatoUptime(s)
    s = math.floor(s)
    if s < 60   then return s .. "s" end
    if s < 3600 then return ("%dm %ds"):format(math.floor(s/60), s % 60) end
    return ("%dh %dm %ds"):format(math.floor(s/3600), math.floor((s%3600)/60), s%60)
end

-- ════════════════════════════════════════════════════════════
--  Construccion de la UI
-- ════════════════════════════════════════════════════════════
local ui = UiLibrary.new(
    "Script Hub",
    "v" .. VERSION_SCRIPT .. "  -  " .. obtenerExecutor()
)

local C = UiLibrary.COLORES

-- ════════════════════════════════════════════════════════════
--  TAB 1 - PERFIL
-- ════════════════════════════════════════════════════════════
local tabPerfil = ui:CrearTab("Perfil", "P")

local secId = ui:CrearSeccion(tabPerfil, "Identidad")
secId:AgregarEtiqueta("Nombre de usuario", jugador.Name)
secId:AgregarEtiqueta("Nombre visible",    jugador.DisplayName)
secId:AgregarEtiqueta("User ID",           tostring(jugador.UserId))
secId:AgregarEtiqueta("Antiguedad",        edadCuenta())

local secSesion = ui:CrearSeccion(tabPerfil, "Sesion Actual")

local jobId = intentar(function() return tostring(game.JobId) end, "N/A")
local jobIdCorto = #jobId > 22 and (jobId:sub(1, 20) .. "..") or jobId

secSesion:AgregarEtiqueta("Job ID",       jobIdCorto)
secSesion:AgregarEtiqueta("Nombre juego", nombreJuego())
secSesion:AgregarEtiqueta("Place ID",     tostring(game.PlaceId))

local itemPing = secSesion:AgregarEtiqueta("Ping", "Midiendo...")

local secChar = ui:CrearSeccion(tabPerfil, "Personaje")

local itemEquipo = secChar:AgregarEtiqueta("Equipo",
    intentar(function()
        return jugador.Team and jugador.Team.Name or "Sin equipo"
    end, "Sin equipo"))

local tieneChar = jugador.Character ~= nil
local itemAvatar = secChar:AgregarEtiqueta(
    "Avatar cargado",
    tieneChar and "Si" or "No",
    tieneChar and C.Exito or C.Error
)

-- ════════════════════════════════════════════════════════════
--  TAB 2 - INFO FULL
-- ════════════════════════════════════════════════════════════
local tabInfo = ui:CrearTab("Info Full", "I")

local secExec = ui:CrearSeccion(tabInfo, "Executor")
secExec:AgregarEtiqueta("Nombre detectado",   obtenerExecutor())
secExec:AgregarEtiqueta("Version UI Library", UiLibrary.ObtenerVersionLibreria())
secExec:AgregarEtiqueta("Version script",     VERSION_SCRIPT)

local secRepo = ui:CrearSeccion(tabInfo, "Repositorio")
secRepo:AgregarTextoLargo("URL del repositorio",   URL_REPO)
secRepo:AgregarTextoLargo("URL de la libreria UI", URL_LIBRERIA)

local secCap = ui:CrearSeccion(tabInfo, "Capacidades del Executor")

local listaCap = {
    { "request / http_request", "request"      },
    { "writefile",              "writefile"     },
    { "readfile",               "readfile"      },
    { "loadstring",             "loadstring"    },
    { "hookfunction",           "hookfunction"  },
    { "getgc",                  "getgc"         },
    { "debug (lib)",            "debug"         },
    { "Drawing (API)",          "Drawing"       },
    { "gethui",                 "gethui"        },
    { "setclipboard",           "setclipboard"  },
    { "syn.request",            "syn"           },
}

for _, cap in ipairs(listaCap) do
    local label, fn = cap[1], cap[2]
    local activo = intentar(function() return soportaFuncion(fn) end, false)
    secCap:AgregarBadge(label, nil, activo)
end

local secUptime = ui:CrearSeccion(tabInfo, "Tiempo de Ejecucion")
local itemUptime = secUptime:AgregarEtiqueta("Uptime",        "0s")
local itemFPS    = secUptime:AgregarEtiqueta("FPS actual",    "-")
local itemHora   = secUptime:AgregarEtiqueta("Inicio sesion", horaInicio())

-- ════════════════════════════════════════════════════════════
--  Loop de actualizacion (Heartbeat)
-- ════════════════════════════════════════════════════════════
local acum = 0

RunService.Heartbeat:Connect(function(dt)
    acum = acum + dt
    if acum < 1 then return end
    acum = 0

    pcall(function()
        itemUptime:Actualizar(formatoUptime(tick() - tickInicio))
    end)

    pcall(function()
        if dt > 0 then
            local fps = redondear(1 / dt)
            local col = fps >= 55 and C.Exito
                     or fps >= 30 and C.Advertencia
                     or              C.Error
            itemFPS:Actualizar(fps .. " fps", col)
        end
    end)

    -- Ping: GetNetworkPing no siempre existe, el pcall lo protege
    pcall(function()
        local ms = redondear(jugador:GetNetworkPing() * 1000)
        local col = ms < 80  and C.Exito
                 or ms < 150 and C.Advertencia
                 or              C.Error
        itemPing:Actualizar(ms .. " ms", col)
    end)

    pcall(function()
        local tiene = jugador.Character ~= nil
        itemAvatar:Actualizar(
            tiene and "Si" or "No",
            tiene and C.Exito or C.Error
        )
    end)

    pcall(function()
        itemEquipo:Actualizar(
            jugador.Team and jugador.Team.Name or "Sin equipo"
        )
    end)
end)

print(("[ScriptHub] v%s cargado OK | UI v%s | Executor: %s"):format(
    VERSION_SCRIPT,
    UiLibrary.ObtenerVersionLibreria(),
    obtenerExecutor()
))
