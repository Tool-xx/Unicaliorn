-- Config.lua - Global configuration constants for Unicaliorn
return {
    -- Colors used in UI and features
    Colors = {
        Background = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(64, 64, 64),
        Text = Color3.fromRGB(255, 255, 255),
        ButtonHover = Color3.fromRGB(25, 25, 25),
        ButtonActive = Color3.fromRGB(35, 35, 35),
        CloseButton = Color3.fromRGB(255, 255, 255),
        ToggleOn = Color3.fromRGB(60, 60, 60),
        ToggleOff = Color3.fromRGB(30, 30, 30),
        SliderFill = Color3.fromRGB(80, 80, 80),
        SliderBg = Color3.fromRGB(20, 20, 20),
        Overlay = Color3.fromRGB(0, 0, 0),
        HealthGreen = Color3.fromRGB(0, 255, 0),
        HealthRed = Color3.fromRGB(255, 0, 0),
        MarkColor = Color3.fromRGB(255, 0, 0),
    },

    -- Animation presets for TweenService
    TweenPresets = {
        Open = TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        Close = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        Hover = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        Appear = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        Fade = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        Drag = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    },

    -- Default values for various features
    Defaults = {
        SpeedhackSpeed = 16,
        FlySpeed = 50,
        SpectateDistance = 10,
        ESP = {
            BoxColor = Color3.fromRGB(255, 255, 255),
            HitboxColor = Color3.fromRGB(255, 0, 0),
            SkeletonColor = Color3.fromRGB(0, 255, 0),
        },
        -- Main window size (used by UI)
        WindowSize = UDim2.new(0, 550, 0, 400),
    },
}
