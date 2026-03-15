--[[
    Tha Bronx 3 - Synapse-Xenon Premium
    Luarmor Compatible | Works on all executors (Solara, Xeno, Fluxus, Delta)
    Custom built-in UI - no external library dependencies
]]

------------------------------------------------------------
-- Compatibility Layer
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
    firetouchinterest = function(part1, part2, toggle)
        if toggle == 0 then
            local oldCF = part1.CFrame
            part1.CFrame = part2.CFrame
            task.wait()
            part1.CFrame = oldCF
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

------------------------------------------------------------
-- Services
------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

------------------------------------------------------------
-- Config State
------------------------------------------------------------
local Config = {
    Main = {
        SelectedPlayer = nil, NoClip = false, Speed = false, SpeedAmount = 0,
        Fly = false, FlySpeedAmount = 7, JumpPower = false, JumpPowerAmount = 100,
    },
    Money = {
        AutoFarmConstruction = false, AutoFarmBank = false, AutoFarmHouse = false,
        AutoFarmStudio = false, AutoFarmDumpsters = false, MoneyAmount = 0,
        SelectedBankAction = "Deposit", AutoDeposit = false, AutoWithdraw = false, AutoDrop = false,
    },
    Misc = {
        InfiniteStamina = false, InstantRespawn = false, InfiniteSleep = false,
        InfiniteHunger = false, InstantInteract = false, AutoPickupCash = false,
        DisableBloodEffects = false, UnlockLockedCars = false, NoRentPay = false,
        NoFallDamage = false, RespawnWhereDied = false,
        SelectedItem = ".TecMag - $20", TeleportLocation = "Basketball Court", SelectedOutfit = "Amiri Outfit",
    },
    Combat = {
        Aimlock = {
            Enabled = false, VisibleCheck = false, AimlockType = "Mouse", TargetParts = "Head",
            MaxDistance = 50, Smoothness = 50, FOVEnabled = false, DrawCircle = false,
            FOVRadius = 50, FOVSides = 50, SnaplineEnabled = false, SnaplineThickness = 50,
        },
        SilentAim = {
            Enabled = false, VisibleCheck = false, AimlockType = "Mouse", TargetParts = "Head",
            MaxDistance = 50, Smoothness = 50, FOVEnabled = false, DrawCircle = false,
            FOVRadius = 50, FOVSides = 50, SnaplineEnabled = false, SnaplineThickness = 50,
        },
    },
    Visuals = {
        EnableESP = false, CornerFrameESP = false, BoxESP = false,
        HealthBar = false, HealthText = false, LerpHealthColor = false, GradientHealth = false,
        Distance = false, MaxDistance = 2000, Chams = false, ThermalEffect = false,
        VisibleCheck = false, FillTransparency = 50, OutlineTransparency = 50,
    },
}

------------------------------------------------------------
-- Custom UI Builder
------------------------------------------------------------
local COLORS = {
    bg = Color3.fromRGB(18, 18, 22),
    sidebar = Color3.fromRGB(22, 22, 28),
    topbar = Color3.fromRGB(22, 22, 28),
    card = Color3.fromRGB(28, 28, 35),
    accent = Color3.fromRGB(0, 120, 255),
    text = Color3.fromRGB(220, 220, 225),
    dimtext = Color3.fromRGB(140, 140, 150),
    toggle_off = Color3.fromRGB(55, 55, 65),
    toggle_on = Color3.fromRGB(0, 120, 255),
    slider_bg = Color3.fromRGB(45, 45, 55),
    input_bg = Color3.fromRGB(35, 35, 45),
    section_text = Color3.fromRGB(100, 100, 115),
    hover = Color3.fromRGB(35, 35, 45),
    border = Color3.fromRGB(40, 40, 50),
}

-- Protect GUI from game resets
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SynapseXenon"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
end)
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 680, 0, 480)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -240)
MainFrame.BackgroundColor3 = COLORS.bg
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = COLORS.border
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Make draggable
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y - MainFrame.AbsolutePosition.Y < 40 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

------------------------------------------------------------
-- Top Bar
------------------------------------------------------------
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = COLORS.topbar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

-- Fix bottom corners of topbar
local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 12)
TopBarFix.Position = UDim2.new(0, 0, 1, -12)
TopBarFix.BackgroundColor3 = COLORS.topbar
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

