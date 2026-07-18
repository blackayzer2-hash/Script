--[[
    ╔════════════════════════════════════════════════════════════╗
    ║       PROJECT: SHADOWCLIENT v3.5 (ULTRA OVERHAUL)          ║
    ║       STUDIO: SHADOW PROTOCOL LABS                         ║
    ║------------------------------------------------------------║
    ║       LEAD DEVELOPER: ENZO CAVALCANTI                      ║
    ║       MOD: MODO MEU REI - UI PREMIUM MOBILE                ║
    ║       SISTEMA DE ESP DINÂMICO POR EQUIPE                   ║
    ╚════════════════════════════════════════════════════════════╝
]]

--// [CORE & CACHE]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

--// [SISTEMA DE CONFIGURAÇÃO AVANÇADO]
getgenv().SystemConfig = {
    -- Combate
    MiraAtiva = false,
    FovRadius = 500,
    Smoothness = 0.35,
    TeamCheck = true,
    
    -- Visual / ESP
    HighlightEnabled = false,
    HighlightTeamColor = Color3.fromRGB(0, 255, 100),
    HighlightEnemyColor = Color3.fromRGB(255, 0, 50),
    HighlightFillTransparency = 0.4,
    HighlightOutlineTransparency = 0.2,
    DotEnabled = false,
    DotShape = "●",
    DotSize = 12,
    LineEnabled = false,
    LineColor = Color3.fromRGB(0, 200, 255),
    LineThickness = 1.5,
    TracerEnabled = false,
    TracerColor = Color3.fromRGB(0, 255, 200),
    TracerThickness = 1,
    MicroHpEnabled = false,
    MicroDistEnabled = false,
    MicroNameEnabled = false,
    MicroTextSize = 9,
    MicroWidth = 40,
    DistColor = Color3.fromRGB(255, 255, 255),
    
    -- Iluminação
    FullBright = false,
    NoShadows = false,
    ClarezaMod = false,
    NeutralColors = false,
    
    -- Movimento
    FlyEnabled = false,
    FlySpeed = 50,
    FlyInfinite = false,
    NoClipAtivo = false,
    WalkSpeedAtivo = false,
    WalkSpeedValue = 50,
    PuloInfinito = false,
    JumpPowerAtivo = false,
    JumpPowerValue = 100,
    
    -- Monitor
    ShowFPS = false,
    ShowPlayers = false,
    ShowPing = false,
    
    -- Sistema
    AntiAFK = false,
    AutoFarm = false,
    ESPToggle = false,
}

--// [VARIÁVEIS AUXILIARES]
local OriginalWalkSpeed = 16
local OriginalJumpPower = 50
local NoClipConnection = nil
local flyVelocity = nil
local flyConnection = nil
local OriginalSettings = {}
local ESPObjects = {
    Highlights = {},
    Dots = {},
    Lines = {},
    Tracers = {},
    MicroHUDs = {}
}

--// [SALVAR CONFIGURAÇÕES ORIGINAIS]
OriginalSettings = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    GlobalShadows = Lighting.GlobalShadows,
    Exposure = Lighting.ExposureCompensation,
}

--// [FUNÇÕES DE UTILIDADE]
local function IsBehindWall(targetPart)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {Player.Character, targetPart.Parent}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rayParams)
    return result ~= nil
end

local function IsAlly(player)
    return player.Team == Player.Team and Player.Team ~= nil
end

local function GetTeamColor(player)
    return IsAlly(player) and getgenv().SystemConfig.HighlightTeamColor or getgenv().SystemConfig.HighlightEnemyColor
end

local function CreateUIElement(parent, className, properties)
    local element = Instance.new(className, parent)
    for key, value in pairs(properties or {}) do
        pcall(function() element[key] = value end)
    end
    return element
end

local function RoundCorners(obj, radius)
    local corner = Instance.new("UICorner", obj)
    corner.CornerRadius = UDim.new(0, radius)
    return corner
end

local function TweenElement(obj, time, data)
    TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quart), data):Play()
end

--// [FUNÇÃO PARA FLY]
local function StartFly()
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if flyVelocity then flyVelocity:Destroy() end
    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.Name = "FlyVelocity"
    flyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    flyVelocity.Parent = hrp
    getgenv().SystemConfig.FlyEnabled = true
    
    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RunService.RenderStepped:Connect(function()
        if not getgenv().SystemConfig.FlyEnabled then 
            StopFly()
            return 
        end
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
            end
        end
        flyVelocity.Velocity = targetVel
    end)
end

local function StopFly()
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
    getgenv().SystemConfig.FlyEnabled = false
end

--// [FUNÇÃO PARA MIRA ASSISTIDA]
local function GetTarget()
    local closest, shortest = nil, getgenv().SystemConfig.FovRadius
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                if not (IsAlly(p) and getgenv().SystemConfig.TeamCheck) then
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

