--[[
    ╔════════════════════════════════════════════════════════════╗
    ║       PROJECT: WARCORE v1.2.0 (ADVANCED RX OVERHAUL)       ║
    ║       STUDIO: WARCORE LABS                                 ║
    ║------------------------------------------------------------║
    ║       LEAD DEVELOPER: ENZO CAVALCANTI                      ║
    ║       MOD: MODO MEU REI - INTERFACE PREMIUM MOBILE         ║
    ║       SISTEMA DE ESP DINÂMICO POR EQUIPE                   ║
    ╚════════════════════════════════════════════════════════════╝
]]

-- =============================================
-- SERVIÇOS E VARIÁVEIS GLOBAIS
-- =============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- =============================================
-- CONFIGURAÇÃO DO SISTEMA
-- =============================================
getgenv().SystemConfig = {
    -- Combate
    MiraAtiva = false,
    FovRadius = 500,
    Smoothness = 0.35,
    TeamCheck = true,

    -- Visual / Raio-X
    HighlightEnabled = false,
    HlDepthMode = "AlwaysOnTop",
    HlFillTransparency = 0.5,
    HlEnemyColor = Color3.fromRGB(255, 0, 0),
    HlAllyColor = Color3.fromRGB(0, 255, 100),
    DotEnabled = false,
    DotShape = "●",
    LineEnabled = false,
    LineColor = Color3.fromRGB(0, 255, 255),
    LineThickness = 1.5,

    -- Micro-HUD
    MicroHpEnabled = false,
    MicroDistEnabled = false,
    MicroTextSize = 8,
    MicroWidth = 35,
    DistColor = Color3.fromRGB(255, 255, 255),

    -- Iluminação
    FullBright = false,
    NoShadows = false,
    ClarezaMod = false,

    -- Monitor
    ShowFPS = false,
    ShowPlayers = false,

    -- Movimento
    FlyEnabled = false,
    FlySpeed = 50,
    FlyInfinite = false,
    SpeedEnabled = false,
    SpeedValue = 50,
    JumpEnabled = false,
    JumpPower = 100,
    InfiniteJump = false,
}

-- =============================================
-- VARIÁVEIS AUXILIARES
-- =============================================
local NoClipAtivo = false
local isTeleportOpen = false
local NoClipConnection = nil
local flyVelocity = nil
local flyConnection = nil
local OriginalWalkSpeed = 16
local OriginalJumpPower = 50

-- Armazenar ESP objects
local espObjects = {}
local highlightObjects = {}
local dotObjects = {}
local lineObjects = {}
local microHUDObjects = {}

-- =============================================
-- INTERFACE PRINCIPAL - MODO MEU REI
-- =============================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- =============================================
-- BOTÃO FLUTUANTE ARRASTÁVEL
-- =============================================
local FloatingBtn = Instance.new("TextButton", ScreenGui)
FloatingBtn.Visible = true
FloatingBtn.Size = UDim2.new(0, 80, 0, 40)
FloatingBtn.Position = UDim2.new(0.85, 0, 0.85, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 30)
FloatingBtn.Text = "👑 Menu"
FloatingBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.TextSize = 14
FloatingBtn.Draggable = true
FloatingBtn.Active = true
FloatingBtn.ZIndex = 10

local BtnCorner = Instance.new("UICorner", FloatingBtn)
BtnCorner.CornerRadius = UDim.new(0, 12)

local BtnStroke = Instance.new("UIStroke", FloatingBtn)
BtnStroke.Thickness = 2
BtnStroke.Color = Color3.fromRGB(60, 70, 120)
BtnStroke.Transparency = 0.3

-- =============================================
-- PAINEL PRINCIPAL - SCROLLINGFRAME MOBILE
-- =============================================
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Visible = false
MainFrame.Size = UDim2.new(0, 320, 0, 480)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 22)
MainFrame.BackgroundTransparency = 0.05
MainFrame.ZIndex = 5

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(40, 50, 100)
MainStroke.Transparency = 0.3

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(15, 18, 32)
Header.BackgroundTransparency = 0.1

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 16)

local TitleLabel = Instance.new("TextLabel", Header)
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "👑 MODO MEU REI"
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextScaled = true

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 30)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16

local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 8)

