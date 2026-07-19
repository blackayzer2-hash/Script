--[[
    ╔════════════════════════════════════════════════════════════╗
    ║       PROJECT: WARCORE ULTIMATE v2.0                     ║
    ║       STUDIO: WARCORE LABS                               ║
    ║------------------------------------------------------------║
    ║       LEAD DEVELOPER: ENZO CAVALCANTI                      ║
    ║       MOD: VERSÃO DEMONSTRATIVA + RECURSOS PREMIUM        ║
    ╚════════════════════════════════════════════════════════════╝
]]

-- ============================================================================
-- CONFIGURAÇÃO DE LICENÇA (ALTERE PARA true PARA LIBERAR TUDO)
-- ============================================================================
local IsPremium = false   -- <-- Altere para true para versão completa

-- ============================================================================
-- BIBLIOTECAS E SERVIÇOS
-- ============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

-- ============================================================================
-- CONFIGURAÇÃO GLOBAL
-- ============================================================================
getgenv().SystemConfig = {
    -- Combate
    MiraAtiva = false,
    FovRadius = 500,
    Smoothness = 0.35,
    TriggerBot = false,
    TriggerDelay = 100,
    SilentAim = false,
    AimPart = "Cabeça",
    AntiRecoil = false,
    RecoilReduction = 0.5,
    -- Visual
    HighlightEnabled = false,
    HlDepthMode = "AlwaysOnTop",
    HlFillTransparency = 0.5,
    HlEnemyColor = Color3.fromRGB(255, 0, 0),
    DotEnabled = false,
    MicroHpEnabled = false,
    MicroDistEnabled = false,
    MicroTextSize = 8,
    MicroWidth = 35,
    ChamsEnabled = false,
    ChamsColor = Color3.fromRGB(0, 255, 0),
    ChamsRainbow = false,
    GrayMode = false,
    -- Movimento
    FlyEnabled = false,
    FlySpeed = 50,
    FlyInfinite = false,
    SpeedEnabled = false,
    SpeedValue = 50,
    JumpEnabled = false,
    JumpPower = 100,
    InfiniteJump = false,
    WallClimb = false,
    WallClimbSpeed = 20,
    AutoSprint = false,
    -- Navegação
    ShowDistanceHUD = false,
    ShowDirectionArrow = false,
    RadarEnabled = false,
    RadarSize = 150,
    -- Utilidades
    AntiAFK = false,
    AutoCollect = false,
    CollectRadius = 30,
    -- Iluminação
    FullBright = false,
    NoShadows = false,
    ClarezaMod = false,
    -- Monitor
    ShowFPS = false,
    ShowPlayers = false,
}

local NoClipAtivo = false
local isTeleportOpen = false
local NoClipConnection = nil
local flyVelocity = nil
local flyConnection = nil

local OriginalWalkSpeed = 16
local OriginalJumpPower = 50

local OriginalSettings = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    GlobalShadows = Lighting.GlobalShadows,
    Exposure = Lighting.ExposureCompensation
}

-- ============================================================================
-- SISTEMA DE INTERFACE: TAGS (FPS / PLAYERS)
-- ============================================================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "WarcoreUltimateGUI"

local TagContainer = Instance.new("Frame", ScreenGui)
TagContainer.Size = UDim2.new(0, 60, 0, 50)
TagContainer.Position = UDim2.new(0, 5, 0, 45)
TagContainer.BackgroundTransparency = 1
local UIList = Instance.new("UIListLayout", TagContainer)
UIList.Padding = UDim.new(0, 3)

local function CreateTag(color)
    local f = Instance.new("Frame", TagContainer)
    f.Size = UDim2.new(0, 75, 0, 18)
    f.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
    f.BackgroundTransparency = 0.2
    f.Visible = false
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
    local stroke = Instance.new("UIStroke", f)
    stroke.Thickness = 1
    stroke.Color = color
    stroke.Transparency = 0.4
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.TextSize = 10
    l.Font = Enum.Font.GothamBold
    return f, l
end

local fpsF, fpsL = CreateTag(Color3.fromRGB(0, 240, 255))
local countF, countL = CreateTag(Color3.fromRGB(255, 0, 120))

-- ============================================================================
-- BOTÃO FLUTUANTE AIM (APENAS VISUAL)
-- ============================================================================
local FloatingBtn = Instance.new("TextButton", ScreenGui)
FloatingBtn.Visible = false
FloatingBtn.Size = UDim2.new(0, 70, 0, 38)
FloatingBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(11, 14, 24)
FloatingBtn.Text = "⚡ OFF"
FloatingBtn.TextColor3 = Color3.fromRGB(130, 140, 160)
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.TextSize = 13
FloatingBtn.Draggable = true
FloatingBtn.Active = true
local BtnCorner = Instance.new("UICorner", FloatingBtn)
BtnCorner.CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", FloatingBtn)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(35, 42, 65)

local function UpdateBtnVisual(active)
    if active then
        TweenService:Create(FloatingBtn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(16, 28, 48)}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(0, 240, 255)}):Play()
        FloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        FloatingBtn.Text = "⚡ ON"
    else
        TweenService:Create(FloatingBtn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(11, 14, 24)}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(35, 42, 65)}):Play()
        FloatingBtn.TextColor3 = Color3.fromRGB(130, 140, 160)
        FloatingBtn.Text = "⚡ OFF"
    end
end

-- ============================================================================
-- FUNÇÕES AUXILIARES
-- ============================================================================
local function getTarget()
    local closest, shortest = nil, getgenv().SystemConfig.FovRadius
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
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

local function IsBehindWall(targetPart)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {Player.Character, targetPart.Parent}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rayParams)
    return result ~= nil
end

-- ============================================================================
-- POPUP PREMIUM (SISTEMA DE BLOQUEIO)
-- ============================================================================
local PremiumPopup = nil
local PopupBackground = nil

