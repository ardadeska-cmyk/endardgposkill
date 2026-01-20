local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera


if _G.HubActive then
    _G.HubActive = false
    task.wait(0.2)
end

local OldGui = CoreGui:FindFirstChild("EndardHub_Modern")
if OldGui then OldGui:Destroy() end


_G.HubActive = true
_G.AutoAim = false 
_G.BossESP = true


_G.PlayerESP = false
_G.HealthESP = false
_G.WeaponESP = false
_G.StaminaESP = false

_G.MainColor = Color3.fromRGB(0, 255, 255) 
_G.SecColor = Color3.fromRGB(20, 20, 25)   
_G.CanToggle = false 

getgenv().AutoFishEnabled = false
getgenv().AutoFishNewEnabled = false
getgenv().FishSellEnabled = false
getgenv().AutoBuyEnabled = false
getgenv().FishTime = 21

local targetNames = {["Hawk Eye"] = true, ["Roger"] = true, ["Santa's Sleigh"] = true, ["Donmingo"] = true, ["Soul King"] = true, ["Juzo the Diamondback"] = true, ["Law"] = true}
local ItemsList = {"Special Tailor Token", "Crab Cutlass","Prodigy Sorcerer Costume","Lifa's Outfit","Raiui", "Knight's Gauntlet" ,"Hunter's Journal","Spare Fruit Bag","Merchants Banana Rod", "Kessui","Race Reroll", "Red Cloud Costume","SP Reset Essence","Coffin Boat", "Ten Tails Jinchuriki Costume", "Striker","Iceborn Headband","Legendary Fruit Chest", "Rare Fruit Chest", "Mythical Fruit Chest", "Rare Fish Bait", "Legendary Fish Bait", "Sorcerer Hunter Costume", "Powderpunk Outfit"}
local FishToSell = {"Blue-Lip Grouper", "Exotic Tigerfin", "Tigerfin", "Fangfish", "Zebra Ribbon Angelfish", "Crimson Snapper", "Crimson Polka Puffer"}

local SelectedItems = {}
local LockTarget = nil


local Library = {}
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EndardHub_Modern"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 

-
function Library:Notify(text, duration)
    local notifFrame = Instance.new("Frame", ScreenGui)
    notifFrame.Size = UDim2.new(0, 300, 0, 40)
    notifFrame.Position = UDim2.new(1, 20, 0.85, 0)
    notifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    notifFrame.BorderSizePixel = 0
    
    local stroke = Instance.new("UIStroke", notifFrame)
    stroke.Color = _G.MainColor
    stroke.Thickness = 1
    
    local corner = Instance.new("UICorner", notifFrame); corner.CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel", notifFrame)
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -320, 0.85, 0)}):Play()
    
    task.delay(duration or 3, function()
        TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(1, 20, 0.85, 0)}):Play()
        task.wait(0.5)
        notifFrame:Destroy()
    end)
end


local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 700, 0, 450)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
MainFrame.BackgroundColor3 = _G.SecColor
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Shadow = Instance.new("ImageLabel", MainFrame)
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1, 120, 1, 120)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6015897843"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ZIndex = -1


local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Text = "EndardHub <font color=\"rgb(0,255,255)\">v2</font>"
Title.RichText = true
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left


local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
TopBar.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)


local SideBar = Instance.new("Frame", MainFrame)
SideBar.Position = UDim2.new(0, 0, 0, 40)
SideBar.Size = UDim2.new(0, 160, 1, -40)
SideBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
SideBar.BorderSizePixel = 0
local SideCorner = Instance.new("UICorner", SideBar); SideCorner.CornerRadius = UDim.new(0, 10)
local SideHide = Instance.new("Frame", SideBar); SideHide.Size = UDim2.new(1,0,0,20); SideHide.Position = UDim2.new(0,0,0,-10); SideHide.BorderSizePixel=0; SideHide.BackgroundColor3=SideBar.BackgroundColor3