-- ScrollingFrame para conteúdo
local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollFrame.Size = UDim2.new(1, -10, 1, -60)
ScrollFrame.Position = UDim2.new(0, 5, 0, 55)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 70, 150)
ScrollFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- =============================================
-- FUNÇÃO PARA CRIAR SEÇÕES DO MENU
-- =============================================
function CreateSection(title, color)
    local section = Instance.new("Frame", ScrollFrame)
    section.Size = UDim2.new(1, 0, 0, 35)
    section.BackgroundTransparency = 1
    section.LayoutOrder = 0

    local line = Instance.new("Frame", section)
    line.Size = UDim2.new(1, 0, 0, 2)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = color or Color3.fromRGB(60, 70, 150)
    line.BackgroundTransparency = 0.5

    local label = Instance.new("TextLabel", section)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(200, 200, 230)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Center

    return section
end

function CreateToggle(title, configKey, defaultValue, callback)
    local frame = Instance.new("Frame", ScrollFrame)
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(15, 18, 30)
    frame.BackgroundTransparency = 0.3
    frame.LayoutOrder = 0

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 50, 0, 28)
    btn.Position = UDim2.new(1, -60, 0.5, -14)
    btn.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(40, 40, 60)
    btn.Text = defaultValue and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11

    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)

    local currentValue = defaultValue

    btn.MouseButton1Click:Connect(function()
        currentValue = not currentValue
        btn.BackgroundColor3 = currentValue and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(40, 40, 60)
        btn.Text = currentValue and "ON" or "OFF"

        if configKey then
            getgenv().SystemConfig[configKey] = currentValue
        end

        if callback then
            callback(currentValue)
        end
    end)

    return { frame = frame, btn = btn, setValue = function(v)
        currentValue = v
        btn.BackgroundColor3 = v and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(40, 40, 60)
        btn.Text = v and "ON" or "OFF"
        if configKey then getgenv().SystemConfig[configKey] = v end
        if callback then callback(v) end
    end }
end

function CreateSlider(title, configKey, min, max, default, increment, callback)
    local frame = Instance.new("Frame", ScrollFrame)
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(15, 18, 30)
    frame.BackgroundTransparency = 0.3
    frame.LayoutOrder = 0

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = title .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Center

    local slider = Instance.new("Frame", frame)
    slider.Size = UDim2.new(1, -20, 0, 6)
    slider.Position = UDim2.new(0, 10, 0, 28)
    slider.BackgroundColor3 = Color3.fromRGB(30, 35, 55)
    slider.BackgroundTransparency = 0.5

    local sliderCorner = Instance.new("UICorner", slider)
    sliderCorner.CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame", slider)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(60, 70, 180)
    fill.BackgroundTransparency = 0.3

    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0, 3)

    local drag = Instance.new("TextButton", slider)
    drag.Size = UDim2.new(0, 20, 0, 20)
    drag.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    drag.BackgroundColor3 = Color3.fromRGB(80, 90, 200)
    drag.Text = ""
    drag.BackgroundTransparency = 0.3

    local dragCorner = Instance.new("UICorner", drag)
    dragCorner.CornerRadius = UDim.new(0, 10)

    local currentValue = default
    local dragging = false

    drag.MouseButton1Down:Connect(function()
        dragging = true
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local absoluteSize = slider.AbsoluteSize.X
            local mouseX = input.Position.X - slider.AbsolutePosition.X
            local percent = math.clamp(mouseX / absoluteSize, 0, 1)
            local value = min + (max - min) * percent
            value = math.round(value / increment) * increment
            value = math.clamp(value, min, max)

            currentValue = value
            fill.Size = UDim2.new(percent, 0, 1, 0)
            drag.Position = UDim2.new(percent, -10, 0.5, -10)
            label.Text = title .. ": " .. tostring(value)

            if configKey then getgenv().SystemConfig[configKey] = value end
            if callback then callback(value) end
        end
    end)

    return { frame = frame, setValue = function(v)
        local percent = (v - min) / (max - min)
        currentValue = v
        fill.Size = UDim2.new(percent, 0, 1, 0)
        drag.Position = UDim2.new(percent, -10, 0.5, -10)
        label.Text = title .. ": " .. tostring(v)
        if configKey then getgenv().SystemConfig[configKey] = v end
        if callback then callback(v) end
    end }
end

