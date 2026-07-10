-- Config.lua
-- Colors, Tween presets, and shared constants for Unicaliorn

return {
    -- ============================================================
    -- COLORS
    -- ============================================================
    COLORS = {
        Background      = Color3.fromRGB(0, 0, 0),
        Border          = Color3.fromRGB(64, 64, 64),
        Text            = Color3.fromRGB(255, 255, 255),
        ButtonHover     = Color3.fromRGB(25, 25, 25),
        ButtonActive    = Color3.fromRGB(35, 35, 35),
        CloseButton     = Color3.fromRGB(255, 255, 255),
        ToggleOn        = Color3.fromRGB(60, 60, 60),
        ToggleOff       = Color3.fromRGB(30, 30, 30),
        SliderFill      = Color3.fromRGB(80, 80, 80),
        SliderBg        = Color3.fromRGB(20, 20, 20),
        Overlay         = Color3.fromRGB(0, 0, 0),
        HealthGreen     = Color3.fromRGB(0, 255, 0),
        HealthRed       = Color3.fromRGB(255, 0, 0),
        MarkColor       = Color3.fromRGB(255, 0, 0),
    },

    -- ============================================================
    -- TWEEN PRESETS
    -- ============================================================
    TWEEN = {
        Open      = TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        Close     = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        Hover     = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        Appear    = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        Fade      = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        Drag      = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Press     = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    },

    -- ============================================================
    -- UI DIMENSIONS
    -- ============================================================
    UI = {
        MainWidth       = 550,
        MainHeight      = 400,
        TitleBarHeight  = 35,
        SidebarWidth    = 120,
        TabButtonHeight = 40,
    },

    -- ============================================================
    -- DEFAULT VALUES
    -- ============================================================
    DEFAULTS = {
        WalkSpeed       = 16,
        FlySpeed        = 50,
        SpeedhackMax    = 1000,
        SpeedhackMin    = 1,
        FlyMax          = 1000,
        FlyMin          = 1,
        SpectateDistMin = 3,
        SpectateDistMax = 30,
        SpectateYawSens = 0.3,
        SpectatePitchMin = -math.rad(80),
        SpectatePitchMax = math.rad(80),
    },

    -- ============================================================
    -- ESP DEFAULT COLORS
    -- ============================================================
    ESP = {
        BoxColor        = Color3.fromRGB(255, 255, 255),
        HitboxColor     = Color3.fromRGB(255, 0, 0),
        SkeletonColor   = Color3.fromRGB(0, 255, 0),
    },

    -- ============================================================
    -- COLOR MENU OPTIONS
    -- ============================================================
    COLOR_OPTIONS = {
        {name = "White", color = Color3.fromRGB(255, 255, 255)},
        {name = "Red",   color = Color3.fromRGB(255, 0, 0)},
        {name = "Cyan",  color = Color3.fromRGB(0, 255, 255)},
        {name = "Black", color = Color3.fromRGB(0, 0, 0)},
    },

    -- ============================================================
    -- SKELETON BONE MAP (for ESP)
    -- ============================================================
    SKELETON_BONES = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"},
    },
}
