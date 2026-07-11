-- Unicaliorn Script
-- Universal GUI Script with Modular Architecture
-- Entry point: loads all modules via GitHub raw URLs

if _G.UnicaliornLoaded then return end
_G.UnicaliornLoaded = true

local SCRIPT_START_TIME = os.time()
print("[Unicaliorn] Initializing modular system...")

-- ============================================================
-- CONFIGURATION: Update this with your actual GitHub raw URL
-- ============================================================
local BASE_URL = "https://raw.githubusercontent.com/Tool-xx/Unicaliorn/main/"

-- Helper to load a module from GitHub
local function loadModule(path)
    local url = BASE_URL .. path
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not success then
        warn("[Unicaliorn] Failed to fetch: " .. url .. " | Error: " .. tostring(result))
        return nil
    end
    local loadSuccess, loaded = pcall(function()
        return loadstring(result)
    end)
    if not loadSuccess then
        warn("[Unicaliorn] Failed to parse: " .. path .. " | Error: " .. tostring(loaded))
        return nil
    end
    local execSuccess, module = pcall(loaded)
    if not execSuccess then
        warn("[Unicaliorn] Failed to execute: " .. path .. " | Error: " .. tostring(module))
        return nil
    end
    print("[Unicaliorn] Loaded: " .. path)
    return module
end

-- ============================================================
-- STEP 1: Load Config (colors, tween presets, constants)
-- ============================================================
local Config = loadModule("Config.lua")
if not Config then
    warn("[Unicaliorn] CRITICAL: Config.lua failed to load. Aborting.")
    return
end

-- ============================================================
-- STEP 2: Load Core Context (services, shared state)
-- ============================================================
local Context = loadModule("Core/Context.lua")
if not Context then
    warn("[Unicaliorn] CRITICAL: Core/Context.lua failed to load. Aborting.")
    return
end

-- Inject Config, BASE_URL and script start time into Context
Context.Config = Config
Context.BASE_URL = BASE_URL
Context.SCRIPT_START_TIME = SCRIPT_START_TIME

-- ============================================================
-- STEP 3: Load UI Components (needed by Tabs and Windows)
-- ============================================================
Context.UI = {}

Context.UI.Components = loadModule("UI/Components.lua")
if Context.UI.Components then
    Context.UI.Components(Context)
else
    warn("[Unicaliorn] WARNING: UI/Components.lua failed to load.")
end

Context.UI.WindowManager = loadModule("UI/WindowManager.lua")
if Context.UI.WindowManager then
    Context.UI.WindowManager(Context)
else
    warn("[Unicaliorn] WARNING: UI/WindowManager.lua failed to load.")
end

-- ============================================================
-- STEP 4: Load Main GUI (creates ScreenGui, MainFrame, etc.)
-- ============================================================
Context.UI.Main = loadModule("UI/MainGUI.lua")
if Context.UI.Main then
    Context.UI.Main(Context)
else
    warn("[Unicaliorn] CRITICAL: UI/MainGUI.lua failed to load. Aborting.")
    return
end

-- ============================================================
-- STEP 5: Load Notification (show injection popup)
-- ============================================================
local Notification = loadModule("UI/Notification.lua")
if Notification then
    local notifModule = Notification(Context)
    if notifModule and notifModule.Show then
        task.defer(function()
            notifModule.Show()
        end)
    end
else
    warn("[Unicaliorn] WARNING: UI/Notification.lua failed to load.")
end

-- ============================================================
-- STEP 6: Load Utils (shared helpers)
-- ============================================================
Context.Utils = loadModule("Utils/Helpers.lua")
if Context.Utils then
    Context.Utils(Context)
else
    warn("[Unicaliorn] WARNING: Utils/Helpers.lua failed to load.")
end

-- ============================================================
-- STEP 7: Load Features (ESP, Fly, Noclip, etc.)
-- ============================================================
Context.Features = {}

local featureFiles = {
    "ESP",
    "Spectate",
    "Mark",
    "AntiAFK",
    "FPSPing",
    "Noclip",
    "Speedhack",
    "Fly",
    "InfinityJump",
    "Plugins"
}

for _, name in ipairs(featureFiles) do
    local module = loadModule("Features/" .. name .. ".lua")
    if module then
        local success, feature = pcall(function() return module(Context) end)
        if success then
            Context.Features[name] = feature
            print("[Unicaliorn] Feature registered: " .. name)
        else
            warn("[Unicaliorn] Feature init failed: " .. name .. " | " .. tostring(feature))
        end
    else
        warn("[Unicaliorn] Feature load failed: " .. name)
    end
end

-- ============================================================
-- STEP 8: Load Windows (ServerInfo, PlayerProfile)
-- ============================================================
Context.Windows = {}

local windowFiles = {
    "ServerInfo",
    "PlayerProfile"
}

for _, name in ipairs(windowFiles) do
    local module = loadModule("Windows/" .. name .. ".lua")
    if module then
        local success, window = pcall(function() return module(Context) end)
        if success then
            Context.Windows[name] = window
            print("[Unicaliorn] Window registered: " .. name)
        else
            warn("[Unicaliorn] Window init failed: " .. name .. " | " .. tostring(window))
        end
    else
        warn("[Unicaliorn] Window load failed: " .. name)
    end
end

-- ============================================================
-- STEP 9: Load Tabs (General, Players, Misc, Movement, Visual)
-- ============================================================
local Tabs = {}

local tabFiles = {
    "General",
    "Players",
    "Misc",
    "Movement",
    "Visual"
}

for _, name in ipairs(tabFiles) do
    local module = loadModule("Tabs/" .. name .. ".lua")
    if module then
        local success, tab = pcall(function() return module(Context) end)
        if success then
            Tabs[name] = tab
            print("[Unicaliorn] Tab registered: " .. name)
        else
            warn("[Unicaliorn] Tab init failed: " .. name .. " | " .. tostring(tab))
        end
    else
        warn("[Unicaliorn] Tab load failed: " .. name)
    end
end

-- ============================================================
-- STEP 10: Wire up Tab Switching & Activate First Tab
-- ============================================================
if Context.UI.Main and Context.UI.Main.setActiveTab then
    -- Wire sidebar buttons to tab switching
    if Context.UI.Main.sidebarButtons then
        for _, button in ipairs(Context.UI.Main.sidebarButtons) do
            button.MouseButton1Click:Connect(function()
                Context.UI.Main.setActiveTab(button.Name)
            end)
        end
    end

    -- Activate first tab
    task.defer(function()
        Context.UI.Main.setActiveTab("General")
    end)
end

-- ============================================================
-- STEP 11: Animate Appearance
-- ============================================================
if Context.UI.Main and Context.UI.Main.animateAppearance then
    Context.UI.Main.animateAppearance()
end

print("[Unicaliorn] Loaded successfully! Modules: " .. 
    tostring(#featureFiles) .. " features, " .. 
    tostring(#windowFiles) .. " windows, " .. 
    tostring(#tabFiles) .. " tabs.")