-- Brand
local BrandLabel = Instance.new("TextLabel")
BrandLabel.Size = UDim2.new(0, 200, 1, 0)
BrandLabel.Position = UDim2.new(0, 15, 0, 0)
BrandLabel.BackgroundTransparency = 1
BrandLabel.Font = Enum.Font.GothamBold
BrandLabel.TextSize = 15
BrandLabel.TextColor3 = COLORS.accent
BrandLabel.TextXAlignment = Enum.TextXAlignment.Left
BrandLabel.Text = "Synapse-Xenon"
BrandLabel.Parent = TopBar

local PremLabel = Instance.new("TextLabel")
PremLabel.Size = UDim2.new(0, 150, 1, 0)
PremLabel.Position = UDim2.new(0, 135, 0, 0)
PremLabel.BackgroundTransparency = 1
PremLabel.Font = Enum.Font.Gotham
PremLabel.TextSize = 11
PremLabel.TextColor3 = COLORS.dimtext
PremLabel.TextXAlignment = Enum.TextXAlignment.Left
PremLabel.Text = "Premium User!"
PremLabel.Parent = TopBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 38, 0, 38)
CloseBtn.Position = UDim2.new(1, -38, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = COLORS.dimtext
CloseBtn.Text = "X"
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

------------------------------------------------------------
-- Sidebar
------------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, -38)
Sidebar.Position = UDim2.new(0, 0, 0, 38)
Sidebar.BackgroundColor3 = COLORS.sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, 0, 0, 0)
SidebarLine.BackgroundColor3 = COLORS.border
SidebarLine.BorderSizePixel = 0
SidebarLine.Parent = Sidebar

------------------------------------------------------------
-- Content Area
------------------------------------------------------------
local ContentArea = Instance.new("Frame")
ContentArea.Name = "Content"
ContentArea.Size = UDim2.new(1, -131, 1, -38)
ContentArea.Position = UDim2.new(0, 131, 0, 38)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true
ContentArea.Parent = MainFrame

------------------------------------------------------------
-- Tab System
------------------------------------------------------------
local tabs = {}
local activeTab = nil
local tabButtons = {}

local function createScrollFrame(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -10)
    scroll.Position = UDim2.new(0, 5, 0, 5)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = COLORS.accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = scroll

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    padding.Parent = scroll

    return scroll
end

local function addTab(name, icon)
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = name
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = false
    tabFrame.Parent = ContentArea

    local scroll = createScrollFrame(tabFrame)

    -- Sidebar button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.Position = UDim2.new(0, 5, 0, 5 + (#tabs) * 37)
    btn.BackgroundColor3 = COLORS.sidebar
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextColor3 = COLORS.dimtext
    btn.Text = (icon or "") .. "  " .. name
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar

    local btnPad = Instance.new("UIPadding")
    btnPad.PaddingLeft = UDim.new(0, 12)
    btnPad.Parent = btn

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local tabData = { frame = tabFrame, scroll = scroll, btn = btn, name = name, order = 0 }
    table.insert(tabs, tabData)
    tabButtons[name] = tabData

    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do
            t.frame.Visible = false
            t.btn.BackgroundTransparency = 1
            t.btn.TextColor3 = COLORS.dimtext
        end
        tabFrame.Visible = true
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = COLORS.accent
        btn.TextColor3 = Color3.new(1, 1, 1)
        activeTab = name
    end)

    return tabData
end

-- UI Element builders
local function addSection(tab, text)
    local label = Instance.new("TextLabel")
    label.Name = "Section"
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = COLORS.section_text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.LayoutOrder = tab.order
    label.Parent = tab.scroll
    tab.order = tab.order + 1
end

local function addToggle(tab, text, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 34)
    holder.BackgroundColor3 = COLORS.card
    holder.BorderSizePixel = 0
    holder.LayoutOrder = tab.order
    holder.Parent = tab.scroll
    tab.order = tab.order + 1

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 6)
    hCorner.Parent = holder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = COLORS.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = holder

    local togBg = Instance.new("Frame")
    togBg.Size = UDim2.new(0, 38, 0, 20)
    togBg.Position = UDim2.new(1, -50, 0.5, -10)
    togBg.BackgroundColor3 = default and COLORS.toggle_on or COLORS.toggle_off
    togBg.BorderSizePixel = 0
    togBg.Parent = holder

    local togCorner = Instance.new("UICorner")
    togCorner.CornerRadius = UDim.new(1, 0)
    togCorner.Parent = togBg

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.BorderSizePixel = 0
    circle.Parent = togBg

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(1, 0)
    cCorner.Parent = circle

    local state = default or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = holder

    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(togBg, TweenInfo.new(0.2), { BackgroundColor3 = state and COLORS.toggle_on or COLORS.toggle_off }):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), { Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }):Play()
        if callback then callback(state) end
    end)

    return { SetState = function(_, v)
        state = v
        togBg.BackgroundColor3 = state and COLORS.toggle_on or COLORS.toggle_off
        circle.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    end }