--// [FUNÇÃO DE MICRO-HUD]
local function CreateMicroDisplay(char, player)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local billboard = root:FindFirstChild("SHADOW_MicroHUD")
    if not billboard then
        billboard = Instance.new("BillboardGui", root)
        billboard.Name = "SHADOW_MicroHUD"
        billboard.AlwaysOnTop = true
        billboard.ExtentsOffset = Vector3.new(0, -4, 0)
        billboard.Size = UDim2.new(0, 40, 0, 20)
        
        -- Background da barra de vida
        local bgBar = Instance.new("Frame", billboard)
        bgBar.Name = "BackgroundBar"
        bgBar.Size = UDim2.new(1, -4, 0, 4)
        bgBar.Position = UDim2.new(0, 2, 0, 2)
        bgBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        bgBar.BackgroundTransparency = 0.3
        bgBar.BorderSizePixel = 0
        RoundCorners(bgBar, 2)
        
        -- Barra de vida
        local mainBar = Instance.new("Frame", bgBar)
        mainBar.Name = "MainBar"
        mainBar.Size = UDim2.new(1, 0, 1, 0)
        mainBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        mainBar.BorderSizePixel = 0
        RoundCorners(mainBar, 2)
        
        -- Nome do jogador
        local nameLabel = Instance.new("TextLabel", billboard)
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0, 10)
        nameLabel.Position = UDim2.new(0, 0, 0, 8)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 9
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        
        -- Distância
        local distLabel = Instance.new("TextLabel", billboard)
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0, 10)
        distLabel.Position = UDim2.new(0, 0, 0, 18)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = ""
        distLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
        distLabel.TextSize = 8
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextStrokeTransparency = 0.5
        distLabel.TextXAlignment = Enum.TextXAlignment.Center
    end
    
    return billboard
end

--// [INICIALIZAÇÃO DA UI]
pcall(function() 
    if CoreGui:FindFirstChild("SHADOWCLIENT_UI") then 
        CoreGui.SHADOWCLIENT_UI:Destroy() 
    end 
end)

local GUI = Instance.new("ScreenGui", CoreGui)
GUI.Name = "SHADOWCLIENT_UI"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

--// [BOTÃO FLUTUANTE DA MIRA]
local FloatingBtn = Instance.new("TextButton", GUI)
FloatingBtn.Visible = false
FloatingBtn.Size = UDim2.new(0, 75, 0, 40)
FloatingBtn.Position = UDim2.new(0.85, 0, 0.45, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(11, 14, 24)
FloatingBtn.Text = "⚡ OFF"
FloatingBtn.TextColor3 = Color3.fromRGB(130, 140, 160)
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.TextSize = 13
FloatingBtn.Draggable = true
FloatingBtn.Active = true
FloatingBtn.ZIndex = 10
RoundCorners(FloatingBtn, 12)

local BtnStroke = Instance.new("UIStroke", FloatingBtn)
BtnStroke.Thickness = 2
BtnStroke.Color = Color3.fromRGB(35, 42, 65)
BtnStroke.Transparency = 0.3

local function UpdateBtnVisual(active)
    if active then
        TweenElement(FloatingBtn, 0.25, {BackgroundColor3 = Color3.fromRGB(16, 28, 48)})
        TweenElement(BtnStroke, 0.25, {Color = Color3.fromRGB(0, 240, 255)})
        FloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        FloatingBtn.Text = "⚡ ON"
    else
        TweenElement(FloatingBtn, 0.25, {BackgroundColor3 = Color3.fromRGB(11, 14, 24)})
        TweenElement(BtnStroke, 0.25, {Color = Color3.fromRGB(35, 42, 65)})
        FloatingBtn.TextColor3 = Color3.fromRGB(130, 140, 160)
        FloatingBtn.Text = "⚡ OFF"
    end
end

FloatingBtn.MouseButton1Click:Connect(function()
    getgenv().SystemConfig.MiraAtiva = not getgenv().SystemConfig.MiraAtiva
    UpdateBtnVisual(getgenv().SystemConfig.MiraAtiva)
end)

--// [BOTÃO DE ABERTURA DO MENU]
local OpenBtn = Instance.new("TextButton", GUI)
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0.04, 0, 0.85, 0)
OpenBtn.Text = "👑"
OpenBtn.TextSize = 28
OpenBtn.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.ZIndex = 10
RoundCorners(OpenBtn, 15)

local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Thickness = 2
OpenStroke.Color = Color3.fromRGB(60, 70, 150)
OpenStroke.Transparency = 0.4

--// [PAINEL PRINCIPAL - MODO MEU REI]
local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, -200, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(10, 12, 22)
Main.Active = true
Main.Draggable = true
Main.ZIndex = 5
Main.Visible = false
RoundCorners(Main, 16)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(40, 50, 120)
MainStroke.Transparency = 0.3

