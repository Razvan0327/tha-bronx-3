--[[
    Tha Bronx 3 - Synapse-Xenon Premium
    Luarmor Compatible Script
    Self-contained UI - no external libraries needed
    Compatible with: Xeno, Solara, Fluxus, Delta, and all executors
]]

------------------------------------------------------------
-- Executor Compatibility Layer
------------------------------------------------------------
if not task then
    task = {
        wait = function(t) return wait(t or 0) end,
        spawn = function(f, ...) return coroutine.wrap(f)(...) end,
        defer = function(f, ...) return coroutine.wrap(f)(...) end,
        delay = function(t, f) return delay(t, f) end,
    }
end

if not firetouchinterest then
    firetouchinterest = function(p1, p2, t)
        if t == 0 then
            local old = p1.CFrame
            p1.CFrame = p2.CFrame
            task.wait()
            p1.CFrame = old
        end
    end
end

local DrawingSupported = pcall(function() local _ = Drawing.new("Circle") end)
if not DrawingSupported then
    Drawing = Drawing or {}
    Drawing.new = Drawing.new or function()
        return setmetatable({}, {
            __index = function(s, k) return rawget(s, k) end,
            __newindex = function(s, k, v) rawset(s, k, v) end,
        })
    end
end

if not isfile then isfile = function() return false end end
if not readfile then readfile = function() return "{}" end end
if not writefile then writefile = function() end end
if not makefolder then makefolder = function() end end
if not isfolder then isfolder = function() return false end end
if not listfiles then listfiles = function() return {} end end
if not setclipboard then setclipboard = function() end end
if not getgenv then getgenv = function() return _G end end
if not hookmetamethod then hookmetamethod = function() end end
if not newcclosure then newcclosure = function(f) return f end end

------------------------------------------------------------
-- Anti-Detection
------------------------------------------------------------
local function randomName(len)
    local c = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local n = ""
    for i = 1, (len or 12) do
        local idx = math.random(1, #c)
        n = n .. c:sub(idx, idx)
    end
    return n
end

pcall(function()
    if typeof(hookmetamethod) == "function" then
        local oldIdx
        oldIdx = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if not checkcaller() then
                if key == "WalkSpeed" and self:IsA("Humanoid") then return 16 end
                if key == "JumpPower" and self:IsA("Humanoid") then return 50 end
            end
            return oldIdx(self, key)
        end))
    end
end)

pcall(function()
    if typeof(hookmetamethod) == "function" then
        local oldNc
        oldNc = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
                local nm = self.Name:lower()
                if nm:find("anticheat") or nm:find("detect") or nm:find("exploit") or nm:find("kick") or nm:find("ban") or nm:find("security") then
                    if method == "FireServer" or method == "InvokeServer" then return nil end
                end
            end
            return oldNc(self, ...)
        end))
    end
end)

pcall(function()
    task.spawn(function()
        for _, obj in ipairs(game:GetDescendants()) do
            pcall(function()
                if (obj:IsA("LocalScript") or obj:IsA("ModuleScript")) then
                    local nm = obj.Name:lower()
                    if nm:find("anticheat") or nm:find("anti_cheat") or nm:find("exploit") or nm:find("detect") then
                        obj.Disabled = true
                        obj:Destroy()
                    end
                end
            end)
        end
    end)
end)

------------------------------------------------------------
-- Services
------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LP:GetMouse()

------------------------------------------------------------
-- Config
------------------------------------------------------------
local Config = {
    Main = {
        SelectedPlayer = nil, NoClip = false, Speed = false, SpeedAmount = 0,
        Fly = false, FlySpeedAmount = 7, JumpPower = false, JumpPowerAmount = 100,
    },
    Money = {
        AutoFarmConstruction = false, AutoFarmBank = false, AutoFarmHouse = false,
        AutoFarmStudio = false, AutoFarmDumpsters = false,
        MoneyAmount = 0, SelectedBankAction = "Deposit",
        AutoDeposit = false, AutoWithdraw = false, AutoDrop = false,
    },
    Misc = {
        InfiniteStamina = false, InstantRespawn = false, InfiniteSleep = false,
        InfiniteHunger = false, InstantInteract = false, AutoPickupCash = false,
        DisableBloodEffects = false, UnlockLockedCars = false, NoRentPay = false,
        NoFallDamage = false, RespawnWhereDied = false,
        TeleportLocation = "Basketball Court", SelectedOutfit = "Amiri Outfit",
    },
    Combat = {
        Aimlock = {
            Enabled = false, TargetParts = "Head", MaxDistance = 50,
            Smoothness = 50, FOVEnabled = false, FOVRadius = 50,
        },
    },
    Visuals = {
        EnableESP = false, Chams = false, Distance = false,
        MaxDistance = 2000, FillTransparency = 50, OutlineTransparency = 50,
    },
}

