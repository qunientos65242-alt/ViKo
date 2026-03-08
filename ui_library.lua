-- ============================================================
--  ui_library.lua  |  Configuracion de la Interfaz
--  Carga la libreria Fluent y construye la ventana con pestanas.
--  Toda la logica del script va en main.lua, no aqui.
-- ============================================================

-- ── Cargar libreria Fluent (repositorio oficial) ─────────────
local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()

-- ── Cargar complemento: gestor de guardado ───────────────────
local GestorGuardado = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"
))()

-- ── Cargar complemento: gestor de interfaz ───────────────────
local GestorInterfaz = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
))()

-- ── Ventana principal ────────────────────────────────────────
local Ventana = Fluent:CreateWindow({
    Title       = "ViKo Script Hub",
    SubTitle    = "Cargando...",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 460),
    Acrylic     = true,   -- efecto acrilico estilo Windows 11
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

-- ── Pestanas ─────────────────────────────────────────────────
local Pestanas = {
    Perfil   = Ventana:AddTab({ Title = "Perfil",    Icon = "user"    }),
    InfoFull = Ventana:AddTab({ Title = "Info Full", Icon = "monitor" }),
}

-- ── Inicializar complementos ─────────────────────────────────
GestorGuardado:SetLibrary(Fluent)
GestorInterfaz:SetLibrary(Fluent)
GestorInterfaz:BuildInterfaceSection(Pestanas.InfoFull)
GestorGuardado:BuildConfigSection(Pestanas.InfoFull)

-- ── Exportar a main.lua ──────────────────────────────────────
return {
    Fluent   = Fluent,
    Ventana  = Ventana,
    Pestanas = Pestanas,
}