function CreateColorPicker(title, configKey, defaultColor, callback)
    local frame = Instance.new("Frame", ScrollFrame)
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(15, 18, 30)
    frame.BackgroundTransparency = 0.3
    frame.LayoutOrder = 0

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local colorBtn = Instance.new("TextButton", frame)
    colorBtn.Size = UDim2.new(0, 40, 0, 28)
    colorBtn.Position = UDim2.new(1, -50, 0.5, -14)
    colorBtn.BackgroundColor3 = defaultColor
    colorBtn.Text = ""
    colorBtn.BackgroundTransparency = 0.3

    local btnCorner = Instance.new("UICorner", colorBtn)
    btnCorner.CornerRadius = UDim.new(0, 6)

    local currentColor = defaultColor

    colorBtn.MouseButton1Click:Connect(function()
        -- Simples seletor de cores com algumas opções pré-definidas
        local colors = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(128, 128, 128)
        }
        local currentIndex = 0
        for i, c in ipairs(colors) do
            if c.R == currentColor.R and c.G == currentColor.G and c.B == currentColor.B then
                currentIndex = i
                break
            end
        end
        local nextIndex = currentIndex % #colors + 1
        currentColor = colors[nextIndex]
        colorBtn.BackgroundColor3 = currentColor

        if configKey then getgenv().SystemConfig[configKey] = currentColor end
        if callback then callback(currentColor) end
    end)

    return { frame = frame, setColor = function(c)
        currentColor = c
        colorBtn.BackgroundColor3 = c
        if configKey then getgenv().SystemConfig[configKey] = c end
        if callback then callback(c) end
    end }
end

function CreateDropdown(title, options, defaultOption, callback)
    local frame = Instance.new("Frame", ScrollFrame)
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(15, 18, 30)
    frame.BackgroundTransparency = 0.3
    frame.LayoutOrder = 0

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 0, 18)
    label.Position = UDim2.new(0, 5, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Center

    local dropdownBtn = Instance.new("TextButton", frame)
    dropdownBtn.Size = UDim2.new(0.8, 0, 0, 28)
    dropdownBtn.Position = UDim2.new(0.1, 0, 0, 20)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 50)
    dropdownBtn.Text = defaultOption
    dropdownBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.TextSize = 12

    local btnCorner = Instance.new("UICorner", dropdownBtn)
    btnCorner.CornerRadius = UDim.new(0, 6)

    local currentOption = defaultOption
    local dropdownOpen = false
    local dropdownList = nil

    dropdownBtn.MouseButton1Click:Connect(function()
        if dropdownList then
            dropdownList:Destroy()
            dropdownList = nil
            dropdownOpen = false
            return
        end

        dropdownOpen = true
        dropdownList = Instance.new("Frame", frame)
        dropdownList.Size = UDim2.new(0.8, 0, 0, math.min(#options * 30, 120))
        dropdownList.Position = UDim2.new(0.1, 0, 0, 48)
        dropdownList.BackgroundColor3 = Color3.fromRGB(20, 23, 40)
        dropdownList.BackgroundTransparency = 0.1

        local listCorner = Instance.new("UICorner", dropdownList)
        listCorner.CornerRadius = UDim.new(0, 6)

        local listLayout = Instance.new("UIListLayout", dropdownList)
        listLayout.Padding = UDim.new(0, 2)

        for _, option in ipairs(options) do
            local optBtn = Instance.new("TextButton", dropdownList)
            optBtn.Size = UDim2.new(1, 0, 0, 28)
            optBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 50)
            optBtn.Text = option
            optBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 11

            local optCorner = Instance.new("UICorner", optBtn)
            optCorner.CornerRadius = UDim.new(0, 4)

            optBtn.MouseButton1Click:Connect(function()
                currentOption = option
                dropdownBtn.Text = option
                if dropdownList then dropdownList:Destroy(); dropdownList = nil; dropdownOpen = false end
                if callback then callback(option) end
            end)
        end
    end)

    -- Fechar dropdown ao clicar fora
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dropdownList then
                local mousePos = UserInputService:GetMouseLocation()
                local absolutePos = dropdownList.AbsolutePosition
                local absoluteSize = dropdownList.AbsoluteSize
                if mousePos.X < absolutePos.X or mousePos.X > absolutePos.X + absoluteSize.X or
                   mousePos.Y < absolutePos.Y or mousePos.Y > absolutePos.Y + absoluteSize.Y then
                    dropdownList:Destroy()
                    dropdownList = nil
                    dropdownOpen = false
                end
            end
        end
    end)

    return { frame = frame, setOption = function(opt)
        currentOption = opt
        dropdownBtn.Text = opt
        if callback then callback(opt) end
    end }