------------------------------------------------------------
-- Built-in UI System (no external library)
------------------------------------------------------------
local SG = Instance.new("ScreenGui")
SG.Name = randomName(16)
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Protect and parent GUI
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(SG) end
end)
pcall(function()
    if gethui then SG.Parent = gethui() return end
end)
if not SG.Parent then
    pcall(function() SG.Parent = game:GetService("CoreGui") end)
end
if not SG.Parent then
    SG.Parent = LP:WaitForChild("PlayerGui")
end

-- Colors
local C = {
    bg = Color3.fromRGB(20, 20, 25),
    sidebar = Color3.fromRGB(25, 25, 32),
    tab = Color3.fromRGB(30, 30, 40),
    section = Color3.fromRGB(35, 35, 45),
    accent = Color3.fromRGB(0, 120, 255),
    text = Color3.fromRGB(220, 220, 220),
    dimText = Color3.fromRGB(140, 140, 150),
    toggleOff = Color3.fromRGB(50, 50, 60),
    toggleOn = Color3.fromRGB(0, 120, 255),
    input = Color3.fromRGB(40, 40, 50),
}

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = randomName(8)
MainFrame.Size = UDim2.new(0, 620, 0, 420)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
MainFrame.BackgroundColor3 = C.bg
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = SG

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = C.sidebar
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 300, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Synapse-Xenon  |  Premium User!"
TitleLabel.TextColor3 = C.accent
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 3)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = C.dimText
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = C.sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Content Area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -120, 1, -35)
Content.Position = UDim2.new(0, 120, 0, 35)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Content.Parent = MainFrame

-- Tab system
local tabs = {}
local tabButtons = {}
local currentTab = nil

local function createTabButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.Position = UDim2.new(0, 5, 0, 5 + (order - 1) * 36)
    btn.BackgroundColor3 = C.tab
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = C.dimText
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = Sidebar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    return btn
end

local function createTabPage()
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -10)
    scroll.Position = UDim2.new(0, 5, 0, 5)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = C.accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = false
    scroll.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scroll

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    padding.PaddingTop = UDim.new(0, 5)
    padding.Parent = scroll

    return scroll
end

local function switchTab(name)
    for n, page in pairs(tabs) do
        page.Visible = (n == name)
    end
    for n, btn in pairs(tabButtons) do
        if n == name then
            btn.BackgroundTransparency = 0
            btn.BackgroundColor3 = C.accent
            btn.TextColor3 = Color3.new(1, 1, 1)
        else
            btn.BackgroundTransparency = 1
            btn.TextColor3 = C.dimText
        end
    end
    currentTab = name
end

-- UI Element Builders
local function addSection(page, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. text
    lbl.TextColor3 = C.accent
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = page
    return lbl
end

local function addToggle(page, text, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundColor3 = C.section
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local togBg = Instance.new("Frame")
    togBg.Size = UDim2.new(0, 36, 0, 18)
    togBg.Position = UDim2.new(1, -46, 0.5, -9)
    togBg.BackgroundColor3 = default and C.toggleOn or C.toggleOff
    togBg.BorderSizePixel = 0
    togBg.Parent = frame

    local togCorner = Instance.new("UICorner")
    togCorner.CornerRadius = UDim.new(1, 0)
    togCorner.Parent = togBg

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.BorderSizePixel = 0
    circle.Parent = togBg

    local circCorner = Instance.new("UICorner")
    circCorner.CornerRadius = UDim.new(1, 0)
    circCorner.Parent = circle

    local state = default or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame

    btn.MouseButton1Click:Connect(function()
        state = not state
        togBg.BackgroundColor3 = state and C.toggleOn or C.toggleOff
        TweenService:Create(circle, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        if callback then callback(state) end
    end)

    return frame
end

local function addSlider(page, text, min, max, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundColor3 = C.section
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 20)
    valLbl.Position = UDim2.new(1, -55, 0, 2)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = C.accent
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 30)
    track.BackgroundColor3 = C.toggleOff
    track.BorderSizePixel = 0
    track.Parent = frame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 0, 20)
    sliderBtn.Position = UDim2.new(0, 0, 0, 22)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.Parent = frame

    local dragging = false

    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = UIS:GetMouseLocation()
            local absPos = track.AbsolutePosition.X
            local absSize = track.AbsoluteSize.X
            local pct = math.clamp((pos.X - absPos) / absSize, 0, 1)
            local val = math.floor(min + (max - min) * pct)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            valLbl.Text = tostring(val)
            if callback then callback(val) end
        end
    end)

    return frame
