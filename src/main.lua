--[[
    Tha Bronx 3 - Synapse-Xenon Premium
    Luarmor Compatible Script
    Compatible with: Xeno, Solara, Fluxus, Delta, and other low-level executors
    
    Structure:
    - Main Tab (Main, Money, Miscellaneous sub-tabs)
    - Combat Tab (Silent Aim, Aimlock)
    - Visuals Tab (ESP)
    - Settings Tab (Config management)
]]

------------------------------------------------------------
-- Executor Compatibility Layer
------------------------------------------------------------

-- Safe require/loadstring wrapper
local function safeLoadstring(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not success then
        -- Fallback: try syn.request or http_request or request
        local requestFunc = (syn and syn.request) or http_request or request or HttpService.RequestAsync
        if requestFunc then
            local ok, res = pcall(function()
                if requestFunc == HttpService.RequestAsync then
                    return HttpService:RequestAsync({ Url = url, Method = "GET" }).Body
                else
                    return requestFunc({ Url = url, Method = "GET" }).Body
                end
            end)
            if ok then result = res end
        end
    end
    if result then
        return loadstring(result)
    end
    return nil
end

-- Polyfill: task library (some executors missing task.wait/task.spawn)
if not task then
    task = {
        wait = function(t) return wait(t or 0) end,
        spawn = function(f, ...) return coroutine.wrap(f)(...) end,
        defer = function(f, ...) return coroutine.wrap(f)(...) end,
        delay = function(t, f) return delay(t, f) end,
    }
end

-- Polyfill: firetouchinterest (many low-level executors lack this)
if not firetouchinterest then
    firetouchinterest = function(part1, part2, toggle)
        -- Fallback: use CFrame teleport method instead
        if toggle == 0 then
            local oldCF = part1.CFrame
            part1.CFrame = part2.CFrame
            task.wait()
            part1.CFrame = oldCF
        end
    end
end

-- Polyfill: Drawing API (Xeno/Solara may not support Drawing.new)
local DrawingSupported = pcall(function() local _ = Drawing.new("Circle") end)
if not DrawingSupported then
    -- Stub Drawing for executors without it; FOV circle just wont render
    Drawing = Drawing or {}
    Drawing.new = Drawing.new or function(type)
        return setmetatable({}, {
            __index = function(self, key)
                return rawget(self, key)
            end,
            __newindex = function(self, key, value)
                rawset(self, key, value)
            end,
        })
    end
end

-- Polyfill: isfile / readfile / writefile / makefolder (for config saving)
if not isfile then
    isfile = function() return false end
end
if not readfile then
    readfile = function() return "{}" end
end
if not writefile then
    writefile = function() end
end
if not makefolder then
    makefolder = function() end
end
if not isfolder then
    isfolder = function() return false end
end
if not delfolder then
    delfolder = function() end
end
if not delfile then
    delfile = function() end
end
if not listfiles then
    listfiles = function() return {} end
end

-- Polyfill: setclipboard
if not setclipboard then
    setclipboard = function() end
end

-- Polyfill: getgenv (some executors use this for globals)
if not getgenv then
    getgenv = function() return _G end
end

-- Polyfill: hookmetamethod / newcclosure
if not hookmetamethod then
    hookmetamethod = function() end
end
if not newcclosure then
    newcclosure = function(f) return f end
end

-- Safe pcall wrapper for exploit functions
local function safecall(func, ...)
    local args = {...}
    local ok, result = pcall(function()
        return func(unpack(args))
    end)
    if ok then return result end
    return nil
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Config State
local Config = {
    -- Main Tab
    Main = {
        SelectedPlayer = nil,
        NoClip = false,
        Speed = false,
        SpeedAmount = 0,
        Fly = false,
        FlySpeedAmount = 7,
        JumpPower = false,
        JumpPowerAmount = 100,
        SelectedUI = "ThaShop",
        EnableUI = false,
    },
    -- Money Tab
    Money = {
        AutoFarmConstruction = false,
        AutoFarmBank = false,
        AutoFarmHouse = false,
        AutoFarmStudio = false,
        AutoFarmDumpsters = false,
        MoneyAmount = 0,
        SelectedBankAction = "Deposit",
        AutoDeposit = false,
        AutoWithdraw = false,
        AutoDrop = false,
    },
    -- Miscellaneous Tab
    Misc = {
        InfiniteStamina = false,
        InstantRespawn = false,
        InfiniteSleep = false,
        InfiniteHunger = false,
        InstantInteract = false,
        AutoPickupCash = false,
        DisableBloodEffects = false,
        UnlockLockedCars = false,
        NoRentPay = false,
        NoFallDamage = false,
        RespawnWhereDied = false,
        SelectedItem = ".TecMag - $20",
        TeleportLocation = "Basketball Court",
        SelectedOutfit = "Amiri Outfit",
    },
    -- Combat Tab
    Combat = {
        SilentAim = {
            Enabled = false,
            Keybind = Enum.KeyCode.Unknown,
            VisibleCheck = false,
            AimlockType = "Mouse",
            TargetParts = "Head",
            MaxDistance = 50,
            Smoothness = 50,
            FOVEnabled = false,
            DrawCircle = false,
            FOVRadius = 50,
            FOVSides = 50,
            SnaplineEnabled = false,
            SnaplineThickness = 50,
        },
        Aimlock = {
            Enabled = false,
            Keybind = Enum.KeyCode.Unknown,
            VisibleCheck = false,
            AimlockType = "Mouse",
            TargetParts = "Head",
            MaxDistance = 50,
            Smoothness = 50,
            FOVEnabled = false,
            DrawCircle = false,
            FOVRadius = 50,
            FOVSides = 50,
            SnaplineEnabled = false,
            SnaplineThickness = 50,
        },
    },
    -- Visuals Tab
    Visuals = {
        EnableESP = false,
        CornerFrameESP = false,
        BoxESP = false,
        HealthBar = false,
        HealthText = false,
        LerpHealthColor = false,
        GradientHealth = false,
        Distance = false,
        MaxDistance = 2000,
        Chams = false,
        ThermalEffect = false,
        VisibleCheck = false,
        FillTransparency = 50,
        OutlineTransparency = 50,
    },
    -- Settings
    Settings = {
        CloseBind = Enum.KeyCode.RightShift,
    },
}

------------------------------------------------------------
-- UI Library Loader (with fallback for low-level executors)
------------------------------------------------------------
local Fluent, SaveManager, Library

local function loadUI()
    local ok1, res1 = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)
    if ok1 then Fluent = res1 end

    local ok2, res2 = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    end)
    if ok2 then SaveManager = res2 end

    local ok3, res3 = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    end)
    if ok3 then Library = res3 end
