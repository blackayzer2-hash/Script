--[[
    BROOKHAVEN RP - SCRIPT COMPLETO COM GUI DE ABAS
    Compatível com Delta Executor Mobile
    Versão: 1.0
]]

-- Variáveis principais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Variáveis de controle
local Flying = false
local SpeedEnabled = false
local JumpEnabled = false
local CurrentSpeed = 16
local CurrentJump = 50

-- RemoteEvents do Brookhaven
local Remotes = {}
local function GetRemotes()
    pcall(function()
        local eventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents") or 
                            ReplicatedStorage:FindFirstChild("Remotes") or
                            ReplicatedStorage:FindFirstChild("Events")
        if eventsFolder then
            for _, v in pairs(eventsFolder:GetChildren()) do
                if v:IsA("RemoteEvent") then
                    Remotes[v.Name] = v
                end
            end
        end
    end)
end
GetRemotes()

-- Função para disparar RemoteEvents com segurança
local function FireRemote(name, ...)
    local success, err = pcall(function()
        local remote = Remotes[name]
        if remote then
            remote:FireServer(...)
        end
    end)
    if not success then
        warn("Erro ao disparar RemoteEvent: " .. tostring(err))
    end
end

-- Criar GUI Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrookhavenHub"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Container Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Título
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 8)
UICorner2.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Text = "BROOKHAVEN HUB"
TitleText.Size = UDim2.new(1, -100, 1, 0)
TitleText.Position = UDim2.new(0, 20, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TitleBar

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 8)
UICorner3.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Sistema de Abas
local TabFrame = Instance.new("Frame")
TabFrame.Name = "TabFrame"
TabFrame.Size = UDim2.new(0, 120, 1, -40)
TabFrame.Position = UDim2.new(0, 0, 0, 40)
TabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -120, 1, -40)
ContentFrame.Position = UDim2.new(0, 120, 0, 40)
ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

-- Função para criar botões de aba
local function CreateTabButton(name, position)
    local Button = Instance.new("TextButton")
    Button.Text = name
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.Position = UDim2.new(0, 5, 0, position)
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 13
    Button.BorderSizePixel = 0
    Button.Parent = TabFrame

    local UICorner4 = Instance.new("UICorner")
    UICorner4.CornerRadius = UDim.new(0, 5)
    UICorner4.Parent = Button

    return Button
end

-- Função para criar páginas de conteúdo
local function CreateContentPage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name
    Page.Size = UDim2.new(1, -10, 1, -10)
    Page.Position = UDim2.new(0, 5, 0, 5)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 5
    Page.Visible = false
    Page.Parent = ContentFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = Page

    return Page
end

-- Criar abas
local tabs = {
    {name = "Equipes", pos = 10},
    {name = "Skins", pos = 50},
    {name = "Mapa", pos = 90},
    {name = "Client", pos = 130}
}

local pages = {}
for _, tab in ipairs(tabs) do
    local btn = CreateTabButton(tab.name, tab.pos)
    local page = CreateContentPage(tab.name)
    pages[tab.name] = page

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do
            p.Visible = false
        end
        page.Visible = true
        for _, child in pairs(TabFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    end)
end

-- Ativar primeira aba
pages["Equipes"].Visible = true

-- =================== ABA 1: EQUIPES DE FAMOSOS ===================
local function CreateSection(parent, title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, -10, 0, 40)
    Section.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Section.BorderSizePixel = 0
    Section.Parent = parent

    local Text = Instance.new("TextLabel")
    Text.Text = title
    Text.Size = UDim2.new(1, -10, 1, 0)
    Text.Position = UDim2.new(0, 10, 0, 0)
    Text.BackgroundTransparency = 1
    Text.TextColor3 = Color3.fromRGB(255, 255, 255)
    Text.Font = Enum.Font.GothamBold
    Text.TextSize = 14
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = Section

    return Section
end

local function CreateButton(parent, text, position, callback)
    local Button = Instance.new("TextButton")
    Button.Text = text
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.Position = position
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 200)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 13
    Button.BorderSizePixel = 0
    Button.Parent = parent

    local UICorner5 = Instance.new("UICorner")
    UICorner5.CornerRadius = UDim.new(0, 5)
    UICorner5.Parent = Button

    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- ABA 1 conteúdo
local tagsPage = pages["Equipes"]

CreateSection(tagsPage, "TAGS DE FAMOSOS"):Size = UDim2.new(1, 0, 0, 30)