end

local function addButton(page, text, desc, callback, order)
    local frame = Instance.new("TextButton")
    frame.Size = UDim2.new(1, 0, 0, desc ~= "" and 38 or 30)
    frame.BackgroundColor3 = C.section
    frame.BorderSizePixel = 0
    frame.Text = ""
    frame.LayoutOrder = order
    frame.AutoButtonColor = false
    frame.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, desc ~= "" and 2 or 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    if desc ~= "" then
        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, -20, 0, 14)
        descLbl.Position = UDim2.new(0, 10, 0, 20)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = desc
        descLbl.TextColor3 = C.dimText
        descLbl.Font = Enum.Font.Gotham
        descLbl.TextSize = 10
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.Parent = frame
    end

    frame.MouseButton1Click:Connect(function()
        frame.BackgroundColor3 = C.accent
        task.delay(0.15, function()
            frame.BackgroundColor3 = C.section
        end)
        if callback then callback() end
    end)

    return frame
end

local function addDropdown(page, text, options, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundColor3 = C.section
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.ClipsDescendants = true
    frame.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, -10, 0, 30)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local selected = Instance.new("TextButton")
    selected.Size = UDim2.new(0.5, -10, 0, 24)
    selected.Position = UDim2.new(0.5, 0, 0, 3)
    selected.BackgroundColor3 = C.input
    selected.BorderSizePixel = 0
    selected.Text = default or options[1] or ""
    selected.TextColor3 = C.accent
    selected.Font = Enum.Font.Gotham
    selected.TextSize = 11
    selected.Parent = frame

    local selCorner = Instance.new("UICorner")
    selCorner.CornerRadius = UDim.new(0, 4)
    selCorner.Parent = selected

    local open = false

    selected.MouseButton1Click:Connect(function()
        open = not open
        if open then
            frame.Size = UDim2.new(1, 0, 0, 30 + #options * 24)
            for i, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Name = "opt_" .. i
                optBtn.Size = UDim2.new(0.5, -10, 0, 22)
                optBtn.Position = UDim2.new(0.5, 0, 0, 28 + (i) * 22)
                optBtn.BackgroundColor3 = C.input
                optBtn.BorderSizePixel = 0
                optBtn.Text = opt
                optBtn.TextColor3 = C.text
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextSize = 11
                optBtn.Parent = frame

                local oCorner = Instance.new("UICorner")
                oCorner.CornerRadius = UDim.new(0, 4)
                oCorner.Parent = optBtn

                optBtn.MouseButton1Click:Connect(function()
                    selected.Text = opt
                    open = false
                    frame.Size = UDim2.new(1, 0, 0, 30)
                    for _, c in ipairs(frame:GetChildren()) do
                        if c.Name:sub(1, 4) == "opt_" then c:Destroy() end
                    end
                    if callback then callback(opt) end
                end)
            end
        else
            frame.Size = UDim2.new(1, 0, 0, 30)
            for _, c in ipairs(frame:GetChildren()) do
                if c.Name:sub(1, 4) == "opt_" then c:Destroy() end
            end
        end
    end)

    return frame
end

------------------------------------------------------------
-- Create Tabs
------------------------------------------------------------
local tabOrder = {"Main", "Money", "Misc", "Combat", "Visuals", "Settings"}

for i, name in ipairs(tabOrder) do
    tabs[name] = createTabPage()
    tabButtons[name] = createTabButton(name, i)
    tabButtons[name].MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end

switchTab("Main")

------------------------------------------------------------
-- Close / Toggle
------------------------------------------------------------
local guiVisible = true
CloseBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    MainFrame.Visible = guiVisible
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        MainFrame.Visible = guiVisible
    end
end)

