-- ============================================================
--  main.lua  |  Script principal  v1.0.2
--  Repo: https://github.com/qunientos65242-alt/ViKo
-- ============================================================

local REPO_USUARIO   = "qunientos65242-alt"
local REPO_NOMBRE    = "ViKo"
local RAMA           = "main"

local BASE_URL       = ("https://raw.githubusercontent.com/%s/%s/%s/")
    :format(REPO_USUARIO, REPO_NOMBRE, RAMA)

local URL_LIBRERIA   = BASE_URL .. "ui_library.lua"
local URL_REPO       = ("https://github.com/%s/%s"):format(REPO_USUARIO, REPO_NOMBRE)
local VERSION_SCRIPT = "1.0.2"

-- ── Carga segura de la libreria UI ───────────────────────────
local function cargarLibreria()
    -- 1. Descargar
    local contenido
    local ok, err = pcall(function()
        contenido = game:HttpGet(URL_LIBRERIA, true)
    end)

    if not ok then
        error("[ViKo] HttpGet fallo: " .. tostring(err) .. "\nURL: " .. URL_LIBRERIA)
    end

    -- 2. Validar que no sea respuesta vacia
    if type(contenido) ~= "string" or #contenido < 20 then
        error("[ViKo] Respuesta vacia desde: " .. URL_LIBRERIA)
    end

    -- 3. Detectar pagina de error 404 / HTML de GitHub
    --    raw.githubusercontent devuelve "404: Not Found" como texto plano
    local inicio = contenido:sub(1, 80):lower()
    if inicio:find("<!doctype")
    or inicio:find("<html")
    or inicio:find("^404")
    or inicio:find("not found")
    or inicio:find("400 bad")
    then
        error(
            "[ViKo] GitHub devolvio error 404.\n" ..
            "Asegurate de que ui_library.lua este en la rama '" .. RAMA .. "'.\n" ..
            "URL intentada: " .. URL_LIBRERIA .. "\n" ..
            "Respuesta recibida: " .. contenido:sub(1, 80)
        )
    end

    -- 4. Compilar
    local fn, compErr = loadstring(contenido)
    if not fn then
        error("[ViKo] Error al compilar ui_library.lua: " .. tostring(compErr))
    end

    -- 5. Ejecutar y retornar la libreria
    local libOk, lib = pcall(fn)
    if not libOk then
        error("[ViKo] Error al ejecutar ui_library.lua: " .. tostring(lib))
    end

    return lib
end

local UiLibrary = cargarLibreria()

-- ── Servicios ────────────────────────────────────────────────
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local MarketService = game:GetService("MarketplaceService")

local jugador    = Players.LocalPlayer
local tickInicio = tick()

-- ── Helpers universales ──────────────────────────────────────

-- Roblox Luau no tiene math.round
local function redondear(n)
    return math.floor(n + 0.5)
end

-- pcall con valor de fallback si falla o retorna nil
local function intentar(fn, defecto)
    local ok, res = pcall(fn)
    if ok and res ~= nil then return res end
    return defecto
end

-- ── Detectar executor ────────────────────────────────────────
local function obtenerExecutor()
    -- Metodo estandar
    local n = intentar(function()
        return identifyexecutor and identifyexecutor() or nil
    end, nil)
    if n then return tostring(n) end

    -- Alternativa
    n = intentar(function()
        return getexecutorname and getexecutorname() or nil
    end, nil)
    if n then return tostring(n) end

    -- Firmas globales usando rawget para no invocar metamétodos
    local firmas = {
        { "KRNL_LOADED",       "Krnl"      },
        { "syn",               "Synapse X" },
        { "fluxus",            "Fluxus"    },
        { "DELTA_VERSION",     "Delta"     },
        { "MACSPLOIT_VERSION", "MacSploit" },
        { "is_sirhurt_closure","Sirhurt"   },
    }
    for _, f in ipairs(firmas) do
        if intentar(function() return rawget(_G, f[1]) ~= nil end, false) then
            return f[2]
        end
    end

    return "Desconocido"
end

-- ── Verificar si el executor soporta una funcion ─────────────
local function soporta(nombre)
    -- rawget nunca lanza error
    if rawget(_G, nombre) ~= nil then return true end

    -- getfenv puede no existir en Luau estricto
    local ok, entorno = pcall(function()
        return type(getfenv) == "function" and getfenv() or nil
    end)
    if ok and entorno and entorno[nombre] ~= nil then return true end

    return false
end

-- ── Edad de cuenta ────────────────────────────────────────────
local function edadCuenta()
    local d = intentar(function() return jugador.AccountAge end, nil)
    if not d then return "N/A" end
    if d < 1   then return "Hoy" end
    if d < 30  then return d .. " dia(s)" end
    if d < 365 then return ("%.1f mes(es)"):format(d / 30) end
    return ("%.1f anno(s)"):format(d / 365)
end

-- ── Nombre del juego ─────────────────────────────────────────
local function nombreJuego()
    local info = intentar(function()
        return MarketService:GetProductInfo(game.PlaceId)
    end, nil)
    return (info and info.Name) or tostring(game.PlaceId)
end

-- ── Hora de inicio ───────────────────────────────────────────
local function horaInicio()
    local h = intentar(function()
        return os.date and os.date("%H:%M:%S") or nil
    end, nil)
    return h or ("t=" .. tostring(redondear(tickInicio)))
end

-- ── Uptime formateado ────────────────────────────────────────
local function uptime(s)
    s = math.floor(s)
    if s < 60   then return s .. "s" end
    if s < 3600 then return ("%dm %ds"):format(math.floor(s/60), s%60) end
    return ("%dh %dm %ds"):format(math.floor(s/3600), math.floor((s%3600)/60), s%60)
