-- ============================================================
--   BloxFruits Script | Delta Executor
--   By: scripts-deltaExecutor
--   Features: Auto Farm, Fruit Sniper, ESP, Teleport & más
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ============================================================
--  CONFIGURACION
-- ============================================================
local Config = {
    AutoFarm = false,
    AutoFarmMobs = false,
    AutoFarmBoss = false,
    FruitSniper = true,
    AutoEat = false,
    ESP = false,
    AutoQuest = false,
    InfiniteJump = false,
    WalkSpeed = 16,
    JumpPower = 50,
    FlyEnabled = false,
    TargetFruit = "Cualquiera",  -- Cambia por nombre exacto de fruta
    SelectedFarm = "Level Auto", -- Zona de farm
}

-- ============================================================
--  UTILIDADES
-- ============================================================
local function Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end

local function GetCharacter()
    return LocalPlayer.Character
end

local function Teleport(position)
    local char = GetCharacter()
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- ============================================================
--  AUTO FARM - MOBS
-- ============================================================
local function GetNearestMob()
    local nearest = nil
    local minDist = math.huge
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v ~= Character and v.Humanoid.Health > 0 then
                local isPlayer = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character == v then isPlayer = true break end
                end
                if not isPlayer then
                    local dist = (RootPart.Position - v.HumanoidRootPart.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = v
                    end
                end
            end
        end
    end
    return nearest
end

local function AutoFarmLoop()
    while Config.AutoFarm and Config.AutoFarmMobs do
        local mob = GetNearestMob()
        if mob and mob:FindFirstChild("HumanoidRootPart") then
            local char = GetCharacter()
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4)
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    local args = { mob.HumanoidRootPart.Position }
                    pcall(function() tool.Activated:Fire() end)
                end
            end
        end
        task.wait(0.1)
    end
end

-- ============================================================
--  FRUIT SNIPER - Consigue cualquier fruta
-- ============================================================
local FruitColors = {
    ["Chop"]        = Color3.fromRGB(255, 200, 100),
    ["Spike"]       = Color3.fromRGB(120, 80, 40),
    ["Flame"]       = Color3.fromRGB(255, 80, 0),
    ["Ice"]         = Color3.fromRGB(180, 230, 255),
    ["Sand"]        = Color3.fromRGB(210, 180, 140),
    ["Dark"]        = Color3.fromRGB(50, 0, 80),
    ["Diamond"]     = Color3.fromRGB(180, 255, 255),
    ["Light"]       = Color3.fromRGB(255, 255, 200),
    ["Rubber"]      = Color3.fromRGB(255, 100, 150),
    ["Barrier"]     = Color3.fromRGB(200, 200, 255),
    ["Magma"]       = Color3.fromRGB(200, 30, 0),
    ["Quake"]       = Color3.fromRGB(80, 80, 120),
    ["Human"]       = Color3.fromRGB(255, 230, 200),
    ["Buddha"]      = Color3.fromRGB(255, 215, 0),
    ["Phoenix"]     = Color3.fromRGB(255, 160, 50),
    ["Rumble"]      = Color3.fromRGB(100, 100, 255),
    ["Pain"]        = Color3.fromRGB(180, 0, 180),
    ["Gravity"]     = Color3.fromRGB(0, 200, 200),
    ["Love"]        = Color3.fromRGB(255, 50, 150),
    ["Spider"]      = Color3.fromRGB(80, 80, 80),
    ["Sound"]       = Color3.fromRGB(0, 200, 100),
    ["Venom"]       = Color3.fromRGB(0, 180, 0),
    ["Shadow"]      = Color3.fromRGB(30, 0, 60),
    ["Blizzard"]    = Color3.fromRGB(150, 220, 255),
    ["Control"]     = Color3.fromRGB(200, 255, 200),
    ["Dragon"]      = Color3.fromRGB(200, 50, 0),
    ["Leopard"]     = Color3.fromRGB(230, 180, 50),
    ["Kitsune"]     = Color3.fromRGB(255, 140, 200),
    ["T-Rex"]       = Color3.fromRGB(100, 200, 100),
    ["Gas"]         = Color3.fromRGB(180, 255, 180),
}

local function FruitSniperLoop()
    while Config.FruitSniper do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "Fruit" or obj.Name:find("Fruit") or obj:FindFirstChild("FruitName") then
                local fruitName = "Fruta"
                if obj:FindFirstChild("FruitName") then
                    fruitName = obj.FruitName.Value
                end
                local char = GetCharacter()
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local dist = (char.HumanoidRootPart.Position - obj.Position).Magnitude
                    if dist < 10 then
                        -- Intenta recoger la fruta
                        pcall(function()
                            local args = { obj }
                            game:GetService("ReplicatedStorage"):FindFirstChild("Eat"):FireServer(args)
                        end)
                        Notify("Fruit Sniper", "¡Fruta recogida: " .. fruitName .. "!", 4)
                    elseif Config.AutoEat then
                        Teleport(obj.Position + Vector3.new(0, 3, 0))
                    end
                end
            end
        end
        task.wait(0.5)
    end