end

-- =============================================
-- CONSTRUÇÃO DO MENU
-- =============================================

-- ABA COMBATE
CreateSection("🎯 COMBATE", Color3.fromRGB(200, 50, 50))

local miraToggle = CreateToggle("Mira Assistida", "MiraAtiva", false, function(v)
    getgenv().SystemConfig.MiraAtiva = v
end)

CreateSlider("Suavidade", "Smoothness", 0.1, 1, 0.35, 0.05, function(v)
    getgenv().SystemConfig.Smoothness = v
end)

-- ABA RAIO-X
CreateSection("🔍 RAIO-X / ESP", Color3.fromRGB(50, 200, 100))

local rxToggle = CreateToggle("Ativar Raio-X", "HighlightEnabled", false, function(v)
    getgenv().SystemConfig.HighlightEnabled = v
    if not v then
        for _, obj in pairs(highlightObjects) do
            pcall(function() obj:Destroy() end)
        end
        highlightObjects = {}
    end
end)

CreateToggle("Ponto na Cabeça", "DotEnabled", false, function(v)
    getgenv().SystemConfig.DotEnabled = v
    if not v then
        for _, obj in pairs(dotObjects) do
            pcall(function() obj:Destroy() end)
        end
        dotObjects = {}
    end
end)

CreateToggle("Linha de Mira", "LineEnabled", false, function(v)
    getgenv().SystemConfig.LineEnabled = v
    if not v then
        for _, obj in pairs(lineObjects) do
            pcall(function() obj:Destroy() end)
        end
        lineObjects = {}
    end
end)

CreateToggle("Micro-HUD (Vida)", "MicroHpEnabled", false, function(v)
    getgenv().SystemConfig.MicroHpEnabled = v
end)

CreateToggle("Micro-HUD (Distância)", "MicroDistEnabled", false, function(v)
    getgenv().SystemConfig.MicroDistEnabled = v
end)

CreateSlider("Tamanho do Texto", "MicroTextSize", 6, 24, 8, 1, function(v)
    getgenv().SystemConfig.MicroTextSize = v
end)

CreateSlider("Largura da Barra", "MicroWidth", 20, 100, 35, 5, function(v)
    getgenv().SystemConfig.MicroWidth = v
end)

CreateDropdown("Modo de Visibilidade", {"Ver através", "Ocultar atrás"}, "Ver através", function(opt)
    if opt == "Ver através" then
        getgenv().SystemConfig.HlDepthMode = "AlwaysOnTop"
    else
        getgenv().SystemConfig.HlDepthMode = "Occluded"
    end
end)

CreateSlider("Transparência do Brilho", "HlFillTransparency", 0, 1, 0.5, 0.05, function(v)
    getgenv().SystemConfig.HlFillTransparency = v
end)

CreateColorPicker("Cor Inimigos", "HlEnemyColor", Color3.fromRGB(255, 0, 0), function(c)
    getgenv().SystemConfig.HlEnemyColor = c
end)

CreateColorPicker("Cor Aliados", "HlAllyColor", Color3.fromRGB(0, 255, 100), function(c)
    getgenv().SystemConfig.HlAllyColor = c
end)

CreateColorPicker("Cor Linha de Mira", "LineColor", Color3.fromRGB(0, 255, 255), function(c)
    getgenv().SystemConfig.LineColor = c
end)

CreateSlider("Espessura da Linha", "LineThickness", 0.5, 5, 1.5, 0.5, function(v)
    getgenv().SystemConfig.LineThickness = v
end)

CreateDropdown("Forma do Ponto", {"● Círculo", "▲ Triângulo", "■ Quadrado", "◆ Losango", "★ Estrela"}, "● Círculo", function(opt)
    local shapeMap = {
        ["● Círculo"] = "●",
        ["▲ Triângulo"] = "▲",
        ["■ Quadrado"] = "■",
        ["◆ Losango"] = "◆",
        ["★ Estrela"] = "★"
    }
    getgenv().SystemConfig.DotShape = shapeMap[opt] or "●"
end)

