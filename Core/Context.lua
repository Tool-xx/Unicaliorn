-- Core/Context.lua
-- Factory for shared context: services, state, and global references
-- Returns a table that all modules receive as their single argument

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

return {
    -- ============================================================
    -- ROBLOX SERVICES
    -- ============================================================
    Services = {
        Players = Players,
        UserInputService = UserInputService,
        TweenService = TweenService,
        RunService = RunService,
        MarketplaceService = MarketplaceService,
        TeleportService = TeleportService,
        HttpService = HttpService,
        StarterGui = StarterGui,
    },

    -- ============================================================
    -- PLAYER REFERENCES
    -- ============================================================
    LocalPlayer = LocalPlayer,
    PlayerGui = PlayerGui,

    -- ============================================================
    -- CONFIG (injected by Unicaliorn.lua after loading Config.lua)
    -- ============================================================
    Config = nil,

    -- ============================================================
    -- SCRIPT START TIME (injected by Unicaliorn.lua)
    -- ============================================================
    SCRIPT_START_TIME = nil,

    -- ============================================================
    -- UI REFERENCES (populated by UI/MainGUI.lua)
    -- ============================================================
    UI = {
        ScreenGui = nil,
        MainFrame = nil,
        TitleBar = nil,
        TitleLabel = nil,
        MinimizeButton = nil,
        CloseButton = nil,
        TopSeparator = nil,
        Sidebar = nil,
        VerticalSeparator = nil,
        SidebarButtonsContainer = nil,
        ContentFrame = nil,
        -- Sub-modules
        Components = nil,
        WindowManager = nil,
        Main = nil,
    },

    -- ============================================================
    -- FEATURES REGISTRY (populated by Features/*.lua)
    -- ============================================================
    Features = {},

    -- ============================================================
    -- WINDOWS REGISTRY (populated by Windows/*.lua)
    -- ============================================================
    Windows = {},

    -- ============================================================
    -- UTILS (populated by Utils/Helpers.lua)
    -- ============================================================
    Utils = nil,

    -- ============================================================
    -- GLOBAL STATE FLAGS
    -- ============================================================
    State = {
        isMinimized = false,
        isClosing = false,
        activeButton = nil,
        activeColorMenu = nil,
        colorMenuConnections = {},
    },

    -- ============================================================
    -- FEATURE STATE (shared across modules)
    -- ============================================================
    FeatureState = {
        -- ESP (colors are dynamic gradient, no static storage needed)
        espEnabled = false,
        espBoxEnabled = true,
        espHitboxEnabled = false,
        espHighlights = {},
        espPlayerAddedConn = nil,
        espCharacterAddedConns = {},

        -- Spectate
        activeSpectatePlayer = nil,
        spectateConnection = nil,
        spectateInputConnection = nil,
        spectateWheelConnection = nil,
        spectateDistance = 10,
        spectateYaw = 0,
        spectatePitch = -math.rad(15),

        -- Mark
        markedPlayers = {},

        -- Anti-AFK
        antiAfkRunning = false,
        antiAfkLoopThread = nil,

        -- FPS / Ping
        fpsWindow = nil,
        fpsConnection = nil,
        pingWindow = nil,
        pingConnection = nil,

        -- Noclip
        noclipEnabled = false,
        noclipConnection = nil,

        -- Speedhack
        speedhackEnabled = false,
        speedhackSpeed = 16,
        speedhackCharConnection = nil,

        -- Fly
        flyEnabled = false,
        flySpeed = 50,
        flyCharConnection = nil,
        flyInputBegan = nil,
        flyInputEnded = nil,
        flyLoop = nil,
        flyBodyGyro = nil,
        flyBodyVelocity = nil,
        flyControl = {F=0, B=0, L=0, R=0, Q=0, E=0},
        flyLastControl = {F=0, B=0, L=0, R=0, Q=0, E=0},
        flyCurrentSpeed = 0,

        -- Infinity Jump
        infinityJumpEnabled = false,
        infinityJumpConnection = nil,
    },

    -- ============================================================
    -- HELPER: Safe disconnect
    -- ============================================================
    SafeDisconnect = function(connection)
        if connection and typeof(connection) == "RBXScriptConnection" then
            pcall(function() connection:Disconnect() end)
        end
        return nil
    end,

    -- ============================================================
    -- HELPER: Safe destroy
    -- ============================================================
    SafeDestroy = function(instance)
        if instance and typeof(instance) == "Instance" then
            pcall(function() instance:Destroy() end)
        end
        return nil
    end,

    -- ============================================================
    -- HELPER: Get Humanoid from Character
    -- ============================================================
    GetHumanoid = function(char)
        if not char then return nil end
        return char:FindFirstChildOfClass("Humanoid")
    end,

    -- ============================================================
    -- HELPER: Get HumanoidRootPart from Character
    -- ============================================================
    GetRootPart = function(char)
        if not char then return nil end
        return char:FindFirstChild("HumanoidRootPart")
    end,

    -- ============================================================
    -- HELPER: Format position vector
    -- ============================================================
    FormatPosition = function(pos)
        if not pos then return "0, 0, 0" end
        return string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
    end,

    -- ============================================================
    -- HELPER: Format health string
    -- ============================================================
    FormatHealth = function(health, maxHealth)
        return string.format("%.1f / %.1f", health or 0, maxHealth or 0)
    end,
}
