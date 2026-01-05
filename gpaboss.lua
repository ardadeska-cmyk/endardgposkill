

--[[
    EndardHub - Ultra Fast Edition
    Hatalar Giderildi:
    - Üst üste binme (Duplicate GUI) sorunu çözüldü.
    - Sunucu değişince işlevlerin çalışmama sorunu çözüldü.
    - Kararma/Karanlıklaşma sorunu giderildi.
    - Hız ayarları optimize edildi.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- TEMİZLİK: Önceki tüm kalıntıları anında sil
local function Cleanup()
    if CoreGui:FindFirstChild("EndardHub") then CoreGui.EndardHub:Destroy() end
    if LocalPlayer.PlayerGui:FindFirstChild("BossTrackerGUI") then LocalPlayer.PlayerGui.BossTrackerGUI:Destroy() end
    local npcsFolder = Workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, v in pairs(npcsFolder:GetDescendants()) do
            if v.Name == "ESP_Tag" then v:Destroy() end
        end
    end
end
Cleanup()

-- AYARLAR (Varsayılan Açık)
_G.RadarActive = true
_G.AutoExecActive = true
local TargetBosses = {"Roger", "Hawk Eye", "Soul King"}

-------------------------------------------------------------------------
-- MODERN ANA MENÜ
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
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

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
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local function CreateModernToggle(name, yPos, default, callback)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -30, 0, 45)
    bg.Position = UDim2.new(0, 15, 0, yPos)
    bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    bg.Parent = MainFrame
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 20)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)
    toggleBtn.Text = ""
    toggleBtn.Parent = bg
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

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

    toggleBtn.MouseButton1Click:Connect(function()
        if name == "Boss Rader" then _G.RadarActive = not _G.RadarActive
        elseif name == "Auto Exec" then _G.AutoExecActive = not _G.AutoExecActive end
        local status = (name == "Boss Rader" and _G.RadarActive or _G.AutoExecActive)
        TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = status and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)}):Play()
    end)
end

-------------------------------------------------------------------------
-- RADAR & ESP SİSTEMİ (TEK DÖNGÜ)
-------------------------------------------------------------------------
local function StartSystem()
    local trackerGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    trackerGui.Name = "BossTrackerGUI"
    
    local listFrame = Instance.new("Frame", trackerGui)
    listFrame.Size = UDim2.new(0, 200, 0, 200)
    listFrame.Position = UDim2.new(0, 15, 0.4, 0)
    listFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    listFrame.BackgroundTransparency = 0.5
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

    task.spawn(function()
        while task.wait(0.5) do
            if not _G.RadarActive then 
                listFrame.Visible = false
                local folder = Workspace:FindFirstChild("NPCs")
                if folder then for _,v in pairs(folder:GetDescendants()) do if v.Name == "ESP_Tag" then v:Destroy() end end end
            else
                listFrame.Visible = true
                local npcsFolder = Workspace:FindFirstChild("NPCs")
                local foundText = "BOSSLAR:\n"
                
                if npcsFolder then
                    -- Boss Kontrolü
                    for _, name in pairs(TargetBosses) do
                        if npcsFolder:FindFirstChild(name) then
                            foundText = foundText .. "• " .. name .. " (Açık)\n"
                        end
                    end
                    listLabel.Text = foundText

                    -- Tüm NPC'lere ESP
                    for _, npc in pairs(npcsFolder:GetChildren()) do
                        if npc:IsA("Model") and not npc:FindFirstChild("ESP_Tag") then
                            local h = npc:FindFirstChild("Head") or npc.PrimaryPart
                            if h then
                                local bg = Instance.new("BillboardGui", npc)
                                bg.Name = "ESP_Tag"
                                bg.Size = UDim2.new(0, 150, 0, 50)
                                bg.AlwaysOnTop = true
                                bg.StudsOffset = Vector3.new(0, 3, 0)
                                local tl = Instance.new("TextLabel", bg)
                                tl.Size = UDim2.new(1, 0, 1, 0)
                                tl.BackgroundTransparency = 1
                                tl.TextColor3 = Color3.new(1, 1, 1)
                                tl.Font = "GothamBold"
                                tl.TextSize = 14
                                task.spawn(function()
                                    while _G.RadarActive and npc.Parent == npcsFolder do
                                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                            local d = (LocalPlayer.Character.HumanoidRootPart.Position - h.Position).Magnitude
                                            tl.Text = string.format("%s\n[%.0f m]", npc.Name, d)
                                            local isB = false
                                            for _, b in pairs(TargetBosses) do if b == npc.Name then isB = true break end end
                                            tl.TextColor3 = isB and Color3.new(1, 1, 0) or Color3.new(1, 1, 1)
                                        end
                                        task.wait(0.2)
                                    end
                                    bg:Destroy()
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-------------------------------------------------------------------------
-- BAŞLATMA VE TELEPORT
-------------------------------------------------------------------------
CreateModernToggle("Boss Rader", 55, true)
CreateModernToggle("Auto Exec", 110, true)

-- N Tuşu (Anında Gizle/Göster)
local vis = true
UserInputService.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.N then
        vis = not vis
        MainFrame.Visible = vis
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    _G.RadarActive = false
    _G.AutoExecActive = false
    Cleanup()
end)

-- Teleport Logic (En Hızlı Şekilde)
LocalPlayer.OnTeleport:Connect(function()
    if _G.AutoExecActive then
        local qot = queue_on_teleport or (syn and syn.queue_on_teleport)
        if qot then
            qot("loadstring(game:HttpGet('" .. _G.EndardLink .. "'))()")
        end
    end
end)

-- Sistemi Başlat
task.spawn(StartSystem)