end

local function addSlider(tab, text, min, max, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 50)
    holder.BackgroundColor3 = COLORS.card
    holder.BorderSizePixel = 0
    holder.LayoutOrder = tab.order
    holder.Parent = tab.scroll
    tab.order = tab.order + 1

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 6)
    hCorner.Parent = holder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 0, 22)
    lbl.Position = UDim2.new(0, 12, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = COLORS.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = holder

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 22)
    valLbl.Position = UDim2.new(1, -55, 0, 2)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 12
    valLbl.TextColor3 = COLORS.text
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Text = tostring(default)
    valLbl.Parent = holder

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    sliderBg.Position = UDim2.new(0, 12, 0, 34)
    sliderBg.BackgroundColor3 = COLORS.slider_bg
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = holder

    local slBgCorner = Instance.new("UICorner")
    slBgCorner.CornerRadius = UDim.new(1, 0)
    slBgCorner.Parent = sliderBg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / math.max(max - min, 1), 0, 1, 0)
    fill.BackgroundColor3 = COLORS.accent
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 0, 20)
    sliderBtn.Position = UDim2.new(0, 0, 0, 24)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.Parent = holder

    local sliding = false
    sliderBtn.MouseButton1Down:Connect(function() sliding = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valLbl.Text = tostring(val)
            if callback then callback(val) end
        end
    end)
end

local function addButton(tab, text, desc, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, desc and desc ~= "" and 44 or 34)
    holder.BackgroundColor3 = COLORS.card
    holder.BorderSizePixel = 0
    holder.LayoutOrder = tab.order
    holder.Parent = tab.scroll
    tab.order = tab.order + 1

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 6)
    hCorner.Parent = holder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, desc and desc ~= "" and 4 or 7)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = COLORS.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = holder

    if desc and desc ~= "" then
        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, -20, 0, 14)
        descLbl.Position = UDim2.new(0, 12, 0, 24)
        descLbl.BackgroundTransparency = 1
        descLbl.Font = Enum.Font.Gotham
        descLbl.TextSize = 10
        descLbl.TextColor3 = COLORS.dimtext
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.Text = desc
        descLbl.Parent = holder
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = holder

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(holder, TweenInfo.new(0.1), { BackgroundColor3 = COLORS.accent }):Play()
        task.wait(0.1)
        TweenService:Create(holder, TweenInfo.new(0.1), { BackgroundColor3 = COLORS.card }):Play()
        if callback then callback() end
    end)
end

local function addDropdown(tab, text, options, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 58)
    holder.BackgroundColor3 = COLORS.card
    holder.BorderSizePixel = 0
    holder.ClipsDescendants = true
    holder.LayoutOrder = tab.order
    holder.Parent = tab.scroll
    tab.order = tab.order + 1

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 6)
    hCorner.Parent = holder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 22)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = COLORS.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = holder

    local selected = Instance.new("TextButton")
    selected.Size = UDim2.new(1, -24, 0, 24)
    selected.Position = UDim2.new(0, 12, 0, 28)
    selected.BackgroundColor3 = COLORS.input_bg
    selected.BorderSizePixel = 0
    selected.Font = Enum.Font.Gotham
    selected.TextSize = 12
    selected.TextColor3 = COLORS.text
    selected.Text = "  " .. (default or options[1] or "")
    selected.TextXAlignment = Enum.TextXAlignment.Left
    selected.Parent = holder

    local selCorner = Instance.new("UICorner")
    selCorner.CornerRadius = UDim.new(0, 4)
    selCorner.Parent = selected

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -22, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 12
    arrow.TextColor3 = COLORS.dimtext
    arrow.Text = "v"
    arrow.Parent = selected

    local isOpen = false
    local closedSize = 58
    local optionHeight = 24

    -- Create option buttons
    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, -24, 0, optionHeight)
        optBtn.Position = UDim2.new(0, 12, 0, closedSize + (i - 1) * optionHeight)
        optBtn.BackgroundColor3 = COLORS.input_bg
        optBtn.BorderSizePixel = 0
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 12
        optBtn.TextColor3 = COLORS.dimtext
        optBtn.Text = "  " .. opt
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.Parent = holder

        local oCorner = Instance.new("UICorner")
        oCorner.CornerRadius = UDim.new(0, 4)
        oCorner.Parent = optBtn

        optBtn.MouseButton1Click:Connect(function()
            selected.Text = "  " .. opt
            isOpen = false
            holder.Size = UDim2.new(1, 0, 0, closedSize)
            holder.ClipsDescendants = true
            if callback then callback(opt) end
        end)
    end

    selected.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            holder.Size = UDim2.new(1, 0, 0, closedSize + #options * optionHeight + 4)
            holder.ClipsDescendants = false
        else
            holder.Size = UDim2.new(1, 0, 0, closedSize)
            holder.ClipsDescendants = true
        end
    end)
