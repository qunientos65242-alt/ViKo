-- ============================================================
--  ui_library.lua  |  Librería UI estilo Fluent / Windows 11
--  Versión: 1.0.0
--  Autor  : Script Hub
-- ============================================================

local UiLibrary = {}
UiLibrary.__index = UiLibrary

-- ── Servicios ────────────────────────────────────────────────
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")

-- ── Constantes de diseño ─────────────────────────────────────
local COLORS = {
    Fondo          = Color3.fromRGB(20,  20,  28),
    FondoPanel     = Color3.fromRGB(28,  28,  38),
    FondoItem      = Color3.fromRGB(38,  38,  52),
    Acento         = Color3.fromRGB(0,   120, 215),
    AcentoHover    = Color3.fromRGB(30,  144, 255),
    TextoPrincipal = Color3.fromRGB(240, 240, 250),
    TextoSub       = Color3.fromRGB(160, 160, 180),
    TextoMuted     = Color3.fromRGB(100, 100, 120),
    Borde          = Color3.fromRGB(55,  55,  75),
    Separador      = Color3.fromRGB(45,  45,  60),
    Exito          = Color3.fromRGB(80,  200, 120),
    Error          = Color3.fromRGB(220, 80,  80),
    Advertencia    = Color3.fromRGB(220, 170, 50),
}

local FUENTE = Enum.Font.GothamSemibold
local FUENTE_REGULAR = Enum.Font.Gotham
local RADIO_BORDE = UDim.new(0, 10)
local RADIO_BORDE_PEQUENO = UDim.new(0, 6)
local VERSION_LIBRERIA = "1.0.0"

-- ── Utilidades internas ──────────────────────────────────────
local function crearInstancia(clase, propiedades, padre)
    local obj = Instance.new(clase)
    for k, v in pairs(propiedades) do
        obj[k] = v
    end
    if padre then obj.Parent = padre end
    return obj
end

local function agregarRedondeo(padre, radio)
    crearInstancia("UICorner", { CornerRadius = radio or RADIO_BORDE }, padre)
end

local function agregarPadding(padre, arriba, abajo, izq, der)
    crearInstancia("UIPadding", {
        PaddingTop    = UDim.new(0, arriba or 8),
        PaddingBottom = UDim.new(0, abajo or 8),
        PaddingLeft   = UDim.new(0, izq   or 10),
        PaddingRight  = UDim.new(0, der   or 10),
    }, padre)
end

local function tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function obtenerVersionLibreria()
    return VERSION_LIBRERIA
end

-- ── Efecto acrílico / blur ────────────────────────────────────
local function aplicarAcrilico(frame)
    -- BlurEffect en la cámara para simular acrílico
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = game:GetService("Lighting")

    tween(blur, TweenInfo.new(0.4), { Size = 8 })

    -- Gradiente sutil sobre el frame
    local grad = crearInstancia("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(30, 30, 42)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(20, 20, 32)),
        }),
        Rotation = 135,
    }, frame)

    return blur
end

