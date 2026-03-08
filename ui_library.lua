-- ============================================================
--  ui_library.lua  |  Configuracion de la UI
--  Carga Fluent (dawid-scripts) y construye ventana + tabs.
--  La logica del script va en main.lua, no aqui.
-- ============================================================

local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()

local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"
))()

local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
))()

-- ── Ventana principal ────────────────────────────────────────
local Window = Fluent:CreateWindow({
    Title       = "ViKo Script Hub",
    SubTitle    = "Cargando...",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 460),
    Acrylic     = true,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

-- ── Tabs ─────────────────────────────────────────────────────
local Tabs = {
    Perfil   = Window:AddTab({ Title = "Perfil",    Icon = "user"    }),
    InfoFull = Window:AddTab({ Title = "Info Full", Icon = "monitor" }),
}

-- ── Inicializar addons ───────────────────────────────────────
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.InfoFull)
SaveManager:BuildConfigSection(Tabs.InfoFull)

-- ── Exportar todo lo necesario a main.lua ────────────────────
return {
    Fluent    = Fluent,
    Window    = Window,
    Tabs      = Tabs,
}