end

local function addTextbox(tab, text, placeholder, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 58)
    holder.BackgroundColor3 = COLORS.card
    holder.BorderSizePixel = 0
    holder.LayoutOrder = tab.order
    holder.Parent = tab.scroll
    tab.order = tab.order + 1

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 6)
    hCorner.Parent = holder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 22)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = COLORS.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = holder

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -24, 0, 24)
    input.Position = UDim2.new(0, 12, 0, 28)
    input.BackgroundColor3 = COLORS.input_bg
    input.BorderSizePixel = 0
    input.Font = Enum.Font.Gotham
    input.TextSize = 12
    input.TextColor3 = COLORS.text
    input.PlaceholderText = placeholder or ""
    input.PlaceholderColor3 = COLORS.dimtext
    input.Text = ""
    input.ClearTextOnFocus = false
    input.Parent = holder

    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = UDim.new(0, 4)
    iCorner.Parent = input

    input.FocusLost:Connect(function()
        if callback then callback(input.Text) end
    end)
end

------------------------------------------------------------
-- BUILD TABS
------------------------------------------------------------

-- === THA BRONX 3 (MAIN) TAB ===
local mainTab = addTab("Tha Bronx 3", "")

addSection(mainTab, "Select Player")

local playerNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then table.insert(playerNames, p.Name) end
end
if #playerNames == 0 then playerNames = {"No players"} end

addDropdown(mainTab, "Select Player", playerNames, nil, function(v) Config.Main.SelectedPlayer = v end)

addSection(mainTab, "Player Options")
addButton(mainTab, "Spectate Player", "", function()
    local t = Config.Main.SelectedPlayer
    if t then local p = Players:FindFirstChild(t); if p and p.Character and p.Character:FindFirstChild("Humanoid") then Camera.CameraSubject = p.Character.Humanoid end end
end)
addButton(mainTab, "Bring Player", "", function()
    local t = Config.Main.SelectedPlayer
    if t then local p = Players:FindFirstChild(t); if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-5) end end
end)
addButton(mainTab, "Bug / Kill Player - Car", "", function() end)
addButton(mainTab, "Auto Kill Player - Gun", "", function() end)
addButton(mainTab, "Auto Ragdoll Player - Gun", "", function() end)
addButton(mainTab, "Teleport To Player", "", function()
    local t = Config.Main.SelectedPlayer
    if t then local p = Players:FindFirstChild(t); if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end
end)
addButton(mainTab, "Down Player - Hold Gun", "", function() end)
addButton(mainTab, "Kill Player - Hold Gun", "", function() end)

addSection(mainTab, "Movement")
addToggle(mainTab, "No Clip", false, function(v) Config.Main.NoClip = v end)
addToggle(mainTab, "Speed", false, function(v) Config.Main.Speed = v end)
addSlider(mainTab, "Speed Amount", 0, 100, 0, function(v) Config.Main.SpeedAmount = v end)
addToggle(mainTab, "Fly", false, function(v) Config.Main.Fly = v end)
addSlider(mainTab, "Fly Speed Amount", 0, 50, 7, function(v) Config.Main.FlySpeedAmount = v end)
addToggle(mainTab, "Jump Power", false, function(v) Config.Main.JumpPower = v end)
addSlider(mainTab, "Jump Power Amount", 0, 500, 100, function(v) Config.Main.JumpPowerAmount = v end)

