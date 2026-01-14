local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// GLOBAL STATES
_G.HubActive = true
_G.AutoAim = false 
_G.BossESP = true
_G.Rainbow = false
_G.MainColor = Color3.fromRGB(0, 162, 255)
_G.CanToggle = false 

getgenv().AutoFishEnabled = false
getgenv().AutoFishNewEnabled = false
getgenv().FishSellEnabled = false
getgenv().AutoBuyEnabled = false
getgenv().FishTime = 21

local targetNames = {["Robo"] = true, ["Hawk Eye"] = true, ["Roger"] = true, ["Donmingo"] = true, ["Soul King"] = true, ["Juzo the Diamondback"] = true, ["Law"] = true}
local ItemsList = {"Special Tailor Token", "Merchants Banana Rod", "Kessui","Race Reroll", "Red Cloud Costume","SP Reset Essence","Coffin Boat", "Ten Tails Jinchuriki Costume", "Striker","Iceborn Headband","Legendary Fruit Chest", "Rare Fruit Chest", "Mythical Fruit Chest", "Rare Fish Bait", "Legendary Fish Bait", "Sorcerer Hunter Costume", "Powderpunk Outfit"}
local FishToSell = {"Blue-Lip Grouper", "Exotic Tigerfin", "Tigerfin", "Fangfish", "Zebra Ribbon Angelfish", "Crimson Snapper", "Crimson Polka Puffer"}

local SelectedItems = {}
local LockTarget = nil
local AimToggleBtn_Ref = nil

--// BOSS ESP LOGIC
task.spawn(function()
    while _G.HubActive do
        pcall(function()
            local npcFolder = workspace:FindFirstChild("NPCs")
            if npcFolder then
                for _, npc in pairs(npcFolder:GetChildren()) do
                    if targetNames[npc.Name] and _G.BossESP then
                        if not npc:FindFirstChild("BossESP_Tag") then
                            local bg = Instance.new("BillboardGui", npc); bg.Name = "BossESP_Tag"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 100, 0, 50); bg.ExtentsOffset = Vector3.new(0, 3, 0)
                            local tl = Instance.new("TextLabel", bg); tl.BackgroundTransparency = 1; tl.Size = UDim2.new(1, 0, 1, 0); tl.Text = npc.Name; tl.TextColor3 = Color3.fromRGB(255, 0, 0); tl.Font = Enum.Font.GothamBold; tl.TextSize = 14
                            local hl = Instance.new("Highlight", npc); hl.Name = "BossESP_Highlight"; hl.FillColor = Color3.fromRGB(255, 0, 0); hl.OutlineColor = Color3.new(1,1,1)
                        end
                    elseif npc:FindFirstChild("BossESP_Tag") and not _G.BossESP then
                        npc.BossESP_Tag:Destroy()
                        if npc:FindFirstChild("BossESP_Highlight") then npc.BossESP_Highlight:Destroy() end
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

--// UI INITIALIZATION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EndardHub_Official"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

--// WATERMARK
task.spawn(function()
    while _G.HubActive do
        pcall(function()
            local hBars = LocalPlayer.PlayerGui:FindFirstChild("healthbars") or LocalPlayer.PlayerGui:FindFirstChild("HealthBars")
            if hBars then
                local myBar = hBars:FindFirstChild(LocalPlayer.Name)
                if myBar and myBar:FindFirstChild("NameT") then
                    myBar.NameT.Text = ".gg/EndardHub"
                    myBar.NameT.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                end
            end
        end)
        task.wait(0.1)
    end
end)

local function showNotify(text)
    local NotifyLabel = Instance.new("TextLabel", ScreenGui); NotifyLabel.Size = UDim2.new(0, 400, 0, 50); NotifyLabel.Position = UDim2.new(0.5, -200, 0.1, -100); NotifyLabel.BackgroundTransparency = 1; NotifyLabel.Text = text; NotifyLabel.TextColor3 = Color3.fromRGB(0, 255, 170); NotifyLabel.Font = Enum.Font.GothamBold; NotifyLabel.TextSize = 25
    local NotifyStroke = Instance.new("UIStroke", NotifyLabel); NotifyStroke.Thickness = 2
    TweenService:Create(NotifyLabel, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -200, 0.15, 0)}):Play()
    task.delay(3, function() TweenService:Create(NotifyLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play(); task.wait(0.5); NotifyLabel:Destroy() end)
end

local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local objects = frame:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
            local isInteracting = false
            for _, obj in pairs(objects) do if obj:IsA("TextButton") or obj:IsA("ScrollingFrame") or obj.Name == "SliderBar" then isInteracting = true break end end
            if not isInteracting then dragging = true; dragStart = input.Position; startPos = frame.Position end
        end
    end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragStart; frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 650, 0, 420); MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210); MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15); MainFrame.Visible = false; MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Color = _G.MainColor; MainStroke.Thickness = 1.5
