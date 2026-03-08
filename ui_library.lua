local Library = {}

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "ViKo_Minimal"

    -- Marco Principal (Acrílico Dark)
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 320, 0, 400)
    Main.Position = UDim2.new(0.5, -160, 0.5, -200)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BackgroundTransparency = 0.2 -- Efecto de transparencia
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true

    -- Bordes y Esquinas
    local Corner = Instance.new("UICorner", Main)
    Corner.CornerRadius = UDim.new(0, 12)
    
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Thickness = 1.5
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.8 -- Borde sutil

    -- Título Minimalista
    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Text = title:upper()
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.SourceSansProLight -- Fuente más elegante
    Title.TextSize = 16
    Title.TextLetterSpacing = 2

    -- Contenedor
    local Container = Instance.new("ScrollingFrame", Main)
    Container.Size = UDim2.new(1, -30, 1, -70)
    Container.Position = UDim2.new(0, 15, 0, 55)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 0 -- Ocultar barra para estética minimalista
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local List = Instance.new("UIListLayout", Container)
    List.Padding = UDim.new(0, 8)

    local Elements = {}
    
    -- Botón con estilo moderno
    function Elements:AddButton(text, callback)
        local Btn = Instance.new("TextButton", Container)
        Btn.Size = UDim2.new(1, 0, 0, 38)
        Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Btn.BackgroundTransparency = 0.9 -- Transparencia en botones
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        Btn.Font = Enum.Font.SourceSans
        Btn.TextSize = 14
        
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        local BtnStroke = Instance.new("UIStroke", Btn)
        BtnStroke.Thickness = 1
        BtnStroke.Transparency = 0.9
        BtnStroke.Color = Color3.new(1, 1, 1)

        -- Efecto Hover simple
        Btn.MouseEnter:Connect(function()
            Btn.BackgroundTransparency = 0.8
            Btn.TextColor3 = Color3.new(1, 1, 1)
        end)
        Btn.MouseLeave:Connect(function()
            Btn.BackgroundTransparency = 0.9
            Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end)

        Btn.MouseButton1Click:Connect(callback)
    end

    return Elements
end

return Library
