--[[
    EndardHub - Modern Edition (Auto-Enabled)
    Özellikler: Otomatik Boss Radar & Auto Exec, Modern Animasyonlu UI
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Eski menüyü anında temizle
if CoreGui:FindFirstChild("EndardHub") then CoreGui.EndardHub:Destroy() end

-- VARSAYILAN OLARAK AÇIK KALSIN İSTEDİĞİN AYARLAR
local RadarActive = true
local AutoExecActive = true

-- ANA MENÜ OLUŞTURMA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EndardHub"
ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 180)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Modern Köşe Yuvarlama
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Giriş Animasyonu (Yumuşak Büyüme)
MainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, 280, 0, 180)}):Play()

-- Başlık Çubuğu
local Title = Instance.new("TextLabel")
Title.Text = "  EndardHub"
Title.Size = UDim2.new(1, -40, 0, 40)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Kapatma (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 20
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- MODERN CHECKBOX FONKSİYONU
local function NewCheckbox(name, pos, default)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 40)
    btn.Position = UDim2.new(0, 15, 0, pos)
    btn.BackgroundColor3 = default and Color3.fromRGB(45, 180, 100) or Color3.fromRGB(45, 45, 45)
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local status = default
    btn.MouseButton1Click:Connect(function()
        status = not status
        local color = status and Color3.fromRGB(45, 180, 100) or Color3.fromRGB(45, 45, 45)
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
        if name == "Boss Rader" then RadarActive = status elseif name == "Auto Exec" then AutoExecActive = status end
    end)
end

-- Boss Radar & ESP (Kodların Orijinal Yapısı Bozulmadı)
local function StartRadar()
    local trackerGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    trackerGui.Name = "BossTrackerGUI"
    local f = Instance.new("Frame", trackerGui)
    f.Size = UDim2.new(0, 180, 0, 200)
    f.Position = UDim2.new(0, 10, 0.4, 0)
    f.BackgroundColor3 = Color3.new(0,0,0)
    f.BackgroundTransparency = 0.6
    Instance.new("UICorner", f)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,-10,1,-10)
    l.Position = UDim2.new(0,5,0,5)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.new(1,1,1)
    l.TextSize = 14
    l.TextYAlignment = "Top"
    l.Font = "Gotham"

    task.spawn(function()
        while true do
            if not RadarActive then 
                trackerGui:Destroy() 
                local folder = Workspace:FindFirstChild("NPCs")
                if folder then for _,v in pairs(folder:GetDescendants()) do if v.Name == "ESP_Tag" then v:Destroy() end end end
                break 
            end
            local txt = "AKTİF BOSSLAR:\n"
            local folder = Workspace:FindFirstChild("NPCs")
            if folder then
                for _, b in pairs({"Roger", "Hawk Eye", "Soul King"}) do
                    local boss = folder:FindFirstChild(b)
                    if boss then
                        txt = txt .. "• " .. b .. "\n"
                        if not boss:FindFirstChild("ESP_Tag") then
                            local bg = Instance.new("BillboardGui", boss)
                            bg.Name = "ESP_Tag"
                            bg.Size = UDim2.new(0,100,0,40)
                            bg.AlwaysOnTop = true
                            local tl = Instance.new("TextLabel", bg)
                            tl.Size = UDim2.new(1,0,1,0)
                            tl.Text = b
                            tl.TextColor3 = Color3.new(1,1,0)
                            tl.BackgroundTransparency = 1
                            tl.Font = "GothamBold"
                        end
                    end
                end
            end
            l.Text = txt
            task.wait(1)
        end
    end)
end

-- Otomatik Başlat
NewCheckbox("Boss Rader", 55, true)
NewCheckbox("Auto Exec", 105, true)
if RadarActive then StartRadar() end

-- N Tuşu (Animasyonlu Gizle/Göster)
local isVisible = true
UserInputService.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.N then
        isVisible = not isVisible
        local targetSize = isVisible and UDim2.new(0, 280, 0, 180) or UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
    end
end)

-- X Butonu (Tamamen Silme)
CloseBtn.MouseButton1Click:Connect(function()
    RadarActive = false
    AutoExecActive = false
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,0)}):Play()
    task.wait(0.3)
    ScreenGui:Destroy()
end)

-- HIZLI AUTO EXEC (Teleport Algılayıcı)
LocalPlayer.OnTeleport:Connect(function()
    if AutoExecActive then
        local teleportScript = "loadstring(game:HttpGet('" .. _G.EndardLink .. "'))()"
        local qot = queue_on_teleport or (syn and syn.queue_on_teleport)
        if qot then qot(teleportScript) end
    end
end)