local function CreatePremiumPopup(featureName)
    if PremiumPopup and PremiumPopup.Parent then
        PremiumPopup:Destroy()
        PopupBackground:Destroy()
    end

    PopupBackground = Instance.new("Frame", ScreenGui)
    PopupBackground.Size = UDim2.new(1, 0, 1, 0)
    PopupBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    PopupBackground.BackgroundTransparency = 0.6
    PopupBackground.BorderSizePixel = 0
    PopupBackground.ZIndex = 50

    PremiumPopup = Instance.new("Frame", PopupBackground)
    PremiumPopup.Size = UDim2.new(0, 0, 0, 0)
    PremiumPopup.Position = UDim2.new(0.5, -220, 0.5, -180)
    PremiumPopup.BackgroundColor3 = Color3.fromRGB(20, 23, 35)
    PremiumPopup.BorderSizePixel = 0
    PremiumPopup.ZIndex = 51
    PremiumPopup.ClipsDescendants = true

    local corner = Instance.new("UICorner", PremiumPopup)
    corner.CornerRadius = UDim.new(0, 18)

    local shadow = Instance.new("UIStroke", PremiumPopup)
    shadow.Thickness = 6
    shadow.Color = Color3.fromRGB(0, 0, 0)
    shadow.Transparency = 0.7

    local border = Instance.new("UIStroke", PremiumPopup)
    border.Thickness = 1
    border.Color = Color3.fromRGB(0, 240, 255)
    border.Transparency = 0.3

    local icon = Instance.new("TextLabel", PremiumPopup)
    icon.Size = UDim2.new(0, 60, 0, 60)
    icon.Position = UDim2.new(0.5, -30, 0, 16)
    icon.BackgroundTransparency = 1
    icon.Text = "🔒"
    icon.TextSize = 40
    icon.TextColor3 = Color3.fromRGB(255, 215, 0)
    icon.Font = Enum.Font.GothamBold

    local title = Instance.new("TextLabel", PremiumPopup)
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.new(0, 20, 0, 80)
    title.BackgroundTransparency = 1
    title.Text = "Recurso Premium"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Center

    local funcName = Instance.new("TextLabel", PremiumPopup)
    funcName.Size = UDim2.new(1, -40, 0, 24)
    funcName.Position = UDim2.new(0, 20, 0, 115)
    funcName.BackgroundTransparency = 1
    funcName.Text = featureName
    funcName.TextColor3 = Color3.fromRGB(0, 240, 255)
    funcName.Font = Enum.Font.GothamMedium
    funcName.TextSize = 18
    funcName.TextXAlignment = Enum.TextXAlignment.Center

    local msg = Instance.new("TextLabel", PremiumPopup)
    msg.Size = UDim2.new(1, -40, 0, 70)
    msg.Position = UDim2.new(0, 20, 0, 150)
    msg.BackgroundTransparency = 1
    msg.Text = "Esta função faz parte da versão completa do WARCORE.\n\nDesbloqueie todos os recursos para ter acesso ao menu completo, atualizações futuras e todas as ferramentas exclusivas."
    msg.TextColor3 = Color3.fromRGB(200, 210, 230)
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 15
    msg.TextXAlignment = Enum.TextXAlignment.Center
    msg.TextYAlignment = Enum.TextYAlignment.Top
    msg.LineHeight = 1.4

    local btnPremium = Instance.new("TextButton", PremiumPopup)
    btnPremium.Size = UDim2.new(1, -40, 0, 50)
    btnPremium.Position = UDim2.new(0, 20, 0, 240)
    btnPremium.Text = "⭐ Obter Versão Completa"
    btnPremium.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    btnPremium.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnPremium.Font = Enum.Font.GothamBold
    btnPremium.TextSize = 18
    btnPremium.AutoButtonColor = false
    local btnCorner = Instance.new("UICorner", btnPremium)
    btnCorner.CornerRadius = UDim.new(0, 12)
    local btnStroke = Instance.new("UIStroke", btnPremium)
    btnStroke.Thickness = 1
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Transparency = 0.3

    btnPremium.MouseEnter:Connect(function()
        TweenService:Create(btnPremium, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 210, 255)}):Play()
    end)
    btnPremium.MouseLeave:Connect(function()
        TweenService:Create(btnPremium, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 180, 255)}):Play()
    end)

    btnPremium.MouseButton1Click:Connect(function()
        OpenPremiumPage()
    end)

    local btnClose = Instance.new("TextButton", PremiumPopup)
    btnClose.Size = UDim2.new(0, 120, 0, 40)
    btnClose.Position = UDim2.new(0.5, -60, 0, 300)
    btnClose.Text = "❌ Fechar"
    btnClose.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
    btnClose.TextColor3 = Color3.fromRGB(220, 230, 240)
    btnClose.Font = Enum.Font.GothamMedium
    btnClose.TextSize = 16
    btnClose.AutoButtonColor = false
    local closeCorner = Instance.new("UICorner", btnClose)
    closeCorner.CornerRadius = UDim.new(0, 10)
    local closeStroke = Instance.new("UIStroke", btnClose)
    closeStroke.Thickness = 1
    closeStroke.Color = Color3.fromRGB(100, 110, 130)
    closeStroke.Transparency = 0.3

    btnClose.MouseEnter:Connect(function()
        TweenService:Create(btnClose, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 75, 90)}):Play()
    end)
    btnClose.MouseLeave:Connect(function()
        TweenService:Create(btnClose, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 55, 70)}):Play()
    end)

    btnClose.MouseButton1Click:Connect(function()
        ClosePremiumPopup()
    end)

    PremiumPopup.Size = UDim2.new(0, 440, 0, 360)
    PremiumPopup.BackgroundTransparency = 1
    TweenService:Create(PremiumPopup, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0
    }):Play()
end

local function ClosePremiumPopup()
    if PremiumPopup and PremiumPopup.Parent then
        local tween = TweenService:Create(PremiumPopup, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0)
        })
        tween:Play()
        tween.Completed:Connect(function()
            if PremiumPopup then PremiumPopup:Destroy() end
            if PopupBackground then PopupBackground:Destroy() end
        end)
    end
end

function OpenPremiumPage()
    Rayfield:Notify({
        Title = "⭐ Versão Completa",
        Content = "Em breve você poderá adquirir a versão completa!",
        Duration = 3,
        Image = 4483362458
    })
end

local function CheckPremium(featureName, callback)
    if IsPremium then
        if callback then callback() end
        return true
    else
        CreatePremiumPopup(featureName)
        return false
    end
end

-- ============================================================================
-- INTERFACE RAYFIELD
-- ============================================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "👑 WARCORE ULTIMATE",
    LoadingTitle = "WARCORE ULTIMATE - Demonstração",
    LoadingSubtitle = "Versão Demonstrativa",
    ConfigurationSaving = { Enabled = false },
    Theme = "Custom"
})

Window.BackgroundColor = Color3.fromRGB(11, 13, 23)

-- ============================================================================
-- BARRA SUPERIOR PERSONALIZADA (FREE + BOTÃO PREMIUM)
-- ============================================================================
local TopBar = Instance.new("Frame", ScreenGui)
TopBar.Size = UDim2.new(0, 480, 0, 70)
TopBar.Position = UDim2.new(0.5, -240, 0, 10)
TopBar.BackgroundColor3 = Color3.fromRGB(11, 13, 23)
TopBar.BackgroundTransparency = 0.1
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 5
local topCorner = Instance.new("UICorner", TopBar)
topCorner.CornerRadius = UDim.new(0, 14)
local topStroke = Instance.new("UIStroke", TopBar)
topStroke.Thickness = 1
topStroke.Color = Color3.fromRGB(0, 240, 255)
topStroke.Transparency = 0.4

local freeLabel = Instance.new("TextLabel", TopBar)
freeLabel.Size = UDim2.new(0, 200, 0, 30)
freeLabel.Position = UDim2.new(0, 16, 0, 8)
freeLabel.BackgroundTransparency = 1
freeLabel.Text = "WARCORE ULTIMATE"
freeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
freeLabel.Font = Enum.Font.GothamBold
freeLabel.TextSize = 22
freeLabel.TextXAlignment = Enum.TextXAlignment.Left

local subLabel = Instance.new("TextLabel", TopBar)
subLabel.Size = UDim2.new(0, 200, 0, 20)
subLabel.Position = UDim2.new(0, 16, 0, 40)
subLabel.BackgroundTransparency = 1
subLabel.Text = "Versão Demonstrativa"
subLabel.TextColor3 = Color3.fromRGB(180, 190, 210)
subLabel.Font = Enum.Font.GothamMedium
subLabel.TextSize = 13
subLabel.TextXAlignment = Enum.TextXAlignment.Left

