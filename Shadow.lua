-- Universal Hub – Delta Executor Mobile (Estável + Copiar + UI fixa + Monitoramento + Teste com Argumentos)
-- Scanner progressivo, menu com botões fixos, monitoramento seguro e teste personalizado de eventos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui") or (Players.LocalPlayer and Players.LocalPlayer:WaitForChild("PlayerGui"))
local player = Players.LocalPlayer
if not player then return end

local remotes = {}               -- {Name, Object, Type}
local consoleOutput = {}
local scanning = false
local scanQueue = {}
local scanCoroutine = nil

local activeListeners = {}
local monitorEnabled = false

-- Interface
local gui = Instance.new("ScreenGui")
gui.Name = "UniversalHub"
gui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 460)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -230)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = gui

local titleBar = Instance.new("TextButton")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
titleBar.Text = "🔧 Universal Hub (arraste)"
titleBar.TextColor3 = Color3.new(1,1,1)
titleBar.Font = Enum.Font.SourceSansBold
titleBar.TextSize = 14
titleBar.Parent = mainFrame

-- Console
local consoleFrame = Instance.new("ScrollingFrame")
consoleFrame.Size = UDim2.new(1, -10, 0.32, -5)
consoleFrame.Position = UDim2.new(0,5,0,38)
consoleFrame.BackgroundColor3 = Color3.fromRGB(25,25,30)
consoleFrame.BorderSizePixel = 0
consoleFrame.ScrollBarThickness = 4
consoleFrame.CanvasSize = UDim2.new(0,0,0,0)
consoleFrame.Parent = mainFrame
local consoleLayout = Instance.new("UIListLayout")
consoleLayout.Parent = consoleFrame
consoleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
consoleLayout.SortOrder = Enum.SortOrder.LayoutOrder
consoleLayout.Padding = UDim.new(0,2)

-- Área de botões dos remotos (scrollável)
local remoteButtonFrame = Instance.new("ScrollingFrame")
remoteButtonFrame.Size = UDim2.new(1, -10, 0.42, -5)
remoteButtonFrame.Position = UDim2.new(0,5,0.38,5)
remoteButtonFrame.BackgroundColor3 = Color3.fromRGB(25,25,30)
remoteButtonFrame.BorderSizePixel = 0
remoteButtonFrame.ScrollBarThickness = 4
remoteButtonFrame.CanvasSize = UDim2.new(0,0,0,0)
remoteButtonFrame.Parent = mainFrame
local remoteButtonLayout = Instance.new("UIListLayout")
remoteButtonLayout.Parent = remoteButtonFrame
remoteButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
remoteButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
remoteButtonLayout.Padding = UDim.new(0,3)

-- Botões fixos inferiores
local fixedButtonFrame = Instance.new("Frame")
fixedButtonFrame.Size = UDim2.new(1, 0, 0, 80)
fixedButtonFrame.Position = UDim2.new(0, 0, 1, -90)
fixedButtonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
fixedButtonFrame.BorderSizePixel = 0
fixedButtonFrame.Parent = mainFrame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.8, 0, 0, 24)
copyBtn.Position = UDim2.new(0.1, 0, 0, 4)
copyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 160)
copyBtn.Text = "📋 Copiar Lista"
copyBtn.TextColor3 = Color3.new(1,1,1)
copyBtn.Font = Enum.Font.SourceSansBold
copyBtn.TextSize = 13
copyBtn.Parent = fixedButtonFrame

local monitorBtn = Instance.new("TextButton")
monitorBtn.Size = UDim2.new(0.8, 0, 0, 24)
monitorBtn.Position = UDim2.new(0.1, 0, 0, 30)
monitorBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
monitorBtn.Text = "👁 Monitoramento OFF"
monitorBtn.TextColor3 = Color3.new(1,1,1)
monitorBtn.Font = Enum.Font.SourceSansBold
monitorBtn.TextSize = 13
monitorBtn.Parent = fixedButtonFrame

local rescanBtn = Instance.new("TextButton")
rescanBtn.Size = UDim2.new(0.8, 0, 0, 24)
rescanBtn.Position = UDim2.new(0.1, 0, 0, 56)
rescanBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
rescanBtn.Text = "🔄 Re-escanear"
rescanBtn.TextColor3 = Color3.new(1,1,1)
rescanBtn.Font = Enum.Font.SourceSansBold
rescanBtn.TextSize = 13
rescanBtn.Parent = fixedButtonFrame

