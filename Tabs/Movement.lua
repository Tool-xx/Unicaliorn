-- Tabs/Movement.lua
-- Movement tab: Noclip, Speedhack, Fly, InfinityJump + speed sliders
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
    content.Name = "Content_Movement"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = COLORS.Border
    content.CanvasSize = UDim2.new(0, 0, 0, 360)
    content.Visible = false
    content.Parent = Context.UI.ContentFrame

    -- Noclip Toggle
    local noclipToggle = Components.createToggle(content, "Noclip", 10, function(enabled)
        if Context.Features.Noclip then
            if enabled then
                Context.Features.Noclip.Enable()
            else
                Context.Features.Noclip.Disable()
            end
        end
    end)

    if FeatureState.noclipEnabled then
        noclipToggle.setEnabled(true)
    end

    -- Speedhack Toggle
    local speedhackToggle = Components.createToggle(content, "Speedhack", 50, function(enabled)
        if Context.Features.Speedhack then
            if enabled then
                Context.Features.Speedhack.Enable()
            else
                Context.Features.Speedhack.Disable()
            end
        end
    end)

    if FeatureState.speedhackEnabled then
        speedhackToggle.setEnabled(true)
    end

    -- Speed Slider
    Components.createSlider(content, "Speed (At 200+, anti-cheat can be triggered)", 85,
        Config.DEFAULTS.SpeedhackMin,
        Config.DEFAULTS.SpeedhackMax,
        FeatureState.speedhackSpeed or Config.DEFAULTS.WalkSpeed,
        function(value)
            if Context.Features.Speedhack then
                Context.Features.Speedhack.SetSpeed(value)
            end
        end
    )

    -- Fly Toggle
    local flyToggle = Components.createToggle(content, "Fly", 135, function(enabled)
        if Context.Features.Fly then
            if enabled then
                -- Disable speedhack if active (conflict)
                if FeatureState.speedhackEnabled and Context.Features.Speedhack then
                    Context.Features.Speedhack.Disable()
                    speedhackToggle.setEnabled(false)
                end
                Context.Features.Fly.Start()
            else
                Context.Features.Fly.Stop()
            end
        end
    end)

    if FeatureState.flyEnabled then
        flyToggle.setEnabled(true)
    end

    -- Fly Speed Slider
    Components.createSlider(content, "Fly Speed (At 200+, anti-cheat can be triggered)", 170,
        Config.DEFAULTS.FlyMin,
        Config.DEFAULTS.FlyMax,
        FeatureState.flySpeed or Config.DEFAULTS.FlySpeed,
        function(value)
            if Context.Features.Fly then
                Context.Features.Fly.SetSpeed(value)
            end
        end
    )

    -- Infinity Jump Toggle
    local infJumpToggle = Components.createToggle(content, "Infinitejump", 220, function(enabled)
        if Context.Features.InfinityJump then
            if enabled then
                Context.Features.InfinityJump.Enable()
            else
                Context.Features.InfinityJump.Disable()
            end
        end
    end)

    if FeatureState.infinityJumpEnabled then
        infJumpToggle.setEnabled(true)
    end

    -- Register tab
    Context.UI.Main.registerTabContent("Movement", content)

    print("[Tab] Movement loaded.")
    return content
end