local TabContainer = Instance.new("Frame", SideBar)
TabContainer.Size = UDim2.new(1, -20, 1, -20)
TabContainer.Position = UDim2.new(0, 10, 0, 10)
TabContainer.BackgroundTransparency = 1
local TabListLayout = Instance.new("UIListLayout", TabContainer); TabListLayout.Padding = UDim.new(0, 8)


local Pages = Instance.new("Frame", MainFrame)
Pages.Position = UDim2.new(0, 170, 0, 50)
Pages.Size = UDim2.new(1, -180, 1, -60)
Pages.BackgroundTransparency = 1

local ActiveTab = nil

function Library:CreateTab(name)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TabBtn.Text = "    " .. name
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 13
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.AutoButtonColor = false
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Indicator = Instance.new("Frame", TabBtn)
    Indicator.Size = UDim2.new(0, 3, 0.6, 0)
    Indicator.Position = UDim2.new(0, 0, 0.2, 0)
    Indicator.BackgroundColor3 = _G.MainColor
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Instance.new("UICorner", Indicator)

    local PageFrame = Instance.new("ScrollingFrame", Pages)
    PageFrame.Size = UDim2.new(1, 0, 1, 0)
    PageFrame.BackgroundTransparency = 1
    PageFrame.ScrollBarThickness = 2
    PageFrame.ScrollBarImageColor3 = _G.MainColor
    PageFrame.Visible = false
    PageFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    local PageList = Instance.new("UIListLayout", PageFrame); PageList.Padding = UDim.new(0, 6)
    PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() PageFrame.CanvasSize = UDim2.new(0,0,0,PageList.AbsoluteContentSize.Y + 10) end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, child in pairs(TabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 30), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                child:FindFirstChild("Frame").Visible = false
            end
        end
        for _, p in pairs(Pages:GetChildren()) do p.Visible = false end
        
        TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(35, 35, 40), TextColor3 = Color3.new(1,1,1)}):Play()
        Indicator.Visible = true
        PageFrame.Visible = true
        ActiveTab = PageFrame
    end)

    if ActiveTab == nil then
        ActiveTab = PageFrame
        PageFrame.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        TabBtn.TextColor3 = Color3.new(1,1,1)
        Indicator.Visible = true
    end

    return PageFrame
end

function Library:CreateToggle(parent, text, default, callback)
    local Container = Instance.new("Frame", parent)
    Container.Size = UDim2.new(1, -10, 0, 40)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)
    
    local Title = Instance.new("TextLabel", Container)
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = text
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamSemibold
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local SwitchBg = Instance.new("Frame", Container)
    SwitchBg.Size = UDim2.new(0, 40, 0, 20)
    SwitchBg.Position = UDim2.new(1, -55, 0.5, -10)
    SwitchBg.BackgroundColor3 = default and _G.MainColor or Color3.fromRGB(50, 50, 55)
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame", SwitchBg)
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Circle.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""

    local toggled = default
    Btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        local targetPos = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local targetColor = toggled and _G.MainColor or Color3.fromRGB(50, 50, 55)
        
        TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = targetPos}):Play()
        TweenService:Create(SwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
        callback(toggled)
    end)
end

function Library:CreateSlider(parent, text, min, max, default, callback)
    local Container = Instance.new("Frame", parent)
    Container.Size = UDim2.new(1, -10, 0, 55)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)
    
    local Title = Instance.new("TextLabel", Container)
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = text .. ": " .. default
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamSemibold
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local BarBg = Instance.new("Frame", Container)
    BarBg.Size = UDim2.new(0.9, 0, 0, 4)
    BarBg.Position = UDim2.new(0.05, 0, 0.7, 0)
    BarBg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    Instance.new("UICorner", BarBg)

    local Fill = Instance.new("Frame", BarBg)
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = _G.MainColor
    Instance.new("UICorner", Fill)

    local Trigger = Instance.new("TextButton", BarBg)
    Trigger.Size = UDim2.new(1, 0, 5, 0)
    Trigger.Position = UDim2.new(0, 0, -2, 0)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""

    local dragging = false
    Trigger.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((i.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            Title.Text = text .. ": " .. val
            TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
            callback(val)
        end
    end)
end

function Library:CreateButton(parent, text, color, callback)
    local Container = Instance.new("Frame", parent)
    Container.Size = UDim2.new(1, -10, 0, 40)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = text
    Btn.TextColor3 = color or Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13

    Btn.MouseEnter:Connect(function() TweenService:Create(Container, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play() end)
    Btn.MouseLeave:Connect(function() TweenService:Create(Container, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play() end)
    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Container, TweenInfo.new(0.1), {Size = UDim2.new(0.95, -10, 0, 35)}):Play()
        task.wait(0.1)
        TweenService:Create(Container, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, 40)}):Play()
        callback()
    end)