local copyBox = Instance.new("TextBox")
copyBox.Size = UDim2.new(1, -10, 0, 0)
copyBox.Position = UDim2.new(0,5,0,0)
copyBox.BackgroundColor3 = Color3.fromRGB(50,50,55)
copyBox.Text = ""
copyBox.TextColor3 = Color3.new(1,1,1)
copyBox.Font = Enum.Font.SourceSans
copyBox.TextSize = 11
copyBox.PlaceholderText = "Lista copiada aparecerá aqui..."
copyBox.ClearTextOnFocus = false
copyBox.Visible = false
copyBox.Parent = mainFrame

local function addConsole(text)
    consoleOutput[#consoleOutput+1] = text
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-6,0,18)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200,200,200)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = #consoleOutput
    label.Parent = consoleFrame
    consoleFrame.CanvasSize = UDim2.new(0,0,0,18 * #consoleOutput)
end

-- Arrasto
local dragActive, dragStart, startPos = false, nil, nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragActive = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragActive = false
            end
        end)
    end
end)
titleBar.InputChanged:Connect(function(input)
    if dragActive and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Scanner progressivo
local function processQueue()
    local processed = 0
    while #scanQueue > 0 do
        local container = table.remove(scanQueue, 1)
        local depth = container.depth or 0
        if depth <= 30 then
            for _, child in ipairs(container.parent:GetChildren()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    table.insert(remotes, {Name = child.Name, Object = child, Type = child.ClassName})
                    addConsole("✅ " .. child.Name .. " (" .. child.ClassName .. ")")
                end
                if child:IsA("Folder") or child:IsA("Model") or child:IsA("Configuration") then
                    table.insert(scanQueue, {parent = child, depth = depth + 1})
                end
            end
        end
        processed = processed + 1
        if processed >= 3 then
            task.wait(0.05)
            processed = 0
        end
    end
    scanning = false
    addConsole("🔎 Scanner concluído: " .. #remotes .. " remotos.")
    buildRemoteButtons()
end

local function startScan()
    if scanning then return end
    scanning = true
    remotes = {}
    for _, child in ipairs(consoleFrame:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    consoleOutput = {}
    for _, child in ipairs(remoteButtonFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    if monitorEnabled then
        toggleMonitor()
    end
    addConsole("🔍 Iniciando scanner...")
    scanQueue = {{parent = ReplicatedStorage, depth = 0}}
    scanCoroutine = coroutine.create(processQueue)
    coroutine.resume(scanCoroutine)
end

-- Construir botões com área de teste expansível
function buildRemoteButtons()
    for _, child in ipairs(remoteButtonFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for i, remote in ipairs(remotes) do
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -6, 0, 32) -- altura inicial
        container.BackgroundColor3 = Color3.fromRGB(65,65,75)
        container.BorderSizePixel = 0
        container.LayoutOrder = i
        container.Parent = remoteButtonFrame

        local mainBtn = Instance.new("TextButton")
        mainBtn.Size = UDim2.new(0.8, 0, 1, 0)
        mainBtn.BackgroundColor3 = Color3.fromRGB(65,65,75)
        mainBtn.Text = remote.Name .. " (" .. remote.Type .. ")"
        mainBtn.TextColor3 = Color3.new(1,1,1)
        mainBtn.Font = Enum.Font.SourceSans
        mainBtn.TextSize = 12
        mainBtn.Parent = container

        local configBtn = Instance.new("TextButton")
        configBtn.Size = UDim2.new(0.2, -2, 1, 0)
        configBtn.Position = UDim2.new(0.8, 2, 0, 0)
        configBtn.BackgroundColor3 = Color3.fromRGB(85, 85, 95)
        configBtn.Text = "⚙️"
        configBtn.TextColor3 = Color3.new(1,1,1)
        configBtn.Font = Enum.Font.SourceSansBold
        configBtn.TextSize = 16
        configBtn.Parent = container

        -- Área de argumentos (oculta)
        local argFrame = Instance.new("Frame")
        argFrame.Size = UDim2.new(1, 0, 0, 30)
        argFrame.Position = UDim2.new(0,0,1,2)
        argFrame.BackgroundColor3 = Color3.fromRGB(45,45,50)
        argFrame.BorderSizePixel = 0
        argFrame.Visible = false
        argFrame.Parent = container

        local argInput = Instance.new("TextBox")
        argInput.Size = UDim2.new(0.7, -4, 0, 24)
        argInput.Position = UDim2.new(0,2,0,3)
        argInput.BackgroundColor3 = Color3.fromRGB(60,60,70)
        argInput.Text = ""
        argInput.TextColor3 = Color3.new(1,1,1)
        argInput.Font = Enum.Font.SourceSans
        argInput.TextSize = 11
        argInput.PlaceholderText = "arg1, arg2, ..."
        argInput.Parent = argFrame

        local sendBtn = Instance.new("TextButton")
        sendBtn.Size = UDim2.new(0.3, -4, 0, 24)
        sendBtn.Position = UDim2.new(0.7, 2, 0, 3)
        sendBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
        sendBtn.Text = "Enviar"
        sendBtn.TextColor3 = Color3.new(1,1,1)
        sendBtn.Font = Enum.Font.SourceSansBold
        sendBtn.TextSize = 12
        sendBtn.Parent = argFrame

        -- Função para processar e enviar argumentos
        local function sendWithArgs()
            local raw = argInput.Text
            -- se vazio, ainda permite disparar sem argumentos
            local args = {}
            if raw ~= "" then
                -- separa por vírgula, ignorando espaços
                for part in string.gmatch(raw, "[^,]+") do
                    local trimmed = part:match("^%s*(.-)%s*$")
                    -- tenta converter para número
                    local num = tonumber(trimmed)
                    if num then
                        table.insert(args, num)
                    else
                        table.insert(args, trimmed)  -- mantém como string
                    end
                end
            end
            pcall(function()
                if remote.Type == "RemoteEvent" then
                    remote.Object:FireServer(unpack(args))
                    addConsole("📤 Disparou: " .. remote.Name .. "(" .. table.concat(args, ", ") .. ")")
                elseif remote.Type == "RemoteFunction" then
                    local res = remote.Object:InvokeServer(unpack(args))
                    addConsole("📥 Invocou: " .. remote.Name .. "(" .. table.concat(args, ", ") .. ") → " .. tostring(res))
                end
            end)
        end

        sendBtn.MouseButton1Click:Connect(sendWithArgs)
        argInput.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                sendWithArgs()
            end
        end)

        configBtn.MouseButton1Click:Connect(function()
            argFrame.Visible = not argFrame.Visible
            container.Size = UDim2.new(1, -6, 0, argFrame.Visible and 64 or 32)
        end)

        -- Clique no nome dispara sem argumentos
        mainBtn.MouseButton1Click:Connect(function()
            pcall(function()
                if remote.Type == "RemoteEvent" then
                    remote.Object:FireServer()
                    addConsole("📤 Disparou: " .. remote.Name .. " (sem argumentos)")
                elseif remote.Type == "RemoteFunction" then
                    local res = remote.Object:InvokeServer()
                    addConsole("📥 Invocou: " .. remote.Name .. " (sem argumentos) → " .. tostring(res))
                end
            end)
        end)
    end
    remoteButtonFrame.CanvasSize = UDim2.new(0,0,0,30 * #remotes + 5)
end

-- Monitoramento seguro
local function toggleMonitor()
    monitorEnabled = not monitorEnabled
    if monitorEnabled then
        for _, remote in ipairs(remotes) do
            if remote.Type == "RemoteEvent" then
                local conn = remote.Object.OnClientEvent:Connect(function(...)
                    local args = {...}
                    local strArgs = ""
                    for i, v in ipairs(args) do strArgs = strArgs .. tostring(v) .. ", " end
                    strArgs = strArgs:sub(1, -3)
                    addConsole("👁 " .. remote.Name .. " recebido(" .. strArgs .. ")")
                end)
                table.insert(activeListeners, conn)
            end
        end
        monitorBtn.Text = "👁 Monitoramento ON"
        monitorBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
        addConsole("👁 Monitoramento ativado.")
    else
        for _, conn in ipairs(activeListeners) do
            pcall(function() conn:Disconnect() end)
        end
        activeListeners = {}
        monitorBtn.Text = "👁 Monitoramento OFF"
        monitorBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        addConsole("👁 Monitoramento desativado.")
    end
end

copyBtn.MouseButton1Click:Connect(function()
    if #remotes == 0 then
        addConsole("⚠️ Nenhum remoto para copiar.")
        return
    end
    local names = {}
    for _, r in ipairs(remotes) do
        table.insert(names, r.Name)
    end
    local text = table.concat(names, "\n")
    local success = pcall(function()
        if setclipboard then setclipboard(text) end
    end)
    if success then
        addConsole("📋 Lista copiada.")
        copyBox.Visible = false
    else
        copyBox.Text = text
        copyBox.Size = UDim2.new(1, -10, 0, 60)
        copyBox.Position = UDim2.new(0,5,0.8,-30)
        copyBox.Visible = true
        addConsole("📋 Lista exibida. Copie manualmente.")
        task.wait(5)
        copyBox.Visible = false
        copyBox.Size = UDim2.new(1, -10, 0, 0)
    end
end)

monitorBtn.MouseButton1Click:Connect(function()
    pcall(toggleMonitor)
end)

rescanBtn.MouseButton1Click:Connect(function()
    startScan()
end)

task.wait(0.5)
startScan()
addConsole("🚀 Universal Hub pronto. Clique em ⚙️ para testar com argumentos.")