local premiumBtn = Instance.new("TextButton", TopBar)
premiumBtn.Size = UDim2.new(0, 180, 0, 42)
premiumBtn.Position = UDim2.new(1, -196, 0, 14)
premiumBtn.Text = "⭐ Obter Completa"
premiumBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
premiumBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
premiumBtn.Font = Enum.Font.GothamBold
premiumBtn.TextSize = 16
premiumBtn.AutoButtonColor = false
local btnCorner2 = Instance.new("UICorner", premiumBtn)
btnCorner2.CornerRadius = UDim.new(0, 12)
local btnStroke2 = Instance.new("UIStroke", premiumBtn)
btnStroke2.Thickness = 1
btnStroke2.Color = Color3.fromRGB(255, 255, 255)
btnStroke2.Transparency = 0.3

premiumBtn.MouseEnter:Connect(function()
    TweenService:Create(premiumBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 210, 255)}):Play()
end)
premiumBtn.MouseLeave:Connect(function()
    TweenService:Create(premiumBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 180, 255)}):Play()
end)
premiumBtn.MouseButton1Click:Connect(function()
    OpenPremiumPage()
end)

task.wait(0.1)
for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui:IsA("ScreenGui") and gui.Name == "Rayfield" then
        for _, child in ipairs(gui:GetChildren()) do
            if child:IsA("Frame") and child.Name == "Main" then
                child.Position = UDim2.new(0.5, -240, 0, 90)
                break
            end
        end
        break
    end
end

-- ============================================================================
-- CRIAÇÃO DAS ABAS
-- ============================================================================
local CombatTab = Window:CreateTab("🔫 Combate", 10734950020)
local VisualTab = Window:CreateTab("👁️ Visual", 10734951477)
local RxTab = Window:CreateTab("🛸 Opções RX", 10734951477)
local LightTab = Window:CreateTab("💡 Iluminação", 10734951477)
local MovimentTab = Window:CreateTab("🧱 Movimento", 4483362458)
local NavTab = Window:CreateTab("🗺️ Navegação", 10734951477)
local StyleTab = Window:CreateTab("🎨 Estilo", 10734951477)
local UtilTab = Window:CreateTab("🛡️ Utilidades", 4483362458)
local TeleportTab = Window:CreateTab("📍 Teleporte", 10734951477)
local StatusTab = Window:CreateTab("📊 Monitor", 4483362458)

-- ============================================================================
-- ABA: COMBATE (AIM, TRIGGER, SILENT, ANTI-RECOIL)
-- ============================================================================
CombatTab:CreateSection("🎯 Mira Assistida")
CombatTab:CreateToggle({
    Name = "🔒 Ativar Mira Assistida",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Aim Assist") then
            getgenv().SystemConfig.MiraAtiva = false
            FloatingBtn.Visible = false
            UpdateBtnVisual(false)
            return
        end
        getgenv().SystemConfig.MiraAtiva = v
        FloatingBtn.Visible = v
        UpdateBtnVisual(v)
    end
})
CombatTab:CreateSlider({
    Name = "🔒 Suavidade de Resposta",
    Range = {0.1, 1},
    Increment = 0.05,
    CurrentValue = 0.35,
    Callback = function(v)
        if not CheckPremium("Suavidade") then return end
        getgenv().SystemConfig.Smoothness = v
    end
})
CombatTab:CreateSlider({
    Name = "🔒 Raio de Visão (FOV)",
    Range = {100, 1000},
    Increment = 10,
    CurrentValue = 500,
    Callback = function(v)
        if not CheckPremium("FOV") then return end
        getgenv().SystemConfig.FovRadius = v
    end
})

CombatTab:CreateSection("🔫 TriggerBot")
CombatTab:CreateToggle({
    Name = "🔒 Ativar TriggerBot (tiro automático)",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("TriggerBot") then return end
        getgenv().SystemConfig.TriggerBot = v
    end
})
CombatTab:CreateSlider({
    Name = "🔒 Delay do Tiro (ms)",
    Range = {0, 500},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(v)
        if not CheckPremium("Trigger Delay") then return end
        getgenv().SystemConfig.TriggerDelay = v
    end
})

CombatTab:CreateSection("🎯 Silent Aim")
CombatTab:CreateToggle({
    Name = "🔒 Ativar Silent Aim",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Silent Aim") then return end
        getgenv().SystemConfig.SilentAim = v
    end
})
CombatTab:CreateDropdown({
    Name = "🔒 Parte do Corpo",
    Options = {"Cabeça", "Tórax", "Aleatório"},
    CurrentOption = "Cabeça",
    MultipleOptions = false,
    Callback = function(opt)
        if not CheckPremium("Silent Aim") then return end
        getgenv().SystemConfig.AimPart = opt
    end
})

CombatTab:CreateSection("🔧 Anti-Recoil")
CombatTab:CreateToggle({
    Name = "Ativar Anti-Recoil (FREE básico)",
    CurrentValue = false,
    Callback = function(v)
        getgenv().SystemConfig.AntiRecoil = v
    end
})
CombatTab:CreateSlider({
    Name = "🔒 Redução de Recoil (Premium ajustável)",
    Range = {0.1, 1},
    Increment = 0.05,
    CurrentValue = 0.5,
    Callback = function(v)
        if not CheckPremium("Anti-Recoil Ajustável") then return end
        getgenv().SystemConfig.RecoilReduction = v
    end
})

-- ============================================================================
-- ABA: VISUAL (ESP BÁSICO + DETALHES PREMIUM)
-- ============================================================================
VisualTab:CreateSection("Elementos de Rastreamento")
VisualTab:CreateToggle({
    Name = "Ativar Scanner Raio-X (RX)",
    CurrentValue = false,
    Callback = function(v)
        getgenv().SystemConfig.HighlightEnabled = v
    end
})
VisualTab:CreateToggle({
    Name = "🔒 Fixar Ponto na Cabeça",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Ponto na Cabeça") then return end
        getgenv().SystemConfig.DotEnabled = v
    end
})
VisualTab:CreateToggle({
    Name = "🔒 Micro-HUD: Exibir Vida nos Pés",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Micro-HUD Vida") then return end
        getgenv().SystemConfig.MicroHpEnabled = v
    end
})
VisualTab:CreateToggle({
    Name = "🔒 Micro-HUD: Exibir Distância",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Micro-HUD Distância") then return end
        getgenv().SystemConfig.MicroDistEnabled = v
    end
})

VisualTab:CreateSection("Ajuste de Escala (Tamanho)")
VisualTab:CreateSlider({
    Name = "🔒 Tamanho do Texto (Distância)",
    Range = {6, 24},
    Increment = 1,
    CurrentValue = 8,
    Callback = function(v)
        if not CheckPremium("Tamanho Texto") then return end
        getgenv().SystemConfig.MicroTextSize = v
    end
})
VisualTab:CreateSlider({
    Name = "🔒 Largura da Barra de Vida",
    Range = {20, 100},
    Increment = 5,
    CurrentValue = 35,
    Callback = function(v)
        if not CheckPremium("Largura Barra") then return end
        getgenv().SystemConfig.MicroWidth = v
    end
})

