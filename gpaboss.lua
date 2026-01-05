-- BU KODU GİTHUB'A YÜKLE
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Önceki menüyü temizle
if CoreGui:FindFirstChild("EndardHub") then
    CoreGui.EndardHub:Destroy()
end

local RadarActive = false
local AutoExecActive = false

-- ANA MENÜ OLUŞTURMA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EndardHub"
ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 180)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Başlık
local Title = Instance.new("TextLabel")
Title.Text = "EndardHub"
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Kapatma (X) Butonu
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

-- Checkbox Oluşturucu
local function NewCheckbox(name, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, pos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = MainFrame
    
    local status = false
    btn.MouseButton1Click:Connect(function()
        status = not status
        btn.BackgroundColor3 = status and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
        callback(status)
    end)
end

-- Boss Radar İşlevleri
local function StopRadar()
    if LocalPlayer.PlayerGui:FindFirstChild("BossTrackerGUI") then
        LocalPlayer.PlayerGui.BossTrackerGUI:Destroy()
    end
    if Workspace:FindFirstChild("NPCs") then
        for _, v in pairs(Workspace.NPCs:GetDescendants()) do
            if v.Name == "ESP_Tag" then v:Destroy() end
        end
    end
end

local function StartRadar()
    local folder = Workspace:WaitForChild("NPCs", 5)
    if not folder then return end
    
    local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    sg.Name = "BossTrackerGUI"
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 180, 0, 200)
    f.Position = UDim2.new(0, 10, 0.4, 0)
    f.BackgroundColor3 = Color3.new(0,0,0)
    f.BackgroundTransparency = 0.5
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.new(1,1,1)
    l.TextSize = 14
    l.TextYAlignment = "Top"

    task.spawn(function()
        while RadarActive do
            local txt = "AKTİF BOSSLAR:\n"
            for _, b in pairs({"Roger", "Hawk Eye", "Soul King"}) do
                local boss = folder:FindFirstChild(b)
                if boss then
                    txt = txt .. "• " .. b .. "\n"
                    if not boss:FindFirstChild("ESP_Tag") then
                        local bg = Instance.new("BillboardGui", boss)
                        bg.Name = "ESP_Tag"
                        bg.Size = UDim2.new(0,100,0,40)
                        bg.AlwaysOnTop = true
                        bg.StudsOffset = Vector3.new(0,3,0)
                        local tl = Instance.new("TextLabel", bg)
                        tl.Size = UDim2.new(1,0,1,0)
                        tl.Text = b
                        tl.TextColor3 = Color3.new(1,1,0)
                        tl.BackgroundTransparency = 1
                    end
                end
            end
            l.Text = txt
            task.wait(1)
        end
    end)
end

-- Butonları Ekle
NewCheckbox("Boss Rader", 50, function(s)
    RadarActive = s
    if s then StartRadar() else StopRadar() end
end)

NewCheckbox("Auto Exec", 95, function(s)
    AutoExecActive = s
end)

-- N Tuşu (Görünürlük)
UserInputService.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.N then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- X Butonu (Tamamen Silme)
CloseBtn.MouseButton1Click:Connect(function()
    RadarActive = false
    AutoExecActive = false
    StopRadar()
    ScreenGui:Destroy()
end)

-- Işınlanma Algılayıcı (Auto Exec)
LocalPlayer.OnTeleport:Connect(function()
    if AutoExecActive then
        local teleportScript = "loadstring(game:HttpGet('" .. _G.EndardLink .. "'))()"
        local qot = queue_on_teleport or (syn and syn.queue_on_teleport)
        if qot then
            qot(teleportScript)
        end
    end
end)