--// [HEADER DO PAINEL]
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(15, 18, 32)
Header.BackgroundTransparency = 0.1
Header.ZIndex = 6
RoundCorners(Header, 16)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "👑 SHADOWCLIENT v3.5"
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(220, 220, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Monitor FPS/Players
local Monitor = Instance.new("TextLabel", Header)
Monitor.Position = UDim2.new(1, -130, 0.5, -8)
Monitor.Size = UDim2.new(0, 120, 0, 16)
Monitor.BackgroundTransparency = 1
Monitor.TextColor3 = Color3.fromRGB(0, 240, 255)
Monitor.TextSize = 11
Monitor.Font = Enum.Font.Gotham
Monitor.Text = ""
Monitor.TextXAlignment = Enum.TextXAlignment.Right

task.spawn(function()
    local fps = 0
    local frameCount = 0
    local lastTime = os.clock()
    
    while GUI and GUI.Parent do
        frameCount = frameCount + 1
        local currentTime = os.clock()
        if currentTime - lastTime >= 1 then
            fps = frameCount
            frameCount = 0
            lastTime = currentTime
            
            local txt = ""
            if getgenv().SystemConfig.ShowFPS then
                txt = "⚡ " .. fps .. " FPS"
            end
            if getgenv().SystemConfig.ShowPlayers then
                if txt ~= "" then txt = txt .. " | " end
                txt = txt .. "👥 " .. #Players:GetPlayers()
            end
            if getgenv().SystemConfig.ShowPing then
                if txt ~= "" then txt = txt .. " | " end
                local ping = math.floor((game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString() or "0"):gsub("[^0-9]", ""))
                txt = txt .. "📶 " .. ping .. "ms"
            end
            Monitor.Text = txt
        end
        task.wait(0.01)
    end
end)

-- Botões de controle
local function CreateHeaderButton(txt, x, color)
    local btn = Instance.new("TextButton", Header)
    btn.Size = UDim2.new(0, 32, 0, 32)
    btn.Position = UDim2.new(1, -x, 0.5, -16)
    btn.Text = txt
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
    btn.ZIndex = 7
    RoundCorners(btn, 8)
    return btn
end

local MinBtn = CreateHeaderButton("—", 75)
local CloseBtn = CreateHeaderButton("✕", 40)

MinBtn.MouseButton1Click:Connect(function()
    TweenElement(Main, 0.3, {Size = UDim2.new(0, 0, 0, 0)})
    task.wait(0.3)
    Main.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = true
    Main.Size = UDim2.new(0, 0, 0, 0)
    TweenElement(Main, 0.3, {Size = UDim2.new(0, 400, 0, 480)})
    OpenBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    GUI:Destroy()
end)

--// [SIDEBAR - TABS]
local Sidebar = Instance.new("Frame", Main)
Sidebar.Position = UDim2.new(0, 0, 0, 48)
Sidebar.Size = UDim2.new(0, 110, 1, -48)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
Sidebar.BackgroundTransparency = 0.1

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 4)

--// [BODY - CONTEÚDO DAS TABS]
local Body = Instance.new("ScrollingFrame", Main)
Body.Position = UDim2.new(0, 115, 0, 52)
Body.Size = UDim2.new(1, -120, 1, -56)
Body.BackgroundTransparency = 1
Body.ScrollBarThickness = 3
Body.ScrollBarImageColor3 = Color3.fromRGB(60, 70, 150)
Body.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
Body.CanvasSize = UDim2.new(0, 0, 0, 0)

local BodyLayout = Instance.new("UIListLayout", Body)
BodyLayout.Padding = UDim.new(0, 0)

local Pages = {}

--// [FUNÇÃO PARA CRIAR TABS]
local function CreateTab(name, icon)
    local Btn = Instance.new("TextButton", Sidebar)
    Btn.Size = UDim2.new(1, -8, 0, 38)
    Btn.Position = UDim2.new(0, 4, 0, 0)
    Btn.Text = icon .. " " .. name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 22, 34)
    Btn.BackgroundTransparency = 0.5
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    RoundCorners(Btn, 8)
    
    local Page = Instance.new("ScrollingFrame", Body)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Visible = false
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 0
    Page.BorderSizePixel = 0
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 6)
    
    Btn.MouseButton1Click:Connect(function()
        for _, p in ipairs(Pages) do 
            p.Visible = false 
        end
        Page.Visible = true
    end)
    
    table.insert(Pages, Page)
    if #Pages == 1 then Page.Visible = true end
    return Page
end

--// [FUNÇÕES DE UI COMPONENTES]
local function CreateSection(parent, title, color)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.BackgroundTransparency = 1
    
    local line = Instance.new("Frame", frame)
    line.Size = UDim2.new(1, 0, 0, 2)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = color or Color3.fromRGB(60, 70, 150)
    line.BackgroundTransparency = 0.4
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = " " .. title
    label.TextColor3 = Color3.fromRGB(200, 200, 230)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    return frame
end

