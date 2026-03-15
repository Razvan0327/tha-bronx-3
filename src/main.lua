--[[
    Tha Bronx 3 - Synapse-Xenon Premium
    Luarmor Compatible Script
    Compatible with: Xeno, Solara, Fluxus, Delta, and other low-level executors
    Uses Orion Library (broad executor support)
]]

------------------------------------------------------------
-- Executor Compatibility Layer
------------------------------------------------------------

-- Polyfill: task library
if not task then
    task = {
        wait = function(t) return wait(t or 0) end,
        spawn = function(f, ...) return coroutine.wrap(f)(...) end,
        defer = function(f, ...) return coroutine.wrap(f)(...) end,
        delay = function(t, f) return delay(t, f) end,
    }
end

-- Polyfill: firetouchinterest
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

-- Polyfill: Drawing API stub
local DrawingSupported = pcall(function() local _ = Drawing.new("Circle") end)
if not DrawingSupported then
    Drawing = Drawing or {}
    Drawing.new = Drawing.new or function()
        return setmetatable({}, {
            __index = function(self, key) return rawget(self, key) end,
            __newindex = function(self, key, value) rawset(self, key, value) end,
        })
    end
end

-- Polyfill: file system
if not isfile then isfile = function() return false end end
if not readfile then readfile = function() return "{}" end end
if not writefile then writefile = function() end end
if not makefolder then makefolder = function() end end
if not isfolder then isfolder = function() return false end end
if not listfiles then listfiles = function() return {} end end
if not delfile then delfile = function() end end
if not delfolder then delfolder = function() end end

-- Polyfill: misc exploit functions
if not setclipboard then setclipboard = function() end end
if not getgenv then getgenv = function() return _G end end
if not hookmetamethod then hookmetamethod = function() end end
if not newcclosure then newcclosure = function(f) return f end end

------------------------------------------------------------
-- Services
------------------------------------------------------------
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