-- === MONEY TAB ===
local moneyTab = addTab("Money", "")

addSection(moneyTab, "Farming")
addToggle(moneyTab, "Auto Farm Construction", false, function(v) Config.Money.AutoFarmConstruction = v end)
addToggle(moneyTab, "Auto Farm Bank", false, function(v) Config.Money.AutoFarmBank = v end)
addToggle(moneyTab, "Auto Farm House", false, function(v) Config.Money.AutoFarmHouse = v end)
addToggle(moneyTab, "Auto Farm Studio", false, function(v) Config.Money.AutoFarmStudio = v end)
addToggle(moneyTab, "Auto Farm Dumpsters", false, function(v) Config.Money.AutoFarmDumpsters = v end)

addSection(moneyTab, "Vulnerability Section")
addButton(moneyTab, "Generate Max Illegal Money Manual", "Requires Ice-Fruit Cup In Inventory!", function() end)
addButton(moneyTab, "Generate Max Illegal Money Auto", "Need 5K To Do This!", function() end)

addSection(moneyTab, "Bank Actions")
addTextbox(moneyTab, "Money Amount", "Enter Money Amount", function(v) Config.Money.MoneyAmount = tonumber(v) or 0 end)
addDropdown(moneyTab, "Select Bank Action", {"Deposit", "Withdraw", "Drop"}, "Deposit", function(v) Config.Money.SelectedBankAction = v end)
addButton(moneyTab, "Apply Selected Bank Action", "", function() end)
addToggle(moneyTab, "Auto Deposit", false, function(v) Config.Money.AutoDeposit = v end)
addToggle(moneyTab, "Auto Withdraw", false, function(v) Config.Money.AutoWithdraw = v end)
addToggle(moneyTab, "Auto Drop", false, function(v) Config.Money.AutoDrop = v end)

addSection(moneyTab, "Duping Section")
addButton(moneyTab, "Duplicate Current Item", "Can Take Few Tries!", function() end)

-- === MISCELLANEOUS TAB ===
local miscTab = addTab("Miscellaneous", "")

addSection(miscTab, "Local Player Modifications")
addToggle(miscTab, "Infinite Stamina", false, function(v) Config.Misc.InfiniteStamina = v end)
addToggle(miscTab, "Instant Respawn", false, function(v) Config.Misc.InstantRespawn = v end)
addToggle(miscTab, "Infinite Sleep", false, function(v) Config.Misc.InfiniteSleep = v end)
addToggle(miscTab, "Infinite Hunger", false, function(v) Config.Misc.InfiniteHunger = v end)
addToggle(miscTab, "Instant Interact", false, function(v) Config.Misc.InstantInteract = v end)
addToggle(miscTab, "Auto Pickup Cash", false, function(v) Config.Misc.AutoPickupCash = v end)
addToggle(miscTab, "Disable Blood Effects", false, function(v) Config.Misc.DisableBloodEffects = v end)
addToggle(miscTab, "Unlock Locked Cars", false, function(v) Config.Misc.UnlockLockedCars = v end)
addToggle(miscTab, "No Rent Pay", false, function(v) Config.Misc.NoRentPay = v end)
addToggle(miscTab, "No Fall Damage", false, function(v) Config.Misc.NoFallDamage = v end)
addToggle(miscTab, "Respawn Where You Died", false, function(v) Config.Misc.RespawnWhereDied = v end)

addSection(miscTab, "Purchase Selected Item")
addDropdown(miscTab, "Purchase Selected Item", {".TecMag - $20", ".GlockMag - $15", ".AR Mag - $50"}, ".TecMag - $20", function(v) Config.Misc.SelectedItem = v end)
addButton(miscTab, "Purchase", "", function() end)

addSection(miscTab, "Teleport To Location")
addDropdown(miscTab, "Teleport Options", {"Basketball Court", "Gun Store", "Bank", "Hospital", "Police Station", "Car Dealer", "Studio", "Apartments", "Gas Station", "Clothing Store", "Barber Shop"}, "Basketball Court", function(v) Config.Misc.TeleportLocation = v end)
addButton(miscTab, "Teleport", "", function() end)

addSection(miscTab, "Outfits")
addDropdown(miscTab, "Select Outfit", {"Amiri Outfit", "Nike Tech", "Bape Set", "Default"}, "Amiri Outfit", function(v) Config.Misc.SelectedOutfit = v end)
addButton(miscTab, "Apply Selected Outfit", "", function() end)