end


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

-- BOSS ESP
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


task.spawn(function()
    while _G.HubActive do
        
        if _G.PlayerESP or _G.HealthESP or _G.WeaponESP or _G.StaminaESP then
            pcall(function()
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer then
                        
                        local char = nil
                        if workspace:FindFirstChild("PlayerCharacters") and workspace.PlayerCharacters:FindFirstChild(plr.Name) then
                            char = workspace.PlayerCharacters[plr.Name]
                        elseif plr.Character then
                            char = plr.Character
                        end
                        
                        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                            local hrp = char.HumanoidRootPart
                            local hum = char.Humanoid
                            
                            
                            local espTag = char:FindFirstChild("EndardVisuals")
                            if not espTag then
                                espTag = Instance.new("BillboardGui", char)
                                espTag.Name = "EndardVisuals"
                                espTag.Size = UDim2.new(0, 200, 0, 150)
                                espTag.AlwaysOnTop = true
                                espTag.ExtentsOffset = Vector3.new(0, 1, 0)

                                local container = Instance.new("Frame", espTag)
                                container.Size = UDim2.new(1, 0, 1, 0)
                                container.BackgroundTransparency = 1
                                
                                local layout = Instance.new("UIListLayout", container)
                                layout.SortOrder = Enum.SortOrder.LayoutOrder
                                layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                                layout.Padding = UDim.new(0, 2)
                                
                                
                                local nameLbl = Instance.new("TextLabel", container)
                                nameLbl.Name = "NameLbl"
                                nameLbl.Size = UDim2.new(1,0,0,15)
                                nameLbl.BackgroundTransparency = 1
                                nameLbl.TextColor3 = Color3.new(1,1,1)
                                nameLbl.TextStrokeTransparency = 0.5
                                nameLbl.Font = Enum.Font.GothamBold
                                nameLbl.TextSize = 14
                                nameLbl.LayoutOrder = 1
                                nameLbl.Visible = false

                                
                                local hpFrame = Instance.new("Frame", container)
                                hpFrame.Name = "HpFrame"
                                hpFrame.Size = UDim2.new(1,0,0,15)
                                hpFrame.BackgroundTransparency = 1
                                hpFrame.LayoutOrder = 2
                                hpFrame.Visible = false
                                
                                local hpText = Instance.new("TextLabel", hpFrame)
                                hpText.Name = "Value"
                                hpText.Size = UDim2.new(1,0,1,0)
                                hpText.BackgroundTransparency = 1
                                hpText.TextColor3 = Color3.fromRGB(0, 255, 0)
                                hpText.TextStrokeTransparency = 0.5
                                hpText.Font = Enum.Font.GothamBold
                                hpText.TextSize = 13
                                hpText.Text = "HP: 100"

                                
                                local barBg = Instance.new("Frame", hpFrame)
                                barBg.Size = UDim2.new(0, 4, 1, 0)
                                barBg.Position = UDim2.new(0.2, 0, 0, 0)
                                barBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
                                barBg.BorderSizePixel = 0
                                
                                local barFill = Instance.new("Frame", barBg)
                                barFill.Name = "Fill"
                                barFill.Size = UDim2.new(1, 0, 1, 0)
                                barFill.Position = UDim2.new(0,0,1,0)
                                barFill.AnchorPoint = Vector2.new(0,1)
                                barFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                                barFill.BorderSizePixel = 0

                                -- 3. WEAPON LABEL
                                local wpLbl = Instance.new("TextLabel", container)
                                wpLbl.Name = "WeaponLbl"
                                wpLbl.Size = UDim2.new(1,0,0,15)
                                wpLbl.BackgroundTransparency = 1
                                wpLbl.TextColor3 = Color3.fromRGB(255, 255, 0)
                                wpLbl.TextStrokeTransparency = 0.5
                                wpLbl.Font = Enum.Font.GothamSemibold
                                wpLbl.TextSize = 13
                                wpLbl.LayoutOrder = 3
                                wpLbl.Visible = false

                                
                                local staLbl = Instance.new("TextLabel", container)
                                staLbl.Name = "StaminaLbl"
                                staLbl.Size = UDim2.new(1,0,0,15)
                                staLbl.BackgroundTransparency = 1
                                staLbl.TextColor3 = Color3.fromRGB(0, 255, 255)
                                staLbl.TextStrokeTransparency = 0.5
                                staLbl.Font = Enum.Font.GothamSemibold
                                staLbl.TextSize = 13
                                staLbl.LayoutOrder = 4
                                staLbl.Visible = false
                            end

                            
                            local container = espTag:FindFirstChild("Frame")
                            if container then
                                
                                local nLbl = container:FindFirstChild("NameLbl")
                                if _G.PlayerESP then
                                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                                    nLbl.Text = plr.Name .. " (" .. dist .. " studs)"
                                    nLbl.Visible = true
                                else
                                    nLbl.Visible = false
                                end

                                
                                local hpFrame = container:FindFirstChild("HpFrame")
                                if _G.HealthESP then
                                    hpFrame.Visible = true
                                    local curHp = math.floor(hum.Health)
                                    local maxHp = hum.MaxHealth
                                    local hpText = hpFrame:FindFirstChild("Value")
                                    local barFill = hpFrame:FindFirstChild("Frame"):FindFirstChild("Fill")
                                    
                                    hpText.Text = "HP: " .. curHp
                                    local scale = math.clamp(curHp / maxHp, 0, 1)
                                    barFill.Size = UDim2.new(1, 0, scale, 0)
                                    
                                    barFill.BackgroundColor3 = Color3.fromHSV(scale * 0.3, 1, 1) 
                                else
                                    hpFrame.Visible = false
                                end

                               
                                local wLbl = container:FindFirstChild("WeaponLbl")
                                if _G.WeaponESP then
                                    wLbl.Visible = true
                                    local toolName = "None"
                                    
                                    for _, item in pairs(char:GetChildren()) do
                                        if item:IsA("Tool") then
                                            toolName = item.Name
                                            break 
                                        end
                                    end
                                    wLbl.Text = "Gun: " .. toolName
                                else
                                    wLbl.Visible = false
                                end

                                
                                local sLbl = container:FindFirstChild("StaminaLbl")
                                if _G.StaminaESP then
                                    sLbl.Visible = true
                                    local val = 0
                                    
                                    local statsFolder = ReplicatedStorage:FindFirstChild("Stats" .. plr.Name)
                                    if statsFolder and statsFolder:FindFirstChild("Stats") and statsFolder:FindFirstChild("Stamina") then
                                        val = statsFolder.Stamina.Value
                                    end
                                    sLbl.Text = "Sta: " .. val
                                else
                                    sLbl.Visible = false
                                end
                            end
                        elseif char and char:FindFirstChild("EndardVisuals") then
                             
                             char.EndardVisuals:Destroy()
                        end
                    end
                end
            end)
        else
            
            pcall(function()
                for _, plr in pairs(Players:GetPlayers()) do
                    local char = workspace:FindFirstChild("PlayerCharacters") and workspace.PlayerCharacters:FindFirstChild(plr.Name) or plr.Character
                    if char and char:FindFirstChild("EndardVisuals") then
                        char.EndardVisuals:Destroy()
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)


local FlySpeed = 120
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

local function GetClosestBoss()
    local dist, target = 800, nil
    local npcFolder = workspace:FindFirstChild("NPCs")
    if npcFolder then for _, npc in pairs(npcFolder:GetChildren()) do if targetNames[npc.Name] and npc:FindFirstChild("HumanoidRootPart") then local d = (npc.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude; if d < dist then dist = d; target = npc end end end end
    return target
end


local FarmPage = Library:CreateTab("Farming")
local MerchPage = Library:CreateTab("Merchant")
local VisualPage = Library:CreateTab("Visuals")
local SettingsPage = Library:CreateTab("Settings")


Library:CreateToggle(FarmPage, "Auto Aim (Lock Boss)", _G.AutoAim, function(v) 
    _G.AutoAim = v 
    if v then 
        LockTarget = GetClosestBoss()
        if LockTarget then Library:Notify("Locked: "..LockTarget.Name) else Library:Notify("Boss Bulunamadı") end
    else
        LockTarget = nil
        Library:Notify("Aim Unlocked")
    end
end)

Library:CreateToggle(FarmPage, "Auto Fish", false, function(v) 
    getgenv().AutoFishEnabled = v
    if v then task.spawn(function() while getgenv().AutoFishEnabled do runFishing(getgenv().FishTime, "AutoFishEnabled") task.wait(0.1) end end) end 
end)
Library:CreateSlider(FarmPage, "Fish Time (s)", 1, 30, 21, function(v) getgenv().FishTime = v end)
Library:CreateToggle(FarmPage, "Auto Sell Fish", false, function(v) 
    getgenv().FishSellEnabled = v; if v then task.spawn(function() while getgenv().FishSellEnabled do for _, f in pairs(FishToSell) do ReplicatedStorage.FishingShopRemote:InvokeServer({Fish = f, All = true, Method = "SellFish"}) end task.wait(2) end end) end 
end)
Library:CreateToggle(FarmPage, "Auto Buy Bait", false, function(v) 
    getgenv().AutoBuyEnabled = v; if v then task.spawn(function() while getgenv().AutoBuyEnabled do pcall(function() ReplicatedStorage.Events.Shop:InvokeServer(workspace.BuyableItems["Common Fish Bait"], 99) end) task.wait(60) end end) end 
end)

Library:CreateButton(FarmPage, "TP: Hawk Eye (Fly)", _G.MainColor, function() if isFlying then StopFlying() else StartFlying(TPTargets.HawkEye) end end)
Library:CreateButton(FarmPage, "TP: Juzo (Fly)", _G.MainColor, function() if isFlying then StopFlying() else StartFlying(TPTargets.Juzo) end end)
Library:CreateButton(FarmPage, "TP: Soul King (Fly)", _G.MainColor, function() if isFlying then StopFlying() else StartFlying(TPTargets.SoulKing) end end)
Library:CreateButton(FarmPage, "TP: Impel Base (Fly)", _G.MainColor, function() if isFlying then StopFlying() else StartFlying(TPTargets.ImpelBase) end end)


Library:CreateButton(MerchPage, "ÇALIŞTIR (Işınlan + 40x)", Color3.fromRGB(0, 180, 255), function()
    pcall(function()
        local comp = ReplicatedStorage.CompassGuider:FindFirstChild("Traveling Merchant")
        if not comp then Library:Notify("Merchant Bulunamadı!"); return end
        local RootPart = LocalPlayer.Character.HumanoidRootPart
        local target = (typeof(comp.Value) == "CFrame" and comp.Value) or CFrame.new(comp.Value)
        local original = RootPart.CFrame
        LocalPlayer:RequestStreamAroundAsync(target.Position)
        RootPart.CFrame = target
        task.spawn(function() for i = 1, 40 do task.spawn(function() ReplicatedStorage.Events.TravelingMerchentRemote:InvokeServer("OpenShop") end) for item, state in pairs(SelectedItems) do if state then task.spawn(function() ReplicatedStorage.Events.TravelingMerchentRemote:InvokeServer(item) end) end end task.wait(0.01) end end)
        task.wait(0.8); RootPart.CFrame = original
        Library:Notify("İşlem Tamamlandı")
    end)
end)
for _, item in pairs(ItemsList) do
    Library:CreateToggle(MerchPage, item, false, function(v) SelectedItems[item] = v end)
end


Library:CreateToggle(VisualPage, "Boss ESP", _G.BossESP, function(v) _G.BossESP = v end)

Library:CreateToggle(VisualPage, "Player ESP (Name)", _G.PlayerESP, function(v) _G.PlayerESP = v end)
Library:CreateToggle(VisualPage, "Health ESP (Bar + Text)", _G.HealthESP, function(v) _G.HealthESP = v end)
Library:CreateToggle(VisualPage, "Weapon ESP", _G.WeaponESP, function(v) _G.WeaponESP = v end)
Library:CreateToggle(VisualPage, "Stamina ESP", _G.StaminaESP, function(v) _G.StaminaESP = v end)


Library:CreateSlider(SettingsPage, "Menu Transparency", 0, 90, 0, function(v) MainFrame.BackgroundTransparency = v/100 end)
Library:CreateButton(SettingsPage, "UNLOAD HUB", Color3.fromRGB(200, 50, 50), function()
    _G.HubActive = false
    ScreenGui:Destroy()
end)


RunService.RenderStepped:Connect(function()
    if not _G.HubActive then return end
    if _G.AutoAim and LockTarget and LockTarget:FindFirstChild("HumanoidRootPart") then 
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, LockTarget.HumanoidRootPart.Position) 
    end
end)

UserInputService.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.N then 
        if MainFrame then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
    if not p and i.KeyCode == Enum.KeyCode.CapsLock then
        _G.AutoAim = not _G.AutoAim
        LockTarget = _G.AutoAim and GetClosestBoss() or nil
        Library:Notify(_G.AutoAim and (LockTarget and "Target: "..LockTarget.Name or "No Boss") or "Aim Unlocked")
    end
end)