local tags = {
    "Dono do Servidor",
    "Youtuber Famoso",
    "Staff",
    "Administrador"
}

for i, tag in ipairs(tags) do
    CreateButton(tagsPage, tag, UDim2.new(0, 5, 0, (i-1)*40 + 40), function()
        pcall(function()
            -- Usar chat para simular tag
            local chatRemote = Remotes["ChatMessage"] or Remotes["SendMessage"] or Remotes["Message"]
            if chatRemote then
                chatRemote:FireServer("[TAG] " .. LocalPlayer.Name .. " é agora " .. tag)
            end
        end)
    end)
end

-- Caixa de texto para tag personalizada
local CustomTagLabel = Instance.new("TextLabel")
CustomTagLabel.Text = "Tag Personalizada:"
CustomTagLabel.Size = UDim2.new(1, -10, 0, 20)
CustomTagLabel.Position = UDim2.new(0, 5, 0, 210)
CustomTagLabel.BackgroundTransparency = 1
CustomTagLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CustomTagLabel.Font = Enum.Font.GothamSemibold
CustomTagLabel.TextSize = 12
CustomTagLabel.TextXAlignment = Enum.TextXAlignment.Left
CustomTagLabel.Parent = tagsPage

local CustomTagBox = Instance.new("TextBox")
CustomTagBox.PlaceholderText = "Digite sua tag..."
CustomTagBox.Size = UDim2.new(1, -10, 0, 30)
CustomTagBox.Position = UDim2.new(0, 5, 0, 235)
CustomTagBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CustomTagBox.TextColor3 = Color3.fromRGB(255, 255, 255)
CustomTagBox.Font = Enum.Font.Gotham
CustomTagBox.TextSize = 14
CustomTagBox.BorderSizePixel = 0
CustomTagBox.Parent = tagsPage

CreateButton(tagsPage, "Aplicar Tag", UDim2.new(0, 5, 0, 270), function()
    pcall(function()
        local chatRemote = Remotes["ChatMessage"] or Remotes["SendMessage"]
        if chatRemote and CustomTagBox.Text ~= "" then
            chatRemote:FireServer("[TAG] " .. LocalPlayer.Name .. " é agora " .. CustomTagBox.Text)
        end
    end)
end)

-- =================== ABA 2: ALTERAÇÃO DE SKIN ===================
local skinsPage = pages["Skins"]

CreateSection(skinsPage, "MUDAR ROUPA"):Size = UDim2.new(1, 0, 0, 30)

local skinFields = {
    {name = "Camisa", default = "ID da Camisa"},
    {name = "Calça", default = "ID da Calça"},
    {name = "Cabelo", default = "ID do Cabelo"},
    {name = "Acessório", default = "ID do Acessório"}
}

local skinTextBoxes = {}

for i, field in ipairs(skinFields) do
    local Label = Instance.new("TextLabel")
    Label.Text = field.name .. ":"
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 5, 0, (i-1)*55 + 40)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = skinsPage

    local TextBox = Instance.new("TextBox")
    TextBox.PlaceholderText = field.default
    TextBox.Size = UDim2.new(1, -10, 0, 30)
    TextBox.Position = UDim2.new(0, 5, 0, (i-1)*55 + 60)
    TextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 14
    TextBox.BorderSizePixel = 0
    TextBox.Parent = skinsPage
    skinTextBoxes[field.name] = TextBox
end

CreateButton(skinsPage, "Aplicar Skin", UDim2.new(0, 5, 0, 270), function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        -- Aplicar camisa
        local shirtId = skinTextBoxes["Camisa"].Text
        if shirtId ~= "" and tonumber(shirtId) then
            local shirt = char:FindFirstChild("Shirt") or Instance.new("Shirt")
            shirt.ShirtTemplate = "rbxassetid://" .. shirtId
            shirt.Parent = char
        end

        -- Aplicar calça
        local pantsId = skinTextBoxes["Calça"].Text
        if pantsId ~= "" and tonumber(pantsId) then
            local pants = char:FindFirstChild("Pants") or Instance.new("Pants")
            pants.PantsTemplate = "rbxassetid://" .. pantsId
            pants.Parent = char
        end

        -- Aplicar cabelo via HumanoidDescription
        local hairId = skinTextBoxes["Cabelo"].Text
        if hairId ~= "" and tonumber(hairId) then
            FireRemote("UpdateAvatar", {HairAccessory = hairId})
        end

        -- Aplicar acessório
        local accessoryId = skinTextBoxes["Acessório"].Text
        if accessoryId ~= "" and tonumber(accessoryId) then
            FireRemote("WearAccessory", accessoryId)
        end
    end)