-- === COMBAT TAB ===
local combatTab = addTab("Combat", "")

addSection(combatTab, "Silent Aim - General")
addToggle(combatTab, "Silent Aim Enabled", false, function(v) Config.Combat.SilentAim.Enabled = v end)

addSection(combatTab, "Silent Aim - Settings")
addToggle(combatTab, "Visible Check", false, function(v) Config.Combat.SilentAim.VisibleCheck = v end)
addDropdown(combatTab, "Aimlock Type", {"Mouse", "Camera", "Closest"}, "Mouse", function(v) Config.Combat.SilentAim.AimlockType = v end)
addDropdown(combatTab, "Target Parts", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, "Head", function(v) Config.Combat.SilentAim.TargetParts = v end)
addSlider(combatTab, "Max Distance", 0, 100, 50, function(v) Config.Combat.SilentAim.MaxDistance = v end)
addSlider(combatTab, "Smoothness", 0, 100, 50, function(v) Config.Combat.SilentAim.Smoothness = v end)

addSection(combatTab, "Silent Aim - FOV")
addToggle(combatTab, "FOV Enabled", false, function(v) Config.Combat.SilentAim.FOVEnabled = v end)
addToggle(combatTab, "Draw Circle", false, function(v) Config.Combat.SilentAim.DrawCircle = v end)
addSlider(combatTab, "FOV Radius", 0, 100, 50, function(v) Config.Combat.SilentAim.FOVRadius = v end)
addSlider(combatTab, "FOV Sides", 0, 100, 50, function(v) Config.Combat.SilentAim.FOVSides = v end)

addSection(combatTab, "Aimlock - General")
addToggle(combatTab, "Aimlock Enabled", false, function(v) Config.Combat.Aimlock.Enabled = v end)

addSection(combatTab, "Aimlock - Settings")
addToggle(combatTab, "AL Visible Check", false, function(v) Config.Combat.Aimlock.VisibleCheck = v end)
addDropdown(combatTab, "AL Aimlock Type", {"Mouse", "Camera", "Closest"}, "Mouse", function(v) Config.Combat.Aimlock.AimlockType = v end)
addDropdown(combatTab, "AL Target Parts", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, "Head", function(v) Config.Combat.Aimlock.TargetParts = v end)
addSlider(combatTab, "AL Max Distance", 0, 100, 50, function(v) Config.Combat.Aimlock.MaxDistance = v end)
addSlider(combatTab, "AL Smoothness", 0, 100, 50, function(v) Config.Combat.Aimlock.Smoothness = v end)

addSection(combatTab, "Aimlock - FOV")
addToggle(combatTab, "AL FOV Enabled", false, function(v) Config.Combat.Aimlock.FOVEnabled = v end)
addToggle(combatTab, "AL Draw Circle", false, function(v) Config.Combat.Aimlock.DrawCircle = v end)
addSlider(combatTab, "AL FOV Radius", 0, 100, 50, function(v) Config.Combat.Aimlock.FOVRadius = v end)
addSlider(combatTab, "AL FOV Sides", 0, 100, 50, function(v) Config.Combat.Aimlock.FOVSides = v end)

-- === VISUALS TAB ===
local visualsTab = addTab("Visuals", "")

addSection(visualsTab, "Enable ESP")
addToggle(visualsTab, "Enable ESP", false, function(v) Config.Visuals.EnableESP = v end)

addSection(visualsTab, "Box ESP")
addToggle(visualsTab, "Corner Frame ESP", false, function(v) Config.Visuals.CornerFrameESP = v end)
addToggle(visualsTab, "Box ESP", false, function(v) Config.Visuals.BoxESP = v end)

addSection(visualsTab, "Healthbar ESP")
addToggle(visualsTab, "Health Bar", false, function(v) Config.Visuals.HealthBar = v end)
addToggle(visualsTab, "Health Text", false, function(v) Config.Visuals.HealthText = v end)
addToggle(visualsTab, "Lerp Health Color", false, function(v) Config.Visuals.LerpHealthColor = v end)
addToggle(visualsTab, "Gradient Health", false, function(v) Config.Visuals.GradientHealth = v end)

addSection(visualsTab, "ESP Settings")
addToggle(visualsTab, "Distance", false, function(v) Config.Visuals.Distance = v end)
addSlider(visualsTab, "Max Distance", 0, 5000, 2000, function(v) Config.Visuals.MaxDistance = v end)

