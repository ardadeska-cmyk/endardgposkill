
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera


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
_G.BossESP = true 
_G.HubActive = true


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EndardHub_Modern"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.Size = UDim2.new(0, 250, 0, 380)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke")
Stroke.Parent = MainFrame
Stroke.Color = Color3.fromRGB(60, 60, 65)
Stroke.Thickness = 1

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Text = "EndardHub"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = Title
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0.65, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Modern Edition"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.Position = UDim2.new(1, -30, 0, 10)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "Container"
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 15, 0, 60)
ContentContainer.Size = UDim2.new(1, -30, 1, -70)

local UIList = Instance.new("UIListLayout")
UIList.Parent = ContentContainer
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 10)



local function createToggle(text, defaultState, callback)
    local Wrapper = Instance.new("Frame")
    Wrapper.Size = UDim2.new(1, 0, 0, 40)
    Wrapper.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Wrapper.Parent = ContentContainer
    Instance.new("UICorner", Wrapper).CornerRadius = UDim.new(0, 8)
    
    local Label = Instance.new("TextLabel")
    Label.Parent = Wrapper
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local SwitchBg = Instance.new("TextButton")
    SwitchBg.Parent = Wrapper
    SwitchBg.Size = UDim2.new(0, 44, 0, 24)
    SwitchBg.Position = UDim2.new(1, -55, 0.5, -12)
    SwitchBg.BackgroundColor3 = defaultState and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(60, 60, 65)
    SwitchBg.Text = ""
    SwitchBg.AutoButtonColor = false
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Parent = SwitchBg
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = defaultState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local isOn = defaultState

    local function setToggle(newState)
        isOn = newState
        local targetPos = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local targetColor = isOn and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(60, 60, 65)
        
        TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
        TweenService:Create(SwitchBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
        
        callback(isOn)
    end

    SwitchBg.MouseButton1Click:Connect(function()
        setToggle(not isOn)
    end)
    
    return setToggle
end

local function createActionButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ContentContainer
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.AutoButtonColor = false
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -4, 0, 36)}):Play()
        task.wait(0.1)
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 40)}):Play()
        callback()
    end)
    return Btn
end

-- [[ MENÜ ELEMANLARI ]] --

local updateAimToggle = createToggle("Auto Aim", false, function(state)
    _G.AutoAim = state
end)

-- Boss ESP Artık defaultState = true (Otomatik Açık)
createToggle("Boss ESP", true, function(state)
    _G.BossESP = state
    if not state then
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "ESP_Marker" or v.Name == "ESP_Name" or v.ClassName == "BoxHandleAdornment" then v:Destroy() end
        end
    end
end)

createActionButton("Mihawk & Roger Tarama", function()
    local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local r = c:WaitForChild("HumanoidRootPart")
    local target = workspace:WaitForChild("Islands"):WaitForChild("Umi Island")
    local oldCF = r.CFrame
    c:PivotTo(target:GetPivot() * CFrame.new(0, 55, 0))
    task.wait(0.5)
    c:PivotTo(oldCF)
end)

createActionButton("Juzo Tarama", function()
    local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local r = c:WaitForChild("HumanoidRootPart")
    local target = workspace:WaitForChild("Islands"):WaitForChild("Turtleback Cave")
    local oldCF = r.CFrame
    c:PivotTo(target:GetPivot() * CFrame.new(0, 15, 0))
    task.wait(0.5)
    c:PivotTo(oldCF)
end)

-- [[ LOJİK ]] --

UserInputService.InputBegan:Connect(function(input, proc)
    if proc then return end
    if input.KeyCode == Enum.KeyCode.CapsLock then
        if updateAimToggle then updateAimToggle(not _G.AutoAim) end
    elseif input.KeyCode == Enum.KeyCode.N then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    _G.HubActive = false
    _G.AutoAim = false
    _G.BossESP = false
    ScreenGui:Destroy()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "ESP_Marker" or v.Name == "ESP_Name" or v.ClassName == "BoxHandleAdornment" then v:Destroy() end
    end
end)

local function createVisibleCross(root)
    local function createBar(size)
        local bar = Instance.new("BoxHandleAdornment")
        bar.Size = size; bar.AlwaysOnTop = true; bar.ZIndex = 10; bar.Adornee = root; bar.Transparency = 0.2; bar.Parent = root; bar.Name = "ESP_Cross_Part"
        return bar
    end
    return createBar(Vector3.new(18, 1.8, 1.8)), createBar(Vector3.new(1.8, 18, 1.8))
end

local function applyESP(npc)
    if not _G.BossESP or not npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("ESP_Marker") then return end
    local marker = Instance.new("StringValue", npc); marker.Name = "ESP_Marker"
    local hl = Instance.new("Highlight", npc); hl.Name = "ESP_Highlight"; hl.FillColor = Color3.fromRGB(255, 0, 0); hl.OutlineColor = Color3.fromRGB(255, 255, 255); hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    local root = npc.HumanoidRootPart
    local bg = Instance.new("BillboardGui", root); bg.Name = "ESP_Name"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 100, 0, 40); bg.StudsOffset = Vector3.new(0, 10, 0)
    local lbl = Instance.new("TextLabel", bg); lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1,0,1,0); lbl.Text = npc.Name; lbl.TextColor3 = Color3.new(1,1,1); lbl.Font = Enum.Font.GothamBold; lbl.TextScaled = true
    local b1, b2 = createVisibleCross(root)
    task.spawn(function()
        local h = 0
        while npc.Parent and _G.BossESP and marker.Parent do
            h = (h + 0.005) % 1
            local col = Color3.fromHSV(h, 1, 1)
            if b1 and b2 then b1.Color3 = col b2.Color3 = col end
            if hl then hl.OutlineColor = col end
            task.wait()
        end
        if b1 then b1:Destroy() end if b2 then b2:Destroy() end if hl then hl:Destroy() end if bg then bg:Destroy() end
    end)
end

task.spawn(function()
    while task.wait(1) do
        if _G.HubActive and _G.BossESP and NPCsFolder then
            for _, npc in pairs(NPCsFolder:GetChildren()) do
                if targetNames[npc.Name] then applyESP(npc) end
            end
        end
    end
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
