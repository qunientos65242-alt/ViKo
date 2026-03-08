local Library = {}

-- Cargamos el motor de Fluent (Estilo Windows 11)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

function Library:Init(hubName, subText)
    local Window = Fluent:CreateWindow({
        Title = hubName,
        SubTitle = subText,
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true, -- El efecto transparente de Win11
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    local Tabs = {}
    
    -- Función para crear pestañas fácilmente
    function Tabs:CreateTab(name, icon)
        local NewTab = Window:AddTab({ Title = name, Icon = icon or "box" })
        
        local Elements = {}
        
        -- Función para añadir botones a la pestaña
        function Elements:AddButton(title, desc, callback)
            NewTab:AddButton({
                Title = title,
                Description = desc or "",
                Callback = callback
            })
        end

        return Elements
    end

    -- Notificación al cargar
    Fluent:Notify({
        Title = hubName,
        Content = "Interfaz cargada con éxito.",
        Duration = 3
    })

    return Tabs
end

return Library
