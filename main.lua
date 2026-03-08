local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"))()
local Win = Lib:CreateWindow("ViKo Hub")

-- BOTÓN EJEMPLO
Win:AddButton("Fly Hack", function()
    print("Vuelo Activado")
end)

-- BOTÓN EJEMPLO 2
Win:AddButton("Speed x100", function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
end)