end

-- ════════════════════════════════════════════════════════════
--  UI
-- ════════════════════════════════════════════════════════════
local ui = UiLibrary.new(
    "ViKo Script Hub",
    "v" .. VERSION_SCRIPT .. "  -  " .. obtenerExecutor()
)

local COL = UiLibrary.COLORES

-- ════════════════════════════════════════════════════════════
--  TAB: PERFIL
-- ════════════════════════════════════════════════════════════
local tabPerfil = ui:CrearTab("Perfil", "P")

-- Identidad
local secId = ui:CrearSeccion(tabPerfil, "Identidad")
secId:AgregarEtiqueta("Nombre de usuario", jugador.Name)
secId:AgregarEtiqueta("Nombre visible",    jugador.DisplayName)
secId:AgregarEtiqueta("User ID",           tostring(jugador.UserId))
secId:AgregarEtiqueta("Antiguedad",        edadCuenta())

-- Sesion
local secSesion = ui:CrearSeccion(tabPerfil, "Sesion Actual")

local jid = intentar(function() return tostring(game.JobId) end, "N/A")
secSesion:AgregarEtiqueta("Job ID",       #jid > 22 and jid:sub(1,20).."..." or jid)
secSesion:AgregarEtiqueta("Juego",        nombreJuego())
secSesion:AgregarEtiqueta("Place ID",     tostring(game.PlaceId))
local itemPing = secSesion:AgregarEtiqueta("Ping", "Midiendo...")

-- Personaje
local secChar = ui:CrearSeccion(tabPerfil, "Personaje")
local itemEquipo = secChar:AgregarEtiqueta("Equipo",
    intentar(function()
        return jugador.Team and jugador.Team.Name or "Sin equipo"
    end, "Sin equipo"))
local tieneChar = jugador.Character ~= nil
local itemAvatar = secChar:AgregarEtiqueta(
    "Avatar cargado",
    tieneChar and "Si" or "No",
    tieneChar and COL.Exito or COL.Error
)

-- ════════════════════════════════════════════════════════════
--  TAB: INFO FULL
-- ════════════════════════════════════════════════════════════
local tabInfo = ui:CrearTab("Info Full", "I")

-- Executor
local secExec = ui:CrearSeccion(tabInfo, "Executor")
secExec:AgregarEtiqueta("Nombre detectado",   obtenerExecutor())
secExec:AgregarEtiqueta("Version UI Library", UiLibrary.ObtenerVersionLibreria())
secExec:AgregarEtiqueta("Version script",     VERSION_SCRIPT)

-- Repositorio
local secRepo = ui:CrearSeccion(tabInfo, "Repositorio")
secRepo:AgregarTextoLargo("URL repositorio",  URL_REPO)
secRepo:AgregarTextoLargo("URL libreria UI",  URL_LIBRERIA)

-- Capacidades
local secCap = ui:CrearSeccion(tabInfo, "Capacidades del Executor")
local caps = {
    { "request / http_request", "request"     },
    { "writefile",              "writefile"   },
    { "readfile",               "readfile"    },
    { "loadstring",             "loadstring"  },
    { "hookfunction",           "hookfunction"},
    { "getgc",                  "getgc"       },
    { "debug (lib)",            "debug"       },
    { "Drawing (API)",          "Drawing"     },
    { "gethui",                 "gethui"      },
    { "setclipboard",           "setclipboard"},
    { "syn.request",            "syn"         },
}
for _, cap in ipairs(caps) do
    local activo = intentar(function() return soporta(cap[2]) end, false)
    secCap:AgregarBadge(cap[1], nil, activo)
end

-- Tiempo
local secT = ui:CrearSeccion(tabInfo, "Tiempo de Ejecucion")
local itemUp  = secT:AgregarEtiqueta("Uptime",       "0s")
local itemFPS = secT:AgregarEtiqueta("FPS actual",   "-")
local itemHora = secT:AgregarEtiqueta("Hora inicio", horaInicio())

-- ════════════════════════════════════════════════════════════
--  Loop de actualizacion
-- ════════════════════════════════════════════════════════════
local acum = 0
RunService.Heartbeat:Connect(function(dt)
    acum = acum + dt
    if acum < 1 then return end
    acum = 0

    pcall(function() itemUp:Actualizar(uptime(tick() - tickInicio)) end)

    pcall(function()
        if dt > 0 then
            local fps = redondear(1 / dt)
            local col = fps >= 55 and COL.Exito
                     or fps >= 30 and COL.Advertencia
                     or              COL.Error
            itemFPS:Actualizar(fps .. " fps", col)
        end
    end)

    pcall(function()
        local ms = redondear(jugador:GetNetworkPing() * 1000)
        local col = ms < 80  and COL.Exito
                 or ms < 150 and COL.Advertencia
                 or              COL.Error
        itemPing:Actualizar(ms .. " ms", col)
    end)

    pcall(function()
        local tiene = jugador.Character ~= nil
        itemAvatar:Actualizar(tiene and "Si" or "No", tiene and COL.Exito or COL.Error)
    end)

    pcall(function()
        itemEquipo:Actualizar(jugador.Team and jugador.Team.Name or "Sin equipo")
    end)
end)

print(("[ViKo] v%s OK | UI v%s | Executor: %s"):format(
    VERSION_SCRIPT,
    UiLibrary.ObtenerVersionLibreria(),
    obtenerExecutor()
))