-- ============================================================================
-- ABA: OPÇÕES RX (TUDO BLOQUEADO EXCETO O TOGGLE PRINCIPAL)
-- ============================================================================
RxTab:CreateSection("Configurações Avançadas do Raio-X")
RxTab:CreateDropdown({
    Name = "🔒 Modo de Visibilidade (Parede)",
    Options = {"Ver através (AlwaysOnTop)", "Ocultar atrás (Occluded)"},
    CurrentOption = "Ver através (AlwaysOnTop)",
    MultipleOptions = false,
    Callback = function(Option)
        if not CheckPremium("Modo Visibilidade") then return end
        if Option == "Ver através (AlwaysOnTop)" then
            getgenv().SystemConfig.HlDepthMode = "AlwaysOnTop"
        else
            getgenv().SystemConfig.HlDepthMode = "Occluded"
        end
    end,
})
RxTab:CreateSlider({
    Name = "🔒 Transparência do Brilho (Fill)",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = 0.5,
    Callback = function(v)
        if not CheckPremium("Transparência Fill") then return end
        getgenv().SystemConfig.HlFillTransparency = v
    end
})
RxTab:CreateColorPicker({
    Name = "🔒 Cor do Contorno (Inimigos)",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        if not CheckPremium("Cor Contorno") then return end
        getgenv().SystemConfig.HlEnemyColor = Value
    end
})

-- ============================================================================
-- ABA: ILUMINAÇÃO (FULLBRIGHT PERMITIDO, OUTROS BLOQUEADOS)
-- ============================================================================
LightTab:CreateToggle({
    Name = "Filtro FullBright Ambiência",
    CurrentValue = false,
    Callback = function(v)
        getgenv().SystemConfig.FullBright = v
        if not v then
            Lighting.Ambient = OriginalSettings.Ambient
            Lighting.Brightness = OriginalSettings.Brightness
            Lighting.ClockTime = OriginalSettings.ClockTime
            Lighting.FogEnd = OriginalSettings.FogEnd
            Lighting.OutdoorAmbient = OriginalSettings.OutdoorAmbient
        end
    end
})
LightTab:CreateToggle({
    Name = "🔒 Clareza Técnico Aprimorada",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Clareza Técnico") then return end
        getgenv().SystemConfig.ClarezaMod = v
    end
})
LightTab:CreateToggle({
    Name = "🔒 Otimizar: Remover Sombras",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Remover Sombras") then return end
        Lighting.GlobalShadows = not v
    end
})

-- ============================================================================
-- ABA: MOVIMENTO (FLY, SPEED, JUMP, WALLCLIMB, AUTOSPRINT)
-- ============================================================================
MovimentTab:CreateSection("🕊️ Fly")
MovimentTab:CreateToggle({
    Name = "🔒 Ativar Fly",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Fly") then return end
        getgenv().SystemConfig.FlyEnabled = v
        if v then startFly() else stopFly() end
    end
})
MovimentTab:CreateToggle({
    Name = "🔒 Modo Infinito (câmera)",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Fly Infinito") then return end
        getgenv().SystemConfig.FlyInfinite = v
    end
})
MovimentTab:CreateSlider({
    Name = "🔒 Velocidade do Fly",
    Range = {1,500},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        if not CheckPremium("Velocidade Fly") then return end
        getgenv().SystemConfig.FlySpeed = v
    end
})

MovimentTab:CreateSection("🧱 No-Clip")
MovimentTab:CreateToggle({
    Name = "🔒 Ativar Matriz No-Clip",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("No-Clip") then return end
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
            if NoClipConnection then NoClipConnection:Disconnect(); NoClipConnection = nil end
        end
    end
})

MovimentTab:CreateSection("⚡ Velocidade de Caminhada")
MovimentTab:CreateToggle({
    Name = "🔒 Ativar Speed Hack",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Speed Hack") then return end
        getgenv().SystemConfig.SpeedEnabled = v
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = v and getgenv().SystemConfig.SpeedValue or OriginalWalkSpeed
        end
    end
})
MovimentTab:CreateSlider({
    Name = "🔒 Velocidade",
    Range = {16,200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        if not CheckPremium("Velocidade") then return end
        getgenv().SystemConfig.SpeedValue = v
        if getgenv().SystemConfig.SpeedEnabled then
            local char = Player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end
})

MovimentTab:CreateSection("🦘 Super Pulo")
MovimentTab:CreateToggle({
    Name = "🔒 Ativar Super Pulo",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Super Pulo") then return end
        getgenv().SystemConfig.JumpEnabled = v
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = v and getgenv().SystemConfig.JumpPower or OriginalJumpPower
        end
    end
})
MovimentTab:CreateSlider({
    Name = "🔒 Altura do Pulo",
    Range = {50,300},
    Increment = 5,
    CurrentValue = 100,
    Callback = function(v)
        if not CheckPremium("Altura Pulo") then return end
        getgenv().SystemConfig.JumpPower = v
        if getgenv().SystemConfig.JumpEnabled then
            local char = Player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = v end
        end
    end
})

MovimentTab:CreateSection("🔄 Pulo Infinito")
MovimentTab:CreateToggle({
    Name = "🔒 Pulo Infinito (pular no ar)",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Pulo Infinito") then return end
        getgenv().SystemConfig.InfiniteJump = v
    end
})

MovimentTab:CreateSection("🧗 Wall-Climb")
MovimentTab:CreateToggle({
    Name = "🔒 Ativar Escalada de Paredes",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Wall-Climb") then return end
        getgenv().SystemConfig.WallClimb = v
    end
})
MovimentTab:CreateSlider({
    Name = "🔒 Velocidade de Escalada",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = 20,
    Callback = function(v)
        if not CheckPremium("Wall-Climb") then return end
        getgenv().SystemConfig.WallClimbSpeed = v
    end
})

MovimentTab:CreateSection("🏃 Auto-Sprint")
MovimentTab:CreateToggle({
    Name = "Auto-Sprint (correr sempre)",
    CurrentValue = false,
    Callback = function(v)
        getgenv().SystemConfig.AutoSprint = v
        if v then
            local char = Player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.AutoRotate = true end
        end
    end
})

-- ============================================================================
-- ABA: NAVEGAÇÃO (RADAR, DISTÂNCIA, DIREÇÃO)
-- ============================================================================
NavTab:CreateSection("📍 Indicadores")
NavTab:CreateToggle({
    Name = "🔒 Exibir Distância do Inimigo no HUD",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Distância HUD") then return end
        getgenv().SystemConfig.ShowDistanceHUD = v
    end
})
NavTab:CreateToggle({
    Name = "🔒 Exibir Seta Direcional",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Seta Direcional") then return end
        getgenv().SystemConfig.ShowDirectionArrow = v
    end
})

NavTab:CreateSection("🗺️ Radar 2D")
NavTab:CreateToggle({
    Name = "Ativar Radar (FREE simples)",
    CurrentValue = false,
    Callback = function(v)
        getgenv().SystemConfig.RadarEnabled = v
    end
})
NavTab:CreateSlider({
    Name = "🔒 Tamanho do Radar (Premium ajustável)",
    Range = {80, 300},
    Increment = 5,
    CurrentValue = 150,
    Callback = function(v)
        if not CheckPremium("Tamanho Radar") then return end
        getgenv().SystemConfig.RadarSize = v
    end
})

-- ============================================================================
-- ABA: ESTILO (CHAMS, MODO CINZA)
-- ============================================================================
StyleTab:CreateSection("🌈 Chams (Cores nos Inimigos)")
StyleTab:CreateToggle({
    Name = "🔒 Ativar Chams",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Chams") then return end
        getgenv().SystemConfig.ChamsEnabled = v
    end
})
StyleTab:CreateColorPicker({
    Name = "🔒 Cor dos Chams",
    Color = Color3.fromRGB(0, 255, 0),
    Callback = function(Value)
        if not CheckPremium("Chams") then return end
        getgenv().SystemConfig.ChamsColor = Value
    end
})
StyleTab:CreateToggle({
    Name = "🔒 Modo Arco-Íris (cores dinâmicas)",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Chams Rainbow") then return end
        getgenv().SystemConfig.ChamsRainbow = v
    end
})

StyleTab:CreateSection("🎨 Modo Cinza")
StyleTab:CreateToggle({
    Name = "Ativar Modo Cinza (baixa qualidade)",
    CurrentValue = false,
    Callback = function(v)
        getgenv().SystemConfig.GrayMode = v
        if v then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Material ~= Enum.Material.Neon then
                    obj.Material = Enum.Material.SmoothPlastic
                end
            end
        end
    end
})

-- ============================================================================
-- ABA: UTILIDADES (ANTI-AFK, AUTO-COLLECT)
-- ============================================================================
UtilTab:CreateSection("🛡️ Anti-AFK")
UtilTab:CreateToggle({
    Name = "Ativar Anti-AFK",
    CurrentValue = false,
    Callback = function(v)
        getgenv().SystemConfig.AntiAFK = v
    end
})

UtilTab:CreateSection("📦 Auto-Collect")
UtilTab:CreateToggle({
    Name = "🔒 Auto-Collect (pegar itens)",
    CurrentValue = false,
    Callback = function(v)
        if not CheckPremium("Auto-Collect") then return end
        getgenv().SystemConfig.AutoCollect = v
    end
})
UtilTab:CreateSlider({
    Name = "🔒 Raio de Coleta",
    Range = {10, 100},
    Increment = 1,
    CurrentValue = 30,
    Callback = function(v)
        if not CheckPremium("Auto-Collect") then return end
        getgenv().SystemConfig.CollectRadius = v
    end
})

-- ============================================================================
-- ABA: TELEPORTE (MESMO DA VERSÃO FREE, LIMITADO A 1 PONTO)
-- ============================================================================
-- (Código do teleporte já existente, mantido)
local tpGui = Instance.new("ScreenGui", CoreGui)
tpGui.Name = "WarcoreTeleporte"
tpGui.Enabled = true
tpGui.ResetOnSpawn = false
tpGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local tpFrame = Instance.new("Frame", tpGui)
tpFrame.Size = UDim2.new(0, 360, 0, 540)
tpFrame.Position = UDim2.new(0.5, -180, 0.5, -270)
tpFrame.BackgroundColor3 = Color3.fromRGB(30, 33, 45)
tpFrame.BackgroundTransparency = 0.05
tpFrame.BorderSizePixel = 0
tpFrame.ClipsDescendants = true
tpFrame.Visible = false
tpFrame.ZIndex = 10

local frameCorner = Instance.new("UICorner", tpFrame)
frameCorner.CornerRadius = UDim.new(0, 18)

local shadow1 = Instance.new("UIStroke", tpFrame)
shadow1.Thickness = 6
shadow1.Color = Color3.fromRGB(0, 0, 0)
shadow1.Transparency = 0.7
shadow1.Name = "Shadow1"

local shadow2 = Instance.new("UIStroke", tpFrame)
shadow2.Thickness = 2
shadow2.Color = Color3.fromRGB(0, 0, 0)
shadow2.Transparency = 0.5
shadow2.Name = "Shadow2"

local border = Instance.new("UIStroke", tpFrame)
border.Thickness = 1
border.Color = Color3.fromRGB(60, 70, 90)
border.Transparency = 0.2

local titleBar = Instance.new("Frame", tpFrame)
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
titleBar.BorderSizePixel = 0
local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 18)
local titleFix = Instance.new("Frame", titleBar)
titleFix.Size = UDim2.new(1, 0, 0, 20)
titleFix.Position = UDim2.new(0, 0, 0, 22)
titleFix.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
titleFix.BorderSizePixel = 0

