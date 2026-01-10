
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera


local targetNames = {
    ["Robo"] = true, ["Hawk Eye"] = true, ["Roger"] = true, 
    ["Donmingo"] = true, ["Soul King"] = true, ["Juzo the Diamondback"] = true, ["Law"] = true
}

local ItemsList = {"Special Tailor Token", "Race Reroll", "Coffin Boat", "Ten Tails Jinchuriki Costume", "Striker","Iceborn Headband","Legendary Fruit Chest", "Rare Fruit Chest", "Mythical Fruit Chest", "Rare Fish Bait", "Legendary Fish Bait", "Sorcerer Hunter Costume", "Powderpunk Outfit"}
local NPCsFolder = workspace:FindFirstChild("NPCs")
local SelectedItems = {}

_G.AutoAim = false
_G.BossESP = true
_G.HubActive = true


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EndardHub_Ultimate"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false


local NotifyLabel = Instance.new("TextLabel")
NotifyLabel.Name = "NotifyLabel"
NotifyLabel.Parent = ScreenGui
NotifyLabel.Size = UDim2.new(0, 400, 0, 50)
NotifyLabel.Position = UDim2.new(0.5, -200, 0.1, -100)
NotifyLabel.BackgroundTransparency = 1
NotifyLabel.Text = ""
NotifyLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
NotifyLabel.Font = Enum.Font.GothamBold
NotifyLabel.TextSize = 25
NotifyLabel.ZIndex = 10
local NotifyStroke = Instance.new("UIStroke", NotifyLabel)
NotifyStroke.Thickness = 2
NotifyStroke.Color = Color3.fromRGB(0, 0, 0)

local function showNotify(text)
    NotifyLabel.Text = text
    NotifyLabel.TextTransparency = 0
    NotifyStroke.Transparency = 0
    NotifyLabel.Position = UDim2.new(0.5, -200, 0.1, -100)
    TweenService:Create(NotifyLabel, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -200, 0.15, 0)}):Play()
    task.delay(2, function()
        TweenService:Create(NotifyLabel, TweenInfo.new(0.5), {TextTransparency = 1, Position = UDim2.new(0.5, -200, 0.1, -100)}):Play()
        TweenService:Create(NotifyStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
    end)
end


local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -225)
MainFrame.Size = UDim2.new(0, 260, 0, 480)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(60, 60, 65)

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "EndardHub"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.Position = UDim2.new(1, -30, 0, 10)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18

local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 15, 0, 60)
ContentContainer.Size = UDim2.new(1, -30, 1, -70)
ContentContainer.CanvasSize = UDim2.new(0, 0, 2.5, 0) -- İçerik arttığı için Canvas büyütüldü
ContentContainer.ScrollBarThickness = 2
ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 170)

local UIList = Instance.new("UIListLayout")
UIList.Parent = ContentContainer
UIList.Padding = UDim.new(0, 8)