-- ABA MOVIMENTO
CreateSection("🕊️ MOVIMENTO", Color3.fromRGB(50, 150, 255))

-- Fly
local flyToggle = CreateToggle("Fly", "FlyEnabled", false, function(v)
    if v then
        startFly()
    else
        stopFly()
    end
end)

CreateToggle("Modo Infinito (Fly)", "FlyInfinite", false, function(v)
    getgenv().SystemConfig.FlyInfinite = v
end)

CreateSlider("Velocidade Fly", "FlySpeed", 1, 500, 50, 1, function(v)
    getgenv().SystemConfig.FlySpeed = v
end)

-- No-Clip
CreateToggle("No-Clip", nil, false, function(v)
    NoClipAtivo = v
    if NoClipAtivo then
        NoClipConnection = RunService.Stepped:Connect(function()
            local char = Player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
        local char = Player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)

-- Speed
local speedToggle = CreateToggle("Speed Hack", "SpeedEnabled", false, function(v)
    getgenv().SystemConfig.SpeedEnabled = v
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if v then
            hum.WalkSpeed = getgenv().SystemConfig.SpeedValue
        else
            hum.WalkSpeed = OriginalWalkSpeed
        end
    end
end)

CreateSlider("Velocidade", "SpeedValue", 16, 200, 50, 1, function(v)
    getgenv().SystemConfig.SpeedValue = v
    if getgenv().SystemConfig.SpeedEnabled then
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end)

-- Jump
local jumpToggle = CreateToggle("Super Pulo", "JumpEnabled", false, function(v)
    getgenv().SystemConfig.JumpEnabled = v
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if v then
            hum.JumpPower = getgenv().SystemConfig.JumpPower
        else
            hum.JumpPower = OriginalJumpPower
        end
    end
end)

CreateSlider("Altura do Pulo", "JumpPower", 50, 300, 100, 5, function(v)
    getgenv().SystemConfig.JumpPower = v
    if getgenv().SystemConfig.JumpEnabled then
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end
end)

CreateToggle("Pulo Infinito", "InfiniteJump", false, function(v)
    getgenv().SystemConfig.InfiniteJump = v
end)

-- ABA ILUMINAÇÃO
CreateSection("💡 ILUMINAÇÃO", Color3.fromRGB(255, 200, 50))

CreateToggle("FullBright", "FullBright", false, function(v)
    getgenv().SystemConfig.FullBright = v
    if v then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 10
        Lighting.ClockTime = 12
        Lighting.FogEnd = 10000
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Ambient = OriginalSettings.Ambient
        Lighting.Brightness = OriginalSettings.Brightness
        Lighting.ClockTime = OriginalSettings.ClockTime
        Lighting.FogEnd = OriginalSettings.FogEnd
        Lighting.OutdoorAmbient = OriginalSettings.OutdoorAmbient
    end
end)

CreateToggle("Clareza Aprimorada", "ClarezaMod", false, function(v)
    getgenv().SystemConfig.ClarezaMod = v
end)

CreateToggle("Remover Sombras", "NoShadows", false, function(v)
    Lighting.GlobalShadows = not v
    getgenv().SystemConfig.NoShadows = v
end)

-- =============================================
-- FUNÇÃO PARA INICIAR FLY
-- =============================================
function startFly()
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
        hum.AutoRotate = true
    end

    if flyVelocity then flyVelocity:Destroy() end
    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.Name = "FlyVelocity"
    flyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    flyVelocity.Parent = hrp
    getgenv().SystemConfig.FlyEnabled = true

    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RunService.RenderStepped:Connect(function()
        if not getgenv().SystemConfig.FlyEnabled then stopFly(); return end
        local char = Player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if not flyVelocity then return end

        local speed = getgenv().SystemConfig.FlySpeed
        local targetVel = Vector3.zero

        if getgenv().SystemConfig.FlyInfinite then
            targetVel = Camera.CFrame.LookVector * speed
        else
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                local flatLook = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
                if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
                local flatCamCFrame = CFrame.lookAt(Vector3.zero, flatLook)
                local rawInput = flatCamCFrame:VectorToObjectSpace(moveDir)
                targetVel = Camera.CFrame:VectorToWorldSpace(rawInput) * speed
            else
                targetVel = Vector3.zero
            end
        end
        flyVelocity.Velocity = targetVel
    end)
end

function stopFly()
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
    getgenv().SystemConfig.FlyEnabled = false
end

-- =============================================
-- FUNÇÕES DE ESP (RAIO-X DINÂMICO POR EQUIPE)
-- =============================================

function updateESP()
    if not getgenv().SystemConfig.HighlightEnabled then
        -- Limpar highlights
        for _, obj in pairs(highlightObjects) do
            pcall(function() obj:Destroy() end)
        end
        highlightObjects = {}
        return
    end

    -- Verificar todos os jogadores
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            local char = otherPlayer.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local isAlly = (otherPlayer.Team == Player.Team and Player.Team ~= nil)
            local color = isAlly and getgenv().SystemConfig.HlAllyColor or getgenv().SystemConfig.HlEnemyColor

            -- Criar ou atualizar Highlight
            local highlight = highlightObjects[otherPlayer]
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Parent = char
                highlightObjects[otherPlayer] = highlight
            end

            highlight.Adornee = char
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.FillTransparency = getgenv().SystemConfig.HlFillTransparency
            highlight.OutlineTransparency = 0.3
            highlight.DepthMode = getgenv().SystemConfig.HlDepthMode == "AlwaysOnTop" and
                Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
        end
    end
end

-- =============================================
-- FUNÇÕES DE DOT (PONTO NA CABEÇA)
-- =============================================

function updateDots()
    if not getgenv().SystemConfig.DotEnabled then
        for _, obj in pairs(dotObjects) do
            pcall(function() obj:Destroy() end)
        end
        dotObjects = {}
        return
    end

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            local char = otherPlayer.Character
            local head = char:FindFirstChild("Head")
            if not head then continue end

            local isAlly = (otherPlayer.Team == Player.Team and Player.Team ~= nil)
            local color = isAlly and getgenv().SystemConfig.HlAllyColor or getgenv().SystemConfig.HlEnemyColor

            local dot = dotObjects[otherPlayer]
            if not dot then
                dot = Instance.new("BillboardGui")
                dot.Size = UDim2.new(0, 30, 0, 30)
                dot.AlwaysOnTop = true
                dot.Parent = head

                local label = Instance.new("TextLabel", dot)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.GothamBold
                label.TextSize = 24
                label.TextColor3 = color
                label.Text = getgenv().SystemConfig.DotShape

                dotObjects[otherPlayer] = dot
            else
                -- Atualizar cor
                local label = dot:FindFirstChildOfClass("TextLabel")
                if label then
                    label.TextColor3 = color
                    label.Text = getgenv().SystemConfig.DotShape
                end
            end
        end
    end
end

-- =============================================
-- FUNÇÕES DE LINE (LINHA DE MIRA)
-- =============================================

function updateLines()
    if not getgenv().SystemConfig.LineEnabled then
        for _, obj in pairs(lineObjects) do
            pcall(function() obj:Destroy() end)
        end
        lineObjects = {}
        return
    end

    local cameraPos = Camera.CFrame.Position

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            local char = otherPlayer.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local isAlly = (otherPlayer.Team == Player.Team and Player.Team ~= nil)
            local color = isAlly and getgenv().SystemConfig.HlAllyColor or getgenv().SystemConfig.HlEnemyColor

            local line = lineObjects[otherPlayer]
            if not line then
                line = Drawing.new("Line")
                line.Thickness = getgenv().SystemConfig.LineThickness
                line.Color = color
                line.Transparency = 1
                line.Visible = true
                lineObjects[otherPlayer] = line
            end

            -- Atualizar posição
            local headPos = char:FindFirstChild("Head")
            if headPos then
                local pos, onScreen = Camera:WorldToViewportPoint(headPos.Position)
                if onScreen and pos.Z > 0 then
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    line.From = center
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Color = color
                    line.Thickness = getgenv().SystemConfig.LineThickness
                    line.Visible = true
                else
                    line.Visible = false
                end
            end
        end
    end
end

-- =============================================
-- FUNÇÕES DE MICRO-HUD
-- =============================================

function updateMicroHUD()
    if not getgenv().SystemConfig.MicroHpEnabled and not getgenv().SystemConfig.MicroDistEnabled then
        for _, obj in pairs(microHUDObjects) do
            pcall(function() obj:Destroy() end)
        end
        microHUDObjects = {}
        return
    end

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            local char = otherPlayer.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then continue end

            local isAlly = (otherPlayer.Team == Player.Team and Player.Team ~= nil)
            local color = isAlly and getgenv().SystemConfig.HlAllyColor or getgenv().SystemConfig.HlEnemyColor

            local billboard = microHUDObjects[otherPlayer]
            if not billboard then
                billboard = Instance.new("BillboardGui", hrp)
                billboard.Name = "Warcore_MicroHUD"
                billboard.AlwaysOnTop = true
                billboard.ExtentsOffset = Vector3.new(0, -4, 0)

                local bg = Instance.new("Frame", billboard)
                bg.Name = "Background"
                bg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
                bg.BackgroundTransparency = 0.5
                bg.BorderSizePixel = 0

                local bgCorner = Instance.new("UICorner", bg)
                bgCorner.CornerRadius = UDim.new(0, 4)

                local hpBar = Instance.new("Frame", bg)
                hpBar.Name = "HPBar"
                hpBar.BackgroundColor3 = color
                hpBar.BorderSizePixel = 0

                local hpCorner = Instance.new("UICorner", hpBar)
                hpCorner.CornerRadius = UDim.new(0, 3)

                local nameLabel = Instance.new("TextLabel", billboard)
                nameLabel.Name = "NameLabel"
                nameLabel.BackgroundTransparency = 1
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextStrokeTransparency = 0.5
                nameLabel.TextXAlignment = Enum.TextXAlignment.Center

                local distLabel = Instance.new("TextLabel", billboard)
                distLabel.Name = "DistLabel"
                distLabel.BackgroundTransparency = 1
                distLabel.Font = Enum.Font.Gotham
                distLabel.TextColor3 = getgenv().SystemConfig.DistColor
                distLabel.TextStrokeTransparency = 0.5
                distLabel.TextXAlignment = Enum.TextXAlignment.Center

                microHUDObjects[otherPlayer] = billboard
            end

            -- Atualizar tamanho
            local textSize = getgenv().SystemConfig.MicroTextSize
            local width = getgenv().SystemConfig.MicroWidth

            local showHp = getgenv().SystemConfig.MicroHpEnabled
            local showDist = getgenv().SystemConfig.MicroDistEnabled

            local totalHeight = 0
            if showHp then totalHeight = totalHeight + 6 end
            if showDist then totalHeight = totalHeight + textSize + 2 end
            if showDist then totalHeight = totalHeight + textSize + 2 end -- Nome + Distância

            billboard.Size = UDim2.new(0, width, 0, totalHeight + 4)

            local bg = billboard.Background
            if bg then
                bg.Size = UDim2.new(1, 0, 1, 0)
            end

            local hpBar = bg and bg:FindFirstChild("HPBar")
            if hpBar then
                local hpPercent = hum.Health / hum.MaxHealth
                hpBar.Size = UDim2.new(hpPercent, 0, 0, 4)
                hpBar.Position = UDim2.new(0, 2, 0, 1)
                hpBar.BackgroundColor3 = color
                hpBar.Visible = showHp
            end

            local nameLabel = billboard:FindFirstChild("NameLabel")
            if nameLabel then
                nameLabel.Size = UDim2.new(1, 0, 0, textSize + 2)
                nameLabel.Position = UDim2.new(0, 0, 0, (showHp and 6 or 0))
                nameLabel.Text = showDist and otherPlayer.Name or ""
                nameLabel.TextSize = textSize
                nameLabel.Visible = showDist
            end

            local distLabel = billboard:FindFirstChild("DistLabel")
            if distLabel then
                local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
                distLabel.Size = UDim2.new(1, 0, 0, textSize + 2)
                distLabel.Position = UDim2.new(0, 0, 0, (showHp and 6 or 0) + (showDist and textSize + 2 or 0))
                distLabel.Text = showDist and string.format("%.1fm", distance) or ""
                distLabel.TextSize = textSize
                distLabel.TextColor3 = getgenv().SystemConfig.DistColor
                distLabel.Visible = showDist
            end
        end
    end
end

-- =============================================
-- MIRA ASSISTIDA (AIMBOT)
-- =============================================

function aimbotUpdate()
    if not getgenv().SystemConfig.MiraAtiva then return end

    local targetPart = getTarget()
    if targetPart then
        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
        local smoothness = getgenv().SystemConfig.Smoothness
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothness)
    end