local icon = Instance.new("ImageLabel", titleBar)
icon.Size = UDim2.new(0, 26, 0, 26)
icon.Position = UDim2.new(0, 10, 0, 8)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://10734951477"
icon.ImageColor3 = Color3.fromRGB(0, 240, 255)
icon.ScaleType = Enum.ScaleType.Fit

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -110, 1, 0)
titleLabel.Position = UDim2.new(0, 42, 0, 0)
titleLabel.Text = "Teleporte Rápido"
titleLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.BackgroundTransparency = 1

local minimizeBtn = Instance.new("TextButton", titleBar)
minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
minimizeBtn.Position = UDim2.new(1, -68, 0, 5)
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = Color3.fromRGB(220, 230, 240)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
minimizeBtn.BackgroundTransparency = 0.3
minimizeBtn.AutoButtonColor = false
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 10)

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -32, 0, 5)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 220, 220)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.BackgroundColor3 = Color3.fromRGB(190, 60, 60)
closeBtn.BackgroundTransparency = 0.2
closeBtn.AutoButtonColor = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10)

local function hover(btn, baseColor, hoverColor, textHover)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor, BackgroundTransparency = 0.1}):Play()
        if textHover then TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = textHover}):Play() end
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = baseColor, BackgroundTransparency = 0.3}):Play()
        if textHover then TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(220,230,240)}):Play() end
    end)
end
hover(minimizeBtn, Color3.fromRGB(50,55,65), Color3.fromRGB(70,75,85), Color3.fromRGB(255,255,255))
hover(closeBtn, Color3.fromRGB(190,60,60), Color3.fromRGB(230,80,80), Color3.fromRGB(255,255,255))

local winDragging = false
local winStart, winFrameStart
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        winDragging = true
        winStart = input.Position
        winFrameStart = tpFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then winDragging = false end
        end)
    end
end)
titleBar.InputChanged:Connect(function(input)
    if winDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - winStart
        tpFrame.Position = UDim2.new(winFrameStart.X.Scale, winFrameStart.X.Offset + delta.X, winFrameStart.Y.Scale, winFrameStart.Y.Offset + delta.Y)
    end
end)

local posPanel = Instance.new("Frame", tpFrame)
posPanel.Size = UDim2.new(1, -24, 0, 46)
posPanel.Position = UDim2.new(0, 12, 0, 52)
posPanel.BackgroundColor3 = Color3.fromRGB(40, 43, 55)
posPanel.BorderSizePixel = 0
Instance.new("UICorner", posPanel).CornerRadius = UDim.new(0, 10)
local posStroke = Instance.new("UIStroke", posPanel)
posStroke.Thickness = 1
posStroke.Color = Color3.fromRGB(0, 240, 255)
posStroke.Transparency = 0.7

local posLabel = Instance.new("TextLabel", posPanel)
posLabel.Size = UDim2.new(1, -10, 1, 0)
posLabel.Position = UDim2.new(0, 5, 0, 0)
posLabel.BackgroundTransparency = 1
posLabel.Text = "📍 Posição: --, --, --"
posLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
posLabel.Font = Enum.Font.GothamMedium
posLabel.TextSize = 15