makeDraggable(MainFrame)

local Title = Instance.new("TextLabel", MainFrame); Title.Text = "EndardHub"; Title.Font = Enum.Font.GothamBold; Title.TextSize = 20; Title.TextColor3 = _G.MainColor; Title.Position = UDim2.new(0, 20, 0, 15); Title.Size = UDim2.new(0, 200, 0, 30); Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left

local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Position = UDim2.new(0, 15, 0, 55); Sidebar.Size = UDim2.new(0, 160, 1, -70); Sidebar.BackgroundTransparency = 1
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)
local Container = Instance.new("Frame", MainFrame); Container.Position = UDim2.new(0, 185, 0, 55); Container.Size = UDim2.new(1, -200, 1, -70); Container.BackgroundTransparency = 1

local Tabs = {}
local function createTab(name)
    local btn = Instance.new("TextButton", Sidebar); btn.Size = UDim2.new(1, 0, 0, 38); btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28); btn.Text = name; btn.TextColor3 = Color3.fromRGB(150, 150, 150); btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; Instance.new("UICorner", btn)
    local page = Instance.new("ScrollingFrame", Container); page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.Visible = false; page.ScrollBarThickness = 2; page.CanvasSize = UDim2.new(0,0,3.5,0); Instance.new("UIListLayout", page).Padding = UDim.new(0, 10)
    btn.MouseButton1Click:Connect(function() for _, t in pairs(Tabs) do t.p.Visible = false; t.b.TextColor3 = Color3.fromRGB(150, 150, 150) end; page.Visible = true; btn.TextColor3 = _G.MainColor end)
    Tabs[name] = {p = page, b = btn}; return page
end

local FarmPage = createTab("Farming"); local MerchPage = createTab("Merchant"); local VisualPage = createTab("Visuals"); local SettingsPage = createTab("Settings")

--// UI HELPERS
local function createToggle(parent, text, default, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1, 0, 0, 45); frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", frame)
    local lbl = Instance.new("TextLabel", frame); lbl.Size = UDim2.new(0.7,0,1,0); lbl.Position = UDim2.new(0,12,0,0); lbl.Text = text; lbl.TextColor3 = Color3.new(1,1,1); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13; lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(0, 40, 0, 20); btn.Position = UDim2.new(1, -50, 0.5, -10); btn.BackgroundColor3 = default and _G.MainColor or Color3.fromRGB(50,50,50); btn.Text = ""; Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
    if text:find("Auto Aim") then AimToggleBtn_Ref = btn end
    btn.MouseButton1Click:Connect(function() default = not default; btn.BackgroundColor3 = default and _G.MainColor or Color3.fromRGB(50,50,50); callback(default) end)
end