task.spawn(function()
    _G.CanToggle = false
    
    
    local IntroBg = Instance.new("Frame", ScreenGui)
    IntroBg.Size = UDim2.new(1,0,1,0)
    IntroBg.BackgroundColor3 = Color3.new(0,0,0)
    IntroBg.BackgroundTransparency = 0.5 
    IntroBg.ZIndex = 999
    
    
    local Blur = Instance.new("BlurEffect", Lighting)
    Blur.Size = 24
    
    local IntroText = Instance.new("TextLabel", IntroBg)
    IntroText.Text = "EndardHub"
    IntroText.TextColor3 = _G.MainColor
    IntroText.Font = Enum.Font.GothamBlack
    IntroText.TextSize = 0
    IntroText.Size = UDim2.new(1,0,1,0)
    IntroText.BackgroundTransparency = 1
    IntroText.ZIndex = 1000
    
    
    TweenService:Create(IntroText, TweenInfo.new(1.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {TextSize = 90}):Play()
    task.wait(1.5)
    
    local stroke = Instance.new("UIStroke", IntroText)
    stroke.Thickness = 0
    stroke.Color = _G.MainColor
    stroke.Transparency = 0.5
    TweenService:Create(stroke, TweenInfo.new(0.5), {Thickness = 3}):Play()
    task.wait(0.5)
    
    
    TweenService:Create(IntroBg, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
    TweenService:Create(IntroText, TweenInfo.new(1), {TextTransparency = 1}):Play()
    TweenService:Create(stroke, TweenInfo.new(1), {Transparency = 1}):Play()
    TweenService:Create(Blur, TweenInfo.new(1), {Size = 0}):Play()
    
    MainFrame.Position = UDim2.new(0.5, -350, 1.2, 0)
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -350, 0.5, -225)}):Play()
    
    task.wait(1)
    IntroBg:Destroy()
    Blur:Destroy()
    _G.CanToggle = true
end)