-- ── Constructor principal ─────────────────────────────────────
function UiLibrary.new(titulo, subtitulo)
    local self = setmetatable({}, UiLibrary)
    self._tabs        = {}
    self._tabActual   = nil
    self._blur        = nil
    self._abierto     = true

    -- ScreenGui
    self.ScreenGui = crearInstancia("ScreenGui", {
        Name            = "FluentUI",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset  = true,
    })

    -- Intentar poner en CoreGui (executors)
    pcall(function()
        self.ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not self.ScreenGui.Parent or self.ScreenGui.Parent ~= game:GetService("CoreGui") then
        self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Contenedor principal
    self.Ventana = crearInstancia("Frame", {
        Name            = "Ventana",
        Size            = UDim2.new(0, 680, 0, 460),
        Position        = UDim2.new(0.5, -340, 0.5, -230),
        BackgroundColor3 = COLORS.Fondo,
        BorderSizePixel = 0,
        ClipsDescendants = false,
    }, self.ScreenGui)
    agregarRedondeo(self.Ventana, UDim.new(0, 12))

    -- Borde exterior sutil
    crearInstancia("UIStroke", {
        Color     = COLORS.Borde,
        Thickness = 1,
        Transparency = 0.4,
    }, self.Ventana)

    -- Efecto acrílico
    self._blur = aplicarAcrilico(self.Ventana)

    -- ── Barra de título ──────────────────────────────────────
    self.BarraTitulo = crearInstancia("Frame", {
        Name            = "BarraTitulo",
        Size            = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = COLORS.FondoPanel,
        BorderSizePixel = 0,
    }, self.Ventana)
    agregarRedondeo(self.BarraTitulo, UDim.new(0, 12))

    -- Parche para bordes inferiores cuadrados en la barra
    crearInstancia("Frame", {
        Size            = UDim2.new(1, 0, 0.5, 0),
        Position        = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = COLORS.FondoPanel,
        BorderSizePixel = 0,
    }, self.BarraTitulo)

    -- Ícono de acento
    crearInstancia("Frame", {
        Size            = UDim2.new(0, 4, 0, 24),
        Position        = UDim2.new(0, 14, 0.5, -12),
        BackgroundColor3 = COLORS.Acento,
        BorderSizePixel = 0,
    }, self.BarraTitulo)

    -- Título
    crearInstancia("TextLabel", {
        Size            = UDim2.new(0, 300, 1, 0),
        Position        = UDim2.new(0, 26, 0, 0),
        BackgroundTransparency = 1,
        Text            = titulo or "Script Hub",
        TextColor3      = COLORS.TextoPrincipal,
        Font            = FUENTE,
        TextSize        = 16,
        TextXAlignment  = Enum.TextXAlignment.Left,
    }, self.BarraTitulo)

    -- Subtítulo
    crearInstancia("TextLabel", {
        Size            = UDim2.new(0, 300, 1, 0),
        Position        = UDim2.new(0, 26, 0, 16),
        BackgroundTransparency = 1,
        Text            = subtitulo or "",
        TextColor3      = COLORS.TextoMuted,
        Font            = FUENTE_REGULAR,
        TextSize        = 11,
        TextXAlignment  = Enum.TextXAlignment.Left,
    }, self.BarraTitulo)

    -- Botón cerrar
    local btnCerrar = crearInstancia("TextButton", {
        Size            = UDim2.new(0, 32, 0, 32),
        Position        = UDim2.new(1, -42, 0.5, -16),
        BackgroundColor3 = COLORS.FondoItem,
        Text            = "✕",
        TextColor3      = COLORS.TextoSub,
        Font            = FUENTE,
        TextSize        = 13,
        BorderSizePixel = 0,
    }, self.BarraTitulo)
    agregarRedondeo(btnCerrar, UDim.new(0, 8))

    btnCerrar.MouseButton1Click:Connect(function()
        self:Destruir()
    end)
    btnCerrar.MouseEnter:Connect(function()
        tween(btnCerrar, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.Error })
    end)
    btnCerrar.MouseLeave:Connect(function()
        tween(btnCerrar, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.FondoItem })
    end)

    -- ── Barra lateral de tabs ────────────────────────────────
    self.BarraLateral = crearInstancia("Frame", {
        Name            = "BarraLateral",
        Size            = UDim2.new(0, 155, 1, -50),
        Position        = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = COLORS.FondoPanel,
        BorderSizePixel = 0,
    }, self.Ventana)

    -- Parche borde superior izquierdo
    crearInstancia("Frame", {
        Size            = UDim2.new(1, 0, 0.05, 0),
        BackgroundColor3 = COLORS.FondoPanel,
        BorderSizePixel = 0,
    }, self.BarraLateral)

    -- Separador vertical
    crearInstancia("Frame", {
        Size            = UDim2.new(0, 1, 1, 0),
        Position        = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = COLORS.Separador,
        BorderSizePixel = 0,
    }, self.BarraLateral)

    -- Lista de botones de tab
    self.ListaTabs = crearInstancia("ScrollingFrame", {
        Size            = UDim2.new(1, 0, 1, -10),
        Position        = UDim2.new(0, 0, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize      = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, self.BarraLateral)

    crearInstancia("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 4),
    }, self.ListaTabs)

    agregarPadding(self.ListaTabs, 4, 4, 6, 6)

    -- ── Contenedor de contenido ──────────────────────────────
    self.Contenido = crearInstancia("Frame", {
        Name            = "Contenido",
        Size            = UDim2.new(1, -156, 1, -50),
        Position        = UDim2.new(0, 156, 0, 50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, self.Ventana)

    -- ── Arrastre ─────────────────────────────────────────────
    self:_habilitarArrastre(self.BarraTitulo, self.Ventana)

    -- Animación de entrada
    self.Ventana.Size = UDim2.new(0, 680, 0, 0)
    self.Ventana.BackgroundTransparency = 1
    tween(self.Ventana, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, 680, 0, 460),
        BackgroundTransparency = 0,
    })

    return self
end

-- ── Arrastre ──────────────────────────────────────────────────
function UiLibrary:_habilitarArrastre(handle, objetivo)
    local arrastrandose = false
    local offsetInicio  = Vector2.new()

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastrandose = true
            offsetInicio  = Vector2.new(
                input.Position.X - objetivo.AbsolutePosition.X,
                input.Position.Y - objetivo.AbsolutePosition.Y
            )
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if arrastrandose and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = input.Position
            objetivo.Position = UDim2.new(
                0, pos.X - offsetInicio.X,
                0, pos.Y - offsetInicio.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastrandose = false
        end
    end)
end

-- ── Crear Tab ─────────────────────────────────────────────────
function UiLibrary:CrearTab(nombre, icono)
    local tab = {}

    -- Botón en la barra lateral
    local btnTab = crearInstancia("TextButton", {
        Size            = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = COLORS.FondoPanel,
        BackgroundTransparency = 1,
        Text            = (icono and (icono .. "  ") or "  ") .. nombre,
        TextColor3      = COLORS.TextoSub,
        Font            = FUENTE_REGULAR,
        TextSize        = 13,
        TextXAlignment  = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        LayoutOrder     = #self._tabs + 1,
    }, self.ListaTabs)
    agregarRedondeo(btnTab, RADIO_BORDE_PEQUENO)
    agregarPadding(btnTab, 0, 0, 10, 6)

    -- Indicador lateral izquierdo
    local indicador = crearInstancia("Frame", {
        Size            = UDim2.new(0, 3, 0.6, 0),
        Position        = UDim2.new(0, 0, 0.2, 0),
        BackgroundColor3 = COLORS.Acento,
        BorderSizePixel = 0,
        Visible         = false,
    }, btnTab)
    agregarRedondeo(indicador, UDim.new(0, 3))

    -- Frame de contenido del tab
    local frameContenido = crearInstancia("ScrollingFrame", {
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = COLORS.Acento,
        CanvasSize      = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible         = false,
    }, self.Contenido)

    crearInstancia("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 8),
    }, frameContenido)

    agregarPadding(frameContenido, 10, 10, 12, 12)

    tab.Boton         = btnTab
    tab.Indicador     = indicador
    tab.Frame         = frameContenido
    tab.Nombre        = nombre
    tab._secciones    = {}

    -- Lógica de selección
    btnTab.MouseButton1Click:Connect(function()
        self:_seleccionarTab(tab)
    end)

    btnTab.MouseEnter:Connect(function()
        if self._tabActual ~= tab then
            tween(btnTab, TweenInfo.new(0.15), { BackgroundTransparency = 0.7, BackgroundColor3 = COLORS.FondoItem })
        end
    end)
    btnTab.MouseLeave:Connect(function()
        if self._tabActual ~= tab then
            tween(btnTab, TweenInfo.new(0.15), { BackgroundTransparency = 1 })
        end
    end)

    table.insert(self._tabs, tab)

    -- Seleccionar el primero automáticamente
    if #self._tabs == 1 then
        self:_seleccionarTab(tab)
    end

    return tab