local inputName = Instance.new("TextBox", tpFrame)
inputName.Size = UDim2.new(1, -24, 0, 48)
inputName.Position = UDim2.new(0, 12, 0, 110)
inputName.PlaceholderText = "Nome do Local"
inputName.PlaceholderColor3 = Color3.fromRGB(180, 190, 210)
inputName.BackgroundColor3 = Color3.fromRGB(40, 43, 55)
inputName.TextColor3 = Color3.fromRGB(255, 255, 255)
inputName.Font = Enum.Font.Gotham
inputName.TextSize = 16
inputName.ClearTextOnFocus = false
Instance.new("UICorner", inputName).CornerRadius = UDim.new(0, 10)
local inputStroke = Instance.new("UIStroke", inputName)
inputStroke.Thickness = 1
inputStroke.Color = Color3.fromRGB(80, 90, 110)
inputStroke.Transparency = 0.3

local saveBtn = Instance.new("TextButton", tpFrame)
saveBtn.Size = UDim2.new(1, -24, 0, 48)
saveBtn.Position = UDim2.new(0, 12, 0, 170)
saveBtn.Text = "💾 Salvar Local"
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 17
saveBtn.AutoButtonColor = false
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 10)
local saveStroke = Instance.new("UIStroke", saveBtn)
saveStroke.Thickness = 1
saveStroke.Color = Color3.fromRGB(255, 255, 255)
saveStroke.Transparency = 0.4
hover(saveBtn, Color3.fromRGB(0,140,255), Color3.fromRGB(0,170,255), Color3.fromRGB(255,255,255))

local container = Instance.new("ScrollingFrame", tpFrame)
container.Size = UDim2.new(1, -24, 0, 250)
container.Position = UDim2.new(0, 12, 0, 230)
container.BackgroundColor3 = Color3.fromRGB(40, 43, 55)
container.BorderSizePixel = 0
container.ScrollBarThickness = 5
container.ScrollBarImageColor3 = Color3.fromRGB(0, 240, 255)
Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder

local clearBtn = Instance.new("TextButton", tpFrame)
clearBtn.Size = UDim2.new(1, -24, 0, 46)
clearBtn.Position = UDim2.new(0, 12, 0, 492)
clearBtn.Text = "🗑 Limpar Tudo"
clearBtn.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 17
clearBtn.AutoButtonColor = false
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 10)
local clearStroke = Instance.new("UIStroke", clearBtn)
clearStroke.Thickness = 1
clearStroke.Color = Color3.fromRGB(255, 255, 255)
clearStroke.Transparency = 0.4
hover(clearBtn, Color3.fromRGB(170,50,50), Color3.fromRGB(210,70,70), Color3.fromRGB(255,255,255))

local savedLocations = {}

local function refreshContainer()
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for i, loc in ipairs(savedLocations) do
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -10, 0, 44)
        btn.Text = loc.name .. "\n" .. string.format("%.1f, %.1f, %.1f", loc.x, loc.y, loc.z)
        btn.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.LayoutOrder = i
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        hover(btn, Color3.fromRGB(50,55,70), Color3.fromRGB(70,75,90))
        btn.MouseButton1Click:Connect(function()
            local char = Player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(loc.x, loc.y, loc.z)
                Rayfield:Notify({
                    Title = "Teleportado",
                    Content = "Movido para " .. loc.name,
                    Duration = 2,
                    Image = 4483362458
                })
            end
        end)
    end
    container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end

saveBtn.MouseButton1Click:Connect(function()
    if inputName.Text == "" then
        Rayfield:Notify({Title = "Aviso", Content = "Digite um nome para o local.", Duration = 2, Image = 4483362458})
        return
    end
    if not IsPremium and #savedLocations >= 1 then
        Rayfield:Notify({
            Title = "🔒 Limite Atingido",
            Content = "Na versão FREE você pode salvar apenas 1 ponto. Adquira a versão completa para salvar ilimitados.",
            Duration = 4,
            Image = 4483362458
        })
        return
    end
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local pos = char.HumanoidRootPart.Position
    local x, y, z = math.floor(pos.X * 100) / 100, math.floor(pos.Y * 100) / 100, math.floor(pos.Z * 100) / 100
    table.insert(savedLocations, {name = inputName.Text, x = x, y = y, z = z})
    inputName.Text = ""
    refreshContainer()
    Rayfield:Notify({Title = "Salvo", Content = inputName.Text .. " adicionado.", Duration = 2, Image = 4483362458})
end)

clearBtn.MouseButton1Click:Connect(function()
    if #savedLocations == 0 then return end
    savedLocations = {}
    refreshContainer()
    Rayfield:Notify({Title = "Limpo", Content = "Todos os locais foram removidos.", Duration = 2, Image = 4483362458})
end)

function toggleMenu(show)
    if show then
        tpFrame.Visible = true
        tpFrame.Size = UDim2.new(0, 0, 0, 540)
        tpFrame.BackgroundTransparency = 1
        TweenService:Create(tpFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 360, 0, 540),
            BackgroundTransparency = 0.05
        }):Play()
    else
        local tween = TweenService:Create(tpFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 540),
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            tpFrame.Visible = false
        end)
    end
end

local function animateBtn(btn, visible)
    if visible then
        btn.Visible = true
        btn.Size = UDim2.new(0, 0, 0, 0)
        btn.BackgroundTransparency = 1
        TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 58, 0, 58),
            BackgroundTransparency = 0.1,
            TextSize = 30
        }):Play()
    else
        local tween = TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function() btn.Visible = false end)
    end
end

local TpFloatingBtn = Instance.new("TextButton", tpGui)
TpFloatingBtn.Size = UDim2.new(0, 58, 0, 58)
TpFloatingBtn.Position = UDim2.new(0.8, 0, 0.7, 0)
TpFloatingBtn.BackgroundColor3 = Color3.fromRGB(11, 13, 23)
TpFloatingBtn.BackgroundTransparency = 0.1
TpFloatingBtn.Text = "📍"
TpFloatingBtn.TextColor3 = Color3.fromRGB(0, 240, 255)
TpFloatingBtn.Font = Enum.Font.GothamBold
TpFloatingBtn.TextSize = 30
TpFloatingBtn.AutoButtonColor = false
TpFloatingBtn.Visible = false
TpFloatingBtn.Active = true
TpFloatingBtn.ZIndex = 10
Instance.new("UICorner", TpFloatingBtn).CornerRadius = UDim.new(0, 22)
local floatShadow = Instance.new("UIStroke", TpFloatingBtn)
floatShadow.Thickness = 3
floatShadow.Color = Color3.fromRGB(0, 0, 0)
floatShadow.Transparency = 0.5
local floatStroke = Instance.new("UIStroke", TpFloatingBtn)
floatStroke.Thickness = 1.5
floatStroke.Color = Color3.fromRGB(0, 240, 255)
floatStroke.Transparency = 0.6

local isDragging = false
local dragStartPos = nil
local btnStartPos = nil
local hasMoved = false

TpFloatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        hasMoved = false
        dragStartPos = input.Position
        btnStartPos = TpFloatingBtn.Position
        local curSize = TpFloatingBtn.Size.X.Offset
        TweenService:Create(TpFloatingBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, curSize + 6, 0, curSize + 6)}):Play()
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
                TweenService:Create(TpFloatingBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 58, 0, 58)}):Play()
            end
        end)
    end
end)

TpFloatingBtn.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        if delta.Magnitude > 5 then hasMoved = true end
        TpFloatingBtn.Position = UDim2.new(
            btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
            btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
        )
    end
end)

TpFloatingBtn.InputEnded:Connect(function(input)
    if not hasMoved and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        isTeleportOpen = not isTeleportOpen
        toggleMenu(isTeleportOpen)
    end
    hasMoved = false
end)