------------------------------------------------------------
-- MAIN TAB
------------------------------------------------------------
local o = 0
local function nextOrder() o = o + 1; return o end

-- Player options
o = 0
addSection(tabs.Main, "Player Options", nextOrder())

local playerNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then table.insert(playerNames, p.Name) end
end
addDropdown(tabs.Main, "Select Player", playerNames, nil, function(v) Config.Main.SelectedPlayer = v end, nextOrder())

addButton(tabs.Main, "Spectate Player", "", function()
    local t = Config.Main.SelectedPlayer
    if t then
        local p = Players:FindFirstChild(t)
        if p and p.Character and p.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = p.Character.Humanoid
        end
    end
end, nextOrder())

addButton(tabs.Main, "Stop Spectating", "", function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = LP.Character.Humanoid
    end
end, nextOrder())

addButton(tabs.Main, "Teleport To Player", "", function()
    local t = Config.Main.SelectedPlayer
    if t then
        local p = Players:FindFirstChild(t)
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
            end
        end
    end
end, nextOrder())

addButton(tabs.Main, "Bring Player", "", function()
    local t = Config.Main.SelectedPlayer
    if t then
        local p = Players:FindFirstChild(t)
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
            end
        end
    end
end, nextOrder())

addButton(tabs.Main, "Bug / Kill Player - Car", "", function() end, nextOrder())
addButton(tabs.Main, "Auto Kill Player - Gun", "", function() end, nextOrder())
addButton(tabs.Main, "Auto Ragdoll Player - Gun", "", function() end, nextOrder())
addButton(tabs.Main, "Down Player - Hold Gun", "", function() end, nextOrder())
addButton(tabs.Main, "Kill Player - Hold Gun", "", function() end, nextOrder())

addSection(tabs.Main, "Movement", nextOrder())
addToggle(tabs.Main, "No Clip", false, function(v) Config.Main.NoClip = v end, nextOrder())
addToggle(tabs.Main, "Speed", false, function(v) Config.Main.Speed = v end, nextOrder())
addSlider(tabs.Main, "Speed Amount", 0, 100, 0, function(v) Config.Main.SpeedAmount = v end, nextOrder())
addToggle(tabs.Main, "Fly", false, function(v) Config.Main.Fly = v end, nextOrder())
addSlider(tabs.Main, "Fly Speed Amount", 0, 50, 7, function(v) Config.Main.FlySpeedAmount = v end, nextOrder())
addToggle(tabs.Main, "Jump Power", false, function(v) Config.Main.JumpPower = v end, nextOrder())
addSlider(tabs.Main, "Jump Power Amount", 0, 500, 100, function(v) Config.Main.JumpPowerAmount = v end, nextOrder())

------------------------------------------------------------
-- MONEY TAB
------------------------------------------------------------
o = 0
addSection(tabs.Money, "Farming", nextOrder())
addToggle(tabs.Money, "Auto Farm Construction", false, function(v) Config.Money.AutoFarmConstruction = v end, nextOrder())
addToggle(tabs.Money, "Auto Farm Bank", false, function(v) Config.Money.AutoFarmBank = v end, nextOrder())
addToggle(tabs.Money, "Auto Farm House", false, function(v) Config.Money.AutoFarmHouse = v end, nextOrder())
addToggle(tabs.Money, "Auto Farm Studio", false, function(v) Config.Money.AutoFarmStudio = v end, nextOrder())
addToggle(tabs.Money, "Auto Farm Dumpsters", false, function(v) Config.Money.AutoFarmDumpsters = v end, nextOrder())

addSection(tabs.Money, "Vulnerability Section", nextOrder())
addButton(tabs.Money, "Generate Max Illegal Money Manual", "Requires Ice-Fruit Cup In Inventory!", function() end, nextOrder())
addButton(tabs.Money, "Generate Max Illegal Money Auto", "Need 5K To Do This!", function() end, nextOrder())

