-- Tabs/Visual.lua
-- Visual tab: ESP toggle + simple toggles for Box, Hitbox, Skeleton
-- All ESP uses dynamic black-white gradient (no color selection)
-- Receives Context, returns tab content frame

return function(Context)
    local TweenService = Context.Services.TweenService
    local Config = Context.Config
    local COLORS = Config.COLORS
    local TWEEN = Config.TWEEN
    local Components = Context.UI.Components
    local FeatureState = Context.FeatureState

    -- ============================================================
    -- CREATE CONTENT
    -- ============================================================
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content_Visual"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = COLORS.Border
    content.CanvasSize = UDim2.new(0, 0, 0, 260)
    content.Visible = false
    content.Parent = Context.UI.ContentFrame

    -- ============================================================
    -- ESP HEADER (main toggle + settings expand)
    -- ============================================================
    local espHeader = Instance.new("Frame")
    espHeader.Name = "ESPHeader"
    espHeader.Size = UDim2.new(1, -20, 0, 30)
    espHeader.Position = UDim2.new(0, 10, 0, 10)
    espHeader.BackgroundColor3 = COLORS.Background
    espHeader.BorderSizePixel = 0
    espHeader.Parent = content

    local espLabel = Instance.new("TextLabel")
    espLabel.Size = UDim2.new(1, -60, 1, 0)
    espLabel.Position = UDim2.new(0, 5, 0, 0)
    espLabel.BackgroundTransparency = 1
    espLabel.Text = "ESP"
    espLabel.TextColor3 = COLORS.Text
    espLabel.TextSize = 14
    espLabel.Font = Enum.Font.Gotham
    espLabel.TextXAlignment = Enum.TextXAlignment.Left
    espLabel.Parent = espHeader

    -- ESP Toggle BG
    local espToggleBg = Instance.new("TextButton")
    espToggleBg.Size = UDim2.new(0, 50, 0, 22)
    espToggleBg.Position = UDim2.new(1, -55, 0.5, -11)
    espToggleBg.BackgroundColor3 = COLORS.ToggleOff
    espToggleBg.BorderSizePixel = 1
    espToggleBg.BorderColor3 = COLORS.Border
    espToggleBg.Text = ""
    espToggleBg.AutoButtonColor = false
    espToggleBg.Parent = espHeader

    local espToggleKnob = Instance.new("Frame")
    espToggleKnob.Size = UDim2.new(0, 18, 0, 18)
    espToggleKnob.Position = UDim2.new(0, 2, 0.5, -9)
    espToggleKnob.BackgroundColor3 = COLORS.Text
    espToggleKnob.BorderSizePixel = 0
    espToggleKnob.Parent = espToggleBg

    -- Settings Toggle Button (▼/▲)
    local settingsToggleBtn = Instance.new("TextButton")
    settingsToggleBtn.Name = "SettingsToggle"
    settingsToggleBtn.Size = UDim2.new(0, 30, 0, 22)
    settingsToggleBtn.Position = UDim2.new(1, -90, 0.5, -11)
    settingsToggleBtn.BackgroundColor3 = COLORS.Background
    settingsToggleBtn.BorderSizePixel = 1
    settingsToggleBtn.BorderColor3 = COLORS.Border
    settingsToggleBtn.Text = "▼"
    settingsToggleBtn.TextColor3 = COLORS.Text
    settingsToggleBtn.TextSize = 12
    settingsToggleBtn.Font = Enum.Font.GothamBold
    settingsToggleBtn.AutoButtonColor = false
    settingsToggleBtn.Parent = espHeader

    -- ESP Toggle Logic
    local espToggleEnabled = false
    espToggleBg.MouseButton1Click:Connect(function()
        espToggleEnabled = not espToggleEnabled
        if espToggleEnabled then
            TweenService:Create(espToggleBg, TWEEN.Hover, {BackgroundColor3 = COLORS.ToggleOn}):Play()
            TweenService:Create(espToggleKnob, TWEEN.Hover, {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
            if Context.Features.ESP then
                Context.Features.ESP.Enable()
            end
        else
            TweenService:Create(espToggleBg, TWEEN.Hover, {BackgroundColor3 = COLORS.ToggleOff}):Play()
            TweenService:Create(espToggleKnob, TWEEN.Hover, {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
            if Context.Features.ESP then
                Context.Features.ESP.Disable()
            end
        end
    end)

    -- Sync with current state
    if FeatureState.espEnabled then
        espToggleEnabled = true
        espToggleBg.BackgroundColor3 = COLORS.ToggleOn
        espToggleKnob.Position = UDim2.new(1, -20, 0.5, -9)
    end

    -- Settings Frame (collapsible)
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "ESP_Settings"
    settingsFrame.Size = UDim2.new(1, -20, 0, 0)
    settingsFrame.Position = UDim2.new(0, 10, 0, 45)
    settingsFrame.BackgroundColor3 = COLORS.Background
    settingsFrame.BorderSizePixel = 1
    settingsFrame.BorderColor3 = COLORS.Border
    settingsFrame.ClipsDescendants = true
    settingsFrame.Visible = true
    settingsFrame.Parent = content

    local settingsOpen = false
    local targetHeight = 150

    settingsToggleBtn.MouseButton1Click:Connect(function()
        settingsOpen = not settingsOpen
        if settingsOpen then
            settingsToggleBtn.Text = "▲"
            TweenService:Create(settingsFrame, TWEEN.Open, {Size = UDim2.new(1, -20, 0, targetHeight)}):Play()
        else
            settingsToggleBtn.Text = "▼"
            TweenService:Create(settingsFrame, TWEEN.Close, {Size = UDim2.new(1, -20, 0, 0)}):Play()
        end
    end)

    -- ============================================================
    -- ESP SUB-TOGGLES (Box, Hitbox, Skeleton) - NO GEAR ICONS
    -- ============================================================
    local yOffset = 10

    -- Box Toggle
    local boxToggle = Components.createToggle(settingsFrame, "Box", yOffset, function(enabled)
        if Context.Features.ESP then
            if enabled then
                Context.Features.ESP.EnableBox()
            else
                Context.Features.ESP.DisableBox()
            end
        end
    end)
    if FeatureState.espBoxEnabled then
        boxToggle.setEnabled(true)
    end
    yOffset = yOffset + 40

    -- Hitbox Toggle
    local hitboxToggle = Components.createToggle(settingsFrame, "Hitbox", yOffset, function(enabled)
        if Context.Features.ESP then
            if enabled then
                Context.Features.ESP.EnableHitbox()
            else
                Context.Features.ESP.DisableHitbox()
            end
        end
    end)
    if FeatureState.espHitboxEnabled then
        hitboxToggle.setEnabled(true)
    end
    yOffset = yOffset + 40

    -- Skeleton Toggle
    local skeletonToggle = Components.createToggle(settingsFrame, "Skeleton", yOffset, function(enabled)
        if Context.Features.ESP then
            if enabled then
                Context.Features.ESP.EnableSkeleton()
            else
                Context.Features.ESP.DisableSkeleton()
            end
        end
    end)
    if FeatureState.espHitboxEnabled then
        skeletonToggle.setEnabled(true)
    end
    yOffset = yOffset + 40

    targetHeight = yOffset + 10
    settingsFrame.Size = UDim2.new(1, -20, 0, 0)

    -- ============================================================
    -- GRADIENT INFO LABEL
    -- ============================================================
    local gradientLabel = Instance.new("TextLabel")
    gradientLabel.Size = UDim2.new(1, -20, 0, 20)
    gradientLabel.Position = UDim2.new(0, 10, 0, 210)
    gradientLabel.BackgroundTransparency = 1
    gradientLabel.Text = "ESP uses dynamic black-white gradient"
    gradientLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    gradientLabel.TextSize = 11
    gradientLabel.Font = Enum.Font.Gotham
    gradientLabel.TextXAlignment = Enum.TextXAlignment.Left
    gradientLabel.Parent = content

    -- Register tab
    Context.UI.Main.registerTabContent("Visual", content)

    print("[Tab] Visual loaded (gradient ESP, no color picker).")
    return content
end
