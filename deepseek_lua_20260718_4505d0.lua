--[[
    BROOKHAVEN RP HUB - DELTA EXECUTOR MOBILE
    SCRIPT COMPLETO E FUNCIONAL
]]

-- Aguardar jogo carregar
wait(3)

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Jogador local
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remover GUI antiga se existir
if PlayerGui:FindFirstChild("BrookHub") then
    PlayerGui.BrookHub:Destroy()
end

-- Criar ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrookHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- ============ FRAME PRINCIPAL ============
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 420, 0, 350)
Main.Position = UDim2.new(0.5, -210, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true
Main.Visible = true
Main.Parent = ScreenGui

-- Borda arredondada
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

-- ============ BARRA DE TÍTULO ============
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Título
local Title = Instance.new("TextLabel")
Title.Text = "🔥 BROOKHAVEN HUB"
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Botão Fechar
local Close = Instance.new("TextButton")
Close.Text = "✕"
Close.Size = UDim2.new(0, 40, 0, 40)
Close.Position = UDim2.new(1, -40, 0, 0)
Close.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 20
Close.BorderSizePixel = 0
Close.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = Close

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ============ BOTÕES DAS ABAS ============
local TabButtons = {}

local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, 110, 1, -40)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

-- Container do conteúdo
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -110, 1, -40)
ContentArea.Position = UDim2.new(0, 110, 0, 40)
ContentArea.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = Main

