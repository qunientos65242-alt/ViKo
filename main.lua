-- ============================================================
--  main.lua  |  ViKo Script Hub  v1.0.3
--  Logica principal. La UI se define en ui_library.lua.
--  Repo: https://github.com/qunientos65242-alt/ViKo
-- ============================================================

-- ── Cargar UI desde el repo ──────────────────────────────────
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"
))()

local Fluent = UI.Fluent
local Window = UI.Window
local Tabs   = UI.Tabs

-- ── Constantes ───────────────────────────────────────────────
local VERSION_SCRIPT = "1.0.3"
local URL_REPO       = "https://github.com/qunientos65242-alt/ViKo"
local URL_UI         = "https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"

-- ── Servicios ────────────────────────────────────────────────
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local MarketService = game:GetService("MarketplaceService")

local jugador    = Players.LocalPlayer
local tickInicio = tick()

-- ════════════════════════════════════════════════════════════
--  HELPERS
-- ════════════════════════════════════════════════════════════
local function intentar(fn, defecto)
    local ok, res = pcall(fn)
    if ok and res ~= nil then return res end
    return defecto
end

local function redondear(n)
    return math.floor(n + 0.5)
end

local function obtenerExecutor()
    local n = intentar(function()
        return identifyexecutor and identifyexecutor() or nil
    end, nil)
    if n then return tostring(n) end

    n = intentar(function()
        return getexecutorname and getexecutorname() or nil
    end, nil)
    if n then return tostring(n) end

    local firmas = {
        {"KRNL_LOADED","Krnl"},{"syn","Synapse X"},{"fluxus","Fluxus"},
        {"DELTA_VERSION","Delta"},{"MACSPLOIT_VERSION","MacSploit"},
    }
    for _, f in ipairs(firmas) do
        if intentar(function() return rawget(_G, f[1]) ~= nil end, false) then
            return f[2]
        end
    end
    return "Desconocido"
end

local function soporta(nombre)
    if rawget(_G, nombre) ~= nil then return true end
    local ok, env = pcall(function()
        return type(getfenv) == "function" and getfenv() or nil
    end)
    return ok and env and env[nombre] ~= nil
end

local function edadCuenta()
    local d = intentar(function() return jugador.AccountAge end, nil)
    if not d then return "N/A" end
    if d < 1   then return "Hoy" end
    if d < 30  then return d .. " dia(s)" end
    if d < 365 then return ("%.1f mes(es)"):format(d / 30) end
    return ("%.1f anno(s)"):format(d / 365)
end

local function nombreJuego()
    local info = intentar(function()
        return MarketService:GetProductInfo(game.PlaceId)
    end, nil)
    return (info and info.Name) or tostring(game.PlaceId)
end

local function horaInicio()
    return intentar(function()
        return os.date and os.date("%H:%M:%S") or nil
    end, "t=" .. tostring(redondear(tickInicio)))
end

local function formatoUptime(s)
    s = math.floor(s)
    if s < 60   then return s .. "s" end
    if s < 3600 then return ("%dm %ds"):format(math.floor(s/60), s%60) end
    return ("%dh %dm %ds"):format(math.floor(s/3600), math.floor((s%3600)/60), s%60)
end

-- ════════════════════════════════════════════════════════════
--  POBLAR TAB: PERFIL
-- ════════════════════════════════════════════════════════════
local jid = intentar(function() return tostring(game.JobId) end, "N/A")

Tabs.Perfil:AddParagraph({
    Title   = "Identidad",
    Content = table.concat({
        "Usuario    : " .. jugador.Name,
        "Display    : " .. jugador.DisplayName,
        "User ID    : " .. tostring(jugador.UserId),
        "Antiguedad : " .. edadCuenta(),
    }, "\n"),
})

