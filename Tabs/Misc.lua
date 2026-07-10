-- Tabs/Misc.lua
-- Misc tab: Anti-AFK, FPS Counter, Ping Counter toggles
-- Receives Context, returns tab content frame

return function(Context)
    local Config = Context.Config
    local COLORS = Config.COLORS
    local Components = Context.UI.Components
    local FeatureState = Context.FeatureState

    -- ============================================================
    -- CREATE CONTENT
    -- ============================================================
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content_Misc"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = COLORS.Border
    content.CanvasSize = UDim2.new(0, 0, 0, 200)
    content.Visible = false
    content.Parent = Context.UI.ContentFrame

    -- Anti-AFK Toggle
    local antiAfkToggle = Components.createToggle(content, "Anti-AFK", 10, function(enabled)
        if Context.Features.AntiAFK then
            if enabled then
                Context.Features.AntiAFK.Start()
            else
                Context.Features.AntiAFK.Stop()
            end
        end
    end)

    -- Sync with current state (in case module was already running)
    if FeatureState.antiAfkRunning then
        antiAfkToggle.setEnabled(true)
    end

    -- FPS Counter Toggle
    local fpsToggle = Components.createToggle(content, "FPS Counter", 50, function(enabled)
        if Context.Features.FPSPing then
            Context.Features.FPSPing.ToggleFPS(enabled)
        end
    end)

    if FeatureState.fpsWindow then
        fpsToggle.setEnabled(true)
    end

    -- Ping Counter Toggle
    local pingToggle = Components.createToggle(content, "Ping Counter", 90, function(enabled)
        if Context.Features.FPSPing then
            Context.Features.FPSPing.TogglePing(enabled)
        end
    end)

    if FeatureState.pingWindow then
        pingToggle.setEnabled(true)
    end

    -- Register tab
    Context.UI.Main.registerTabContent("Misc", content)

    print("[Tab] Misc loaded.")
    return content
end