end)

-- Botões especiais
CreateButton(skinsPage, "Ficar Invisível", UDim2.new(0, 5, 0, 310), function()
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0.9
                end
            end
        end
    end)
end)

CreateButton(skinsPage, "Ficar Visível", UDim2.new(0, 5, 0, 350), function()
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
        end
    end)
end)

CreateButton(skinsPage, "Virar Gigante (R15)", UDim2.new(0, 5, 0, 390), function()
    pcall(function()
        local char = LocalPlayer.Character
        if char and Humanoid.RigType == Enum.HumanoidRigType.R15 then
            local scale = char:FindFirstChild("Scale") or Instance.new("NumberValue")
            scale.Name = "Scale"
            scale.Value = 3
            scale.Parent = char
        end
    end)
end)

CreateButton(skinsPage, "Virar Mini (R15)", UDim2.new(0, 5, 0, 430), function()
    pcall(function()
        local char = LocalPlayer.Character
        if char and Humanoid.RigType == Enum.HumanoidRigType.R15 then
            local scale = char:FindFirstChild("Scale") or Instance.new("NumberValue")
            scale.Name = "Scale"
            scale.Value = 0.3
            scale.Parent = char
        end
    end)
end)

-- =================== ABA 3: MANIPULAÇÃO DO MAPA ===================
local mapPage = pages["Mapa"]

CreateSection(mapPage, "EVENTOS DO MAPA"):Size = UDim2.new(1, 0, 0, 30)

local mapButtons = {
    {name = "Ativar Alarme da Casa", func = function()
        FireRemote("TriggerAlarm", LocalPlayer)
        FireRemote("HouseAlarm", true)
        FireRemote("AlarmEvent", "FireAlarm")
    end},
    {name = "Causar Incêndio", func = function()
        FireRemote("StartFire", LocalPlayer.Character)
        FireRemote("FireEvent", "HouseFire")
        FireRemote("DisasterEvent", "Fire")
    end},
    {name = "Causar Inundação", func = function()
        FireRemote("StartFlood", LocalPlayer.Character)
        FireRemote("FloodEvent", "HouseFlood")
        FireRemote("DisasterEvent", "Flood")
    end},
    {name = "Destrancar Todas Portas", func = function()
        for i = 1, 30 do
            FireRemote("UnlockDoor", i)
            FireRemote("DoorEvent", "Unlock", i)
        end
    end},
    {name = "Ativar Tornado", func = function()
        FireRemote("DisasterEvent", "Tornado")
        FireRemote("WeatherEvent", "Tornado")
    end}
}

for i, btn in ipairs(mapButtons) do
    CreateButton(mapPage, btn.name, UDim2.new(0, 5, 0, (i-1)*40 + 40), btn.func)
end

CreateSection(mapPage, "SPAWN DE ITENS"):Size = UDim2.new(1, 0, 0, 30)
CreateSection(mapPage, "SPAWN DE ITENS").Position = UDim2.new(0, 0, 0, 250)

local itemNames = {"CarroEsportivo", "Helicoptero", "Barco", "Moto", "Bicicleta", "Skate"}
for i, item in ipairs(itemNames) do
    CreateButton(mapPage, "Spawnar " .. item, UDim2.new(0, 5, 0, (i-1)*40 + 290), function()
        pcall(function()
            FireRemote("SpawnVehicle", item)
            FireRemote("SpawnItem", item)
            FireRemote("InventoryEvent", "Spawn", item)
        end)
    end)
end

-- =================== ABA 4: CLIENT / EXPLOIT ===================
local clientPage = pages["Client"]

CreateSection(clientPage, "MOVIMENTAÇÃO"):Size = UDim2.new(1, 0, 0, 30)

-- Speed Slider
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Text = "Velocidade: 16"
SpeedLabel.Size = UDim2.new(1, -10, 0, 20)
SpeedLabel.Position = UDim2.new(0, 5, 0, 40)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 12
SpeedLabel.Parent = clientPage

local SpeedSlider = Instance.new("TextBox")
SpeedSlider.Text = "16"
SpeedSlider.Size = UDim2.new(1, -10, 0, 30)
SpeedSlider.Position = UDim2.new(0, 5, 0, 60)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedSlider.Font = Enum.Font.Gotham
SpeedSlider.TextSize = 14
SpeedSlider.Parent = clientPage