end

loadUI()

if not Fluent then
    warn("[Synapse-Xenon] Failed to load UI library. Make sure HTTP requests are enabled.")
    return
end

------------------------------------------------------------
-- Window Creation
------------------------------------------------------------
local Window = Fluent:CreateWindow({
    Title = "Synapse-Xenon" .. "    " .. "Premium User!",
    SubTitle = "",
    TabWidth = 130,
    Size = UDim2.fromOffset(640, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Config.Settings.CloseBind,
})

------------------------------------------------------------
-- Tabs
------------------------------------------------------------
local Tabs = {
    Main = Window:AddTab({ Title = "Tha Bronx 3", Icon = "home" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

------------------------------------------------------------
-- MAIN TAB - Sub tabs via sections
------------------------------------------------------------
do
    -- ==================== MAIN SUB-TAB ====================
    local MainSection = Tabs.Main:AddSection("Main")

    -- Select Player
    local playerNames = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(playerNames, p.Name)
        end
    end

    local SelectPlayer = Tabs.Main:AddDropdown("SelectPlayer", {
        Title = "Select Player",
        Description = "Selected Player",
        Values = playerNames,
        Multi = false,
        Default = nil,
    })

    SelectPlayer:OnChanged(function(val)
        Config.Main.SelectedPlayer = val
    end)

    -- Player Options Section
    Tabs.Main:AddSection("Player Options")

    Tabs.Main:AddButton({
        Title = "Spectate Player",
        Description = "",
        Callback = function()
            local target = Config.Main.SelectedPlayer
            if target then
                local plr = Players:FindFirstChild(target)
                if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    Camera.CameraSubject = plr.Character.Humanoid
                end
            end
        end,
    })

    Tabs.Main:AddButton({
        Title = "Bring Player",
        Description = "",
        Callback = function()
            local target = Config.Main.SelectedPlayer
            if target then
                local plr = Players:FindFirstChild(target)
                if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        plr.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                    end
                end
            end
        end,
    })

    Tabs.Main:AddButton({
        Title = "Bug / Kill Player - Car",
        Description = "",
        Callback = function()
            -- Placeholder: game-specific remote
        end,
    })

    Tabs.Main:AddButton({
        Title = "Auto Kill Player - Gun",
        Description = "",
        Callback = function()
            -- Placeholder: game-specific remote
        end,
    })

    Tabs.Main:AddButton({
        Title = "Auto Ragdoll Player - Gun",
        Description = "",
        Callback = function()
            -- Placeholder: game-specific remote
        end,
    })

    Tabs.Main:AddButton({
        Title = "Teleport To Player",
        Description = "",
        Callback = function()
            local target = Config.Main.SelectedPlayer
            if target then
                local plr = Players:FindFirstChild(target)
                if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
                    end
                end
            end
        end,
    })

    Tabs.Main:AddButton({
        Title = "Down Player - Hold Gun",
        Description = "",
        Callback = function()
            -- Placeholder: game-specific remote
        end,
    })

    Tabs.Main:AddButton({
        Title = "Kill Player - Hold Gun",
        Description = "",
        Callback = function()
            -- Placeholder: game-specific remote
        end,
    })

    -- Right side options
    Tabs.Main:AddSection("Movement")

    local NoClipToggle = Tabs.Main:AddToggle("NoClip", {
        Title = "No Clip",
        Default = false,
    })

    NoClipToggle:OnChanged(function(val)
        Config.Main.NoClip = val
    end)

    local SpeedToggle = Tabs.Main:AddToggle("Speed", {
        Title = "Speed",
        Default = false,
    })

    SpeedToggle:OnChanged(function(val)
        Config.Main.Speed = val
    end)

    local SpeedSlider = Tabs.Main:AddSlider("SpeedAmount", {
        Title = "Speed Amount",
        Description = "",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,
    })

    SpeedSlider:OnChanged(function(val)
        Config.Main.SpeedAmount = val
    end)

    local FlyToggle = Tabs.Main:AddToggle("Fly", {
        Title = "Fly",
        Default = false,
    })

    FlyToggle:OnChanged(function(val)
        Config.Main.Fly = val
    end)

    local FlySpeedSlider = Tabs.Main:AddSlider("FlySpeedAmount", {
        Title = "Fly Speed Amount",
        Description = "",
        Default = 7,
        Min = 0,
        Max = 50,
        Rounding = 0,
    })

    FlySpeedSlider:OnChanged(function(val)
        Config.Main.FlySpeedAmount = val
    end)

    local JumpToggle = Tabs.Main:AddToggle("JumpPower", {
        Title = "Jump Power",
        Default = false,
    })

    JumpToggle:OnChanged(function(val)
        Config.Main.JumpPower = val
    end)

    local JumpSlider = Tabs.Main:AddSlider("JumpPowerAmount", {
        Title = "Jump Power Amount",
        Description = "",
        Default = 100,
        Min = 0,
        Max = 500,
        Rounding = 0,
    })

    JumpSlider:OnChanged(function(val)
        Config.Main.JumpPowerAmount = val
    end)

    -- Toggle Interfaces Section
    Tabs.Main:AddSection("Toggle Interfaces Section")

    local UIDropdown = Tabs.Main:AddDropdown("SelectedUI", {
        Title = "Selected UI",
        Values = { "ThaShop", "Phone", "Inventory", "Map" },
        Default = "ThaShop",
    })

    UIDropdown:OnChanged(function(val)
        Config.Main.SelectedUI = val
    end)

    Tabs.Main:AddToggle("EnableUI", {
        Title = "Enable UI",
        Default = false,
    }):OnChanged(function(val)
        Config.Main.EnableUI = val
    end)

    -- ==================== MONEY SUB-TAB ====================
    Tabs.Main:AddSection("— Money —")

    -- Farming
    Tabs.Main:AddSection("Farming")

    Tabs.Main:AddToggle("AutoFarmConstruction", {
        Title = "Auto Farm Construction",
        Default = false,
    }):OnChanged(function(val)
        Config.Money.AutoFarmConstruction = val
    end)

    Tabs.Main:AddToggle("AutoFarmBank", {
        Title = "Auto Farm Bank",
        Default = false,
    }):OnChanged(function(val)
        Config.Money.AutoFarmBank = val
    end)

    Tabs.Main:AddToggle("AutoFarmHouse", {
        Title = "Auto Farm House",
        Default = false,
    }):OnChanged(function(val)
        Config.Money.AutoFarmHouse = val
    end)

    Tabs.Main:AddToggle("AutoFarmStudio", {
        Title = "Auto Farm Studio",
        Default = false,
    }):OnChanged(function(val)
        Config.Money.AutoFarmStudio = val
    end)

    Tabs.Main:AddToggle("AutoFarmDumpsters", {
        Title = "Auto Farm Dumpsters",
        Default = false,
    }):OnChanged(function(val)
        Config.Money.AutoFarmDumpsters = val
    end)

    -- Vulnerability Section
    Tabs.Main:AddSection("Vulnerability Section")

    Tabs.Main:AddButton({
        Title = "Generate Max Illegal Money Manual",
        Description = "Requires Ice-Fruit Cup In Inventory!",
        Callback = function()
            -- Placeholder: fire game-specific remote for illegal money
        end,
    })

    Tabs.Main:AddButton({
        Title = "Generate Max Illegal Money Auto",
        Description = "Need 5K To Do This!",
        Callback = function()
            -- Placeholder: fire game-specific remote for auto illegal money
        end,
    })

    -- Bank Actions
    Tabs.Main:AddSection("Bank Actions")

    local MoneyInput = Tabs.Main:AddInput("MoneyAmount", {
        Title = "Money Amount",
        Default = "",
        Placeholder = "Enter Money Amount",
        Numeric = true,
    })

    MoneyInput:OnChanged(function(val)
        Config.Money.MoneyAmount = tonumber(val) or 0
    end)

    local BankActionDropdown = Tabs.Main:AddDropdown("SelectBankAction", {
        Title = "Select Bank Action",
        Values = { "Deposit", "Withdraw", "Drop" },
        Default = "Deposit",
    })

    BankActionDropdown:OnChanged(function(val)
        Config.Money.SelectedBankAction = val
    end)

    Tabs.Main:AddButton({
        Title = "Apply Selected Bank Action",
        Description = "",
        Callback = function()
            -- Placeholder: fire bank action remote with Config.Money.SelectedBankAction and Config.Money.MoneyAmount
        end,
    })

    Tabs.Main:AddToggle("AutoDeposit", {
        Title = "Auto Deposit",
        Default = false,
    }):OnChanged(function(val)
        Config.Money.AutoDeposit = val
    end)

    Tabs.Main:AddToggle("AutoWithdraw", {
        Title = "Auto Withdraw",
        Default = false,
    }):OnChanged(function(val)
        Config.Money.AutoWithdraw = val
    end)

    Tabs.Main:AddToggle("AutoDrop", {
        Title = "Auto Drop",
        Default = false,
    }):OnChanged(function(val)
        Config.Money.AutoDrop = val
    end)

    -- Duping Section
    Tabs.Main:AddSection("Duping Section")

    Tabs.Main:AddButton({
        Title = "Duplicate Current Item",
        Description = "Can Take Few Tries!",
        Callback = function()
            -- Placeholder: fire dupe remote
        end,
    })

    -- ==================== MISCELLANEOUS SUB-TAB ====================
    Tabs.Main:AddSection("— Miscellaneous —")

    -- Local Player Modifications
    Tabs.Main:AddSection("Local Player Modifications")

    Tabs.Main:AddToggle("InfiniteStamina", {
        Title = "Infinite Stamina",
        Default = false,
    }):OnChanged(function(val)
        Config.Misc.InfiniteStamina = val
    end)

    Tabs.Main:AddToggle("InstantRespawn", {
        Title = "Instant Respawn",
        Default = false,
    }):OnChanged(function(val)
        Config.Misc.InstantRespawn = val
    end)

    Tabs.Main:AddToggle("InfiniteSleep", {
        Title = "Infinite Sleep",
        Default = false,
    }):OnChanged(function(val)
        Config.Misc.InfiniteSleep = val
    end)

    Tabs.Main:AddToggle("InfiniteHunger", {
        Title = "Infinite Hunger",
        Default = false,
    }):OnChanged(function(val)
        Config.Misc.InfiniteHunger = val
    end)

    Tabs.Main:AddToggle("InstantInteract", {
        Title = "Instant Interact",
        Default = false,
    }):OnChanged(function(val)
        Config.Misc.InstantInteract = val
    end)

    Tabs.Main:AddToggle("AutoPickupCash", {
        Title = "Auto Pickup Cash",
        Default = false,
    }):OnChanged(function(val)
        Config.Misc.AutoPickupCash = val
    end)

    Tabs.Main:AddToggle("DisableBloodEffects", {
        Title = "Disable Blood Effects",
        Default = false,
    }):OnChanged(function(val)
        Config.Misc.DisableBloodEffects = val
    end)

    Tabs.Main:AddToggle("UnlockLockedCars", {
        Title = "Unlock Locked Cars",
        Default = false,
    }):OnChanged(function(val)
        Config.Misc.UnlockLockedCars = val
    end)

    Tabs.Main:AddToggle("NoRentPay", {
        Title = "No Rent Pay",
        Default = false,
    }):OnChanged(function(val)
        Config.Misc.NoRentPay = val
    end)

    Tabs.Main:AddToggle("NoFallDamage", {
        Title = "No Fall Damage",
        Default = false,
    }):OnChanged(function(val)
        Config.Misc.NoFallDamage = val
    end)

    Tabs.Main:AddToggle("RespawnWhereDied", {
        Title = "Respawn Where You Died",
        Default = false,
    }):OnChanged(function(val)
        Config.Misc.RespawnWhereDied = val
    end)

    -- Purchase Selected Item
    Tabs.Main:AddSection("Purchase Selected Item")

    local ItemDropdown = Tabs.Main:AddDropdown("PurchaseItem", {
        Title = "Purchase Selected Item",
        Values = { ".TecMag - $20", ".GlockMag - $15", ".AR Mag - $50" },
        Default = ".TecMag - $20",
    })

    ItemDropdown:OnChanged(function(val)
        Config.Misc.SelectedItem = val
    end)

    Tabs.Main:AddButton({
        Title = "Purchase",
        Description = "",
        Callback = function()
            -- Placeholder: fire purchase remote with Config.Misc.SelectedItem
        end,
    })

    -- Teleport To Location
    Tabs.Main:AddSection("Teleport To Location")

    local TeleportDropdown = Tabs.Main:AddDropdown("TeleportOptions", {
        Title = "Teleport Options",
        Values = {
            "Basketball Court", "Gun Store", "Bank", "Hospital",
            "Police Station", "Car Dealer", "Studio", "Apartments",
            "Gas Station", "Clothing Store", "Barber Shop",
        },
        Default = "Basketball Court",
    })

    TeleportDropdown:OnChanged(function(val)
        Config.Misc.TeleportLocation = val
    end)

    Tabs.Main:AddButton({
        Title = "Teleport",
        Description = "",
        Callback = function()
            -- Placeholder: teleport to predefined coordinates based on Config.Misc.TeleportLocation
        end,
    })

    -- Outfits
    Tabs.Main:AddSection("Outfits")

    local OutfitDropdown = Tabs.Main:AddDropdown("SelectOutfit", {
        Title = "Select Outfit",
        Values = { "Amiri Outfit", "Nike Tech", "Bape Set", "Default" },
        Default = "Amiri Outfit",
    })

    OutfitDropdown:OnChanged(function(val)
        Config.Misc.SelectedOutfit = val
    end)

    Tabs.Main:AddButton({
        Title = "Apply Selected Outfit",
        Description = "",
        Callback = function()
            -- Placeholder: fire outfit remote with Config.Misc.SelectedOutfit
        end,
    })
end

------------------------------------------------------------
-- COMBAT TAB
------------------------------------------------------------
do
    -- Silent Aim Section
    Tabs.Combat:AddSection("Silent Aim")

    Tabs.Combat:AddSection("General")

    Tabs.Combat:AddToggle("SilentAimEnabled", {
        Title = "Enabled",
        Default = false,
    }):OnChanged(function(val)
        Config.Combat.SilentAim.Enabled = val
    end)

    Tabs.Combat:AddKeybind("SilentAimKeybind", {
        Title = "Keybind",
        Mode = "Toggle",
        Default = Enum.KeyCode.Unknown,
    }):OnChanged(function(val)
        Config.Combat.SilentAim.Keybind = val
    end)

    -- Settings
    Tabs.Combat:AddSection("Settings")

    Tabs.Combat:AddToggle("SilentVisibleCheck", {
        Title = "Visible Check",
        Default = false,
    }):OnChanged(function(val)
        Config.Combat.SilentAim.VisibleCheck = val
    end)

    Tabs.Combat:AddDropdown("SilentAimlockType", {
        Title = "Aimlock Type",
        Values = { "Mouse", "Camera", "Closest" },
        Default = "Mouse",
    }):OnChanged(function(val)
        Config.Combat.SilentAim.AimlockType = val
    end)

    Tabs.Combat:AddDropdown("SilentTargetParts", {
        Title = "Target Parts",
        Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
        Default = "Head",
    }):OnChanged(function(val)
        Config.Combat.SilentAim.TargetParts = val
    end)

    Tabs.Combat:AddSlider("SilentMaxDistance", {
        Title = "Max Distance",
        Description = "",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    }):OnChanged(function(val)
        Config.Combat.SilentAim.MaxDistance = val
    end)

    Tabs.Combat:AddSlider("SilentSmoothness", {
        Title = "Smoothness",
        Description = "",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    }):OnChanged(function(val)
        Config.Combat.SilentAim.Smoothness = val
    end)

    -- Field Of View
    Tabs.Combat:AddSection("Field Of View")

    Tabs.Combat:AddToggle("SilentFOVEnabled", {
        Title = "Enabled",
        Default = false,
    }):OnChanged(function(val)
        Config.Combat.SilentAim.FOVEnabled = val
    end)

    Tabs.Combat:AddToggle("SilentDrawCircle", {
        Title = "Draw Circle",
        Default = false,
    }):OnChanged(function(val)
        Config.Combat.SilentAim.DrawCircle = val
    end)

    Tabs.Combat:AddSection("Field Of View Settings")

    Tabs.Combat:AddSlider("SilentFOVRadius", {
        Title = "Radius",
        Description = "",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    }):OnChanged(function(val)
        Config.Combat.SilentAim.FOVRadius = val
    end)

    Tabs.Combat:AddSlider("SilentFOVSides", {
        Title = "Sides",
        Description = "",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    }):OnChanged(function(val)
        Config.Combat.SilentAim.FOVSides = val
    end)

    -- Snapline
    Tabs.Combat:AddSection("Snapline")

    Tabs.Combat:AddToggle("SilentSnapline", {
        Title = "Enabled",
        Default = false,
    }):OnChanged(function(val)
        Config.Combat.SilentAim.SnaplineEnabled = val
    end)

    Tabs.Combat:AddSlider("SilentSnaplineThickness", {
        Title = "Snapline Thickness",
        Description = "",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    }):OnChanged(function(val)
        Config.Combat.SilentAim.SnaplineThickness = val
    end)

    -- ==================== AIMLOCK ====================
    Tabs.Combat:AddSection("— Aimlock —")

    Tabs.Combat:AddSection("General")

    Tabs.Combat:AddToggle("AimlockEnabled", {
        Title = "Enabled",
        Default = false,
    }):OnChanged(function(val)
        Config.Combat.Aimlock.Enabled = val
    end)

    Tabs.Combat:AddKeybind("AimlockKeybind", {
        Title = "Keybind",
        Mode = "Toggle",
        Default = Enum.KeyCode.Unknown,
    }):OnChanged(function(val)
        Config.Combat.Aimlock.Keybind = val
    end)

    Tabs.Combat:AddSection("Settings")

    Tabs.Combat:AddToggle("AimlockVisibleCheck", {
        Title = "Visible Check",
        Default = false,
    }):OnChanged(function(val)
        Config.Combat.Aimlock.VisibleCheck = val
    end)

    Tabs.Combat:AddDropdown("AimlockType", {
        Title = "Aimlock Type",
        Values = { "Mouse", "Camera", "Closest" },
        Default = "Mouse",
    }):OnChanged(function(val)
        Config.Combat.Aimlock.AimlockType = val
    end)

    Tabs.Combat:AddDropdown("AimlockTargetParts", {
        Title = "Target Parts",
        Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
        Default = "Head",
    }):OnChanged(function(val)
        Config.Combat.Aimlock.TargetParts = val
    end)

    Tabs.Combat:AddSlider("AimlockMaxDistance", {
        Title = "Max Distance",
        Description = "",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    }):OnChanged(function(val)
        Config.Combat.Aimlock.MaxDistance = val
    end)

    Tabs.Combat:AddSlider("AimlockSmoothness", {
        Title = "Smoothness",
        Description = "",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    }):OnChanged(function(val)
        Config.Combat.Aimlock.Smoothness = val
    end)

    Tabs.Combat:AddSection("Field Of View")

    Tabs.Combat:AddToggle("AimlockFOVEnabled", {
        Title = "Enabled",
        Default = false,
    }):OnChanged(function(val)
        Config.Combat.Aimlock.FOVEnabled = val
    end)

    Tabs.Combat:AddToggle("AimlockDrawCircle", {
        Title = "Draw Circle",
        Default = false,
    }):OnChanged(function(val)
        Config.Combat.Aimlock.DrawCircle = val
    end)

    Tabs.Combat:AddSection("Field Of View Settings")

    Tabs.Combat:AddSlider("AimlockFOVRadius", {
        Title = "Radius",
        Description = "",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    }):OnChanged(function(val)
        Config.Combat.Aimlock.FOVRadius = val
    end)

    Tabs.Combat:AddSlider("AimlockFOVSides", {
        Title = "Sides",
        Description = "",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    }):OnChanged(function(val)
        Config.Combat.Aimlock.FOVSides = val
    end)

    Tabs.Combat:AddSection("Snapline")

    Tabs.Combat:AddToggle("AimlockSnapline", {
        Title = "Enabled",
        Default = false,
    }):OnChanged(function(val)
        Config.Combat.Aimlock.SnaplineEnabled = val
    end)

    Tabs.Combat:AddSlider("AimlockSnaplineThickness", {
        Title = "Snapline Thickness",
        Description = "",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    }):OnChanged(function(val)
        Config.Combat.Aimlock.SnaplineThickness = val
    end)
end

------------------------------------------------------------
-- VISUALS TAB
------------------------------------------------------------
do
    Tabs.Visuals:AddSection("ESP")

    -- Enable ESP
    Tabs.Visuals:AddSection("Enable ESP")

    Tabs.Visuals:AddToggle("EnableESP", {
        Title = "Enable ESP",
        Default = false,
    }):OnChanged(function(val)
        Config.Visuals.EnableESP = val
    end)

    -- Box ESP
    Tabs.Visuals:AddSection("Box ESP")

    Tabs.Visuals:AddToggle("CornerFrameESP", {
        Title = "Corner Frame ESP",
        Default = false,
    }):OnChanged(function(val)
        Config.Visuals.CornerFrameESP = val
    end)

    Tabs.Visuals:AddToggle("BoxESP", {
        Title = "Box ESP",
        Default = false,
    }):OnChanged(function(val)
        Config.Visuals.BoxESP = val
    end)

    -- Healthbar ESP
    Tabs.Visuals:AddSection("Healthbar ESP")

    Tabs.Visuals:AddToggle("HealthBar", {
        Title = "Health Bar",
        Default = false,
    }):OnChanged(function(val)
        Config.Visuals.HealthBar = val
    end)

    Tabs.Visuals:AddToggle("HealthText", {
        Title = "Health Text",
        Default = false,
    }):OnChanged(function(val)
        Config.Visuals.HealthText = val
    end)

    Tabs.Visuals:AddToggle("LerpHealthColor", {
        Title = "Lerp Health Color",
        Default = false,
    }):OnChanged(function(val)
        Config.Visuals.LerpHealthColor = val
    end)

    Tabs.Visuals:AddToggle("GradientHealth", {
        Title = "Gradient Health",
        Default = false,
    }):OnChanged(function(val)
        Config.Visuals.GradientHealth = val
    end)

    -- Extra ESP
    Tabs.Visuals:AddSection("Extra ESP")

    -- ESP Settings
    Tabs.Visuals:AddSection("ESP Settings")

    Tabs.Visuals:AddToggle("ESPDistance", {
        Title = "Distance",
        Default = false,
    }):OnChanged(function(val)
        Config.Visuals.Distance = val
    end)

    Tabs.Visuals:AddSlider("MaxDistance", {
        Title = "Max Distance",
        Description = "",
        Default = 2000,
        Min = 0,
        Max = 5000,
        Rounding = 0,
    }):OnChanged(function(val)
        Config.Visuals.MaxDistance = val
    end)

    -- Cham ESP
    Tabs.Visuals:AddSection("Cham ESP")

    Tabs.Visuals:AddToggle("Chams", {
        Title = "Chams",
        Default = false,
    }):OnChanged(function(val)
        Config.Visuals.Chams = val
    end)

    Tabs.Visuals:AddToggle("ThermalEffect", {
        Title = "Thermal Effect",
        Default = false,
    }):OnChanged(function(val)
        Config.Visuals.ThermalEffect = val
    end)

    Tabs.Visuals:AddToggle("ESPVisibleCheck", {
        Title = "Visible Check",
        Default = false,
    }):OnChanged(function(val)
        Config.Visuals.VisibleCheck = val
    end)

    Tabs.Visuals:AddSlider("FillTransparency", {
        Title = "Fill Transparency",
        Description = "",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    }):OnChanged(function(val)
        Config.Visuals.FillTransparency = val
    end)

    Tabs.Visuals:AddSlider("OutlineTransparency", {
        Title = "Outline Transparency",
        Description = "",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    }):OnChanged(function(val)
        Config.Visuals.OutlineTransparency = val
    end)

    -- World Visuals
    Tabs.Visuals:AddSection("World Visuals")
end

------------------------------------------------------------
-- SETTINGS TAB
------------------------------------------------------------
do
    if SaveManager then
        pcall(function()
            SaveManager:SetLibrary(Fluent)
            SaveManager:SetFolder("SynapseXenonThaBronx3")
            SaveManager:BuildConfigSection(Tabs.Settings)
        end)
    end

    Tabs.Settings:AddSection("UI Settings")

    Tabs.Settings:AddKeybind("CloseBind", {
        Title = "Close Bind",
        Mode = "Toggle",
        Default = Enum.KeyCode.RightShift,
    }):OnChanged(function(val)
        Config.Settings.CloseBind = val
    end)
end

------------------------------------------------------------
-- CORE LOOPS (Feature Logic)
------------------------------------------------------------

-- NoClip Loop
local noclipConn
RunService.Stepped:Connect(function()
    if Config.Main.NoClip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Speed Loop
RunService.Heartbeat:Connect(function()
    if Config.Main.Speed and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16 + Config.Main.SpeedAmount
        end
    end
end)

-- Jump Power Loop
RunService.Heartbeat:Connect(function()
    if Config.Main.JumpPower and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = Config.Main.JumpPowerAmount
        end
    end
end)

-- Fly System
local flyBodyVelocity = nil
local flyBodyGyro = nil

RunService.Heartbeat:Connect(function()
    if Config.Main.Fly and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not flyBodyVelocity then
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flyBodyVelocity.Parent = hrp

                flyBodyGyro = Instance.new("BodyGyro")
                flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                flyBodyGyro.Parent = hrp
            end

            local speed = Config.Main.FlySpeedAmount
            local direction = Vector3.new(0, 0, 0)

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            flyBodyVelocity.Velocity = direction * speed * 10
            flyBodyGyro.CFrame = Camera.CFrame
        end
    else
        if flyBodyVelocity then
            flyBodyVelocity:Destroy()
            flyBodyVelocity = nil
        end
        if flyBodyGyro then
            flyBodyGyro:Destroy()
            flyBodyGyro = nil
        end
    end
end)

-- ESP System
local espObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end

    local espData = {}

    -- Highlight (Chams)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0, 120, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = Config.Visuals.FillTransparency / 100
    highlight.OutlineTransparency = Config.Visuals.OutlineTransparency / 100
    highlight.Enabled = false
    espData.Highlight = highlight

    -- Billboard for name/distance/health
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.Text = player.Name
    nameLabel.Parent = billboard

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextStrokeTransparency = 0.5
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 11
    distLabel.Text = ""
    distLabel.Parent = billboard

    espData.Billboard = billboard
    espData.NameLabel = nameLabel
    espData.DistLabel = distLabel

    espObjects[player] = espData

    local function onCharacterAdded(character)
        highlight.Adornee = character
        highlight.Parent = character
        billboard.Parent = character:WaitForChild("Head", 5)
    end

    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

local function removeESP(player)
    local data = espObjects[player]
    if data then
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        espObjects[player] = nil
    end
end

-- Initialize ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    for player, data in pairs(espObjects) do
        local enabled = Config.Visuals.EnableESP
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if enabled and character and hrp and localHrp then
            local dist = (hrp.Position - localHrp.Position).Magnitude

            if dist <= Config.Visuals.MaxDistance then
                -- Chams
                data.Highlight.Enabled = Config.Visuals.Chams
                data.Highlight.FillTransparency = Config.Visuals.FillTransparency / 100
                data.Highlight.OutlineTransparency = Config.Visuals.OutlineTransparency / 100

                -- Billboard
                data.Billboard.Enabled = true

                -- Distance text
                if Config.Visuals.Distance then
                    data.DistLabel.Text = string.format("[%d studs]", math.floor(dist))
                else
                    data.DistLabel.Text = ""
                end
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

-- Aimlock / Silent Aim FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.Color = Color3.fromRGB(0, 120, 255)
fovCircle.Filled = false
fovCircle.Transparency = 0.7
fovCircle.Visible = false

RunService.RenderStepped:Connect(function()
    -- Update FOV circle for active combat mode
    local combatConfig = Config.Combat.Aimlock.Enabled and Config.Combat.Aimlock or Config.Combat.SilentAim
    if combatConfig.FOVEnabled and combatConfig.DrawCircle then
        fovCircle.Visible = true
        fovCircle.Position = UserInputService:GetMouseLocation()
        fovCircle.Radius = (combatConfig.FOVRadius / 100) * 300
        fovCircle.NumSides = math.floor((combatConfig.FOVSides / 100) * 60) + 3
    else
        fovCircle.Visible = false
    end
end)

-- Aimlock Function
local function getClosestPlayerToMouse(config)
    local closest = nil
    local closestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = player.Character:FindFirstChild(config.TargetParts)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    local fovRadius = (config.FOVRadius / 100) * 300

                    if (not config.FOVEnabled or dist2D <= fovRadius) and dist2D < closestDist then
                        -- Distance check
                        local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if localHrp then
                            local dist3D = (part.Position - localHrp.Position).Magnitude
                            local maxDist = (config.MaxDistance / 100) * 1000
                            if dist3D <= maxDist then
                                closest = player
                                closestDist = dist2D
                            end
                        end
                    end
                end
            end
        end
    end

    return closest
end

-- Aimlock Loop
local aimlockTarget = nil

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Config.Combat.Aimlock.Enabled then
            aimlockTarget = getClosestPlayerToMouse(Config.Combat.Aimlock)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimlockTarget = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if Config.Combat.Aimlock.Enabled and aimlockTarget then
        local character = aimlockTarget.Character
        if character then
            local part = character:FindFirstChild(Config.Combat.Aimlock.TargetParts)
            if part then
                local smoothness = 1 - (Config.Combat.Aimlock.Smoothness / 100) * 0.9
                local targetCFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothness)
            end
        end
    end
end)

-- Auto Pickup Cash Loop
RunService.Heartbeat:Connect(function()
    if Config.Misc.AutoPickupCash and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
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

-- Infinite Stamina / Sleep / Hunger hooks
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            -- No Fall Damage
            if Config.Misc.NoFallDamage then
                -- State change hook for fall damage prevention
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end
        end
    end
end)

------------------------------------------------------------
-- Select default tab and notify
------------------------------------------------------------
Window:SelectTab(1)

Fluent:Notify({
    Title = "Synapse-Xenon",
    Content = "Tha Bronx 3 script loaded successfully!",
    Duration = 5,
})

-- Load saved config if available
if SaveManager then
    pcall(function()
        SaveManager:LoadAutoloadConfig()
    end)
end
