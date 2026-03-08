local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "ViKo Hub",
    SubTitle = "by qunientos",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- ESTO ACTIVA EL EFECTO ACRÍLICO DE WINDOWS 11
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Pestañas (Tabs) estilo Win11
local Tabs = {
    Main = Window:AddTab({ Title = "Principal", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Configuración", Icon = "settings" })
}

-- Agregar un Botón
Tabs.Main:AddButton({
    Title = "Velocidad x100",
    Description = "Aumenta tu velocidad de caminata",
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
    end
})

-- Agregar un Switch (Toggle)
Tabs.Main:AddToggle("MyToggle", {Title = "Salto Infinito", Default = false}):OnChanged(function(Value)
    _G.InfJump = Value
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if _G.InfJump then
            game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)
end)

-- Notificación de inicio
Fluent:Notify({
    Title = "ViKo Cargado",
    Content = "La interfaz Windows 11 se ejecutó correctamente.",
    Duration = 5
})

Window:SelectTab(1)