local function createToggle(text, defaultState, callback)
    local Wrapper = Instance.new("Frame")
    Wrapper.Size = UDim2.new(1, 0, 0, 35)
    Wrapper.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Wrapper.Parent = ContentContainer
    Instance.new("UICorner", Wrapper).CornerRadius = UDim.new(0, 6)
    local Label = Instance.new("TextLabel")
    Label.Parent = Wrapper; Label.Size = UDim2.new(0.6, 0, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.BackgroundTransparency = 1; Label.Text = text; Label.TextColor3 = Color3.fromRGB(220, 220, 220); Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left
    local SwitchBg = Instance.new("TextButton")
    SwitchBg.Parent = Wrapper; SwitchBg.Size = UDim2.new(0, 36, 0, 20); SwitchBg.Position = UDim2.new(1, -42, 0.5, -10); SwitchBg.BackgroundColor3 = defaultState and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(60, 60, 65); SwitchBg.Text = ""; SwitchBg.AutoButtonColor = false; Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
    local Knob = Instance.new("Frame")
    Knob.Parent = SwitchBg; Knob.Size = UDim2.new(0, 14, 0, 14); Knob.Position = defaultState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7); Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    local isOn = defaultState
    local function setToggle(newState)
        isOn = newState
        local targetPos = isOn and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        local targetColor = isOn and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(60, 60, 65)
        TweenService:Create(Knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        callback(isOn)
    end
    SwitchBg.MouseButton1Click:Connect(function() setToggle(not isOn) end)
    return setToggle
end

local function createActionButton(text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ContentContainer; Btn.Size = UDim2.new(1, 0, 0, 35); Btn.BackgroundColor3 = color or Color3.fromRGB(50, 50, 55); Btn.Text = text; Btn.TextColor3 = Color3.fromRGB(255, 255, 255); Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 13; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local function performUltraFastScan(targets)
    local found = {}
    local checkDuration = 0.6 
    local startTime = tick()
    while tick() - startTime < checkDuration do
        for _, name in pairs(targets) do
            if NPCsFolder:FindFirstChild(name) and not found[name] then found[name] = true end
        end
        task.wait(0.02)
    end
    local foundList = {}
    for name, _ in pairs(found) do table.insert(foundList, name:upper()) end
    if #foundList > 0 then showNotify("BULUNDU: " .. table.concat(foundList, " & ")) end
end


local updateAimToggle = createToggle("Auto Aim [Caps Lock]", false, function(state) _G.AutoAim = state end)
createToggle("Boss ESP", true, function(state) _G.BossESP = state end)

createActionButton("Mihawk & Roger Tarama", Color3.fromRGB(80, 50, 120), function()
    local r = LocalPlayer.Character.HumanoidRootPart
    local old = r.CFrame
    LocalPlayer.Character:PivotTo(workspace.Islands["Umi Island"]:GetPivot() * CFrame.new(0, 55, 0))
    task.spawn(performUltraFastScan, {"Roger", "Hawk Eye"})
    task.wait(0.65)
    r.CFrame = old
end)


createActionButton("Juzo Tarama", Color3.fromRGB(150, 80, 0), function()
    local r = LocalPlayer.Character.HumanoidRootPart
    local old = r.CFrame
    LocalPlayer.Character:PivotTo(workspace.Islands["Turtleback Cave"]:GetPivot() * CFrame.new(0, -65, 0))
    task.spawn(performUltraFastScan, {"Juzo the Diamondback"})
    task.wait(0.65)
    r.CFrame = old
end)


local Divider = Instance.new("Frame"); Divider.Parent = ContentContainer; Divider.Size = UDim2.new(1, 0, 0, 1); Divider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
local MTitle = Instance.new("TextLabel"); MTitle.Parent = ContentContainer; MTitle.Size = UDim2.new(1, 0, 0, 20); MTitle.Text = "MERCHANT ITEMS"; MTitle.TextColor3 = Color3.fromRGB(0, 255, 170); MTitle.Font = Enum.Font.GothamBold; MTitle.BackgroundTransparency = 1; MTitle.TextSize = 12

for _, itemName in pairs(ItemsList) do
    local ItemBtn = Instance.new("TextButton")
    ItemBtn.Parent = ContentContainer; ItemBtn.Size = UDim2.new(1, 0, 0, 25); ItemBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); ItemBtn.Text = itemName; ItemBtn.TextColor3 = Color3.fromRGB(180, 180, 180); ItemBtn.Font = Enum.Font.Gotham; ItemBtn.TextSize = 11; Instance.new("UICorner", ItemBtn)
    ItemBtn.MouseButton1Click:Connect(function()
        if SelectedItems[itemName] then SelectedItems[itemName] = nil; ItemBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); ItemBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        else SelectedItems[itemName] = true; ItemBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100); ItemBtn.TextColor3 = Color3.fromRGB(255, 255, 255) end
    end)
end

