-- ============================================================
--  ui_library.lua | FIXED VERSION
-- ============================================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title       = "ViKo Script Hub",
    SubTitle    = "by ViKo",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 460),
    Acrylic     = true,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

-- REGISTRO DE TODAS LAS TABS (Asegúrate de que coincidan con main.lua)
local Tabs = {
    Main     = Window:AddTab({ Title = "Main",      Icon = "swords" }),
    Profile  = Window:AddTab({ Title = "Profile",   Icon = "user" }),
    FullInfo = Window:AddTab({ Title = "Full Info", Icon = "monitor" }),
    Settings = Window:AddTab({ Title = "Settings",  Icon = "settings" })
}

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

return {
    Fluent      = Fluent,
    Window      = Window,
    Tabs        = Tabs,
    SaveManager = SaveManager,
}