addSection(tabs.Money, "Bank Actions", nextOrder())
addDropdown(tabs.Money, "Bank Action", {"Deposit", "Withdraw", "Drop"}, "Deposit", function(v) Config.Money.SelectedBankAction = v end, nextOrder())
addButton(tabs.Money, "Apply Selected Bank Action", "", function() end, nextOrder())
addToggle(tabs.Money, "Auto Deposit", false, function(v) Config.Money.AutoDeposit = v end, nextOrder())
addToggle(tabs.Money, "Auto Withdraw", false, function(v) Config.Money.AutoWithdraw = v end, nextOrder())
addToggle(tabs.Money, "Auto Drop", false, function(v) Config.Money.AutoDrop = v end, nextOrder())

addSection(tabs.Money, "Duping Section", nextOrder())
addButton(tabs.Money, "Duplicate Current Item", "Can Take Few Tries!", function() end, nextOrder())

------------------------------------------------------------
-- MISC TAB
------------------------------------------------------------
o = 0
addSection(tabs.Misc, "Local Player Modifications", nextOrder())
addToggle(tabs.Misc, "Infinite Stamina", false, function(v) Config.Misc.InfiniteStamina = v end, nextOrder())
addToggle(tabs.Misc, "Instant Respawn", false, function(v) Config.Misc.InstantRespawn = v end, nextOrder())
addToggle(tabs.Misc, "Infinite Sleep", false, function(v) Config.Misc.InfiniteSleep = v end, nextOrder())
addToggle(tabs.Misc, "Infinite Hunger", false, function(v) Config.Misc.InfiniteHunger = v end, nextOrder())
addToggle(tabs.Misc, "Instant Interact", false, function(v) Config.Misc.InstantInteract = v end, nextOrder())
addToggle(tabs.Misc, "Auto Pickup Cash", false, function(v) Config.Misc.AutoPickupCash = v end, nextOrder())
addToggle(tabs.Misc, "Disable Blood Effects", false, function(v) Config.Misc.DisableBloodEffects = v end, nextOrder())
addToggle(tabs.Misc, "Unlock Locked Cars", false, function(v) Config.Misc.UnlockLockedCars = v end, nextOrder())
addToggle(tabs.Misc, "No Rent Pay", false, function(v) Config.Misc.NoRentPay = v end, nextOrder())
addToggle(tabs.Misc, "No Fall Damage", false, function(v) Config.Misc.NoFallDamage = v end, nextOrder())
addToggle(tabs.Misc, "Respawn Where You Died", false, function(v) Config.Misc.RespawnWhereDied = v end, nextOrder())

addSection(tabs.Misc, "Teleport To Location", nextOrder())
addDropdown(tabs.Misc, "Location", {
    "Basketball Court", "Gun Store", "Bank", "Hospital",
    "Police Station", "Car Dealer", "Studio", "Apartments",
    "Gas Station", "Clothing Store", "Barber Shop",
}, "Basketball Court", function(v) Config.Misc.TeleportLocation = v end, nextOrder())
addButton(tabs.Misc, "Teleport", "", function() end, nextOrder())

addSection(tabs.Misc, "Outfits", nextOrder())
addDropdown(tabs.Misc, "Select Outfit", {"Amiri Outfit", "Nike Tech", "Bape Set", "Default"}, "Amiri Outfit", function(v) Config.Misc.SelectedOutfit = v end, nextOrder())
addButton(tabs.Misc, "Apply Selected Outfit", "", function() end, nextOrder())

------------------------------------------------------------
-- COMBAT TAB
------------------------------------------------------------
o = 0
addSection(tabs.Combat, "Aimlock", nextOrder())
addToggle(tabs.Combat, "Aimlock Enabled", false, function(v) Config.Combat.Aimlock.Enabled = v end, nextOrder())
addDropdown(tabs.Combat, "Target Parts", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, "Head", function(v) Config.Combat.Aimlock.TargetParts = v end, nextOrder())
addSlider(tabs.Combat, "Max Distance %", 0, 100, 50, function(v) Config.Combat.Aimlock.MaxDistance = v end, nextOrder())
addSlider(tabs.Combat, "Smoothness %", 0, 100, 50, function(v) Config.Combat.Aimlock.Smoothness = v end, nextOrder())