addSection(visualsTab, "Cham ESP")
addToggle(visualsTab, "Chams", false, function(v) Config.Visuals.Chams = v end)
addToggle(visualsTab, "Thermal Effect", false, function(v) Config.Visuals.ThermalEffect = v end)
addToggle(visualsTab, "Visible Check", false, function(v) Config.Visuals.VisibleCheck = v end)
addSlider(visualsTab, "Fill Transparency", 0, 100, 50, function(v) Config.Visuals.FillTransparency = v end)
addSlider(visualsTab, "Outline Transparency", 0, 100, 50, function(v) Config.Visuals.OutlineTransparency = v end)

-- === SETTINGS TAB ===
local settingsTab = addTab("Settings", "")

addSection(settingsTab, "UI Settings")
addButton(settingsTab, "Toggle UI (RightShift)", "", function()
    MainFrame.Visible = not MainFrame.Visible
end)
addButton(settingsTab, "Destroy GUI", "", function()
    ScreenGui:Destroy()
end)

-- Select first tab by default
if tabs[1] then
    tabs[1].btn.BackgroundTransparency = 0
    tabs[1].btn.BackgroundColor3 = COLORS.accent
    tabs[1].btn.TextColor3 = Color3.new(1, 1, 1)
    tabs[1].frame.Visible = true
end

-- Toggle keybind
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

------------------------------------------------------------
-- CORE LOOPS
------------------------------------------------------------

-- NoClip
RunService.Stepped:Connect(function()
    pcall(function()
        if Config.Main.NoClip and LocalPlayer.Character then
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end)

-- Speed
RunService.Heartbeat:Connect(function()
    pcall(function()
        if Config.Main.Speed and LocalPlayer.Character then
            local h = LocalPlayer.Character:FindFirstChild("Humanoid")
            if h then h.WalkSpeed = 16 + Config.Main.SpeedAmount end
        end
    end)
end)

-- Jump Power
RunService.Heartbeat:Connect(function()
    pcall(function()
        if Config.Main.JumpPower and LocalPlayer.Character then
            local h = LocalPlayer.Character:FindFirstChild("Humanoid")
            if h then h.JumpPower = Config.Main.JumpPowerAmount end
        end
    end)
end)

-- Fly
local flyBV, flyBG = nil, nil
RunService.Heartbeat:Connect(function()
    pcall(function()
        if Config.Main.Fly and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not flyBV then
                    flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(1e9,1e9,1e9); flyBV.Parent = hrp
                    flyBG = Instance.new("BodyGyro"); flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9); flyBG.Parent = hrp
                end
                local s = Config.Main.FlySpeedAmount
                local d = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then d = d + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then d = d - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then d = d - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then d = d + Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then d = d + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then d = d - Vector3.new(0,1,0) end
                flyBV.Velocity = d * s * 10
                flyBG.CFrame = Camera.CFrame
            end
        else
            if flyBV then flyBV:Destroy(); flyBV = nil end
            if flyBG then flyBG:Destroy(); flyBG = nil end
        end
    end)
end)

-- ESP
local espObjects = {}
local function createESP(player)
    if player == LocalPlayer then return end
    local data = {}
    data.Highlight = Instance.new("Highlight")
    data.Highlight.FillColor = Color3.fromRGB(0, 120, 255)
    data.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    data.Highlight.FillTransparency = 0.5
    data.Highlight.OutlineTransparency = 0.5
    data.Highlight.Enabled = false

    data.Billboard = Instance.new("BillboardGui")
    data.Billboard.Size = UDim2.new(0, 200, 0, 50)
    data.Billboard.StudsOffset = Vector3.new(0, 3, 0)
    data.Billboard.AlwaysOnTop = true
    data.Billboard.Enabled = false

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 0.5, 0); nl.BackgroundTransparency = 1
    nl.TextColor3 = Color3.new(1,1,1); nl.TextStrokeTransparency = 0.5
    nl.Font = Enum.Font.GothamBold; nl.TextSize = 13; nl.Text = player.Name
    nl.Parent = data.Billboard
    data.NameLabel = nl

    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1, 0, 0.5, 0); dl.Position = UDim2.new(0,0,0.5,0); dl.BackgroundTransparency = 1
    dl.TextColor3 = Color3.fromRGB(200,200,200); dl.TextStrokeTransparency = 0.5
    dl.Font = Enum.Font.Gotham; dl.TextSize = 11; dl.Text = ""
    dl.Parent = data.Billboard
    data.DistLabel = dl

    espObjects[player] = data

    local function onChar(char)
        pcall(function()
            data.Highlight.Adornee = char; data.Highlight.Parent = char
            local head = char:WaitForChild("Head", 5)
            if head then data.Billboard.Parent = head end
        end)
    end
    if player.Character then task.spawn(function() onChar(player.Character) end) end
    player.CharacterAdded:Connect(onChar)
