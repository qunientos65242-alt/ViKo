-- ViKo Hub | Lógica de Scripts
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"))()

local Window = Lib:CreateWindow("ViKo Hub | 2026")

Window:AddButton("Velocidad x100", function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
end)

Window:AddButton("Salto Infinito", function()
    game:GetService("UserInputService").JumpRequest:Connect(function()
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end)
end)

Window:AddButton("Reset Character", function()
    game.Players.LocalPlayer.Character:BreakJoints()
end)
