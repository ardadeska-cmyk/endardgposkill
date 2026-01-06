-- [[ EndardHub Modern Edition - Auto-Refresh Boss ESP ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GENİŞLETİLMİŞ NPC LİSTESİ
local targetNames = {
    ["Robo"] = true, 
    ["Hawk Eye"] = true, 
    ["Roger"] = true, 
    ["Donmingo"] = true, 
    ["Soul King"] = true, 
    ["Juzo the Diamondback"] = true, 
    ["Law"] = true
}

local NPCsFolder = workspace:FindFirstChild("NPCs")

_G.AutoAim = false
_G.BossESP = false
_G.HubActive = true

-- GUI OLUŞTURMA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EndardHub_Gui"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true 
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.BackgroundTransparency = 0.5
Title.Text = "EndardHub"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.Position = UDim2.new(0.85, 0, 0, 5)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold

local function createButton(name, pos)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.Position = pos
    btn.Size = UDim2.new(0.85, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local AimCB = createButton("Auto Aim", UDim2.new(0.075, 0, 0.3, 0))
local BossCB = createButton("Boss ESP", UDim2.new(0.075, 0, 0.6, 0))

local function updateAimUI()
    local targetColor = _G.AutoAim and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(45, 45, 45)
    TweenService:Create(AimCB, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
    AimCB.Text = "Auto Aim: " .. (_G.AutoAim and "ON" or "OFF")
end

local function updateBossUI()
    local targetColor = _G.BossESP and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(45, 45, 45)
    TweenService:Create(BossCB, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
    BossCB.Text = "Boss ESP: " .. (_G.BossESP and "ON" or "OFF")
end

-- Temizleme
CloseBtn.MouseButton1Click:Connect(function()
    _G.HubActive = false
    _G.AutoAim = false
    _G.BossESP = false
    ScreenGui:Destroy()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "ESP_Marker" or v.Name == "ESP_Name" or v.ClassName == "BoxHandleAdornment" then v:Destroy() end
    end
end)

local function toggleAim()
    _G.AutoAim = not _G.AutoAim
    updateAimUI()
end

local function toggleBoss()
    _G.BossESP = not _G.BossESP
    updateBossUI()
    if not _G.BossESP then
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "ESP_Marker" or v.Name == "ESP_Name" or v.ClassName == "BoxHandleAdornment" then v:Destroy() end
        end
    end
end

AimCB.MouseButton1Click:Connect(toggleAim)
BossCB.MouseButton1Click:Connect(toggleBoss)

UserInputService.InputBegan:Connect(function(input, proc)
    if proc then return end
    if input.KeyCode == Enum.KeyCode.N then
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.J then
        toggleAim()
    end
end)

-- ARTİ İŞARETİ OLUŞTURUCU
local function createVisibleCross(root)
    local function createBar(size)
        local bar = Instance.new("BoxHandleAdornment")
        bar.Size = size
        bar.AlwaysOnTop = true
        bar.ZIndex = 10
        bar.Adornee = root
        bar.Transparency = 0.2
        bar.Parent = root
        bar.Name = "ESP_Cross_Part"
        return bar
    end
    return createBar(Vector3.new(18, 1.8, 1.8)), createBar(Vector3.new(1.8, 18, 1.8))
end

-- ESP UYGULAMA FONKSİYONU
local function applyESP(npc)
    if not _G.BossESP or not npc:FindFirstChild("HumanoidRootPart") then return end
    if npc:FindFirstChild("ESP_Marker") then return end

    -- Marker olarak bir parça ekle ki tekrar eklemesin
    local marker = Instance.new("StringValue", npc)
    marker.Name = "ESP_Marker"

    -- Highlight
    local hl = Instance.new("Highlight", npc)
    hl.Name = "ESP_Highlight"
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    -- Name Tag
    local root = npc.HumanoidRootPart
    local bg = Instance.new("BillboardGui", root)
    bg.Name = "ESP_Name"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 100, 0, 40); bg.StudsOffset = Vector3.new(0, 10, 0)
    local lbl = Instance.new("TextLabel", bg)
    lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1,0,1,0); lbl.Text = npc.Name; lbl.TextColor3 = Color3.new(1,1,1); lbl.Font = Enum.Font.GothamBold; lbl.TextScaled = true
    
    -- Cross
    local bar1, bar2 = createVisibleCross(root)
    
    task.spawn(function()
        local hue = 0
        while npc.Parent and _G.BossESP and marker.Parent do
            hue = (hue + 0.01) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            if bar1 and bar2 then
                bar1.Color3 = color
                bar2.Color3 = color
            end
            task.wait()
        end
        if bar1 then bar1:Destroy() end
        if bar2 then bar2:Destroy() end
        if hl then hl:Destroy() end
        if bg then bg:Destroy() end
    end)
end

-- ANA DÖNGÜ VE YENİLEME
task.spawn(function()
    while task.wait(1) do -- Her saniye tara
        if _G.HubActive and _G.BossESP and NPCsFolder then
            for _, npc in pairs(NPCsFolder:GetChildren()) do
                if targetNames[npc.Name] then
                    applyESP(npc)
                end
            end
        end
    end
end)

-- AİMBOT DÖNGÜSÜ
RunService.RenderStepped:Connect(function()
    if not _G.HubActive or not _G.AutoAim or not NPCsFolder then return end
    
    local dist, target = math.huge, nil
    for _, npc in pairs(NPCsFolder:GetChildren()) do
        -- Robo hariç diğer Boss'lara aim
        if targetNames[npc.Name] and npc.Name ~= "Robo" and npc:FindFirstChild("HumanoidRootPart") then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local d = (npc.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d; target = npc end
            end
        end
    end
    
    if target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.HumanoidRootPart.Position)
    end
end)