local function CreateToggle(parent, text, default, callback)
    local state = default or false
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(15, 18, 30)
    frame.BackgroundTransparency = 0.2
    RoundCorners(frame, 10)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local switch = Instance.new("TextButton", frame)
    switch.Size = UDim2.new(0, 50, 0, 26)
    switch.Position = UDim2.new(1, -60, 0.5, -13)
    switch.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 40, 60)
    switch.Text = state and "ON" or "OFF"
    switch.TextColor3 = Color3.fromRGB(255, 255, 255)
    switch.Font = Enum.Font.GothamBold
    switch.TextSize = 11
    RoundCorners(switch, 8)
    
    switch.MouseButton1Click:Connect(function()
        state = not state
        switch.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 40, 60)
        switch.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end)
    
    return { frame = frame, setValue = function(v)
        state = v
        switch.BackgroundColor3 = v and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 40, 60)
        switch.Text = v and "ON" or "OFF"
        if callback then callback(v) end
    end }
end

local function CreateSlider(parent, text, min, max, default, increment, callback)
    local value = default or min
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(15, 18, 30)
    frame.BackgroundTransparency = 0.2
    RoundCorners(frame, 10)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 0, 18)
    label.Position = UDim2.new(0, 5, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(value)
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Center
    
    local track = Instance.new("Frame", frame)
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(30, 35, 55)
    track.BackgroundTransparency = 0.5
    RoundCorners(track, 3)
    
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(60, 70, 180)
    RoundCorners(fill, 3)
    
    local drag = Instance.new("TextButton", track)
    drag.Size = UDim2.new(0, 20, 0, 20)
    drag.Position = UDim2.new((value - min) / (max - min), -10, 0.5, -10)
    drag.BackgroundColor3 = Color3.fromRGB(80, 90, 220)
    drag.Text = ""
    RoundCorners(drag, 10)
    
    local dragging = false
    local currentValue = value
    
    drag.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    local function updateSlider(input)
        local absoluteSize = track.AbsoluteSize.X
        local mouseX = input.Position.X - track.AbsolutePosition.X
        local percent = math.clamp(mouseX / absoluteSize, 0, 1)
        local val = min + (max - min) * percent
        val = math.round(val / (increment or 1)) * (increment or 1)
        val = math.clamp(val, min, max)
        
        currentValue = val
        fill.Size = UDim2.new(percent, 0, 1, 0)
        drag.Position = UDim2.new(percent, -10, 0.5, -10)
        label.Text = text .. ": " .. tostring(val)
        if callback then callback(val) end
    end
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                         input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    return { frame = frame, setValue = function(v)
        local percent = (v - min) / (max - min)
        currentValue = v
        fill.Size = UDim2.new(percent, 0, 1, 0)
        drag.Position = UDim2.new(percent, -10, 0.5, -10)
        label.Text = text .. ": " .. tostring(v)
        if callback then callback(v) end
    end }
end

local function CreateColorPicker(parent, text, defaultColor, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(15, 18, 30)
    frame.BackgroundTransparency = 0.2
    RoundCorners(frame, 10)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local colorBtn = Instance.new("TextButton", frame)
    colorBtn.Size = UDim2.new(0, 40, 0, 26)
    colorBtn.Position = UDim2.new(1, -50, 0.5, -13)
    colorBtn.BackgroundColor3 = defaultColor
    colorBtn.Text = ""
    RoundCorners(colorBtn, 6)
    
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
    local colorIndex = 1
    
    colorBtn.MouseButton1Click:Connect(function()
        colorIndex = colorIndex % #colors + 1
        colorBtn.BackgroundColor3 = colors[colorIndex]
        if callback then callback(colors[colorIndex]) end
    end)
    
    return { frame = frame, setColor = function(c)
        colorBtn.BackgroundColor3 = c
        if callback then callback(c) end
    end }
end

local function CreateDropdown(parent, text, options, default, callback)
    local currentOption = default or options[1]
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 48)
    frame.BackgroundColor3 = Color3.fromRGB(15, 18, 30)
    frame.BackgroundTransparency = 0.2
    RoundCorners(frame, 10)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 0, 18)
    label.Position = UDim2.new(0, 5, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Center
    
    local dropdownBtn = Instance.new("TextButton", frame)
    dropdownBtn.Size = UDim2.new(0.8, 0, 0, 26)
    dropdownBtn.Position = UDim2.new(0.1, 0, 0, 22)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 50)
    dropdownBtn.Text = currentOption
    dropdownBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.TextSize = 11
    RoundCorners(dropdownBtn, 6)
    
    local isOpen = false
    local dropdownList = nil
    
    dropdownBtn.MouseButton1Click:Connect(function()
        if isOpen and dropdownList then
            dropdownList:Destroy()
            dropdownList = nil
            isOpen = false
            return
        end
        
        isOpen = true
        dropdownList = Instance.new("Frame", frame)
        dropdownList.Size = UDim2.new(0.8, 0, 0, math.min(#options * 30, 120))
        dropdownList.Position = UDim2.new(0.1, 0, 0, 48)
        dropdownList.BackgroundColor3 = Color3.fromRGB(20, 23, 40)
        dropdownList.BackgroundTransparency = 0.1
        RoundCorners(dropdownList, 6)
        
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
            RoundCorners(optBtn, 4)
            
            optBtn.MouseButton1Click:Connect(function()
                currentOption = option
                dropdownBtn.Text = option
                if dropdownList then dropdownList:Destroy(); dropdownList = nil; isOpen = false end
                if callback then callback(option) end
            end)
        end
    end)
    
    return { frame = frame, setOption = function(opt)
        currentOption = opt
        dropdownBtn.Text = opt
        if callback then callback(opt) end
    end }
end

--// [CRIAR TABS]
local CombatTab = CreateTab("Combate", "🔫")
local VisualTab = CreateTab("Visual", "👁️")
local ESPTab = CreateTab("Raio-X", "🔍")
local LightTab = CreateTab("Luz", "💡")
local MoveTab = CreateTab("Movimento", "🧱")
local StatusTab = CreateTab("Status", "📊")

--// [CONTEÚDO - COMBATE]
CreateSection(CombatTab, "🎯 Sistema de Mira", Color3.fromRGB(200, 50, 50))
CreateToggle(CombatTab, "Mira Assistida", false, function(v)
    getgenv().SystemConfig.MiraAtiva = v
    FloatingBtn.Visible = v
    UpdateBtnVisual(v)
end)
CreateSlider(CombatTab, "Suavidade", 0.1, 1.0, 0.35, 0.05, function(v)
    getgenv().SystemConfig.Smoothness = v
end)
CreateSlider(CombatTab, "FOV (Raio de Mira)", 100, 800, 500, 50, function(v)
    getgenv().SystemConfig.FovRadius = v
end)
CreateToggle(CombatTab, "Verificar Equipe", true, function(v)
    getgenv().SystemConfig.TeamCheck = v
end)

--// [CONTEÚDO - VISUAL]
CreateSection(VisualTab, "🎨 Elementos Visuais", Color3.fromRGB(100, 200, 255))
CreateToggle(VisualTab, "Modo Clareza", false, function(v)
    getgenv().SystemConfig.ClarezaMod = v
end)
CreateToggle(VisualTab, "Remover Sombras", false, function(v)
    Lighting.GlobalShadows = not v
    getgenv().SystemConfig.NoShadows = v
end)
CreateToggle(VisualTab, "Cores Neutras", false, function(v)
    getgenv().SystemConfig.NeutralColors = v
end)

--// [CONTEÚDO - RAIO-X]
CreateSection(ESPTab, "🔍 Scanner Avançado", Color3.fromRGB(0, 200, 100))
CreateToggle(ESPTab, "Ativar Raio-X", false, function(v)
    getgenv().SystemConfig.HighlightEnabled = v
    if not v then
        for _, obj in pairs(ESPObjects.Highlights) do
            pcall(function() obj:Destroy() end)
        end
        ESPObjects.Highlights = {}
    end
end)

CreateSection(ESPTab, "🎯 Pontos e Linhas", Color3.fromRGB(200, 150, 0))
CreateToggle(ESPTab, "Ponto na Cabeça", false, function(v)
    getgenv().SystemConfig.DotEnabled = v
end)
CreateToggle(ESPTab, "Linha de Mira", false, function(v)
    getgenv().SystemConfig.LineEnabled = v
end)
CreateToggle(ESPTab, "Tracer (Rastro)", false, function(v)
    getgenv().SystemConfig.TracerEnabled = v
end)
CreateSlider(ESPTab, "Espessura da Linha", 0.5, 5, 1.5, 0.5, function(v)
    getgenv().SystemConfig.LineThickness = v
end)

CreateSection(ESPTab, "📊 Micro-HUD", Color3.fromRGB(200, 100, 200))
CreateToggle(ESPTab, "Exibir Vida", false, function(v)
    getgenv().SystemConfig.MicroHpEnabled = v
end)
CreateToggle(ESPTab, "Exibir Distância", false, function(v)
    getgenv().SystemConfig.MicroDistEnabled = v
end)
CreateToggle(ESPTab, "Exibir Nome", false, function(v)
    getgenv().SystemConfig.MicroNameEnabled = v
end)
CreateSlider(ESPTab, "Tamanho do Texto", 6, 16, 9, 1, function(v)
    getgenv().SystemConfig.MicroTextSize = v
end)
CreateSlider(ESPTab, "Largura da Barra", 25, 80, 40, 5, function(v)
    getgenv().SystemConfig.MicroWidth = v
end)

CreateSection(ESPTab, "🎨 Cores do Sistema", Color3.fromRGB(255, 200, 50))
CreateColorPicker(ESPTab, "Cor - Aliados", Color3.fromRGB(0, 255, 100), function(c)
    getgenv().SystemConfig.HighlightTeamColor = c
end)
CreateColorPicker(ESPTab, "Cor - Inimigos", Color3.fromRGB(255, 0, 50), function(c)
    getgenv().SystemConfig.HighlightEnemyColor = c
end)
CreateColorPicker(ESPTab, "Cor da Linha", Color3.fromRGB(0, 200, 255), function(c)
    getgenv().SystemConfig.LineColor = c
end)
CreateColorPicker(ESPTab, "Cor do Tracer", Color3.fromRGB(0, 255, 200), function(c)
    getgenv().SystemConfig.TracerColor = c
end)

CreateSection(ESPTab, "⚙️ Configurações Avançadas", Color3.fromRGB(150, 150, 200))
CreateDropdown(ESPTab, "Modo de Profundidade", {"Sempre Visível", "Atrás de Paredes"}, "Sempre Visível", function(opt)
    getgenv().SystemConfig.HlDepthMode = opt == "Sempre Visível" and "AlwaysOnTop" or "Occluded"
end)
CreateDropdown(ESPTab, "Forma do Ponto", {"● Círculo", "▲ Triângulo", "■ Quadrado", "◆ Losango", "★ Estrela"}, "● Círculo", function(opt)
    local shapes = {
        ["● Círculo"] = "●",
        ["▲ Triângulo"] = "▲",
        ["■ Quadrado"] = "■",
        ["◆ Losango"] = "◆",
        ["★ Estrela"] = "★"
    }
    getgenv().SystemConfig.DotShape = shapes[opt] or "●"
end)

--// [CONTEÚDO - LUZ]
CreateSection(LightTab, "💡 Controle de Iluminação", Color3.fromRGB(255, 200, 50))
CreateToggle(LightTab, "FullBright", false, function(v)
    getgenv().SystemConfig.FullBright = v
    if not v then
        Lighting.Ambient = OriginalSettings.Ambient
        Lighting.Brightness = OriginalSettings.Brightness
        Lighting.ClockTime = OriginalSettings.ClockTime
        Lighting.FogEnd = OriginalSettings.FogEnd
        Lighting.OutdoorAmbient = OriginalSettings.OutdoorAmbient
    end
end)

--// [CONTEÚDO - MOVIMENTO]
CreateSection(MoveTab, "🕊️ Fly", Color3.fromRGB(50, 150, 255))
CreateToggle(MoveTab, "Ativar Fly", false, function(v)
    if v then StartFly() else StopFly() end
end)
CreateToggle(MoveTab, "Modo Infinito", false, function(v)
    getgenv().SystemConfig.FlyInfinite = v
end)
CreateSlider(MoveTab, "Velocidade", 1, 500, 50, 5, function(v)
    getgenv().SystemConfig.FlySpeed = v
end)

CreateSection(MoveTab, "🧱 Física", Color3.fromRGB(200, 150, 0))
CreateToggle(MoveTab, "No-Clip", false, function(v)
    getgenv().SystemConfig.NoClipAtivo = v
    if v then
        NoClipConnection = RunService.Stepped:Connect(function()
            if Player.Character then
                for _, part in ipairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if NoClipConnection then NoClipConnection:Disconnect(); NoClipConnection = nil end
        if Player.Character then
            for _, part in ipairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)

CreateSection(MoveTab, "⚡ Velocidade", Color3.fromRGB(0, 200, 255))
CreateToggle(MoveTab, "Speed Hack", false, function(v)
    getgenv().SystemConfig.WalkSpeedAtivo = v
    if not v and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = OriginalWalkSpeed end
    end
end)
CreateSlider(MoveTab, "Velocidade", 16, 200, 50, 1, function(v)
    getgenv().SystemConfig.WalkSpeedValue = v
end)

CreateSection(MoveTab, "🦘 Pulo", Color3.fromRGB(200, 100, 255))
CreateToggle(MoveTab, "Super Pulo", false, function(v)
    getgenv().SystemConfig.JumpPowerAtivo = v
    if Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = v and getgenv().SystemConfig.JumpPowerValue or OriginalJumpPower
        end
    end
end)
CreateSlider(MoveTab, "Altura do Pulo", 50, 300, 100, 5, function(v)
    getgenv().SystemConfig.JumpPowerValue = v
    if getgenv().SystemConfig.JumpPowerAtivo and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end
end)
CreateToggle(MoveTab, "Pulo Infinito", false, function(v)
    getgenv().SystemConfig.PuloInfinito = v
end)

--// [CONTEÚDO - STATUS]
CreateSection(StatusTab, "📊 Monitor de Desempenho", Color3.fromRGB(0, 200, 255))
CreateToggle(StatusTab, "Exibir FPS", false, function(v)
    getgenv().SystemConfig.ShowFPS = v
end)
CreateToggle(StatusTab, "Exibir Players", false, function(v)
    getgenv().SystemConfig.ShowPlayers = v
end)
CreateToggle(StatusTab, "Exibir Ping", false, function(v)
    getgenv().SystemConfig.ShowPing = v
end)

CreateSection(StatusTab, "🛡️ Sistema", Color3.fromRGB(200, 200, 200))
CreateToggle(StatusTab, "Anti-AFK", false, function(v)
    getgenv().SystemConfig.AntiAFK = v
    if v then
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            if getgenv().SystemConfig.AntiAFK then
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "W", false, game)
                task.wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, "W", false, game)
            end
        end)
    end
end)