-- Função para criar aba
local function CreateTab(name, yPos)
    -- Botão da aba
    local TabBtn = Instance.new("TextButton")
    TabBtn.Text = name
    TabBtn.Size = UDim2.new(1, -10, 0, 35)
    TabBtn.Position = UDim2.new(0, 5, 0, yPos)
    TabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 13
    TabBtn.BorderSizePixel = 0
    TabBtn.AutoButtonColor = false
    TabBtn.Parent = TabBar
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabBtn
    
    -- Página da aba
    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = name .. "Page"
    TabPage.Size = UDim2.new(1, -10, 1, -10)
    TabPage.Position = UDim2.new(0, 5, 0, 5)
    TabPage.BackgroundTransparency = 1
    TabPage.BorderSizePixel = 0
    TabPage.ScrollBarThickness = 5
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    TabPage.Visible = false
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 100)
    TabPage.Parent = ContentArea
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 6)
    Layout.Parent = TabPage
    
    -- Conectar clique
    TabBtn.MouseButton1Click:Connect(function()
        -- Esconder todas as páginas
        for _, tab in ipairs(TabButtons) do
            tab.Page.Visible = false
            tab.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            tab.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        -- Mostrar esta página
        TabPage.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    return {Button = TabBtn, Page = TabPage}
end

-- Criar 4 abas
TabButtons = {
    CreateTab("🏷️ EQUIPES", 10),
    CreateTab("👤 SKINS", 55),
    CreateTab("🗺️ MAPA", 100),
    CreateTab("⚡ CLIENT", 145)
}

-- Ativar primeira aba
TabButtons[1].Button.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
TabButtons[1].Button.TextColor3 = Color3.fromRGB(255, 255, 255)
TabButtons[1].Page.Visible = true

-- ============ FUNÇÕES AUXILIARES ============
local function CreateLabel(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Size = UDim2.new(1, 0, 0, 22)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
    return Label
end

local function CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Text = text
    Button.Size = UDim2.new(1, -4, 0, 32)
    Button.BackgroundColor3 = Color3.fromRGB(65, 65, 200)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
        wait(0.1)
        Button.BackgroundColor3 = Color3.fromRGB(65, 65, 200)
        pcall(callback)
    end)
    
    return Button
end

local function CreateTextBox(parent, placeholder)
    local TextBox = Instance.new("TextBox")
    TextBox.PlaceholderText = placeholder
    TextBox.Size = UDim2.new(1, -4, 0, 30)
    TextBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 13
    TextBox.BorderSizePixel = 0
    TextBox.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = TextBox
    
    return TextBox
end

-- Variáveis globais
local CurrentSpeed = 16
local CurrentJump = 50
local SpeedEnabled = false
local JumpEnabled = false
local Flying = false
local BodyGyro = nil
local BodyVelocity = nil

-- ============ ABA 1: EQUIPES ============
local page1 = TabButtons[1].Page
page1.CanvasSize = UDim2.new(0, 0, 0, 280)

CreateLabel(page1, "🎭 TAGS DE FAMOSOS")

local tags = {
    "👑 Dono do Servidor",
    "📺 Youtuber Famoso",
    "🛡️ Staff Oficial",
    "⚙️ Administrador"
}

for _, tag in ipairs(tags) do
    CreateButton(page1, tag, function()
        local msg = "[TAG] " .. LocalPlayer.Name .. " agora é " .. tag
        for _, remoteName in ipairs({"ChatMessage", "SendMessage", "SendChat"}) do
            if ReplicatedStorage:FindFirstChild(remoteName) then
                ReplicatedStorage[remoteName]:FireServer(msg)
            end
            if ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild(remoteName) then
                ReplicatedStorage.RemoteEvents[remoteName]:FireServer(msg)
            end
        end
    end)
end

CreateLabel(page1, "✏️ TAG PERSONALIZADA")
local CustomTag = CreateTextBox(page1, "Digite sua tag...")

CreateButton(page1, "✅ APLICAR TAG CUSTOM", function()
    if CustomTag.Text ~= "" then
        local msg = "[TAG] " .. LocalPlayer.Name .. " agora é " .. CustomTag.Text
        for _, remoteName in ipairs({"ChatMessage", "SendMessage", "SendChat"}) do
            if ReplicatedStorage:FindFirstChild(remoteName) then
                ReplicatedStorage[remoteName]:FireServer(msg)
            end
            if ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild(remoteName) then
                ReplicatedStorage.RemoteEvents[remoteName]:FireServer(msg)
            end
        end
    end
end)

-- ============ ABA 2: SKINS ============
local page2 = TabButtons[2].Page
page2.CanvasSize = UDim2.new(0, 0, 0, 450)

CreateLabel(page2, "👕 ID DA CAMISA")
local ShirtID = CreateTextBox(page2, "Ex: 12345678")

CreateLabel(page2, "👖 ID DA CALÇA")
local PantsID = CreateTextBox(page2, "Ex: 12345678")

CreateLabel(page2, "💇 ID DO CABELO")
local HairID = CreateTextBox(page2, "Ex: 12345678")

CreateLabel(page2, "💎 ID DO ACESSÓRIO")
local AccessoryID = CreateTextBox(page2, "Ex: 12345678")

CreateButton(page2, "✅ APLICAR VISUAL", function()
    local char = LocalPlayer.Character
    if not char then return end
    
    local shirtId = ShirtID.Text
    if shirtId ~= "" and tonumber(shirtId) then
        local shirt = char:FindFirstChild("Shirt") or Instance.new("Shirt")
        shirt.ShirtTemplate = "rbxassetid://" .. shirtId
        shirt.Parent = char
    end
    
    local pantsId = PantsID.Text
    if pantsId ~= "" and tonumber(pantsId) then
        local pants = char:FindFirstChild("Pants") or Instance.new("Pants")
        pants.PantsTemplate = "rbxassetid://" .. pantsId
        pants.Parent = char
    end
    
    local hairId = HairID.Text
    if hairId ~= "" and tonumber(hairId) then
        if ReplicatedStorage:FindFirstChild("UpdateAvatar") then
            ReplicatedStorage.UpdateAvatar:FireServer(hairId)
        end
        if ReplicatedStorage:FindFirstChild("ChangeHair") then
            ReplicatedStorage.ChangeHair:FireServer(hairId)
        end
    end
    
    local accId = AccessoryID.Text
    if accId ~= "" and tonumber(accId) then
        if ReplicatedStorage:FindFirstChild("WearAccessory") then
            ReplicatedStorage.WearAccessory:FireServer(accId)
        end
    end
end)

CreateLabel(page2, "🎭 EFEITOS ESPECIAIS")

CreateButton(page2, "👻 FICAR INVISÍVEL", function()
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0.9
            end
        end
    end
end)

CreateButton(page2, "🔍 FICAR VISÍVEL", function()
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
    end
end)

CreateButton(page2, "🦍 MODO GIGANTE", function()
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Size = part.Size * 2
            end
        end
    end
end)

CreateButton(page2, "🐜 MODO MINI", function()
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Size = part.Size * 0.5
            end
        end
    end
end)

-- ============ ABA 3: MAPA ============
local page3 = TabButtons[3].Page
page3.CanvasSize = UDim2.new(0, 0, 0, 500)

CreateLabel(page3, "🔥 EVENTOS DO MAPA")

local events = {
    {"🚨 ATIVAR ALARME", function()
        for _, name in ipairs({"TriggerAlarm", "HouseAlarm", "FireAlarm"}) do
            if ReplicatedStorage:FindFirstChild(name) then
                ReplicatedStorage[name]:FireServer()
            end
            if ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild(name) then
                ReplicatedStorage.RemoteEvents[name]:FireServer()
            end
        end
    end},
    {"🔥 CAUSAR INCÊNDIO", function()
        for _, name in ipairs({"StartFire", "FireEvent", "DisasterEvent"}) do
            if ReplicatedStorage:FindFirstChild(name) then
                ReplicatedStorage[name]:FireServer("Fire")
            end
            if ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild(name) then
                ReplicatedStorage.RemoteEvents[name]:FireServer("Fire")
            end
        end
    end},
    {"💧 CAUSAR INUNDAÇÃO", function()
        for _, name in ipairs({"StartFlood", "FloodEvent", "DisasterEvent"}) do
            if ReplicatedStorage:FindFirstChild(name) then
                ReplicatedStorage[name]:FireServer("Flood")
            end
            if ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild(name) then
                ReplicatedStorage.RemoteEvents[name]:FireServer("Flood")
            end
        end
    end},
    {"🔓 DESTRANCAR PORTAS", function()
        for i = 1, 30 do
            for _, name in ipairs({"UnlockDoor", "DoorEvent"}) do
                if ReplicatedStorage:FindFirstChild(name) then
                    ReplicatedStorage[name]:FireServer(i)
                end
                if ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild(name) then
                    ReplicatedStorage.RemoteEvents[name]:FireServer(i)
                end
            end
        end
    end},
    {"🌪️ ATIVAR TORNADO", function()
        for _, name in ipairs({"DisasterEvent", "WeatherEvent"}) do
            if ReplicatedStorage:FindFirstChild(name) then
                ReplicatedStorage[name]:FireServer("Tornado")
            end
            if ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild(name) then
                ReplicatedStorage.RemoteEvents[name]:FireServer("Tornado")
            end
        end
    end}
}

for _, event in ipairs(events) do
    CreateButton(page3, event[1], event[2])
end

CreateLabel(page3, "🚗 SPAWNAR VEÍCULOS")

local vehicles = {"CarroEsportivo", "Helicoptero", "Barco", "Moto"}
for _, vehicle in ipairs(vehicles) do
    CreateButton(page3, "🚘 " .. vehicle, function()
        for _, name in ipairs({"SpawnVehicle", "SpawnItem", "Spawn"}) do
            if ReplicatedStorage:FindFirstChild(name) then
                ReplicatedStorage[name]:FireServer(vehicle)
            end
            if ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild(name) then
                ReplicatedStorage.RemoteEvents[name]:FireServer(vehicle)
            end
        end
    end)
end

-- ============ ABA 4: CLIENT ============
local page4 = TabButtons[4].Page
page4.CanvasSize = UDim2.new(0, 0, 0, 1200)

CreateLabel(page4, "🏃 MOVIMENTAÇÃO")

CreateLabel(page4, "VELOCIDADE ATUAL: 16")
local SpeedBox = CreateTextBox(page4, "16")

CreateLabel(page4, "PULO ATUAL: 50")
local JumpBox = CreateTextBox(page4, "50")

CreateButton(page4, "✅ APLICAR SPEED/JUMP", function()
    local speed = tonumber(SpeedBox.Text) or 16
    local jump = tonumber(JumpBox.Text) or 50
    CurrentSpeed = speed
    CurrentJump = jump
    SpeedEnabled = true
    JumpEnabled = true
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speed
        LocalPlayer.Character.Humanoid.JumpPower = jump
    end
end)

CreateButton(page4, "🔄 RESETAR MOVIMENTO", function()
    SpeedEnabled = false
    JumpEnabled = false
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end)

CreateButton(page4, "✈️ ATIVAR/DESATIVAR FLY", function()
    Flying = not Flying
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if Flying then
        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        BodyGyro.P = 30000
        BodyGyro.CFrame = root.CFrame
        BodyGyro.Parent = root
        
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.P = 30000
        BodyVelocity.Parent = root
    else
        if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
        if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
    end
end)

-- Controle de voo
RunService.Stepped:Connect(function()
    if Flying and BodyGyro and BodyVelocity then
        pcall(function()
            local camera = workspace.CurrentCamera
            BodyGyro.CFrame = camera.CFrame
            
            local direction = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            
            BodyVelocity.Velocity = direction * 50
        end)
    end
    
    -- Manter speed/jump
    if SpeedEnabled or JumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                if SpeedEnabled then hum.WalkSpeed = CurrentSpeed end
                if JumpEnabled then hum.JumpPower = CurrentJump end
            end
        end
    end
end)

CreateLabel(page4, "📍 TELEPORTES")

local teleports = {
    {"🏦 BANCO", CFrame.new(44, 4, -196)},
    {"🚔 DELEGACIA", CFrame.new(99, 4, -133)},
    {"🏪 MERCADO", CFrame.new(-72, 4, -166)},
    {"🏠 SPAWN", CFrame.new(13, 4, 15)}
}

for _, tp in ipairs(teleports) do
    CreateButton(page4, tp[1], function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = tp[2]
        end
    end)
end

CreateLabel(page4, "🏘️ CASAS (1-30)")

for i = 1, 30 do
    CreateButton(page4, "🏠 CASA " .. i, function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(80 + (i * 8), 4, 80 + (i * 8))
        end
    end)
end

-- Reconectar ao morrer
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(0.5)
    if SpeedEnabled then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = CurrentSpeed end
    end
    if JumpEnabled then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = CurrentJump end
    end
end)

print("=================================")
print(" BROOKHAVEN HUB CARREGADO!")
print(" Menu visível no centro da tela")
print(" 4 abas funcionais")
print(" Compatível com Delta Executor")
print("=================================")