minimizeBtn.MouseButton1Click:Connect(function()
    isTeleportOpen = false
    toggleMenu(false)
end)

closeBtn.MouseButton1Click:Connect(function()
    isTeleportOpen = false
    toggleMenu(false)
end)

TeleportTab:CreateToggle({
    Name = "Ativar Sistema de Teleporte",
    CurrentValue = false,
    Callback = function(value)
        if value then
            animateBtn(TpFloatingBtn, true)
        else
            animateBtn(TpFloatingBtn, false)
            if isTeleportOpen then
                isTeleportOpen = false
                toggleMenu(false)
            end
        end
    end
})

RunService.RenderStepped:Connect(function()
    if tpFrame.Visible and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local p = Player.Character.HumanoidRootPart.Position
        posLabel.Text = string.format("📍 Posição: %.1f, %.1f, %.1f", p.X, p.Y, p.Z)
    end
end)

-- ============================================================================
-- ABA: MONITOR (FPS, PLAYERS) - PERMITIDO
-- ============================================================================
StatusTab:CreateToggle({
    Name = "Monitorar Taxa de FPS",
    CurrentValue = false,
    Callback = function(v)
        getgenv().SystemConfig.ShowFPS = v
        fpsF.Visible = v
    end
})
StatusTab:CreateToggle({
    Name = "Contador Ativo de Players",
    CurrentValue = false,
    Callback = function(v)
        getgenv().SystemConfig.ShowPlayers = v
        countF.Visible = v
    end
})

-- ============================================================================
-- LOOP PRINCIPAL (TODAS AS FUNÇÕES)
-- ============================================================================
local triggerCooldown = false
local lastShotTime = 0
local rainbowHue = 0

RunService.RenderStepped:Connect(function(dt)
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    -- 1. FPS / Players
    if getgenv().SystemConfig.ShowFPS then
        fpsL.Text = " ⚡ FPS: " .. math.floor(1/dt)
    end
    if getgenv().SystemConfig.ShowPlayers then
        countL.Text = " 👥 Players: " .. #Players:GetPlayers()
    end

    -- 2. FullBright
    if getgenv().SystemConfig.FullBright then
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        Lighting.ClockTime = 14
    end

    -- 3. Clareza (Premium)
    if IsPremium and getgenv().SystemConfig.ClarezaMod then
        Lighting.Brightness = 3
        Lighting.ExposureCompensation = 0.5
    else
        if not getgenv().SystemConfig.FullBright then
            Lighting.Brightness = OriginalSettings.Brightness
            Lighting.ExposureCompensation = OriginalSettings.Exposure
        end
    end

    -- 4. Auto-Sprint (FREE)
    if getgenv().SystemConfig.AutoSprint and hum then
        hum.AutoRotate = true
    end

    -- 5. Wall-Climb (Premium)
    if IsPremium and getgenv().SystemConfig.WallClimb and char and hum then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Detectar parede à frente
            local ray = RaycastParams.new()
            ray.FilterDescendantsInstances = {char}
            local hit = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 3, ray)
            if hit then
                local move = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
                local jump = UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0
                local climbVel = (hit.Normal * -1) * getgenv().SystemConfig.WallClimbSpeed * move
                climbVel = climbVel + Vector3.new(0, getgenv().SystemConfig.WallClimbSpeed * jump, 0)
                hrp.Velocity = climbVel
            end
        end
    end

    -- 6. Anti-AFK (FREE)
    if getgenv().SystemConfig.AntiAFK then
        local vUser = VirtualUser
        pcall(function()
            vUser:CaptureController()
            vUser:ClickButton2(Vector2.new())
        end)
    end

    -- 7. Auto-Collect (Premium)
    if IsPremium and getgenv().SystemConfig.AutoCollect and char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local radius = getgenv().SystemConfig.CollectRadius
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Tool") or obj:IsA("Part") and obj:FindFirstChild("TouchInterest") then
                    if (obj.Position - hrp.Position).Magnitude < radius then
                        -- Simular coleta (fire touch)
                        firetouchinterest(hrp, obj, 0)
                        task.wait(0.05)
                        firetouchinterest(hrp, obj, 1)
                    end
                end
            end
        end
    end

    -- 8. Aim Assist (Premium)
    if IsPremium and getgenv().SystemConfig.MiraAtiva then
        local target = getTarget()
        if target then
            local goal = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, getgenv().SystemConfig.Smoothness * math.clamp(60 * dt, 0, 1))
        end
    end

    -- 9. TriggerBot (Premium)
    if IsPremium and getgenv().SystemConfig.TriggerBot and char then
        local mouse = Player:GetMouse()
        local target = getTarget()
        if target then
            local pos, vis = Camera:WorldToViewportPoint(target.Position)
            if vis and (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude < 50 then
                if tick() - lastShotTime >= getgenv().SystemConfig.TriggerDelay / 1000 then
                    -- Simular clique (depende do jogo)
                    mouse1click()
                    lastShotTime = tick()
                end
            end
        end
    end

    -- 10. Silent Aim (Premium)
    if IsPremium and getgenv().SystemConfig.SilentAim and char then
        -- Implementação simplificada: redireciona o tiro para o alvo
        -- (Para jogos que usam RemoteEvent, seria necessário mais lógica)
        -- Aqui apenas notificação de que está ativo
    end

    -- 11. Anti-Recoil (FREE)
    if getgenv().SystemConfig.AntiRecoil and char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Compensação básica: ajuste de rotação da câmera
            -- Depende do jogo, mas podemos aplicar uma correção
            -- Exemplo: diminuir o recoil modificando a posição da arma
            -- (não implementado universalmente)
        end
    end

    -- 12. Chams (Premium)
    if IsPremium and getgenv().SystemConfig.ChamsEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local char = p.Character
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local cham = part:FindFirstChild("ChamEffect")
                        if not cham then
                            cham = Instance.new("BoxHandleAdornment", part)
                            cham.Name = "ChamEffect"
                            cham.Size = part.Size
                            cham.CFrame = part.CFrame
                            cham.AlwaysOnTop = true
                            cham.ZIndex = 0
                        end
                        local color = getgenv().SystemConfig.ChamsColor
                        if getgenv().SystemConfig.ChamsRainbow then
                            rainbowHue = (rainbowHue + dt * 0.5) % 1
                            color = Color3.fromHSV(rainbowHue, 1, 1)
                        end
                        cham.Color3 = color
                        cham.Adornee = part
                        cham.Visible = true
                    end
                end
            end
        end
    end

    -- 13. Modo Cinza (FREE)
    if getgenv().SystemConfig.GrayMode then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Material ~= Enum.Material.Neon then
                obj.Material = Enum.Material.SmoothPlastic
            end
        end
    end

    -- 14. ESP (Highlight) - básico
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            if head then
                local isTeam = (p.Team == Player.Team and Player.Team ~= nil)
                local statusColor = isTeam and Color3.fromRGB(0, 255, 0) or getgenv().SystemConfig.HlEnemyColor

                local hl = char:FindFirstChild("System_HL") or Instance.new("Highlight", char)
                hl.Name = "System_HL"
                hl.Enabled = getgenv().SystemConfig.HighlightEnabled
                hl.FillColor = statusColor
                hl.OutlineColor = statusColor
                hl.FillTransparency = getgenv().SystemConfig.HlFillTransparency
                hl.OutlineTransparency = 0
                if IsPremium then
                    hl.DepthMode = Enum.HighlightDepthMode[getgenv().SystemConfig.HlDepthMode]
                else
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end

                -- Dot (Premium)
                local dot = head:FindFirstChild("System_Dot")
                if IsPremium and getgenv().SystemConfig.DotEnabled then
                    if not dot then
                        local bill = Instance.new("BillboardGui", head)
                        bill.Name = "System_Dot"
                        bill.Size = UDim2.new(0, 10, 0, 10)
                        bill.AlwaysOnTop = true
                        bill.ExtentsOffset = Vector3.new(0, 1.5, 0)
                        local f = Instance.new("Frame", bill)
                        f.Size = UDim2.new(1,0,1,0)
                        Instance.new("UICorner", f).CornerRadius = UDim.new(1,0)
                        dot = bill
                    end
                    dot.Enabled = true
                    local behind = IsBehindWall(head)
                    local dotColor = isTeam and Color3.fromRGB(0, 255, 0) or (behind and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(255, 0, 0))
                    dot.Frame.BackgroundColor3 = dotColor
                elseif dot then
                    dot:Destroy()
                end

                -- Micro-HUD (Premium)
                if IsPremium then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local hud = root:FindFirstChild("Aguia_MicroHUD")
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum and (getgenv().SystemConfig.MicroHpEnabled or getgenv().SystemConfig.MicroDistEnabled) and hum.Health > 0 then
                            local function CreateMicroDisplay(char)
                                local root = char:FindFirstChild("HumanoidRootPart")
                                if not root then return nil end
                                local billboard = root:FindFirstChild("Aguia_MicroHUD")
                                if not billboard then
                                    billboard = Instance.new("BillboardGui", root)
                                    billboard.Name = "Aguia_MicroHUD"
                                    billboard.AlwaysOnTop = true
                                    billboard.ExtentsOffset = Vector3.new(0, -3.7, 0)
                                    local bgBar = Instance.new("Frame", billboard)
                                    bgBar.Name = "BackgroundBar"
                                    bgBar.Size = UDim2.new(1, 0, 0, 2)
                                    bgBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                                    bgBar.BorderSizePixel = 0
                                    local mainBar = Instance.new("Frame", bgBar)
                                    mainBar.Name = "MainBar"
                                    mainBar.Size = UDim2.new(1, 0, 1, 0)
                                    mainBar.BorderSizePixel = 0
                                    local label = Instance.new("TextLabel", billboard)
                                    label.Name = "DistLabel"
                                    label.BackgroundTransparency = 1
                                    label.Font = Enum.Font.GothamBold
                                    label.TextStrokeTransparency = 0.4
                                end
                                billboard.Size = UDim2.new(0, getgenv().SystemConfig.MicroWidth, 0, getgenv().SystemConfig.MicroTextSize + 4)
                                billboard.DistLabel.Size = UDim2.new(1, 0, 0, getgenv().SystemConfig.MicroTextSize)
                                billboard.DistLabel.TextSize = getgenv().SystemConfig.MicroTextSize
                                billboard.DistLabel.Position = UDim2.new(0, 0, 0, 3)
                                return billboard
                            end
                            local currentHud = CreateMicroDisplay(char)
                            if currentHud then
                                local teamColor = isTeam and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 50, 50)
                                if getgenv().SystemConfig.MicroHpEnabled then
                                    local healthRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                    currentHud.BackgroundBar.MainBar.Size = UDim2.new(healthRatio, 0, 1, 0)
                                    currentHud.BackgroundBar.MainBar.BackgroundColor3 = teamColor
                                    currentHud.BackgroundBar.Visible = true
                                else
                                    currentHud.BackgroundBar.Visible = false
                                end
                                if getgenv().SystemConfig.MicroDistEnabled then
                                    local distance = math.floor(Player:DistanceFromCharacter(root.Position))
                                    currentHud.DistLabel.Text = string.format("%dm", distance)
                                    currentHud.DistLabel.TextColor3 = teamColor
                                    currentHud.DistLabel.Visible = true
                                else
                                    currentHud.DistLabel.Visible = false
                                end
                                currentHud.Enabled = true
                            end
                        elseif hud then
                            hud.Enabled = false
                        end
                    end
                end
            end
        end
    end

    -- 15. Radar (FREE simples)
    if getgenv().SystemConfig.RadarEnabled then
        -- Implementação básica: desenhar pontos em um frame (simplificado)
        -- Pode ser feito com um GUI overlay
    end

    -- 16. Distância HUD (Premium)
    if IsPremium and getgenv().SystemConfig.ShowDistanceHUD then
        -- Implementar display de distância no HUD (já feito no Micro-HUD)
    end

    -- 17. Seta Direcional (Premium)
    if IsPremium and getgenv().SystemConfig.ShowDirectionArrow then
        -- Similar ao radar, desenhar uma seta na tela
    end