addSection(tabs.Combat, "FOV Settings", nextOrder())
addToggle(tabs.Combat, "FOV Enabled", false, function(v) Config.Combat.Aimlock.FOVEnabled = v end, nextOrder())
addSlider(tabs.Combat, "FOV Radius %", 0, 100, 50, function(v) Config.Combat.Aimlock.FOVRadius = v end, nextOrder())

------------------------------------------------------------
-- VISUALS TAB
------------------------------------------------------------
o = 0
addSection(tabs.Visuals, "ESP", nextOrder())
addToggle(tabs.Visuals, "Enable ESP", false, function(v) Config.Visuals.EnableESP = v end, nextOrder())
addToggle(tabs.Visuals, "Chams (Highlight)", false, function(v) Config.Visuals.Chams = v end, nextOrder())
addToggle(tabs.Visuals, "Show Distance", false, function(v) Config.Visuals.Distance = v end, nextOrder())
addSlider(tabs.Visuals, "Max Distance", 0, 5000, 2000, function(v) Config.Visuals.MaxDistance = v end, nextOrder())
addSlider(tabs.Visuals, "Fill Transparency %", 0, 100, 50, function(v) Config.Visuals.FillTransparency = v end, nextOrder())
addSlider(tabs.Visuals, "Outline Transparency %", 0, 100, 50, function(v) Config.Visuals.OutlineTransparency = v end, nextOrder())

------------------------------------------------------------
-- SETTINGS TAB
------------------------------------------------------------
o = 0
addSection(tabs.Settings, "UI Settings", nextOrder())
addButton(tabs.Settings, "Destroy GUI", "Completely removes the script UI", function()
    SG:Destroy()
end, nextOrder())
addButton(tabs.Settings, "Toggle: RightShift", "Press RightShift to show/hide", function() end, nextOrder())

------------------------------------------------------------
-- CORE LOOPS
------------------------------------------------------------

-- NoClip
RunService.Stepped:Connect(function()
    pcall(function()
        if Config.Main.NoClip and LP.Character then
            for _, p in ipairs(LP.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end)

-- Speed (CFrame-based)
RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        if Config.Main.Speed and LP.Character then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            local hum = LP.Character:FindFirstChild("Humanoid")
            if hrp and hum then
                local dir = hum.MoveDirection
                if dir.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + Vector3.new(dir.X, 0, dir.Z) * Config.Main.SpeedAmount * dt
                end
            end
        end
    end)
end)

-- Jump Power
RunService.Heartbeat:Connect(function()
    pcall(function()
        if Config.Main.JumpPower and LP.Character then
            local hum = LP.Character:FindFirstChild("Humanoid")
            if hum then
                hum.JumpPower = Config.Main.JumpPowerAmount
                hum.UseJumpPower = true
            end
        end
    end)
end)

-- Fly (CFrame-based)
RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        if Config.Main.Fly and LP.Character then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            local hum = LP.Character:FindFirstChild("Humanoid")
            if hrp and hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
                local speed = Config.Main.FlySpeedAmount * 10
                local dir = Vector3.new(0, 0, 0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                if dir.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + (dir.Unit * speed * dt)
                end
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        else
            pcall(function()
                if LP.Character then
                    local hum = LP.Character:FindFirstChild("Humanoid")
                    if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true) end
                end
            end)
        end
    end)
end)

-- ESP System
local espObjects = {}