Tabs.Perfil:AddParagraph({
    Title   = "Sesion Actual",
    Content = table.concat({
        "Juego    : " .. nombreJuego(),
        "Place ID : " .. tostring(game.PlaceId),
        "Job ID   : " .. (#jid > 24 and jid:sub(1,22).."..." or jid),
    }, "\n"),
})

local parrafoPersonaje = Tabs.Perfil:AddParagraph({
    Title   = "Personaje",
    Content = "Cargando...",
})

-- ════════════════════════════════════════════════════════════
--  POBLAR TAB: INFO FULL
-- ════════════════════════════════════════════════════════════
Tabs.InfoFull:AddParagraph({
    Title   = "Executor",
    Content = table.concat({
        "Nombre  : " .. obtenerExecutor(),
        "Fluent  : " .. tostring(Fluent.Version or "latest"),
        "Script  : v" .. VERSION_SCRIPT,
    }, "\n"),
})

Tabs.InfoFull:AddParagraph({
    Title   = "Repositorio",
    Content = table.concat({
        "Script Hub : " .. URL_REPO,
        "UI Library : " .. URL_UI,
    }, "\n"),
})

-- Capacidades del executor
local caps = {
    {"request / http_request", "request"},
    {"writefile",              "writefile"},
    {"readfile",               "readfile"},
    {"loadstring",             "loadstring"},
    {"hookfunction",           "hookfunction"},
    {"getgc",                  "getgc"},
    {"debug (lib)",            "debug"},
    {"Drawing (API)",          "Drawing"},
    {"gethui",                 "gethui"},
    {"setclipboard",           "setclipboard"},
    {"syn.request",            "syn"},
}

local lineas = {}
for _, cap in ipairs(caps) do
    local ok = intentar(function() return soporta(cap[2]) end, false)
    table.insert(lineas, (ok and "[SI]  " or "[NO]  ") .. cap[1])
end

Tabs.InfoFull:AddParagraph({
    Title   = "Capacidades del Executor",
    Content = table.concat(lineas, "\n"),
})

local parrafoUptime = Tabs.InfoFull:AddParagraph({
    Title   = "Tiempo de Ejecucion",
    Content = "Iniciando...",
})

-- ════════════════════════════════════════════════════════════
--  LOOP DE ACTUALIZACION
-- ════════════════════════════════════════════════════════════
local acum = 0
RunService.Heartbeat:Connect(function(dt)
    acum = acum + dt
    if acum < 1 then return end
    acum = 0

    pcall(function()
        local fps = redondear(dt > 0 and (1/dt) or 0)
        local ms  = intentar(function()
            return redondear(jugador:GetNetworkPing() * 1000)
        end, 0)

        parrafoUptime:SetDesc(table.concat({
            "Uptime     : " .. formatoUptime(tick() - tickInicio),
            "FPS        : " .. fps .. " fps",
            "Ping       : " .. ms  .. " ms",
            "Hora inicio: " .. horaInicio(),
        }, "\n"))
    end)

    pcall(function()
        local char   = jugador.Character
        local equipo = jugador.Team and jugador.Team.Name or "Sin equipo"
        local hum    = char and char:FindFirstChildOfClass("Humanoid")
        local vida   = hum
            and (tostring(redondear(hum.Health)) .. " / " .. tostring(redondear(hum.MaxHealth)))
            or "N/A"

        parrafoPersonaje:SetDesc(table.concat({
            "Avatar : " .. (char and "Si" or "No"),
            "Equipo : " .. equipo,
            "Vida   : " .. vida,
        }, "\n"))
    end)
end)

-- ── Titulo con executor detectado ───────────────────────────
Window:SetSubtitle("v" .. VERSION_SCRIPT .. " · " .. obtenerExecutor())
Window:SelectTab(1)

Fluent:Notify({
    Title    = "ViKo cargado",
    Content  = "v" .. VERSION_SCRIPT .. " · " .. obtenerExecutor(),
    Duration = 5,
})

print(("[ViKo] v%s OK | Executor: %s"):format(VERSION_SCRIPT, obtenerExecutor()))
