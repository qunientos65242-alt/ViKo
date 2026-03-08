local Library = {}
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

function Library:Init(hubName, subText)
    local Window = Fluent:CreateWindow({
        Title = hubName,
        SubTitle = subText,
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true, 
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    local Tabs = {
        Profile = Window:AddTab({ Title = "Perfil", Icon = "user" }),
        Settings = Window:AddTab({ Title = "Configuración", Icon = "settings" })
    }

    function Library:GetTabs() return Tabs end
    function Library:GetWindow() return Window end
    function Library:GetFluent() return Fluent end

    return Library
end

return Library