end

local function removeESP(player)
    local d = espObjects[player]
    if d then pcall(function() d.Highlight:Destroy(); d.Billboard:Destroy() end); espObjects[player] = nil end
end

for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    pcall(function()
        for player, data in pairs(espObjects) do
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local lhrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if Config.Visuals.EnableESP and char and hrp and lhrp then
                local dist = (hrp.Position - lhrp.Position).Magnitude
                if dist <= Config.Visuals.MaxDistance then
                    data.Highlight.Enabled = Config.Visuals.Chams
                    data.Highlight.FillTransparency = Config.Visuals.FillTransparency / 100
                    data.Highlight.OutlineTransparency = Config.Visuals.OutlineTransparency / 100
                    data.Billboard.Enabled = true
                    data.DistLabel.Text = Config.Visuals.Distance and string.format("[%d studs]", math.floor(dist)) or ""
                else
                    data.Highlight.Enabled = false; data.Billboard.Enabled = false
                end
            else
                if data.Highlight then data.Highlight.Enabled = false end
                if data.Billboard then data.Billboard.Enabled = false end
            end
        end
    end)
end)

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1; fovCircle.Color = Color3.fromRGB(0, 120, 255)
fovCircle.Filled = false; fovCircle.Transparency = 0.7; fovCircle.Visible = false

RunService.RenderStepped:Connect(function()
    pcall(function()
        local cc = Config.Combat.Aimlock.Enabled and Config.Combat.Aimlock or Config.Combat.SilentAim
        if cc.FOVEnabled and cc.DrawCircle then
            fovCircle.Visible = true
            fovCircle.Position = UserInputService:GetMouseLocation()
            fovCircle.Radius = (cc.FOVRadius / 100) * 300
            fovCircle.NumSides = math.floor((cc.FOVSides / 100) * 60) + 3
        else
            fovCircle.Visible = false
        end
    end)
end)

-- Aimlock
local function getClosest(config)
    local closest, closestDist = nil, math.huge
    local mp = UserInputService:GetMouseLocation()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local part = p.Character:FindFirstChild(config.TargetParts)
            if part then
                local sp, on = Camera:WorldToViewportPoint(part.Position)
                if on then
                    local d2 = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
                    local fr = (config.FOVRadius / 100) * 300
                    if (not config.FOVEnabled or d2 <= fr) and d2 < closestDist then
                        local lh = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if lh then
                            local d3 = (part.Position - lh.Position).Magnitude
                            if d3 <= (config.MaxDistance / 100) * 1000 then closest = p; closestDist = d2 end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local aimlockTarget = nil
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.UserInputType == Enum.UserInputType.MouseButton2 and Config.Combat.Aimlock.Enabled then
        aimlockTarget = getClosest(Config.Combat.Aimlock)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then aimlockTarget = nil end
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        if Config.Combat.Aimlock.Enabled and aimlockTarget and aimlockTarget.Character then
            local part = aimlockTarget.Character:FindFirstChild(Config.Combat.Aimlock.TargetParts)
            if part then
                local sm = 1 - (Config.Combat.Aimlock.Smoothness / 100) * 0.9
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), sm)
            end
        end
    end)
end)

-- Auto Pickup Cash
RunService.Heartbeat:Connect(function()
    pcall(function()
        if Config.Misc.AutoPickupCash and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("cash") or obj.Name:lower():find("money") or obj.Name:lower():find("drop")) then
                        if (obj.Position - hrp.Position).Magnitude <= 50 then
                            firetouchinterest(hrp, obj, 0); task.wait(); firetouchinterest(hrp, obj, 1)
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
        if Config.Misc.NoFallDamage and LocalPlayer.Character then
            local h = LocalPlayer.Character:FindFirstChild("Humanoid")
            if h then
                h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end
        end
    end)
end)

print("[Synapse-Xenon] Loaded successfully!")