-- Jump Power
local JumpLabel = Instance.new("TextLabel")
JumpLabel.Text = "Pulo: 50"
JumpLabel.Size = UDim2.new(1, -10, 0, 20)
JumpLabel.Position = UDim2.new(0, 5, 0, 100)
JumpLabel.BackgroundTransparency = 1
JumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpLabel.Font = Enum.Font.Gotham
JumpLabel.TextSize = 12
JumpLabel.Parent = clientPage

local JumpSlider = Instance.new("TextBox")
JumpSlider.Text = "50"
JumpSlider.Size = UDim2.new(1, -10, 0, 30)
JumpSlider.Position = UDim2.new(0, 5, 0, 120)
JumpSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
JumpSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpSlider.Font = Enum.Font.Gotham
JumpSlider.TextSize = 14
JumpSlider.Parent = clientPage

CreateButton(clientPage, "Aplicar Speed/Jump", UDim2.new(0, 5, 0, 160), function()
    pcall(function()
        local speed = tonumber(SpeedSlider.Text) or 16
        local jump = tonumber(JumpSlider.Text) or 50
        CurrentSpeed = speed
        CurrentJump = jump
        SpeedEnabled = true
        JumpEnabled = true
        SpeedLabel.Text = "Velocidade: " .. speed
        JumpLabel.Text = "Pulo: " .. jump
    end)
end)

CreateButton(clientPage, "Resetar Speed/Jump", UDim2.new(0, 5, 0, 200), function()
    SpeedEnabled = false
    JumpEnabled = false
    pcall(function()
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
    end)
    SpeedLabel.Text = "Velocidade: 16"
    JumpLabel.Text = "Pulo: 50"
end)

-- Botão Fly
CreateButton(clientPage, "FLY (Voo)", UDim2.new(0, 5, 0, 240), function()
    Flying = not Flying
    
    if Flying then
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        bodyGyro.P = 30000
        bodyGyro.Parent = RootPart

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.P = 30000
        bodyVelocity.Parent = RootPart

        game:GetService("RunService").Stepped:Connect(function()
            if Flying then
                bodyGyro.CFrame = workspace.CurrentCamera.CFrame
                
                local moveDirection = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                bodyVelocity.Velocity = moveDirection * 50
            end
        end)
    else
        if RootPart:FindFirstChild("BodyGyro") then
            RootPart.BodyGyro:Destroy()
        end
        if RootPart:FindFirstChild("BodyVelocity") then
            RootPart.BodyVelocity:Destroy()
        end
    end
end)

-- Teleportes
CreateSection(clientPage, "TELEPORTES"):Size = UDim2.new(1, 0, 0, 30)
CreateSection(clientPage, "TELEPORTES").Position = UDim2.new(0, 0, 0, 285)

local teleportLocations = {
    {name = "Banco", position = Vector3.new(44, 4, -196)},
    {name = "Delegacia", position = Vector3.new(99, 4, -133)},
    {name = "Mercado", position = Vector3.new(-72, 4, -166)},
    {name = "Spawn Principal", position = Vector3.new(13, 4, 15)},
}

for i, loc in ipairs(teleportLocations) do
    CreateButton(clientPage, loc.name, UDim2.new(0, 5, 0, (i-1)*40 + 325), function()
        pcall(function()
            if RootPart then
                RootPart.CFrame = CFrame.new(loc.position)
            end
        end)
    end)
end

-- Casas 1-30
for i = 1, 30 do
    local housePos = Vector3.new(100 + (i * 10), 4, 100 + (i * 10))
    CreateButton(clientPage, "Casa " .. i, UDim2.new(0, 5, 0, (i-1)*40 + 325 + (4*40)), function()
        pcall(function()
            if RootPart then
                RootPart.CFrame = CFrame.new(housePos)
            end
        end)
    end)
end

-- Loop para manter Speed e Jump
RunService.Stepped:Connect(function()
    if SpeedEnabled and Humanoid then
        Humanoid.WalkSpeed = CurrentSpeed
    end
    if JumpEnabled and Humanoid then
        Humanoid.JumpPower = CurrentJump
    end
end)

-- Reconectar Character
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    
    if SpeedEnabled then
        Humanoid.WalkSpeed = CurrentSpeed
    end
    if JumpEnabled then
        Humanoid.JumpPower = CurrentJump
    end
end)

print("Brookhaven Hub carregado com sucesso!")