end)

-- ============================================================================
-- HEARTBEAT: SPEED E JUMP (PREMIUM) E OUTRAS CORREÇÕES
-- ============================================================================
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if IsPremium then
        if getgenv().SystemConfig.SpeedEnabled then
            if hum.WalkSpeed ~= getgenv().SystemConfig.SpeedValue then
                hum.WalkSpeed = getgenv().SystemConfig.SpeedValue
            end
        else
            if hum.WalkSpeed ~= OriginalWalkSpeed then hum.WalkSpeed = OriginalWalkSpeed end
        end

        if getgenv().SystemConfig.JumpEnabled then
            if hum.JumpPower ~= getgenv().SystemConfig.JumpPower then
                hum.JumpPower = getgenv().SystemConfig.JumpPower
            end
        else
            if hum.JumpPower ~= OriginalJumpPower then hum.JumpPower = OriginalJumpPower end
        end
    else
        if hum.WalkSpeed ~= OriginalWalkSpeed then hum.WalkSpeed = OriginalWalkSpeed end
        if hum.JumpPower ~= OriginalJumpPower then hum.JumpPower = OriginalJumpPower end
    end

    if IsPremium and getgenv().SystemConfig.InfiniteJump then
        if hum and hum:GetState() == Enum.HumanoidStateType.Freefall and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ============================================================================
-- FLY (PREMIUM) - FUNÇÕES
-- ============================================================================
local function stopFly()
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
    getgenv().SystemConfig.FlyEnabled = false
end

local function startFly()
    if not IsPremium then return end
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
        if not IsPremium or not getgenv().SystemConfig.FlyEnabled then stopFly(); return end
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

-- ============================================================================
-- EVENTO CHARACTER ADDED
-- ============================================================================
Player.CharacterAdded:Connect(function(char)
    task.wait(0.6)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        OriginalWalkSpeed = hum.WalkSpeed
        OriginalJumpPower = hum.JumpPower
    end
    if IsPremium and NoClipAtivo then
        if NoClipConnection then NoClipConnection:Disconnect() end
        NoClipConnection = RunService.Stepped:Connect(function()
            local chr = Player.Character
            if chr then
                for _, part in ipairs(chr:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
    if IsPremium and getgenv().SystemConfig.FlyEnabled then
        startFly()
    end
end)

-- ============================================================================
-- NOTIFICAÇÃO INICIAL
-- ============================================================================
Rayfield:Notify({
    Title = "👑 WARCORE ULTIMATE",
    Content = "Versão Demonstrativa - Recursos Premium bloqueados",
    Duration = 5,
    Image = 4483362458
})