local function createSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1, 0, 0, 50); frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", frame)
    local lbl = Instance.new("TextLabel", frame); lbl.Size = UDim2.new(1,0,0,20); lbl.Position = UDim2.new(0,12,0,5); lbl.Text = text .. ": " .. default; lbl.TextColor3 = Color3.new(1,1,1); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local bar = Instance.new("Frame", frame); bar.Name = "SliderBar"; bar.Size = UDim2.new(0.9, 0, 0, 4); bar.Position = UDim2.new(0.05, 0, 0.75, 0); bar.BackgroundColor3 = Color3.fromRGB(40,40,40); Instance.new("UICorner", bar)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = _G.MainColor; Instance.new("UICorner", fill)
    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local pos = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); fill.Size = UDim2.new(pos, 0, 1, 0); local val = math.floor(min + (max - min) * pos); lbl.Text = text .. ": " .. val; callback(val) end end)
end

--// FISHING LOGIC
local function runFishing(waitTime, isEnabledVar)
    local Remote = ReplicatedStorage:WaitForChild("Fishing"):WaitForChild("Remotes"):WaitForChild("Action")
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local rod = LocalPlayer.Backpack:FindFirstChild("Rod") or char:FindFirstChild("Rod")
        if not rod then for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do if v.Name:lower():find("rod") then rod = v break end end end

        if rod and hum and hrp then
            hum:EquipTool(rod); task.wait(0.2)
            Remote:InvokeServer({Goal = hrp.Position, Action = "Throw", Bait = "Common Fish Bait"})
            task.wait(waitTime)
            if getgenv()[isEnabledVar] then
                Remote:InvokeServer({Action = "Reel"})
                task.wait(1); hum:UnequipTools(); task.wait(0.5)
            end
        end
    end)
end

--// NO-GRAVITY FLY LOGIC
local FlySpeed = 140
local currentTween, noclipConnection, isFlying = nil, nil, false
local TPTargets = {
    ImpelBase = CFrame.new(5937.09619, 6.06799984, -9470.65332),
    HawkEye   = CFrame.new(12599.041, 13.1663523, 2785.85669),
    SoulKing  = CFrame.new(4705.62305, 145.94603, -11611.9756),
    Juzo      = CFrame.new(1777.96753, 36.3749886, -10628.9688)
}