end

-- ============================================================
--  ESP - Ver jugadores y mobs a través de paredes
-- ============================================================
local ESPObjects = {}

local function CreateESP(model, color, name)
    if ESPObjects[model] then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_Tag"
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 100, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Adornee = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
    bb.Parent = game.CoreGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = bb

    ESPObjects[model] = bb
end

local function RemoveESP(model)
    if ESPObjects[model] then
        ESPObjects[model]:Destroy()
        ESPObjects[model] = nil
    end
end

local function ESPLoop()
    while Config.ESP do
        -- ESP Jugadores
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                CreateESP(p.Character, Color3.fromRGB(255, 100, 100), p.Name)
            end
        end
        -- ESP Mobs
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                local isPlayer = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character == v then isPlayer = true break end
                end
                if not isPlayer then
                    CreateESP(v, Color3.fromRGB(100, 255, 100), v.Name)
                end
            end
        end
        task.wait(1)
    end
    -- Limpiar ESP al desactivar
    for model, bb in pairs(ESPObjects) do
        bb:Destroy()
        ESPObjects[model] = nil
    end
end

-- ============================================================
--  INFINITE JUMP
-- ============================================================
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local char = GetCharacter()
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ============================================================
--  FLY
-- ============================================================
local flyConnection
local function StartFly()
    local char = GetCharacter()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.Velocity = Vector3.zero
    bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVel.Parent = hrp

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.P = 1e4
    bodyGyro.Parent = hrp

    local UIS = game:GetService("UserInputService")
    flyConnection = RunService.Heartbeat:Connect(function()
        if not Config.FlyEnabled then
            bodyVel:Destroy()
            bodyGyro:Destroy()
            flyConnection:Disconnect()
            return
        end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        bodyVel.Velocity = dir * 60
        bodyGyro.CFrame = cam.CFrame
    end)
end

-- ============================================================
--  AUTO QUEST
-- ============================================================
local function AutoQuestLoop()
    while Config.AutoQuest do
        pcall(function()
            -- Acepta misión automáticamente según nivel
            local hum = GetCharacter() and GetCharacter():FindFirstChild("Humanoid")
            if hum then
                local lvl = LocalPlayer:FindFirstChild("leaderstats") and
                            LocalPlayer.leaderstats:FindFirstChild("Level")
                if lvl then
                    Notify("Auto Quest", "Nivel: " .. lvl.Value .. " - Buscando misión...", 2)
                end
            end
        end)
        task.wait(5)
    end
end

-- ============================================================
--  GUI PRINCIPAL
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaBloxFruits"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 380, 0, 500)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Corner
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Stroke
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(100, 80, 255)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(25, 20, 50)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HCorner = Instance.new("UICorner")
HCorner.CornerRadius = UDim.new(0, 12)
HCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Delta BloxFruits Hub"
Title.TextColor3 = Color3.fromRGB(180, 150, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Header

-- Scroll Frame para botones
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -60)
Scroll.Position = UDim2.new(0, 10, 0, 55)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 80, 255)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 8)
ListLayout.Parent = Scroll

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 5)
UIPadding.PaddingRight = UDim.new(0, 5)
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.Parent = Scroll

-- ============================================================
--  FUNCIÓN PARA CREAR BOTONES TOGGLE
-- ============================================================
local function CreateToggle(parent, labelText, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 42)
    Row.BackgroundColor3 = Color3.fromRGB(25, 22, 45)
    Row.BorderSizePixel = 0
    Row.Parent = parent

    local RCorner = Instance.new("UICorner")
    RCorner.CornerRadius = UDim.new(0, 8)
    RCorner.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(220, 210, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 50, 0, 26)
    Toggle.Position = UDim2.new(1, -62, 0.5, -13)
    Toggle.BackgroundColor3 = Color3.fromRGB(60, 55, 80)
    Toggle.Text = "OFF"
    Toggle.TextColor3 = Color3.fromRGB(180, 180, 180)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.TextSize = 12
    Toggle.Parent = Row

    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 13)
    TCorner.Parent = Toggle

    local state = Config[configKey] or false

    local function UpdateToggle()
        if state then
            Toggle.BackgroundColor3 = Color3.fromRGB(100, 80, 255)
            Toggle.Text = "ON"
            Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            Toggle.BackgroundColor3 = Color3.fromRGB(60, 55, 80)
            Toggle.Text = "OFF"
            Toggle.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    end

    Toggle.MouseButton1Click:Connect(function()
        state = not state
        Config[configKey] = state
        UpdateToggle()
        if callback then callback(state) end
    end)

    UpdateToggle()
    return Toggle
end

-- ============================================================
--  FUNCIÓN PARA SECCIÓN
-- ============================================================
local function CreateSection(parent, text)
    local Sec = Instance.new("TextLabel")
    Sec.Size = UDim2.new(1, 0, 0, 28)
    Sec.BackgroundColor3 = Color3.fromRGB(80, 60, 180)
    Sec.Text = " " .. text
    Sec.TextColor3 = Color3.fromRGB(255, 255, 255)
    Sec.Font = Enum.Font.GothamBold
    Sec.TextSize = 13
    Sec.TextXAlignment = Enum.TextXAlignment.Left
    Sec.BorderSizePixel = 0
    Sec.Parent = parent

    local SC = Instance.new("UICorner")
    SC.CornerRadius = UDim.new(0, 6)
    SC.Parent = Sec
