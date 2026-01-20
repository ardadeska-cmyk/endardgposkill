--[[
    EndardHub - Jujutsu Zero V2 (ULTRA SPEED & AUTO-TP TO BOSS)
    Auto Execute: https://raw.githubusercontent.com/ardadeska-cmyk/endardgposkill/refs/heads/main/jubo.lua
]]

if not game:IsLoaded() then game.Loaded:Wait() end
if _G.EndardHubLoaded then return end
_G.EndardHubLoaded = true

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- --- AUTO EXECUTE (TELEPORT) ---
local function SetAutoExec()
    local queue_on_teleport = (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or queue_on_teleport
    if queue_on_teleport then
        LocalPlayer.OnTeleport:Connect(function(State)
            if _G.Config and _G.Config.AutoExecute then
                queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/ardadeska-cmyk/endardgposkill/refs/heads/main/jubo.lua"))()]])
            end
        end)
    end
end
SetAutoExec()

-- --- KARAKTER BULMA ---
local function GetMyCharacter()
    local path = workspace:FindFirstChild("Characters")
    if path and path:FindFirstChild("Server") and path.Server:FindFirstChild("Players") then
        for _, model in pairs(path.Server.Players:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
                return model
            end
        end
    end
    return LocalPlayer.Character
end

-- --- AYARLAR ---
_G.Config = {
    Aura = true,
    Retry = true,
    AutoExecute = true,
    BringMob = true -- Bu artık "TP to Mob" olarak çalışacak
}
local Config = _G.Config

local Colors = {
    Main = Color3.fromRGB(18, 18, 18),
    Accent = Color3.fromRGB(120, 80, 255),
    Enabled = Color3.fromRGB(0, 200, 100),
    Disabled = Color3.fromRGB(200, 50, 50),
    Text = Color3.fromRGB(255, 255, 255),
    Dark = Color3.fromRGB(30, 30, 30)
}

local function CreateMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EndardHub_V2_SmartStart"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 335)
    mainFrame.Position = UDim2.new(0.5, -150, 0.4, -140)
    mainFrame.BackgroundColor3 = Colors.Main
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Colors.Dark
    title.Text = " EndardHub - Jujutsu Zero V2"
    title.TextColor3 = Colors.Accent
    title.TextSize = 18
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Colors.Text
    closeBtn.BackgroundColor3 = Colors.Disabled
    closeBtn.Parent = title
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

    local function createCheckbox(labelText, pos, configKey)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 260, 0, 45)
        container.Position = pos
        container.BackgroundColor3 = Colors.Dark
        container.Parent = mainFrame
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        label.Text = labelText
        label.TextColor3 = Colors.Text
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.SourceSansSemibold
        label.TextSize = 14
        label.Parent = container

        local box = Instance.new("TextButton")
        box.Size = UDim2.new(0, 40, 0, 22)
        box.Position = UDim2.new(1, -50, 0.5, -11)
        box.BackgroundColor3 = Config[configKey] and Colors.Enabled or Colors.Disabled
        box.Text = ""
        box.Parent = container
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 11)

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 14, 0, 14)
        indicator.Position = Config[configKey] and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7)
        indicator.BackgroundColor3 = Colors.Text
        indicator.Parent = box
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

        box.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            box.BackgroundColor3 = Config[configKey] and Colors.Enabled or Colors.Disabled
            indicator:TweenPosition(Config[configKey] and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7), "Out", "Quad", 0.2, true)
        end)
    end

    createCheckbox("Hyper Boss Aura", UDim2.new(0, 20, 0, 55), "Aura")
    createCheckbox("Auto Retry Boss", UDim2.new(0, 20, 0, 110), "Retry")
    createCheckbox("Auto Execute (URL)", UDim2.new(0, 20, 0, 165), "AutoExecute")
    createCheckbox("TP to Mob (Always)", UDim2.new(0, 20, 0, 220), "BringMob")

    local running = true
    closeBtn.MouseButton1Click:Connect(function()
        running = false
        _G.EndardHubLoaded = false
        screenGui:Destroy()
    end)

    UserInputService.InputBegan:Connect(function(i, g)
        if not g and i.KeyCode == Enum.KeyCode.N then mainFrame.Visible = not mainFrame.Visible end
    end)

    -- --- ANA MOTOR (HEARTBEAT) ---
    task.spawn(function()
        local Net = ReplicatedStorage:WaitForChild("NetworkComm")
        local Combat = Net:WaitForChild("CombatService"):WaitForChild("DamageCharacter_Method")
        local Skill = Net:WaitForChild("SkillService"):WaitForChild("StartSkilll_Method")
        local Retry = Net:WaitForChild("RaidsService"):WaitForChild("RetryRaid_Method")
        
        local hbConnection
        hbConnection = RunService.Heartbeat:Connect(function()
            if not running then hbConnection:Disconnect() return end

            local myChar = GetMyCharacter()
            if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
            
            local myRoot = myChar.HumanoidRootPart
            local NPCsFolder = workspace.Characters.Server.NPCs
            local npcList = NPCsFolder:GetChildren()

            -- TP TO MOB (Seni Boss'un yanına götürür)
            if Config.BringMob then
                for _, npc in pairs(npcList) do
                    local nRoot = npc:FindFirstChild("HumanoidRootPart")
                    local nHum = npc:FindFirstChild("Humanoid")
                    if nRoot and nHum and nHum.Health > 0 then
                        -- Boss'un 3 birim arkasına ve biraz üstüne ışınlan (Sıkışmamak için)
                        myRoot.CFrame = nRoot.CFrame * CFrame.new(0, 2, 3)
                        break -- İlk bulduğu Boss'a gider
                    end
                end
            end

            -- AURA (ORİJİNAL SALDIRI PAKETLERİ)
            if Config.Aura and #npcList > 0 then
                local targets = {}
                for _, v in pairs(npcList) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        table.insert(targets, v)
                    end
                end

                if #targets > 0 then
                    local attackData = {
                        ["CanParry"] = true,
                        ["OnCharacterHit"] = function() end,
                        ["Origin"] = myRoot.CFrame,
                        ["Parries"] = {},
                        ["WindowID"] = myChar.Name .. "_Punch",
                        ["LocalCharacter"] = myChar,
                        ["SkillID"] = "Punch"
                    }

                    -- Çift vuruş paketi
                    for _ = 1, 2 do 
                        task.spawn(function()
                            Combat:InvokeServer(targets, true, attackData)
                        end)
                    end
                    
                    -- Skill tetikleme
                    task.spawn(function()
                        Skill:InvokeServer("Punch", myChar, Vector3.zero, 1, 1)
                    end)
                end
            end
        end)

        -- Retry Döngüsü
        while running do
            if Config.Retry and #workspace.Characters.Server.NPCs:GetChildren() == 0 then
                pcall(function() Retry:InvokeServer() end)
                task.wait(2)
            end
            task.wait(1)
        end
    end)
end

-- --- BAŞLATMA ---
task.spawn(function()
    local NPCsFolder = workspace:WaitForChild("Characters"):WaitForChild("Server"):WaitForChild("NPCs")
    while true do
        if #NPCsFolder:GetChildren() > 0 then
            CreateMenu()
            break 
        end
        task.wait(1)
    end
end)