createActionButton("ÇALIŞTIR (Işınlan + 40x)", Color3.fromRGB(0, 100, 200), function()
    local RootPart = LocalPlayer.Character.HumanoidRootPart
    local compassObj = ReplicatedStorage.CompassGuider:FindFirstChild("Traveling Merchant")
    if not compassObj then return end
    local targetCFrame = (typeof(compassObj.Value) == "CFrame" and compassObj.Value) or CFrame.new(compassObj.Value)
    local originalCFrame = RootPart.CFrame
    local Remote = ReplicatedStorage.Events.TravelingMerchentRemote
    LocalPlayer:RequestStreamAroundAsync(targetCFrame.Position); RootPart.CFrame = targetCFrame
    task.spawn(function()
        for i = 1, 40 do
            task.spawn(function() pcall(function() Remote:InvokeServer("OpenShop") end) end)
            for itemName, _ in pairs(SelectedItems) do task.spawn(function() pcall(function() Remote:InvokeServer(itemName) end) end) end
            task.wait(0.01)
        end
    end)
    task.wait(0.8); RootPart.CFrame = originalCFrame
end)


task.spawn(function()
    while _G.HubActive do
        pcall(function()
            local hBars = LocalPlayer.PlayerGui:FindFirstChild("healthbars")
            if hBars then
                for _, child in pairs(hBars:GetDescendants()) do
                    if child.Name == "NameT" and child.Text ~= ".gg/EndardHub" then
                        if child.Parent.Name == LocalPlayer.Name or child.Parent:FindFirstChild(LocalPlayer.Name) then child.Text = ".gg/EndardHub" end
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end)

local function applyESP(npc)
    if not _G.BossESP or npc:FindFirstChild("ESP_Marker") then return end
    local marker = Instance.new("StringValue", npc); marker.Name = "ESP_Marker"
    local hl = Instance.new("Highlight", npc); hl.Name = "ESP_Highlight"; hl.FillColor = Color3.fromRGB(255, 0, 0); hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    local root = npc:FindFirstChild("HumanoidRootPart")
    if root then
        local bg = Instance.new("BillboardGui", root); bg.Name = "ESP_Name"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 100, 0, 40); bg.StudsOffset = Vector3.new(0, 3, 0)
        local lbl = Instance.new("TextLabel", bg); lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1,0,1,0); lbl.Text = npc.Name; lbl.TextColor3 = Color3.new(1,1,1); lbl.Font = Enum.Font.GothamBold; lbl.TextScaled = true
    end
    task.spawn(function()
        while npc.Parent and _G.BossESP do hl.OutlineColor = Color3.fromHSV(tick()%5/5, 1, 1) task.wait(0.1) end
        if hl then hl:Destroy() end if npc:FindFirstChild("ESP_Name") then npc.ESP_Name:Destroy() end
    end)
end

task.spawn(function()
    while task.wait(1) do
        if _G.HubActive and _G.BossESP and NPCsFolder then
            for _, npc in pairs(NPCsFolder:GetChildren()) do if targetNames[npc.Name] then applyESP(npc) end end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, proc)
    if proc then return end
    if input.KeyCode == Enum.KeyCode.CapsLock and updateAimToggle then updateAimToggle(not _G.AutoAim)
    elseif input.KeyCode == Enum.KeyCode.N then MainFrame.Visible = not MainFrame.Visible end
end)

CloseBtn.MouseButton1Click:Connect(function()
    _G.HubActive = false; _G.AutoAim = false; _G.BossESP = false; ScreenGui:Destroy()
end)

RunService.RenderStepped:Connect(function()
    if not _G.HubActive or not _G.AutoAim or not NPCsFolder then return end
    local dist, target = math.huge, nil
    for _, npc in pairs(NPCsFolder:GetChildren()) do
        if targetNames[npc.Name] and npc.Name ~= "Robo" and npc:FindFirstChild("HumanoidRootPart") then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local d = (npc.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d; target = npc end
            end
        end
    end
    if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.HumanoidRootPart.Position) end
end)