local function StopFlying()
    isFlying = false; if currentTween then currentTween:Cancel() end
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    pcall(function()
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if hrp:FindFirstChild("FlyForce") then hrp.FlyForce:Destroy() end
        LocalPlayer.Character.Humanoid.PlatformStand = false
        for _, v in pairs(LocalPlayer.Character:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = true end end
    end)
end

local function StartFlying(targetCFrame)
    StopFlying(); isFlying = true; local RootPart = LocalPlayer.Character.HumanoidRootPart
    local bv = Instance.new("BodyVelocity", RootPart); bv.Name = "FlyForce"; bv.Velocity = Vector3.new(0,0,0); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    local dist = (RootPart.Position - targetCFrame.Position).Magnitude
    currentTween = TweenService:Create(RootPart, TweenInfo.new(dist / FlySpeed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    currentTween:Play(); LocalPlayer.Character.Humanoid.PlatformStand = true
    noclipConnection = RunService.Stepped:Connect(function() for _, v in pairs(LocalPlayer.Character:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end end)
    task.spawn(function() while isFlying do pcall(function() ReplicatedStorage.Events.takestam:FireServer(0.55, "dash") end) task.wait(0.4) end end)
    currentTween.Completed:Connect(StopFlying)
end

--// FARMING TAB CONTENT
createToggle(FarmPage, "Auto Aim (Lock Boss)", _G.AutoAim, function(v) _G.AutoAim = v end)
createToggle(FarmPage, "Auto Fish", false, function(v) getgenv().AutoFishEnabled = v; if v then task.spawn(function() while getgenv().AutoFishEnabled do runFishing(getgenv().FishTime, "AutoFishEnabled") task.wait(0.1) end end) end end)
createSlider(FarmPage, "Fish Time (s)", 1, 30, 21, function(v) getgenv().FishTime = v end)
createToggle(FarmPage, "Auto Sell Fish", false, function(v) 
    getgenv().FishSellEnabled = v; if v then task.spawn(function() while getgenv().FishSellEnabled do for _, f in pairs(FishToSell) do ReplicatedStorage.FishingShopRemote:InvokeServer({Fish = f, All = true, Method = "SellFish"}) end task.wait(2) end end) end 
end)
createToggle(FarmPage, "Auto Buy Bait", false, function(v) 
    getgenv().AutoBuyEnabled = v; if v then task.spawn(function() while getgenv().AutoBuyEnabled do pcall(function() ReplicatedStorage.Events.Shop:InvokeServer(workspace.BuyableItems["Common Fish Bait"], 99) end) task.wait(60) end end) end 
end)
--- FLY BUTTONS ---
createToggle(FarmPage, "Hawk Eye TP (Fly)", false, function(v) if v then StartFlying(TPTargets.HawkEye) else StopFlying() end end)
createToggle(FarmPage, "Juzo TP (Fly)", false, function(v) if v then StartFlying(TPTargets.Juzo) else StopFlying() end end)
createToggle(FarmPage, "Soul King TP (Fly)", false, function(v) if v then StartFlying(TPTargets.SoulKing) else StopFlying() end end)
createToggle(FarmPage, "Impel Base TP (Fly)", false, function(v) if v then StartFlying(TPTargets.ImpelBase) else StopFlying() end end)

--// MERCHANT TAB
local MerchActionBtn = Instance.new("TextButton", MerchPage); MerchActionBtn.Size = UDim2.new(1, 0, 0, 45); MerchActionBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200); MerchActionBtn.Text = "ÇALIŞTIR (Işınlan + 40x)"; MerchActionBtn.TextColor3 = Color3.new(1,1,1); MerchActionBtn.Font = Enum.Font.GothamBold; MerchActionBtn.TextSize = 14; Instance.new("UICorner", MerchActionBtn)
MerchActionBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local comp = ReplicatedStorage.CompassGuider:FindFirstChild("Traveling Merchant")
        if not comp then showNotify("Merchant Bulunamadı!"); return end
        local RootPart = LocalPlayer.Character.HumanoidRootPart
        local target = (typeof(comp.Value) == "CFrame" and comp.Value) or CFrame.new(comp.Value)
        local original = RootPart.CFrame
        LocalPlayer:RequestStreamAroundAsync(target.Position)
        RootPart.CFrame = target
        task.spawn(function() for i = 1, 40 do task.spawn(function() ReplicatedStorage.Events.TravelingMerchentRemote:InvokeServer("OpenShop") end) for item, state in pairs(SelectedItems) do if state then task.spawn(function() ReplicatedStorage.Events.TravelingMerchentRemote:InvokeServer(item) end) end end task.wait(0.01) end end)
        task.wait(0.8); RootPart.CFrame = original
    end)
end)

for _, item in pairs(ItemsList) do
    local btn = Instance.new("TextButton", MerchPage); btn.Size = UDim2.new(1,0,0,28); btn.BackgroundColor3 = Color3.fromRGB(45,45,45); btn.Text = item; btn.TextColor3 = Color3.fromRGB(180,180,180); btn.Font = Enum.Font.Gotham; btn.TextSize = 11; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() SelectedItems[item] = not SelectedItems[item]; btn.BackgroundColor3 = SelectedItems[item] and Color3.fromRGB(0,150,100) or Color3.fromRGB(45,45,45) end)
end

--// VISUALS & SETTINGS
createToggle(VisualPage, "Boss ESP", _G.BossESP, function(v) _G.BossESP = v end)
createSlider(SettingsPage, "Menu Transparency", 0, 90, 0, function(v) MainFrame.BackgroundTransparency = v/100 end)
createToggle(SettingsPage, "Rainbow UI", false, function(v) _G.Rainbow = v end)

