-- ============================================================
--  ui_library.lua  |  Interface Configuration
--  Loads the Fluent library and builds the window with tabs.
--  All script logic goes in main.lua, not here.
-- ============================================================

-- ── Load Fluent library (official repository) ─────────────────
local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()

-- ── Load addon: save manager ──────────────────────────────────
local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"
))()

-- ── Load addon: interface manager ─────────────────────────────
local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
))()

-- ── Main window ───────────────────────────────────────────────
local Window = Fluent:CreateWindow({
    Title       = "ViKo Script Hub",
    SubTitle    = "Loading...",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 460),
    Acrylic     = true,   -- Windows 11 acrylic effect
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

-- ── Tabs ──────────────────────────────────────────────────────
local Tabs = {
    Profile  = Window:AddTab({ Title = "Profile",  Icon = "user"     }),
    FullInfo = Window:AddTab({ Title = "Full Info", Icon = "monitor"  }),
    Settings = Window:AddTab({ Title = "Settings",  Icon = "settings" }),
}

-- ── Initialize addons ─────────────────────────────────────────
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- ── Export to main.lua ────────────────────────────────────────
return {
    Fluent      = Fluent,
    Window      = Window,
    Tabs        = Tabs,
    SaveManager = SaveManager,
}