------------------------------------------------------------
-- Config State
------------------------------------------------------------
local Config = {
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
    Combat = {
        SilentAim = {
            Enabled = false,
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
    Settings = {
        CloseBind = Enum.KeyCode.RightShift,
    },
}

------------------------------------------------------------
-- Load Orion Library (most compatible with low-level executors)
------------------------------------------------------------
local OrionLib

local function tryLoadOrion()
    -- Try multiple sources for maximum compatibility
    local urls = {
        "https://raw.githubusercontent.com/shlexware/Orion/main/source",
        "https://raw.githubusercontent.com/jensonhirst/orion/main/orion",
    }
    for _, url in ipairs(urls) do
        local ok, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if ok and result then
            return result
        end
    end
    return nil
end

OrionLib = tryLoadOrion()

if not OrionLib then
    -- Last resort: try with request function
    pcall(function()
        local resp
        if request then
            resp = request({ Url = "https://raw.githubusercontent.com/shlexware/Orion/main/source", Method = "GET" })
        elseif http_request then
            resp = http_request({ Url = "https://raw.githubusercontent.com/shlexware/Orion/main/source", Method = "GET" })
        end
        if resp and resp.Body then
            OrionLib = loadstring(resp.Body)()
        end
    end)
end

if not OrionLib then
    warn("[Synapse-Xenon] Failed to load UI library. Check HTTP requests.")
    return
end

------------------------------------------------------------
-- Window Creation
------------------------------------------------------------
local Window = OrionLib:MakeWindow({
    Name = "Synapse-Xenon | Premium User!",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SynapseXenonThaBronx3",
    IntroText = "Synapse-Xenon | Tha Bronx 3",
    IntroIcon = "rbxassetid://0",
})

------------------------------------------------------------
-- MAIN TAB
------------------------------------------------------------
local MainTab = Window:MakeTab({
    Name = "Tha Bronx 3",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

-- Player list helper
local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

MainTab:AddSection({ Name = "Select Player" })

MainTab:AddDropdown({
    Name = "Select Player",
    Default = "",
    Options = getPlayerNames(),
    Callback = function(val)
        Config.Main.SelectedPlayer = val
    end,
})

MainTab:AddSection({ Name = "Player Options" })

MainTab:AddButton({
    Name = "Spectate Player",
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

MainTab:AddButton({
    Name = "Stop Spectating",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end,
})

MainTab:AddButton({
    Name = "Bring Player",
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

MainTab:AddButton({
    Name = "Bug / Kill Player - Car",
    Callback = function()
        -- Game-specific remote
    end,
})

MainTab:AddButton({
    Name = "Auto Kill Player - Gun",
    Callback = function()
        -- Game-specific remote
    end,
})

MainTab:AddButton({
    Name = "Auto Ragdoll Player - Gun",
    Callback = function()
        -- Game-specific remote
    end,
})

MainTab:AddButton({
    Name = "Teleport To Player",
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

MainTab:AddButton({
    Name = "Down Player - Hold Gun",
    Callback = function()
        -- Game-specific remote
    end,
})

MainTab:AddButton({
    Name = "Kill Player - Hold Gun",
    Callback = function()
        -- Game-specific remote
    end,
})

MainTab:AddSection({ Name = "Movement" })

MainTab:AddToggle({
    Name = "No Clip",
    Default = false,
    Callback = function(val)
        Config.Main.NoClip = val
    end,
})

MainTab:AddToggle({
    Name = "Speed",
    Default = false,
    Callback = function(val)
        Config.Main.Speed = val
    end,
})

MainTab:AddSlider({
    Name = "Speed Amount",
    Min = 0,
    Max = 100,
    Default = 0,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "",
    Callback = function(val)
        Config.Main.SpeedAmount = val
    end,
})

MainTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(val)
        Config.Main.Fly = val
    end,
})

MainTab:AddSlider({
    Name = "Fly Speed Amount",
    Min = 0,
    Max = 50,
    Default = 7,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "",
    Callback = function(val)
        Config.Main.FlySpeedAmount = val
    end,
})

MainTab:AddToggle({
    Name = "Jump Power",
    Default = false,
    Callback = function(val)
        Config.Main.JumpPower = val
    end,
})

MainTab:AddSlider({
    Name = "Jump Power Amount",
    Min = 0,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "",
    Callback = function(val)
        Config.Main.JumpPowerAmount = val
    end,
})

MainTab:AddSection({ Name = "Toggle Interfaces" })

MainTab:AddDropdown({
    Name = "Selected UI",
    Default = "ThaShop",
    Options = { "ThaShop", "Phone", "Inventory", "Map" },
    Callback = function(val)
        Config.Main.SelectedUI = val
    end,
})

MainTab:AddToggle({
    Name = "Enable UI",
    Default = false,
    Callback = function(val)
        Config.Main.EnableUI = val
    end,
})

------------------------------------------------------------
-- MONEY TAB
------------------------------------------------------------
local MoneyTab = Window:MakeTab({
    Name = "Money",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

MoneyTab:AddSection({ Name = "Farming" })

MoneyTab:AddToggle({
    Name = "Auto Farm Construction",
    Default = false,
    Callback = function(val)
        Config.Money.AutoFarmConstruction = val
    end,
})

MoneyTab:AddToggle({
    Name = "Auto Farm Bank",
    Default = false,
    Callback = function(val)
        Config.Money.AutoFarmBank = val
    end,
})

MoneyTab:AddToggle({
    Name = "Auto Farm House",
    Default = false,
    Callback = function(val)
        Config.Money.AutoFarmHouse = val
    end,
})

MoneyTab:AddToggle({
    Name = "Auto Farm Studio",
    Default = false,
    Callback = function(val)
        Config.Money.AutoFarmStudio = val
    end,
})

MoneyTab:AddToggle({
    Name = "Auto Farm Dumpsters",
    Default = false,
    Callback = function(val)
        Config.Money.AutoFarmDumpsters = val
    end,
})

MoneyTab:AddSection({ Name = "Vulnerability Section" })

MoneyTab:AddButton({
    Name = "Generate Max Illegal Money Manual",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Info",
            Content = "Requires Ice-Fruit Cup In Inventory!",
            Time = 3,
        })
        -- Game-specific remote
    end,
})

MoneyTab:AddButton({
    Name = "Generate Max Illegal Money Auto",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Info",
            Content = "Need 5K To Do This!",
            Time = 3,
        })
        -- Game-specific remote
    end,
})

MoneyTab:AddSection({ Name = "Bank Actions" })

MoneyTab:AddTextbox({
    Name = "Money Amount",
    Default = "",
    TextDisappear = false,
    Callback = function(val)
        Config.Money.MoneyAmount = tonumber(val) or 0
    end,
})

MoneyTab:AddDropdown({
    Name = "Select Bank Action",
    Default = "Deposit",
    Options = { "Deposit", "Withdraw", "Drop" },
    Callback = function(val)
        Config.Money.SelectedBankAction = val
    end,
})

MoneyTab:AddButton({
    Name = "Apply Selected Bank Action",
    Callback = function()
        -- Game-specific remote using Config.Money.SelectedBankAction and Config.Money.MoneyAmount
    end,
})

MoneyTab:AddToggle({
    Name = "Auto Deposit",
    Default = false,
    Callback = function(val)
        Config.Money.AutoDeposit = val
    end,
})

MoneyTab:AddToggle({
    Name = "Auto Withdraw",
    Default = false,
    Callback = function(val)
        Config.Money.AutoWithdraw = val
    end,
})

MoneyTab:AddToggle({
    Name = "Auto Drop",
    Default = false,
    Callback = function(val)
        Config.Money.AutoDrop = val
    end,
})

MoneyTab:AddSection({ Name = "Duping Section" })

MoneyTab:AddButton({
    Name = "Duplicate Current Item",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Info",
            Content = "Can Take Few Tries!",
            Time = 3,
        })
        -- Game-specific remote
    end,
})

------------------------------------------------------------
-- MISCELLANEOUS TAB
------------------------------------------------------------
local MiscTab = Window:MakeTab({
    Name = "Miscellaneous",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

MiscTab:AddSection({ Name = "Local Player Modifications" })

MiscTab:AddToggle({
    Name = "Infinite Stamina",
    Default = false,
    Callback = function(val)
        Config.Misc.InfiniteStamina = val
    end,
})

MiscTab:AddToggle({
    Name = "Instant Respawn",
    Default = false,
    Callback = function(val)
        Config.Misc.InstantRespawn = val
    end,
})

MiscTab:AddToggle({
    Name = "Infinite Sleep",
    Default = false,
    Callback = function(val)
        Config.Misc.InfiniteSleep = val
    end,
})

MiscTab:AddToggle({
    Name = "Infinite Hunger",
    Default = false,
    Callback = function(val)
        Config.Misc.InfiniteHunger = val
    end,
})

MiscTab:AddToggle({
    Name = "Instant Interact",
    Default = false,
    Callback = function(val)
        Config.Misc.InstantInteract = val
    end,
})

MiscTab:AddToggle({
    Name = "Auto Pickup Cash",
    Default = false,
    Callback = function(val)
        Config.Misc.AutoPickupCash = val
    end,
})

MiscTab:AddToggle({
    Name = "Disable Blood Effects",
    Default = false,
    Callback = function(val)
        Config.Misc.DisableBloodEffects = val
    end,
})

MiscTab:AddToggle({
    Name = "Unlock Locked Cars",
    Default = false,
    Callback = function(val)
        Config.Misc.UnlockLockedCars = val
    end,
})

MiscTab:AddToggle({
    Name = "No Rent Pay",
    Default = false,
    Callback = function(val)
        Config.Misc.NoRentPay = val
    end,
})

MiscTab:AddToggle({
    Name = "No Fall Damage",
    Default = false,
    Callback = function(val)
        Config.Misc.NoFallDamage = val
    end,
})

MiscTab:AddToggle({
    Name = "Respawn Where You Died",
    Default = false,
    Callback = function(val)
        Config.Misc.RespawnWhereDied = val
    end,
})

MiscTab:AddSection({ Name = "Purchase Selected Item" })

MiscTab:AddDropdown({
    Name = "Purchase Selected Item",
    Default = ".TecMag - $20",
    Options = { ".TecMag - $20", ".GlockMag - $15", ".AR Mag - $50" },
    Callback = function(val)
        Config.Misc.SelectedItem = val
    end,
})

MiscTab:AddButton({
    Name = "Purchase",
    Callback = function()
        -- Game-specific remote
    end,
})

MiscTab:AddSection({ Name = "Teleport To Location" })

MiscTab:AddDropdown({
    Name = "Teleport Options",
    Default = "Basketball Court",
    Options = {
        "Basketball Court", "Gun Store", "Bank", "Hospital",
        "Police Station", "Car Dealer", "Studio", "Apartments",
        "Gas Station", "Clothing Store", "Barber Shop",
    },
    Callback = function(val)
        Config.Misc.TeleportLocation = val
    end,
})

MiscTab:AddButton({
    Name = "Teleport",
    Callback = function()
        -- Teleport to predefined coordinates based on Config.Misc.TeleportLocation
    end,
})

MiscTab:AddSection({ Name = "Outfits" })

MiscTab:AddDropdown({
    Name = "Select Outfit",
    Default = "Amiri Outfit",
    Options = { "Amiri Outfit", "Nike Tech", "Bape Set", "Default" },
    Callback = function(val)
        Config.Misc.SelectedOutfit = val
    end,
})

MiscTab:AddButton({
    Name = "Apply Selected Outfit",
    Callback = function()
        -- Game-specific remote
    end,
})

------------------------------------------------------------
-- COMBAT TAB
------------------------------------------------------------
local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

-- Silent Aim
CombatTab:AddSection({ Name = "Silent Aim - General" })

CombatTab:AddToggle({
    Name = "Silent Aim Enabled",
    Default = false,
    Callback = function(val)
        Config.Combat.SilentAim.Enabled = val
    end,
})

CombatTab:AddSection({ Name = "Silent Aim - Settings" })

CombatTab:AddToggle({
    Name = "SA Visible Check",
    Default = false,
    Callback = function(val)
        Config.Combat.SilentAim.VisibleCheck = val
    end,
})

CombatTab:AddDropdown({
    Name = "SA Aimlock Type",
    Default = "Mouse",
    Options = { "Mouse", "Camera", "Closest" },
    Callback = function(val)
        Config.Combat.SilentAim.AimlockType = val
    end,
})

CombatTab:AddDropdown({
    Name = "SA Target Parts",
    Default = "Head",
    Options = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Callback = function(val)
        Config.Combat.SilentAim.TargetParts = val
    end,
})

CombatTab:AddSlider({
    Name = "SA Max Distance",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "%",
    Callback = function(val)
        Config.Combat.SilentAim.MaxDistance = val
    end,
})

CombatTab:AddSlider({
    Name = "SA Smoothness",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "%",
    Callback = function(val)
        Config.Combat.SilentAim.Smoothness = val
    end,
})

CombatTab:AddSection({ Name = "Silent Aim - FOV" })

CombatTab:AddToggle({
    Name = "SA FOV Enabled",
    Default = false,
    Callback = function(val)
        Config.Combat.SilentAim.FOVEnabled = val
    end,
})

CombatTab:AddToggle({
    Name = "SA Draw Circle",
    Default = false,
    Callback = function(val)
        Config.Combat.SilentAim.DrawCircle = val
    end,
})

CombatTab:AddSlider({
    Name = "SA FOV Radius",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "%",
    Callback = function(val)
        Config.Combat.SilentAim.FOVRadius = val
    end,
})

CombatTab:AddSlider({
    Name = "SA FOV Sides",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "%",
    Callback = function(val)
        Config.Combat.SilentAim.FOVSides = val
    end,
})

CombatTab:AddSection({ Name = "Silent Aim - Snapline" })

CombatTab:AddToggle({
    Name = "SA Snapline Enabled",
    Default = false,
    Callback = function(val)
        Config.Combat.SilentAim.SnaplineEnabled = val
    end,
})

CombatTab:AddSlider({
    Name = "SA Snapline Thickness",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "%",
    Callback = function(val)
        Config.Combat.SilentAim.SnaplineThickness = val
    end,
})

-- Aimlock
CombatTab:AddSection({ Name = "Aimlock - General" })

CombatTab:AddToggle({
    Name = "Aimlock Enabled",
    Default = false,
    Callback = function(val)
        Config.Combat.Aimlock.Enabled = val
    end,
})

CombatTab:AddSection({ Name = "Aimlock - Settings" })

CombatTab:AddToggle({
    Name = "AL Visible Check",
    Default = false,
    Callback = function(val)
        Config.Combat.Aimlock.VisibleCheck = val
    end,
})

CombatTab:AddDropdown({
    Name = "AL Aimlock Type",
    Default = "Mouse",
    Options = { "Mouse", "Camera", "Closest" },
    Callback = function(val)
        Config.Combat.Aimlock.AimlockType = val
    end,
})

CombatTab:AddDropdown({
    Name = "AL Target Parts",
    Default = "Head",
    Options = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Callback = function(val)
        Config.Combat.Aimlock.TargetParts = val
    end,
})

CombatTab:AddSlider({
    Name = "AL Max Distance",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "%",
    Callback = function(val)
        Config.Combat.Aimlock.MaxDistance = val
    end,
})

CombatTab:AddSlider({
    Name = "AL Smoothness",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "%",
    Callback = function(val)
        Config.Combat.Aimlock.Smoothness = val
    end,
})

CombatTab:AddSection({ Name = "Aimlock - FOV" })

CombatTab:AddToggle({
    Name = "AL FOV Enabled",
    Default = false,
    Callback = function(val)
        Config.Combat.Aimlock.FOVEnabled = val
    end,
})

CombatTab:AddToggle({
    Name = "AL Draw Circle",
    Default = false,
    Callback = function(val)
        Config.Combat.Aimlock.DrawCircle = val
    end,
})

CombatTab:AddSlider({
    Name = "AL FOV Radius",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "%",
    Callback = function(val)
        Config.Combat.Aimlock.FOVRadius = val
    end,
})

CombatTab:AddSlider({
    Name = "AL FOV Sides",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "%",
    Callback = function(val)
        Config.Combat.Aimlock.FOVSides = val
    end,
})

CombatTab:AddSection({ Name = "Aimlock - Snapline" })

CombatTab:AddToggle({
    Name = "AL Snapline Enabled",
    Default = false,
    Callback = function(val)
        Config.Combat.Aimlock.SnaplineEnabled = val
    end,
})

CombatTab:AddSlider({
    Name = "AL Snapline Thickness",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "%",
    Callback = function(val)
        Config.Combat.Aimlock.SnaplineThickness = val
    end,
})

------------------------------------------------------------
-- VISUALS TAB
------------------------------------------------------------
local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

VisualsTab:AddSection({ Name = "Enable ESP" })

VisualsTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(val)
        Config.Visuals.EnableESP = val
    end,
})

VisualsTab:AddSection({ Name = "Box ESP" })

VisualsTab:AddToggle({
    Name = "Corner Frame ESP",
    Default = false,
    Callback = function(val)
        Config.Visuals.CornerFrameESP = val
    end,
})

VisualsTab:AddToggle({
    Name = "Box ESP",
    Default = false,
    Callback = function(val)
        Config.Visuals.BoxESP = val
    end,
})

VisualsTab:AddSection({ Name = "Healthbar ESP" })

VisualsTab:AddToggle({
    Name = "Health Bar",
    Default = false,
    Callback = function(val)
        Config.Visuals.HealthBar = val
    end,
})

VisualsTab:AddToggle({
    Name = "Health Text",
    Default = false,
    Callback = function(val)
        Config.Visuals.HealthText = val
    end,
})

VisualsTab:AddToggle({
    Name = "Lerp Health Color",
    Default = false,
    Callback = function(val)
        Config.Visuals.LerpHealthColor = val
    end,
})

VisualsTab:AddToggle({
    Name = "Gradient Health",
    Default = false,
    Callback = function(val)
        Config.Visuals.GradientHealth = val
    end,
})

VisualsTab:AddSection({ Name = "ESP Settings" })

VisualsTab:AddToggle({
    Name = "Distance",
    Default = false,
    Callback = function(val)
        Config.Visuals.Distance = val
    end,
})

VisualsTab:AddSlider({
    Name = "Max Distance",
    Min = 0,
    Max = 5000,
    Default = 2000,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 50,
    ValueName = " studs",
    Callback = function(val)
        Config.Visuals.MaxDistance = val
    end,
})

VisualsTab:AddSection({ Name = "Cham ESP" })

VisualsTab:AddToggle({
    Name = "Chams",
    Default = false,
    Callback = function(val)
        Config.Visuals.Chams = val
    end,
})

VisualsTab:AddToggle({
    Name = "Thermal Effect",
    Default = false,
    Callback = function(val)
        Config.Visuals.ThermalEffect = val
    end,
})

VisualsTab:AddToggle({
    Name = "Visible Check",
    Default = false,
    Callback = function(val)
        Config.Visuals.VisibleCheck = val
    end,
})

VisualsTab:AddSlider({
    Name = "Fill Transparency",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "%",
    Callback = function(val)
        Config.Visuals.FillTransparency = val
    end,
})

VisualsTab:AddSlider({
    Name = "Outline Transparency",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "%",
    Callback = function(val)
        Config.Visuals.OutlineTransparency = val
    end,
})

VisualsTab:AddSection({ Name = "World Visuals" })

------------------------------------------------------------
-- SETTINGS TAB
------------------------------------------------------------
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

SettingsTab:AddSection({ Name = "UI Settings" })

SettingsTab:AddBind({
    Name = "Close / Open Bind",
    Default = Enum.KeyCode.RightShift,
    Hold = false,
    Callback = function()
        OrionLib:Destroy()
    end,
})

SettingsTab:AddButton({
    Name = "Destroy GUI",
    Callback = function()
        OrionLib:Destroy()
    end,
})

------------------------------------------------------------
-- CORE LOOPS (Feature Logic)
------------------------------------------------------------

-- NoClip Loop
RunService.Stepped:Connect(function()
    pcall(function()
        if Config.Main.NoClip and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- Speed Loop
RunService.Heartbeat:Connect(function()
    pcall(function()
        if Config.Main.Speed and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16 + Config.Main.SpeedAmount
            end
        end
    end)
end)

-- Jump Power Loop
RunService.Heartbeat:Connect(function()
    pcall(function()
        if Config.Main.JumpPower and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = Config.Main.JumpPowerAmount
            end
        end
    end)
end)

-- Fly System
local flyBodyVelocity = nil
local flyBodyGyro = nil

RunService.Heartbeat:Connect(function()
    pcall(function()
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
end)

-- ESP System
local espObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end

    local espData = {}

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0, 120, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = Config.Visuals.FillTransparency / 100
    highlight.OutlineTransparency = Config.Visuals.OutlineTransparency / 100
    highlight.Enabled = false
    espData.Highlight = highlight

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
        pcall(function()
            highlight.Adornee = character
            highlight.Parent = character
            local head = character:WaitForChild("Head", 5)
            if head then
                billboard.Parent = head
            end
        end)
    end

    if player.Character then
        task.spawn(function()
            onCharacterAdded(player.Character)
        end)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

local function removeESP(player)
    local data = espObjects[player]
    if data then
        pcall(function()
            if data.Highlight then data.Highlight:Destroy() end
            if data.Billboard then data.Billboard:Destroy() end
        end)
        espObjects[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    pcall(function()
        for player, data in pairs(espObjects) do
            local enabled = Config.Visuals.EnableESP
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if enabled and character and hrp and localHrp then
                local dist = (hrp.Position - localHrp.Position).Magnitude

                if dist <= Config.Visuals.MaxDistance then
                    data.Highlight.Enabled = Config.Visuals.Chams
                    data.Highlight.FillTransparency = Config.Visuals.FillTransparency / 100
                    data.Highlight.OutlineTransparency = Config.Visuals.OutlineTransparency / 100
                    data.Billboard.Enabled = true

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
end)

-- FOV Circle (only works on executors with Drawing support)
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.Color = Color3.fromRGB(0, 120, 255)
fovCircle.Filled = false
fovCircle.Transparency = 0.7
fovCircle.Visible = false

RunService.RenderStepped:Connect(function()
    pcall(function()
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
    pcall(function()
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
end)

-- Auto Pickup Cash Loop
RunService.Heartbeat:Connect(function()
    pcall(function()
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
end)

-- No Fall Damage / State hooks
RunService.Heartbeat:Connect(function()
    pcall(function()
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                if Config.Misc.NoFallDamage then
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                end
            end
        end
    end)
end)

------------------------------------------------------------
-- Init notification
------------------------------------------------------------
OrionLib:MakeNotification({
    Name = "Synapse-Xenon",
    Content = "Tha Bronx 3 script loaded successfully!",
    Image = "rbxassetid://4483345998",
    Time = 5,
})

OrionLib:Init()
