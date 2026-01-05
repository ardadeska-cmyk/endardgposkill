

--[[
    EndardHub - Modern Elite Edition
    Özellikler: 
    - Tüm NPC'ler için Full ESP (İsim + Mesafe)
    - Özel Boss Listesi (Sol Panel)
    - Modern Animasyonlu UI
    - Auto-Enabled (Radar ve Auto-Exec hazır açılır)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Eski kalıntıları temizle
if CoreGui:FindFirstChild("EndardHub") then CoreGui.EndardHub:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild("BossTrackerGUI") then LocalPlayer.PlayerGui.BossTrackerGUI:Destroy() end

local RadarActive = true
local AutoExecActive = true
local TargetBosses = {"Roger", "Hawk Eye", "Soul King"}

-------------------------------------------------------------------------
-- MODERN ANA MENÜ (EndardHub)
-------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EndardHub"
ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 180)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 12)

-- Açılış Animasyonu
MainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 280, 0, 180)}):Play()

local Title = Instance.new("TextLabel")
Title.Text = "  EndardHub"
Title.Size = UDim2.new(1, -40, 0, 45)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 24
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-------------------------------------------------------------------------
-- MODERN CHECKBOX SİSTEMİ
-------------------------------------------------------------------------
local function CreateModernToggle(name, yPos, default, callback)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -30, 0, 45)
    bg.Position = UDim2.new(0, 15, 0, yPos)
    bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    bg.Parent = MainFrame
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = bg

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 20)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)
    toggleBtn.Text = ""
    toggleBtn.Parent = bg
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

    local status = default
    toggleBtn.MouseButton1Click:Connect(function()
        status = not status
        local goal = status and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)
        TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = goal}):Play()
        callback(status)
    end)
end

-------------------------------------------------------------------------
-- BOSS LISTESI & FULL NPC ESP
-------------------------------------------------------------------------
local function StartRadarSystem()
    local npcsFolder = Workspace:WaitForChild("NPCs", 5)
    if not npcsFolder then return end

    -- Sol Boss Listesi GUI
    local trackerGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    trackerGui.Name = "BossTrackerGUI"
    
    local listFrame = Instance.new("Frame", trackerGui)
    listFrame.Size = UDim2.new(0, 200, 0, 250)
    listFrame.Position = UDim2.new(0, 15, 0.4, 0)
    listFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    listFrame.BackgroundTransparency = 0.4
    Instance.new("UICorner", listFrame)

    local listLabel = Instance.new("TextLabel", listFrame)
    listLabel.Size = UDim2.new(1, -20, 1, -20)
    listLabel.Position = UDim2.new(0, 10, 0, 10)
    listLabel.BackgroundTransparency = 1
    listLabel.TextColor3 = Color3.new(1, 1, 1)
    listLabel.Font = "GothamBold"
    listLabel.TextSize = 14
    listLabel.TextYAlignment = "Top"
    listLabel.TextXAlignment = "Left"

    -- ESP Fonksiyonu (Tüm NPC'ler için)
    local function applyESP(model)
        if model:FindFirstChild("ESP_Tag") then return end
        local head = model:WaitForChild("Head", 2) or model.PrimaryPart
        if head then
            local bg = Instance.new("BillboardGui", model)
            bg.Name = "ESP_Tag"
            bg.Size = UDim2.new(0, 200, 0, 50)
            bg.AlwaysOnTop = true
            bg.StudsOffset = Vector3.new(0, 3, 0)

            local tl = Instance.new("TextLabel", bg)
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 1
            tl.TextColor3 = Color3.fromRGB(255, 255, 255)
            tl.TextStrokeTransparency = 0
            tl.Font = "GothamBold"
            tl.TextSize = 16

            task.spawn(function()
                while RadarActive and model.Parent == npcsFolder do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                        tl.Text = string.format("%s\n[%.0f m]", model.Name, dist)
                        
                        -- Boss ise sarı, normal NPC ise beyaz yap
                        local isBoss = false
                        for _, b in pairs(TargetBosses) do if b == model.Name then isBoss = true break end end
                        tl.TextColor3 = isBoss and Color3.new(1, 1, 0) or Color3.new(1, 1, 1)
                    end
                    task.wait(0.2)
                end
                bg:Destroy()
            end)
        end
    end

    -- Ana Döngü
    task.spawn(function()
        while RadarActive do
            local foundText = "BOSSLAR:\n"
            for _, name in pairs(TargetBosses) do
                if npcsFolder:FindFirstChild(name) then
                    foundText = foundText .. "• " .. name .. " (Açık)\n"
                end
            end
            listLabel.Text = foundText

            for _, npc in pairs(npcsFolder:GetChildren()) do
                if npc:IsA("Model") then applyESP(npc) end
            end
            task.wait(1)
        end
        trackerGui:Destroy()
    end)
end

-------------------------------------------------------------------------
-- BAĞLANTILAR
-------------------------------------------------------------------------
CreateModernToggle("Boss Rader", 55, true, function(s)
    RadarActive = s
    if s then StartRadarSystem() end
end)

CreateModernToggle("Auto Exec", 110, true, function(s)
    AutoExecActive = s
end)

-- N Tuşu (Yumuşak Gizleme)
local visible = true
UserInputService.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.N then
        visible = not visible
        MainFrame:TweenPosition(visible and UDim2.new(0.5, -140, 0.5, -90) or UDim2.new(0.5, -140, 1.2, 0), "Out", "Quart", 0.4, true)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    RadarActive = false
    AutoExecActive = false
    MainFrame:TweenSize(UDim2.new(0,0,0,0), "In", "Back", 0.3, true, function() ScreenGui:Destroy() end)
end)

-- Başlat
if RadarActive then StartRadarSystem() end

-- Teleport (Auto-Exec)
LocalPlayer.OnTeleport:Connect(function()
    if AutoExecActive then
        local code = "loadstring(game:HttpGet('" .. _G.EndardLink .. "'))()"
        if queue_on_teleport then queue_on_teleport(code) end
    end
end)