local UnloadBtn = Instance.new("TextButton", SettingsPage); UnloadBtn.Size = UDim2.new(1,0,0,40); UnloadBtn.BackgroundColor3 = Color3.fromRGB(150,50,50); UnloadBtn.Text = "UNLOAD HUB"; UnloadBtn.TextColor3 = Color3.new(1,1,1); UnloadBtn.Font = Enum.Font.GothamBold; UnloadBtn.TextSize = 14; Instance.new("UICorner", UnloadBtn)
UnloadBtn.MouseButton1Click:Connect(function() _G.HubActive = false; ScreenGui:Destroy() end)

--// CLOSEST BOSS & INPUT
local function GetClosestBoss()
    local dist, target = 800, nil
    local npcFolder = workspace:FindFirstChild("NPCs")
    if npcFolder then for _, npc in pairs(npcFolder:GetChildren()) do if targetNames[npc.Name] and npc:FindFirstChild("HumanoidRootPart") then local d = (npc.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude; if d < dist then dist = d; target = npc end end end end
    return target
end

UserInputService.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.N and _G.CanToggle then MainFrame.Visible = not MainFrame.Visible end
    if not p and i.KeyCode == Enum.KeyCode.CapsLock then
        _G.AutoAim = not _G.AutoAim
        if AimToggleBtn_Ref then AimToggleBtn_Ref.BackgroundColor3 = _G.AutoAim and _G.MainColor or Color3.fromRGB(50,50,50) end
        LockTarget = _G.AutoAim and GetClosestBoss() or nil
        showNotify(_G.AutoAim and (LockTarget and "Locked: "..LockTarget.Name or "Boss Bulunamadı!") or "Aim Unlocked")
    end
end)

RunService.RenderStepped:Connect(function()
    if not _G.HubActive then return end
    if _G.Rainbow then local c = Color3.fromHSV(tick() % 5 / 5, 1, 1); MainStroke.Color = c; Title.TextColor3 = c end
    if _G.AutoAim and LockTarget and LockTarget:FindFirstChild("HumanoidRootPart") then Camera.CFrame = CFrame.new(Camera.CFrame.Position, LockTarget.HumanoidRootPart.Position) end
end)

Tabs["Farming"].p.Visible = true; Tabs["Farming"].b.TextColor3 = _G.MainColor

--// GÜNCEL GİRİŞ EFEKTİ (EKRAN KARARMA + TURKUAZ YAZI)
task.spawn(function()
    -- Arka Plan Karartma
    local IntroOverlay = Instance.new("Frame", ScreenGui)
    IntroOverlay.Size = UDim2.new(1, 0, 1, 0)
    IntroOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    IntroOverlay.BackgroundTransparency = 1
    IntroOverlay.ZIndex = 199
    
    -- Turkuaz Yazı
    local IntroText = Instance.new("TextLabel", IntroOverlay)
    IntroText.Size = UDim2.new(1, 0, 1, 0)
    IntroText.BackgroundTransparency = 1
    IntroText.Text = "EndardHub"
    IntroText.TextColor3 = Color3.fromRGB(0, 255, 255) -- Turkuaz
    IntroText.Font = Enum.Font.GothamBold
    IntroText.TextSize = 80
    IntroText.TextTransparency = 1
    IntroText.ZIndex = 200

    -- Animasyon Başlangıcı
    TweenService:Create(IntroOverlay, TweenInfo.new(1), {BackgroundTransparency = 0.4}):Play()
    TweenService:Create(IntroText, TweenInfo.new(1), {TextTransparency = 0}):Play()
    
    task.wait(3) -- Yazının ekranda kalma süresi

    -- Animasyon Bitişi (Menü Açılırken Kaybolma)
    TweenService:Create(IntroOverlay, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
    TweenService:Create(IntroText, TweenInfo.new(1), {TextTransparency = 1}):Play()
    
    task.wait(1)
    IntroOverlay:Destroy()
    _G.CanToggle = true
    MainFrame.Visible = true
end)