end

-- ── Seleccionar Tab ───────────────────────────────────────────
function UiLibrary:_seleccionarTab(tab)
    for _, t in ipairs(self._tabs) do
        t.Frame.Visible       = false
        t.Indicador.Visible   = false
        tween(t.Boton, TweenInfo.new(0.15), {
            BackgroundTransparency = 1,
            TextColor3             = COLORS.TextoSub,
        })
    end
    self._tabActual = tab
    tab.Frame.Visible     = true
    tab.Indicador.Visible = true
    tween(tab.Boton, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.6,
        BackgroundColor3       = COLORS.FondoItem,
        TextColor3             = COLORS.TextoPrincipal,
    })
end

-- ── Crear Sección dentro de un Tab ───────────────────────────
function UiLibrary:CrearSeccion(tab, titulo)
    local seccion = {}

    -- Encabezado de sección
    local header = crearInstancia("Frame", {
        Size            = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder     = #tab._secciones * 100,
    }, tab.Frame)

    crearInstancia("TextLabel", {
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text            = string.upper(titulo or "SECCIÓN"),
        TextColor3      = COLORS.Acento,
        Font            = FUENTE,
        TextSize        = 10,
        TextXAlignment  = Enum.TextXAlignment.Left,
        LetterSpacing   = 2,
    }, header)

    -- Línea separadora
    crearInstancia("Frame", {
        Size            = UDim2.new(1, 0, 0, 1),
        Position        = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = COLORS.Separador,
        BorderSizePixel = 0,
    }, header)

    seccion.Header      = header
    seccion._items      = {}
    seccion._layoutOrder = #tab._secciones * 100 + 1

    table.insert(tab._secciones, seccion)

    -- ── Método: AgregarEtiqueta ──────────────────────────────
    function seccion:AgregarEtiqueta(clave, valor, colorValor)
        local fila = crearInstancia("Frame", {
            Size            = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = COLORS.FondoItem,
            BorderSizePixel = 0,
            LayoutOrder     = self._layoutOrder + #self._items,
        }, tab.Frame)
        agregarRedondeo(fila, RADIO_BORDE_PEQUENO)
        agregarPadding(fila, 0, 0, 12, 12)

        local lblClave = crearInstancia("TextLabel", {
            Size            = UDim2.new(0.5, -4, 1, 0),
            BackgroundTransparency = 1,
            Text            = tostring(clave),
            TextColor3      = COLORS.TextoSub,
            Font            = FUENTE_REGULAR,
            TextSize        = 12,
            TextXAlignment  = Enum.TextXAlignment.Left,
        }, fila)

        local lblValor = crearInstancia("TextLabel", {
            Size            = UDim2.new(0.5, -4, 1, 0),
            Position        = UDim2.new(0.5, 4, 0, 0),
            BackgroundTransparency = 1,
            Text            = tostring(valor or "—"),
            TextColor3      = colorValor or COLORS.TextoPrincipal,
            Font            = FUENTE,
            TextSize        = 12,
            TextXAlignment  = Enum.TextXAlignment.Right,
            TextTruncate    = Enum.TextTruncate.AtEnd,
        }, fila)

        local item = { Frame = fila, LblClave = lblClave, LblValor = lblValor }

        function item:Actualizar(nuevoValor, nuevoColor)
            lblValor.Text = tostring(nuevoValor or "—")
            if nuevoColor then lblValor.TextColor3 = nuevoColor end
        end

        table.insert(self._items, item)
        return item
    end

    -- ── Método: AgregarBadge ─────────────────────────────────
    function seccion:AgregarBadge(clave, valor, activo)
        local fila = crearInstancia("Frame", {
            Size            = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = COLORS.FondoItem,
            BorderSizePixel = 0,
            LayoutOrder     = self._layoutOrder + #self._items,
        }, tab.Frame)
        agregarRedondeo(fila, RADIO_BORDE_PEQUENO)
        agregarPadding(fila, 0, 0, 12, 12)

        crearInstancia("TextLabel", {
            Size            = UDim2.new(0.6, -4, 1, 0),
            BackgroundTransparency = 1,
            Text            = tostring(clave),
            TextColor3      = COLORS.TextoSub,
            Font            = FUENTE_REGULAR,
            TextSize        = 12,
            TextXAlignment  = Enum.TextXAlignment.Left,
        }, fila)

        local colorBadge = activo and COLORS.Exito or COLORS.Error
        local badge = crearInstancia("Frame", {
            Size            = UDim2.new(0, 60, 0, 20),
            Position        = UDim2.new(1, -60, 0.5, -10),
            BackgroundColor3 = colorBadge,
            BorderSizePixel = 0,
        }, fila)
        agregarRedondeo(badge, UDim.new(0, 10))

        local badgeTexto = crearInstancia("TextLabel", {
            Size            = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text            = activo and "✓ SI" or "✗ NO",
            TextColor3      = Color3.fromRGB(255, 255, 255),
            Font            = FUENTE,
            TextSize        = 11,
        }, badge)

        local item = { Frame = fila, Badge = badge, BadgeTexto = badgeTexto }

        function item:Actualizar(nuevoActivo)
            local c = nuevoActivo and COLORS.Exito or COLORS.Error
            badge.BackgroundColor3 = c
            badgeTexto.Text = nuevoActivo and "✓ SI" or "✗ NO"
        end

        table.insert(self._items, item)
        return item
    end

    -- ── Método: AgregarTextoLargo ────────────────────────────
    function seccion:AgregarTextoLargo(clave, valor)
        local altura = 44
        local fila = crearInstancia("Frame", {
            Size            = UDim2.new(1, 0, 0, altura),
            BackgroundColor3 = COLORS.FondoItem,
            BorderSizePixel = 0,
            LayoutOrder     = self._layoutOrder + #self._items,
        }, tab.Frame)
        agregarRedondeo(fila, RADIO_BORDE_PEQUENO)
        agregarPadding(fila, 6, 6, 12, 12)

        crearInstancia("TextLabel", {
            Size            = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text            = tostring(clave),
            TextColor3      = COLORS.TextoSub,
            Font            = FUENTE_REGULAR,
            TextSize        = 11,
            TextXAlignment  = Enum.TextXAlignment.Left,
        }, fila)

        local lblValor = crearInstancia("TextLabel", {
            Size            = UDim2.new(1, 0, 0, 20),
            Position        = UDim2.new(0, 0, 0, 18),
            BackgroundTransparency = 1,
            Text            = tostring(valor or "—"),
            TextColor3      = COLORS.Acento,
            Font            = FUENTE,
            TextSize        = 12,
            TextXAlignment  = Enum.TextXAlignment.Left,
            TextTruncate    = Enum.TextTruncate.AtEnd,
        }, fila)

        local item = { Frame = fila, LblValor = lblValor }

        function item:Actualizar(v)
            lblValor.Text = tostring(v or "—")
        end

        table.insert(self._items, item)
        return item
    end

    return seccion
end

-- ── Destruir ──────────────────────────────────────────────────
function UiLibrary:Destruir()
    if self._blur then
        tween(self._blur, TweenInfo.new(0.3), { Size = 0 })
        task.delay(0.35, function()
            pcall(function() self._blur:Destroy() end)
        end)
    end
    tween(self.Ventana, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, 680, 0, 0),
        BackgroundTransparency = 1,
    })
    task.delay(0.35, function()
        pcall(function() self.ScreenGui:Destroy() end)
    end)
end

-- ── Exportar ──────────────────────────────────────────────────
UiLibrary.ObtenerVersionLibreria = obtenerVersionLibreria
UiLibrary.COLORES = COLORS

return UiLibrary