end

function getTarget()
    local closest, shortest = nil, getgenv().SystemConfig.FovRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local isTeam = (p.Team == Player.Team and Player.Team ~= nil)
                if not (isTeam and getgenv().SystemConfig.TeamCheck) then
                    local pos, vis = Camera:WorldToViewportPoint(head.Position)
                    if vis and pos.Z > 0 then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortest then
                            shortest = dist
                            closest = head
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- =============================================
-- FULLBRIGHT / CLAREZA
-- =============================================

function updateLighting()
    if getgenv().SystemConfig.FullBright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 10
        Lighting.ClockTime = 12
        Lighting.FogEnd = 10000
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end

    if getgenv().SystemConfig.ClarezaMod then
        Lighting.Brightness = 5
        Lighting.ExposureCompensation = 2
        Lighting.ColorCorrection.Enabled = true
        Lighting.ColorCorrection.Saturation = 0.8
        Lighting.ColorCorrection.Contrast = 1.2
        Lighting.ColorCorrection.Brightness = 1.1
    else
        Lighting.ExposureCompensation = 0
        if Lighting:FindFirstChild("ColorCorrection") then
            Lighting.ColorCorrection.Enabled = false
        end
    end
end

-- =============================================
-- PULO INFINITO
-- =============================================

local function handleInfiniteJump()
    if not getgenv().SystemConfig.InfiniteJump then return end

    UserInputService.JumpRequest:Connect(function()
        if getgenv().SystemConfig.InfiniteJump then
            local char = Player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-- =============================================
-- RENDER LOOP PRINCIPAL
-- =============================================

RunService.RenderStepped:Connect(function()
    -- Atualizar ESP (Highlight)
    updateESP()

    -- Atualizar Dots
    updateDots()

    -- Atualizar Lines
    updateLines()

    -- Atualizar Micro-HUD
    updateMicroHUD()

    -- Atualizar mira assistida
    aimbotUpdate()

    -- Atualizar iluminação
    updateLighting()

    -- Atualizar pulo infinito
    handleInfiniteJump()
end)

-- =============================================
-- CONTROLES DE INTERFACE
-- =============================================

FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Arrastar o MainFrame
local dragging = false
local dragStart = nil
local frameStart = nil

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        frameStart = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            frameStart.X.Scale,
            frameStart.X.Offset + delta.X,
            frameStart.Y.Scale,
            frameStart.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- =============================================
-- INICIALIZAÇÃO
-- =============================================

print("👑 WARCORE v1.2.0 - MODO MEU REI")
print("Sistema de ESP Dinâmico por Equipe Ativo")
print("Desenvolvido por Enzo Cavalcanti")

-- Iniciar verificações de jogadores
Players.PlayerAdded:Connect(function()
    -- Limpar objetos antigos
    highlightObjects = {}
    dotObjects = {}
    lineObjects = {}
    microHUDObjects = {}
end)

Players.PlayerRemoving:Connect(function(player)
    -- Limpar objetos do jogador removido
    if highlightObjects[player] then
        pcall(function() highlightObjects[player]:Destroy() end)
        highlightObjects[player] = nil
    end
    if dotObjects[player] then
        pcall(function() dotObjects[player]:Destroy() end)
        dotObjects[player] = nil
    end
    if lineObjects[player] then
        pcall(function() lineObjects[player]:Destroy() end)
        lineObjects[player] = nil
    end
    if microHUDObjects[player] then
        pcall(function() microHUDObjects[player]:Destroy() end)
        microHUDObjects[player] = nil
    end
end)

-- Salvar configurações originais
OriginalSettings.Ambient = Lighting.Ambient
OriginalSettings.Brightness = Lighting.Brightness
OriginalSettings.ClockTime = Lighting.ClockTime
OriginalSettings.FogEnd = Lighting.FogEnd
OriginalSettings.OutdoorAmbient = Lighting.OutdoorAmbient

-- =============================================
-- LIMPEZA E FINALIZAÇÃO
-- =============================================

print("✅ Script inicializado com sucesso!")
print("Clique em '👑 Menu' para abrir o painel.")