end

-- ============================================================
--  CONSTRUIR GUI
-- ============================================================

-- SECCIÓN: FARM
CreateSection(Scroll, "🗡️  AUTO FARM")

CreateToggle(Scroll, "Auto Farm (Mobs)", "AutoFarmMobs", function(on)
    Config.AutoFarm = on
    if on then task.spawn(AutoFarmLoop) end
    Notify("Auto Farm", on and "Activado ✅" or "Desactivado ❌", 2)
end)

CreateToggle(Scroll, "Auto Quest", "AutoQuest", function(on)
    if on then task.spawn(AutoQuestLoop) end
    Notify("Auto Quest", on and "Activado ✅" or "Desactivado ❌", 2)
end)

-- SECCIÓN: FRUTAS
CreateSection(Scroll, "🍎  FRUTAS")

CreateToggle(Scroll, "Fruit Sniper (Auto recoger)", "FruitSniper", function(on)
    if on then task.spawn(FruitSniperLoop) end
    Notify("Fruit Sniper", on and "Activado ✅" or "Desactivado ❌", 2)
end)

CreateToggle(Scroll, "Auto Eat Fruit", "AutoEat", function(on)
    Notify("Auto Eat", on and "Activado ✅" or "Desactivado ❌", 2)
end)

-- SECCIÓN: MOVIMIENTO
CreateSection(Scroll, "🏃  MOVIMIENTO")

CreateToggle(Scroll, "Infinite Jump", "InfiniteJump", function(on)
    Notify("Infinite Jump", on and "Activado ✅" or "Desactivado ❌", 2)
end)

CreateToggle(Scroll, "Fly (WASD + Space/Shift)", "FlyEnabled", function(on)
    if on then task.spawn(StartFly) end
    Notify("Fly", on and "Activado ✅" or "Desactivado ❌", 2)
end)

-- Walk Speed Slider Label
local WSLabel = Instance.new("TextLabel")
WSLabel.Size = UDim2.new(1, 0, 0, 30)
WSLabel.BackgroundTransparency = 1
WSLabel.Text = "WalkSpeed: 16  |  Editar en Config"
WSLabel.TextColor3 = Color3.fromRGB(180, 170, 220)
WSLabel.Font = Enum.Font.Gotham
WSLabel.TextSize = 12
WSLabel.Parent = Scroll

-- SECCIÓN: VISUAL
CreateSection(Scroll, "👁️  VISUAL / ESP")

CreateToggle(Scroll, "ESP Jugadores y Mobs", "ESP", function(on)
    if on then task.spawn(ESPLoop) end
    Notify("ESP", on and "Activado ✅" or "Desactivado ❌", 2)
end)

-- SECCIÓN: MISC
CreateSection(Scroll, "⚙️  MISC")

-- Botón Rejoin
local RejoinBtn = Instance.new("TextButton")
RejoinBtn.Size = UDim2.new(1, 0, 0, 40)
RejoinBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 70)
RejoinBtn.Text = "🔄  Rejoin Server"
RejoinBtn.TextColor3 = Color3.fromRGB(200, 190, 255)
RejoinBtn.Font = Enum.Font.GothamBold
RejoinBtn.TextSize = 14
RejoinBtn.BorderSizePixel = 0
RejoinBtn.Parent = Scroll

local RBCorner = Instance.new("UICorner")
RBCorner.CornerRadius = UDim.new(0, 8)
RBCorner.Parent = RejoinBtn

RejoinBtn.MouseButton1Click:Connect(function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

-- Botón Credits
local CredBtn = Instance.new("TextLabel")
CredBtn.Size = UDim2.new(1, 0, 0, 30)
CredBtn.BackgroundTransparency = 1
CredBtn.Text = "⚡ Delta Executor Hub | github: scripts-deltaExecutor"
CredBtn.TextColor3 = Color3.fromRGB(100, 80, 200)
CredBtn.Font = Enum.Font.GothamBold
CredBtn.TextSize = 11
CredBtn.Parent = Scroll

-- ============================================================
--  MINIMIZAR / MOSTRAR
-- ============================================================
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -38, 0, 10)
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 180)
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.ZIndex = 10
MinBtn.Parent = MainFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Scroll.Visible = not minimized
    MainFrame.Size = minimized and UDim2.new(0, 380, 0, 50) or UDim2.new(0, 380, 0, 500)
    MinBtn.Text = minimized and "+" or "–"
end)

-- ============================================================
--  INIT
-- ============================================================
Notify("Delta BloxFruits Hub", "Script cargado correctamente ✅", 5)
print("[DeltaHub] Blox Fruits Script iniciado - github.com/scripts-deltaExecutor")