--// [RENDER LOOP PRINCIPAL]
RunService.RenderStepped:Connect(function(dt)
    -- Speed Hack
    if getgenv().SystemConfig.WalkSpeedAtivo and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = getgenv().SystemConfig.WalkSpeedValue end
    end
    
    -- Pulo Infinito
    if getgenv().SystemConfig.PuloInfinito then
        UserInputService.JumpRequest:Connect(function()
            if getgenv().SystemConfig.PuloInfinito and Player.Character then
                local hum = Player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
    
    -- Mira Assistida
    if getgenv().SystemConfig.MiraAtiva then
        local target = GetTarget()
        if target then
            local goal = CFrame.new(Camera.CFrame.Position, target.Position)
            local smoothness = getgenv().SystemConfig.Smoothness * math.clamp(60 * dt, 0, 1)
            Camera.CFrame = Camera.CFrame:Lerp(goal, smoothness)
        end
    end
    
    -- Iluminação
    if getgenv().SystemConfig.FullBright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 10
        Lighting.ClockTime = 14
        Lighting.FogEnd = 10000
    elseif getgenv().SystemConfig.ClarezaMod then
        Lighting.Brightness = 4
        Lighting.ExposureCompensation = 1
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
    else
        Lighting.Brightness = OriginalSettings.Brightness
        Lighting.ExposureCompensation = OriginalSettings.Exposure
        Lighting.Ambient = OriginalSettings.Ambient
    end
    
    -- ESP e Renderização dos Jogadores
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            
            if head and hum and hum.Health > 0 then
                local isTeam = IsAlly(p)
                local teamColor = isTeam and getgenv().SystemConfig.HighlightTeamColor or getgenv().SystemConfig.HighlightEnemyColor
                local behindWall = IsBehindWall(head)
                
                -- Highlight (Raio-X)
                if getgenv().SystemConfig.HighlightEnabled then
                    local hl = ESPObjects.Highlights[p]
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Parent = char
                        ESPObjects.Highlights[p] = hl
                    end
                    hl.Adornee = char
                    hl.FillColor = teamColor
                    hl.OutlineColor = teamColor
                    hl.FillTransparency = getgenv().SystemConfig.HighlightFillTransparency or 0.4
                    hl.OutlineTransparency = getgenv().SystemConfig.HighlightOutlineTransparency or 0.2
                    hl.DepthMode = getgenv().SystemConfig.HlDepthMode == "AlwaysOnTop" and 
                        Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                    hl.Enabled = true
                else
                    if ESPObjects.Highlights[p] then
                        ESPObjects.Highlights[p]:Destroy()
                        ESPObjects.Highlights[p] = nil
                    end
                end
                
                -- Dot (Ponto na Cabeça)
                if getgenv().SystemConfig.DotEnabled then
                    local dot = head:FindFirstChild("SHADOW_Dot")
                    if not dot then
                        local bill = Instance.new("BillboardGui", head)
                        bill.Name = "SHADOW_Dot"
                        bill.Size = UDim2.new(0, getgenv().SystemConfig.DotSize or 12, 0, getgenv().SystemConfig.DotSize or 12)
                        bill.AlwaysOnTop = true
                        bill.ExtentsOffset = Vector3.new(0, 1.5, 0)
                        
                        local frame = Instance.new("Frame", bill)
                        frame.Size = UDim2.new(1, 0, 1, 0)
                        frame.BackgroundColor3 = teamColor
                        RoundCorners(frame, 100)
                        
                        local label = Instance.new("TextLabel", bill)
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = getgenv().SystemConfig.DotShape or "●"
                        label.TextColor3 = teamColor
                        label.TextSize = getgenv().SystemConfig.DotSize or 12
                        label.Font = Enum.Font.GothamBold
                        label.TextXAlignment = Enum.TextXAlignment.Center
                        label.TextYAlignment = Enum.TextYAlignment.Center
                        dot = bill
                    end
                    
                    local frame = dot:FindFirstChildOfClass("Frame")
                    if frame then
                        frame.BackgroundColor3 = teamColor
                    end
                    
                    local label = dot:FindFirstChildOfClass("TextLabel")
                    if label then
                        label.TextColor3 = teamColor
                        label.Text = getgenv().SystemConfig.DotShape or "●"
                    end
                    
                    dot.Enabled = true
                else
                    local dot = head:FindFirstChild("SHADOW_Dot")
                    if dot then dot:Destroy() end
                end
                
                -- Line (Linha de Mira)
                if getgenv().SystemConfig.LineEnabled and root then
                    local line = ESPObjects.Lines[p]
                    if not line then
                        line = Drawing.new("Line")
                        line.Thickness = getgenv().SystemConfig.LineThickness
                        line.Color = getgenv().SystemConfig.LineColor
                        line.Transparency = 1
                        line.Visible = true
                        ESPObjects.Lines[p] = line
                    end
                    
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen and pos.Z > 0 then
                        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        line.From = center
                        line.To = Vector2.new(pos.X, pos.Y)
                        line.Color = getgenv().SystemConfig.LineColor
                        line.Thickness = getgenv().SystemConfig.LineThickness
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                else
                    if ESPObjects.Lines[p] then
                        ESPObjects.Lines[p]:Destroy()
                        ESPObjects.Lines[p] = nil
                    end
                end
                
                -- Tracer (Rastro)
                if getgenv().SystemConfig.TracerEnabled and root then
                    local tracer = ESPObjects.Tracers[p]
                    if not tracer then
                        tracer = Drawing.new("Line")
                        tracer.Thickness = getgenv().SystemConfig.TracerThickness or 1
                        tracer.Color = getgenv().SystemConfig.TracerColor
                        tracer.Transparency = 0.8
                        tracer.Visible = true
                        ESPObjects.Tracers[p] = tracer
                    end
                    
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen and pos.Z > 0 then
                        local bottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        tracer.From = bottom
                        tracer.To = Vector2.new(pos.X, pos.Y)
                        tracer.Color = getgenv().SystemConfig.TracerColor
                        tracer.Thickness = getgenv().SystemConfig.TracerThickness or 1
                        tracer.Visible = true
                    else
                        tracer.Visible = false
                    end
                else
                    if ESPObjects.Tracers[p] then
                        ESPObjects.Tracers[p]:Destroy()
                        ESPObjects.Tracers[p] = nil
                    end
                end
                
                -- Micro-HUD
                if root and (getgenv().SystemConfig.MicroHpEnabled or getgenv().SystemConfig.MicroDistEnabled or getgenv().SystemConfig.MicroNameEnabled) then
                    local hud = CreateMicroDisplay(char, p)
                    if hud then
                        local bgBar = hud:FindFirstChild("BackgroundBar")
                        local mainBar = bgBar and bgBar:FindFirstChild("MainBar")
                        local nameLabel = hud:FindFirstChild("NameLabel")
                        local distLabel = hud:FindFirstChild("DistLabel")
                        
                        if bgBar then
                            bgBar.Visible = getgenv().SystemConfig.MicroHpEnabled
                            if mainBar then
                                mainBar.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
                                mainBar.BackgroundColor3 = teamColor
                            end
                        end
                        
                        if nameLabel then
                            nameLabel.Visible = getgenv().SystemConfig.MicroNameEnabled
                            nameLabel.Text = getgenv().SystemConfig.MicroNameEnabled and p.Name or ""
                            nameLabel.TextSize = getgenv().SystemConfig.MicroTextSize
                        end
                        
                        if distLabel then
                            distLabel.Visible = getgenv().SystemConfig.MicroDistEnabled
                            if getgenv().SystemConfig.MicroDistEnabled then
                                local distance = Player:DistanceFromCharacter(root.Position)
                                distLabel.Text = string.format("%.1fm", distance)
                                distLabel.TextColor3 = getgenv().SystemConfig.DistColor
                                distLabel.TextSize = getgenv().SystemConfig.MicroTextSize
                            end
                        end
                        
                        hud.Enabled = true
                    end
                else
                    if root then
                        local hud = root:FindFirstChild("SHADOW_MicroHUD")
                        if hud then hud:Destroy() end
                    end
                end
            end
        end
    end
    
    -- Limpar objetos de jogadores que saíram
    for player, obj in pairs(ESPObjects.Highlights) do
        if not player.Parent then
            pcall(function() obj:Destroy() end)
            ESPObjects.Highlights[player] = nil
        end
    end
    for player, obj in pairs(ESPObjects.Lines) do
        if not player.Parent then
            pcall(function() obj:Destroy() end)
            ESPObjects.Lines[player] = nil
        end
    end
    for player, obj in pairs(ESPObjects.Tracers) do
        if not player.Parent then
            pcall(function() obj:Destroy() end)
            ESPObjects.Tracers[player] = nil
        end
    end
end)

--// [FINALIZAÇÃO]
print("👑 SHADOWCLIENT v3.5 - MODO MEU REI")
print("⚡ Sistema de ESP Dinâmico por Equipe")
print("🎯 Mira Assistida Otimizada")
print("🚀 Desenvolvido por Enzo Cavalcanti")
print("✅ Injetado com sucesso, meu rei!")