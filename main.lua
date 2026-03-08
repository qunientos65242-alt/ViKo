local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "ViKo Hub PRO",
    SubTitle = "by qunientos65242",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Inicio", Icon = "home" }),
    Hacks = Window:AddTab({ Title = "Explotación", Icon = "zap" }),
    Settings = Window:AddTab({ Title = "Ajustes", Icon = "settings" })
}

-- FUNCIONES DE EXPLOTACIÓN (Basadas en tus capturas)
local Remotes = game:GetService("ReplicatedStorage").Remotes

Tabs.Hacks:AddButton({
    Title = "Intentar Desbloquear Niveles",
    Description = "Usa el evento UpdateUnlockedLevels encontrado",
    Callback = function()
        -- Intentamos enviar una señal de que el nivel 99 está desbloqueado
        Remotes.UpdateUnlockedLevels:FireServer(99)
        Fluent:Notify({Title = "ViKo", Content = "Señal de nivel enviada.", Duration = 3})
    end
})

Tabs.Hacks:AddButton({
    Title = "Abrir Caja Gratis",
    Description = "Ejecuta OpenCrate sin gastar",
    Callback = function()
        Remotes.OpenCrate:FireServer("Default") -- Intentamos abrir la caja básica
        Fluent:Notify({Title = "ViKo", Content = "Intentando abrir caja...", Duration = 3})
    end
})

Tabs.Hacks:AddButton({
    Title = "Simular Donación",
    Description = "Usa el evento Donate detectado",
    Callback = function()
        Remotes.Donate:FireServer(1000000)
        Fluent:Notify({Title = "ViKo", Content = "Simulando donación de 1M...", Duration = 3})
    end
})

-- Súper Velocidad (Ya la tenías)
Tabs.Main:AddToggle("Speed", {Title = "Súper Velocidad", Default = false})
task.spawn(function()
    while true do
        if Fluent.Options.Speed.Value then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
        task.wait(0.1)
    end
end)

Window:SelectTab(1)