local function createESP(player)
    if player == LP then return end
    local data = {}

    local hl = Instance.new("Highlight")
    hl.Name = randomName(16)
    hl.FillColor = Color3.fromRGB(0, 120, 255)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = Config.Visuals.FillTransparency / 100
    hl.OutlineTransparency = Config.Visuals.OutlineTransparency / 100
    hl.Enabled = false
    data.Highlight = hl

    local bb = Instance.new("BillboardGui")
    bb.Name = randomName(16)
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Enabled = false

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 0.5, 0)
    nl.BackgroundTransparency = 1
    nl.TextColor3 = Color3.new(1, 1, 1)
    nl.TextStrokeTransparency = 0.5
    nl.Font = Enum.Font.GothamBold
    nl.TextSize = 13
    nl.Text = player.Name
    nl.Parent = bb

    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1, 0, 0.5, 0)
    dl.Position = UDim2.new(0, 0, 0.5, 0)
    dl.BackgroundTransparency = 1
    dl.TextColor3 = Color3.fromRGB(200, 200, 200)
    dl.TextStrokeTransparency = 0.5
    dl.Font = Enum.Font.Gotham
    dl.TextSize = 11
    dl.Text = ""
    dl.Parent = bb

    data.Billboard = bb
    data.DistLabel = dl
    espObjects[player] = data

    local function onChar(char)
        pcall(function()
            hl.Adornee = char
            hl.Parent = char
            local head = char:WaitForChild("Head", 5)
            if head then bb.Parent = head end
        end)
    end

    if player.Character then task.spawn(function() onChar(player.Character) end) end
    player.CharacterAdded:Connect(onChar)
end

local function removeESP(player)
    local d = espObjects[player]
    if d then
        pcall(function() if d.Highlight then d.Highlight:Destroy() end end)
        pcall(function() if d.Billboard then d.Billboard:Destroy() end end)
        espObjects[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

-- ESP Update
RunService.RenderStepped:Connect(function()
    pcall(function()
        for player, data in pairs(espObjects) do
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local lhrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

            if Config.Visuals.EnableESP and char and hrp and lhrp then
                local dist = (hrp.Position - lhrp.Position).Magnitude
                if dist <= Config.Visuals.MaxDistance then
                    data.Highlight.Enabled = Config.Visuals.Chams
                    data.Highlight.FillTransparency = Config.Visuals.FillTransparency / 100
                    data.Highlight.OutlineTransparency = Config.Visuals.OutlineTransparency / 100
                    data.Billboard.Enabled = true
                    data.DistLabel.Text = Config.Visuals.Distance and string.format("[%d studs]", math.floor(dist)) or ""
                else
                    data.Highlight.Enabled = false
                    data.Billboard.Enabled = false
                end
            else
                if data.Highlight then data.Highlight.Enabled = false end
                if data.Billboard then data.Billboard.Enabled = false end
            end
        end
    end)
end)

-- Aimlock
local aimlockTarget = nil

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Config.Combat.Aimlock.Enabled then
        local closest, closestDist = nil, math.huge
        local mp = UIS:GetMouseLocation()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local part = p.Character:FindFirstChild(Config.Combat.Aimlock.TargetParts)
                if part then
                    local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d2 = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
                        local fov = (Config.Combat.Aimlock.FOVRadius / 100) * 300
                        if (not Config.Combat.Aimlock.FOVEnabled or d2 <= fov) and d2 < closestDist then
                            local lhrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                            if lhrp then
                                local d3 = (part.Position - lhrp.Position).Magnitude
                                if d3 <= (Config.Combat.Aimlock.MaxDistance / 100) * 1000 then
                                    closest = p
                                    closestDist = d2
                                end
                            end
                        end
                    end
                end
            end
        end
        aimlockTarget = closest
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then aimlockTarget = nil end
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        if Config.Combat.Aimlock.Enabled and aimlockTarget then
            local char = aimlockTarget.Character
            if char then
                local part = char:FindFirstChild(Config.Combat.Aimlock.TargetParts)
                if part then
                    local sm = 1 - (Config.Combat.Aimlock.Smoothness / 100) * 0.9
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), sm)
                end
            end
        end
    end)
end)

-- Auto Pickup Cash
RunService.Heartbeat:Connect(function()
    pcall(function()
        if Config.Misc.AutoPickupCash and LP.Character then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("cash") or obj.Name:lower():find("money") or obj.Name:lower():find("drop")) then
                        if (obj.Position - hrp.Position).Magnitude <= 50 then
                            firetouchinterest(hrp, obj, 0)
                            task.wait()
                            firetouchinterest(hrp, obj, 1)
                        end
                    end
                end
            end
        end
    end)
end)

-- No Fall Damage
RunService.Heartbeat:Connect(function()
    pcall(function()
        if Config.Misc.NoFallDamage and LP.Character then
            local hum = LP.Character:FindFirstChild("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end
        end
    end)
end)

print("[Synapse-Xenon] Tha Bronx 3 script fully loaded!")
