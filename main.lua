local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"))()

-- El nombre ahora se verá en mayúsculas y espaciado (Estilo Minimal)
local Window = Lib:CreateWindow("ViKo Project")

Window:AddButton("Infinite Jump", function()
    -- Tu código de salto aquí
end)

Window:AddButton("Speed Boost", function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 80
end)
