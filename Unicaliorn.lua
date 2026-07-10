-- Unicaliorn.lua - Main Entry Point
-- Loads all modules, initializes GUI, features, and starts the script.

if _G.UnicaliornLoaded then
    return
end
_G.UnicaliornLoaded = true

local BASE_URL = "https://raw.githubusercontent.com/Tool-xx/Unicaliorn/main/"

-- Simple HTTP GET with error handling
local function httpGet(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not success then
        warn("[Unicaliorn] Failed to fetch: " .. url .. " - " .. tostring(result))
        return nil
    end
    return result
end

-- Load and execute a Lua module from URL, returning its result
local function loadModule(moduleName)
    local url = BASE_URL .. moduleName .. ".lua"
    local source = httpGet(url)
    if not source then
        return nil
    end

    local success, result = pcall(function()
        return loadstring(source)()
    end)
    if not success then
        warn("[Unicaliorn] Failed to load module " .. moduleName .. ": " .. tostring(result))
        return nil
    end
    return result
end

print("[Unicaliorn] Loading modules...")

-- 1. Config (pure data)
local Config = loadModule("Config")
if not Config then
    error("Config module failed to load")
end

-- 2. UI Components (depends on Config)
local Components = loadModule("UI/Components")
if not Components then
    error("UI Components module failed to load")
end

-- Initialize Components with Config if needed (assuming Components.init exists)
if Components.init then
    Components.init(Config)
end

-- 3. UI (depends on Config, Components)
local UI = loadModule("UI/UI")
if not UI then
    error("UI module failed to load")
end

-- Initialize UI
if UI.init then
    UI.init(Config, Components)
end

-- 4. Features (each is a constructor function)
local FeatureConstructors = {
    ESP = loadModule("Features/ESP"),
    Spectate = loadModule("Features/Spectate"),
    Mark = loadModule("Features/Mark"),
    AntiAFK = loadModule("Features/AntiAFK"),
    FPSPing = loadModule("Features/FPSPing"),
    Noclip = loadModule("Features/Noclip"),
    Speedhack = loadModule("Features/Speedhack"),
    Fly = loadModule("Features/Fly"),
    InfinityJump = loadModule("Features/InfinityJump"),
}

-- Create instances of features, passing Config and a services table if needed
local services = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    MarketplaceService = game:GetService("MarketplaceService"),
    TeleportService = game:GetService("TeleportService"),
    StarterGui = game:GetService("StarterGui"),
    HttpService = game:GetService("HttpService"),
}

local features = {}
for name, ctor in pairs(FeatureConstructors) do
    if ctor then
        local instance = ctor(Config, services) -- or ctor(Config, services, UI)
        if instance then
            features[name] = instance
            print("[Unicaliorn] Feature loaded: " .. name)
        else
            warn("[Unicaliorn] Feature constructor returned nil: " .. name)
        end
    else
        warn("[Unicaliorn] Feature module not found: " .. name)
    end
end

-- 5. Windows (UI windows)
local ServerInfo = loadModule("UI/Windows/ServerInfo")
local PlayerProfile = loadModule("UI/Windows/PlayerProfile")

-- 6. Tabs (content factories)
local TabConstructors = {
    General = loadModule("Tabs/General"),
    Players = loadModule("Tabs/Players"),
    Misc = loadModule("Tabs/Misc"),
    Movement = loadModule("Tabs/Movement"),
    Visual = loadModule("Tabs/Visual"),
}

local tabs = {}
for name, ctor in pairs(TabConstructors) do
    if ctor then
        -- Each tab factory receives Config, UI, Components, features, windows, etc.
        local contentFrame = ctor(Config, UI, Components, features, {ServerInfo = ServerInfo, PlayerProfile = PlayerProfile})
        if contentFrame then
            tabs[name] = contentFrame
            UI.registerTab(name, contentFrame)
            print("[Unicaliorn] Tab registered: " .. name)
        else
            warn("[Unicaliorn] Tab factory returned nil: " .. name)
        end
    else
        warn("[Unicaliorn] Tab module not found: " .. name)
    end
end

-- 7. FeatureManager (optional, can integrate here or let tabs handle features directly)
local FeatureManager = loadModule("FeatureManager")
if FeatureManager then
    if FeatureManager.init then
        FeatureManager.init(Config, UI, features, tabs)
    end
end

-- 8. Show UI with animation
UI:show()

-- 9. Cleanup on UI close
UI:onClose(function()
    print("[Unicaliorn] Shutting down...")
    -- Disable all active features
    for name, feature in pairs(features) do
        if feature.isEnabled and feature.isEnabled() then
            pcall(feature.disable, feature)
        end
    end
    _G.UnicaliornLoaded = nil
end)

print("[Unicaliorn] Loaded successfully!")
