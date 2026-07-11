-- UI/MainGUI.lua
-- Creates the main ScreenGui, MainFrame, TitleBar, Sidebar, ContentFrame
-- Handles tab switching, minimize, close, and appearance animation
-- Receives Context, populates Context.UI.Main and UI references

return function(Context)
    local Players = Context.Services.Players
    local UserInputService = Context.Services.UserInputService
    local TweenService = Context.Services.TweenService
    local Config = Context.Config
    local COLORS = Config.COLORS
    local TWEEN = Config.TWEEN
    local UI_DIMS = Config.UI
    local Components = Context.UI.Components

    -- ============================================================
    -- CREATE SCREEN GUI
    -- ============================================================
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Unicaliorn"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = Context.PlayerGui
    Context.UI.ScreenGui = ScreenGui
    print("[MainGUI] ScreenGui created.")

    -- ============================================================
    -- CREATE MAIN FRAME
    -- ============================================================
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, UI_DIMS.MainWidth, 0, UI_DIMS.MainHeight)
    MainFrame.Position = UDim2.new(0.5, -UI_DIMS.MainWidth/2, 0.5, -UI_DIMS.MainHeight/2)
    MainFrame.BackgroundColor3 = COLORS.Background
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = COLORS.Border
    MainFrame.BackgroundTransparency = 1
    MainFrame.Parent = ScreenGui
    Context.UI.MainFrame = MainFrame

    -- ============================================================
    -- TITLE BAR
    -- ============================================================
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, UI_DIMS.TitleBarHeight)
    TitleBar.BackgroundColor3 = COLORS.Background
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 2
    TitleBar.Parent = MainFrame
    Context.UI.TitleBar = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Unicaliorn"
    TitleLabel.TextColor3 = COLORS.Text
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 2
    TitleLabel.Parent = TitleBar
    Context.UI.TitleLabel = TitleLabel

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 35, 0, 35)
    MinimizeButton.Position = UDim2.new(1, -70, 0, 0)
    MinimizeButton.BackgroundColor3 = COLORS.Background
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = "—"
    MinimizeButton.TextColor3 = COLORS.Text
    MinimizeButton.TextSize = 18
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.AutoButtonColor = false
    MinimizeButton.ZIndex = 2
    MinimizeButton.Parent = TitleBar
    Context.UI.MinimizeButton = MinimizeButton

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -35, 0, 0)
    CloseButton.BackgroundColor3 = COLORS.Background
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = COLORS.CloseButton
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.AutoButtonColor = false
    CloseButton.ZIndex = 2
    CloseButton.Parent = TitleBar
    Context.UI.CloseButton = CloseButton

    -- ============================================================
    -- BOTTOM SEPARATOR (под TitleBar, над Sidebar и ContentFrame)
    -- ============================================================
    local BottomSeparator = Instance.new("Frame")
    BottomSeparator.Name = "BottomSeparator"
    BottomSeparator.Size = UDim2.new(1, 0, 0, 1)
    BottomSeparator.Position = UDim2.new(0, 0, 0, UI_DIMS.TitleBarHeight)
    BottomSeparator.BackgroundColor3 = COLORS.Border
    BottomSeparator.BorderSizePixel = 0
    BottomSeparator.ZIndex = 3
    BottomSeparator.Parent = MainFrame
    Context.UI.BottomSeparator = BottomSeparator

    -- ============================================================
    -- SIDEBAR (сдвинута на 1px вниз, чтобы линия была видна)
    -- ============================================================
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, UI_DIMS.SidebarWidth, 1, -(UI_DIMS.TitleBarHeight + 1))
    Sidebar.Position = UDim2.new(0, 0, 0, UI_DIMS.TitleBarHeight + 1)
    Sidebar.BackgroundColor3 = COLORS.Background
    Sidebar.BorderSizePixel = 0
    Sidebar.ClipsDescendants = true
    Sidebar.ZIndex = 1
    Sidebar.Parent = MainFrame
    Context.UI.Sidebar = Sidebar

    local VerticalSeparator = Instance.new("Frame")
    VerticalSeparator.Name = "VerticalSeparator"
    VerticalSeparator.Size = UDim2.new(0, 1, 1, -(UI_DIMS.TitleBarHeight + 1))
    VerticalSeparator.Position = UDim2.new(0, UI_DIMS.SidebarWidth, 0, UI_DIMS.TitleBarHeight + 1)
    VerticalSeparator.BackgroundColor3 = COLORS.Border
    VerticalSeparator.BorderSizePixel = 0
    VerticalSeparator.ZIndex = 2
    VerticalSeparator.Parent = MainFrame
    Context.UI.VerticalSeparator = VerticalSeparator

    local SidebarButtonsContainer = Instance.new("Frame")
    SidebarButtonsContainer.Name = "Buttons"
    SidebarButtonsContainer.Size = UDim2.new(1, 0, 1, 0)
    SidebarButtonsContainer.BackgroundTransparency = 1
    SidebarButtonsContainer.Parent = Sidebar
    Context.UI.SidebarButtonsContainer = SidebarButtonsContainer

    -- ============================================================
    -- CONTENT FRAME (сдвинута на 1px вниз, чтобы линия была видна)
    -- ============================================================
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -(UI_DIMS.SidebarWidth + 1), 1, -(UI_DIMS.TitleBarHeight + 1))
    ContentFrame.Position = UDim2.new(0, UI_DIMS.SidebarWidth + 1, 0, UI_DIMS.TitleBarHeight + 1)
    ContentFrame.BackgroundColor3 = COLORS.Background
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ClipsDescendants = true
    ContentFrame.ZIndex = 1
    ContentFrame.Parent = MainFrame
    Context.UI.ContentFrame = ContentFrame

    -- ============================================================
    -- SIDEBAR BUTTONS
    -- ============================================================
    local buttonNames = {"General", "Players", "Misc", "Movement", "Visual"}
    local sidebarButtons = {}
    local buttonSeparators = {}
    local activeContent = {}

    for i, name in ipairs(buttonNames) do
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(1, 0, 0, UI_DIMS.TabButtonHeight)
        button.Position = UDim2.new(0, 0, 0, (i - 1) * UI_DIMS.TabButtonHeight)
        button.BackgroundColor3 = COLORS.Background
        button.BorderSizePixel = 0
        button.Text = name
        button.TextColor3 = COLORS.Text
        button.TextSize = 14
        button.Font = Enum.Font.Gotham
        button.AutoButtonColor = false
        button.Parent = SidebarButtonsContainer

        if i < #buttonNames then
            local sep = Instance.new("Frame")
            sep.Name = "Separator"
            sep.Size = UDim2.new(1, -20, 0, 1)
            sep.Position = UDim2.new(0, 10, 1, 0)
            sep.BackgroundColor3 = COLORS.Border
            sep.BorderSizePixel = 0
            sep.Parent = button
            table.insert(buttonSeparators, sep)
        end

        table.insert(sidebarButtons, button)
    end

    -- ============================================================
    -- TAB SWITCHING
    -- ============================================================
    local activeButton = nil

    local function setActiveTab(tabName)
        if activeButton == tabName then return end

        -- Reset previous button
        for _, btn in ipairs(sidebarButtons) do
            if btn.Name == activeButton then
                TweenService:Create(btn, TWEEN.Hover, {BackgroundColor3 = COLORS.Background}):Play()
            end
        end

        -- Highlight new button
        for _, btn in ipairs(sidebarButtons) do
            if btn.Name == tabName then
                TweenService:Create(btn, TWEEN.Hover, {BackgroundColor3 = COLORS.ButtonActive}):Play()
            end
        end

        -- Show/hide content
        for name, content in pairs(activeContent) do
            if name == tabName then
                content.Visible = true
                local label = content:FindFirstChild("TextLabel")
                if label then
                    TweenService:Create(label, TWEEN.Open, {TextTransparency = 0}):Play()
                end
            else
                content.Visible = false
            end
        end

        activeButton = tabName
        Context.State.activeButton = tabName
    end

    -- ============================================================
    -- MINIMIZE / CLOSE
    -- ============================================================
    local isMinimized = false
    local isClosing = false

    local function toggleMinimize()
        if isClosing then return end
        if not isMinimized then
            isMinimized = true
            Context.State.isMinimized = true
            TweenService:Create(Sidebar, TWEEN.Close, {Size = UDim2.new(0, UI_DIMS.SidebarWidth, 0, 0)}):Play()
            TweenService:Create(ContentFrame, TWEEN.Close, {Size = UDim2.new(1, -(UI_DIMS.SidebarWidth + 1), 0, 0)}):Play()
            TweenService:Create(VerticalSeparator, TWEEN.Close, {Size = UDim2.new(0, 1, 0, 0)}):Play()
            TweenService:Create(BottomSeparator, TWEEN.Close, {BackgroundTransparency = 1}):Play()
            for _, btn in ipairs(sidebarButtons) do
                TweenService:Create(btn, TWEEN.Close, {TextTransparency = 1}):Play()
            end
            for _, sep in ipairs(buttonSeparators) do
                TweenService:Create(sep, TWEEN.Close, {BackgroundTransparency = 1}):Play()
            end
            TweenService:Create(MainFrame, TWEEN.Open, {Size = UDim2.new(0, UI_DIMS.MainWidth, 0, UI_DIMS.TitleBarHeight)}):Play()
            TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            task.delay(0.15, function()
                MinimizeButton.Text = "□"
                TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
            end)
        else
            isMinimized = false
            Context.State.isMinimized = false
            TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            task.delay(0.15, function()
                MinimizeButton.Text = "—"
                TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
            end)
            TweenService:Create(MainFrame, TWEEN.Open, {Size = UDim2.new(0, UI_DIMS.MainWidth, 0, UI_DIMS.MainHeight)}):Play()
            task.delay(0.1, function()
                TweenService:Create(Sidebar, TWEEN.Open, {Size = UDim2.new(0, UI_DIMS.SidebarWidth, 1, -(UI_DIMS.TitleBarHeight + 1))}):Play()
                TweenService:Create(ContentFrame, TWEEN.Open, {Size = UDim2.new(1, -(UI_DIMS.SidebarWidth + 1), 1, -(UI_DIMS.TitleBarHeight + 1))}):Play()
                TweenService:Create(VerticalSeparator, TWEEN.Open, {Size = UDim2.new(0, 1, 1, -(UI_DIMS.TitleBarHeight + 1))}):Play()
                TweenService:Create(BottomSeparator, TWEEN.Open, {BackgroundTransparency = 0}):Play()
                for _, btn in ipairs(sidebarButtons) do
                    TweenService:Create(btn, TWEEN.Open, {TextTransparency = 0}):Play()
                end
                for _, sep in ipairs(buttonSeparators) do
                    TweenService:Create(sep, TWEEN.Open, {BackgroundTransparency = 0}):Play()
                end
            end)
        end
    end

    local function destroyScript()
        if isClosing then return end
        isClosing = true
        Context.State.isClosing = true
        print("[Unicaliorn] Destroying...")

        -- Close color menu
        if Components and Components.closeColorMenu then
            Components.closeColorMenu()
        end

        -- Stop all features
        for name, feature in pairs(Context.Features) do
            if feature and feature.Disable then
                pcall(function() feature.Disable() end)
            end
        end

        -- Stop spectate
        if Context.Features.Spectate and Context.Features.Spectate.Stop then
            pcall(function() Context.Features.Spectate.Stop() end)
        end

        -- Unmark all
        if Context.Features.Mark and Context.Features.Mark.UnmarkAll then
            pcall(function() Context.Features.Mark.UnmarkAll() end)
        end

        -- Fade out everything
        local fadeOut = TweenService:Create(MainFrame, TWEEN.Close, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, UI_DIMS.MainWidth, 0, UI_DIMS.MainHeight - 20)
        })
        TweenService:Create(TitleBar, TWEEN.Close, {BackgroundTransparency = 1}):Play()
        TweenService:Create(TitleLabel, TWEEN.Close, {TextTransparency = 1}):Play()
        TweenService:Create(MinimizeButton, TWEEN.Close, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        TweenService:Create(CloseButton, TWEEN.Close, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        TweenService:Create(BottomSeparator, TWEEN.Close, {BackgroundTransparency = 1}):Play()
        TweenService:Create(Sidebar, TWEEN.Close, {BackgroundTransparency = 1}):Play()
        TweenService:Create(VerticalSeparator, TWEEN.Close, {BackgroundTransparency = 1}):Play()
        for _, button in ipairs(sidebarButtons) do
            TweenService:Create(button, TWEEN.Close, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        end
        for _, sep in ipairs(buttonSeparators) do
            TweenService:Create(sep, TWEEN.Close, {BackgroundTransparency = 1}):Play()
        end
        TweenService:Create(ContentFrame, TWEEN.Close, {BackgroundTransparency = 1}):Play()
        fadeOut:Play()
        fadeOut.Completed:Wait()

        -- Destroy overlays and windows
        for _, v in ipairs(ScreenGui:GetChildren()) do
            if v.Name:find("Overlay") or v.Name:find("Window") then
                v:Destroy()
            end
        end
        ScreenGui:Destroy()
        _G.UnicaliornLoaded = nil
        print("[Unicaliorn] Destroyed.")
    end

    MinimizeButton.MouseButton1Click:Connect(toggleMinimize)
    CloseButton.MouseButton1Click:Connect(destroyScript)

    -- Hover effects
    Components.setupHoverEffect(MinimizeButton)
    Components.setupHoverEffect(CloseButton)
    for _, btn in ipairs(sidebarButtons) do
        Components.setupHoverEffect(btn, {Context.State.activeButton})
    end

    -- MainFrame drag
    Components.makeDraggable(MainFrame, TitleBar)

    -- ============================================================
    -- APPEARANCE ANIMATION
    -- ============================================================
    local function animateAppearance()
        MainFrame.Position = UDim2.new(0.5, -UI_DIMS.MainWidth/2, 0.5, -UI_DIMS.MainHeight/2)
        MainFrame.Size = UDim2.new(0, UI_DIMS.MainWidth - 50, 0, UI_DIMS.MainHeight - 50)
        MainFrame.BackgroundTransparency = 1

        task.wait(0.1)
        TweenService:Create(MainFrame, TWEEN.Appear, {
            Position = UDim2.new(0.5, -UI_DIMS.MainWidth/2, 0.5, -UI_DIMS.MainHeight/2),
            Size = UDim2.new(0, UI_DIMS.MainWidth, 0, UI_DIMS.MainHeight),
            BackgroundTransparency = 0
        }):Play()

        TitleLabel.TextTransparency = 1
        task.delay(0.15, function()
            TweenService:Create(TitleLabel, TWEEN.Fade, {TextTransparency = 0}):Play()
        end)

        MinimizeButton.BackgroundTransparency = 1
        MinimizeButton.TextTransparency = 1
        CloseButton.BackgroundTransparency = 1
        CloseButton.TextTransparency = 1
        task.delay(0.25, function()
            TweenService:Create(MinimizeButton, TWEEN.Fade, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        end)
        task.delay(0.35, function()
            TweenService:Create(CloseButton, TWEEN.Fade, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        end)

        BottomSeparator.BackgroundTransparency = 1
        task.delay(0.3, function()
            TweenService:Create(BottomSeparator, TWEEN.Fade, {BackgroundTransparency = 0}):Play()
        end)

        VerticalSeparator.BackgroundTransparency = 1
        task.delay(0.35, function()
            TweenService:Create(VerticalSeparator, TWEEN.Fade, {BackgroundTransparency = 0}):Play()
        end)

        for i, btn in ipairs(sidebarButtons) do
            btn.BackgroundTransparency = 1
            btn.TextTransparency = 1
            task.delay(0.4 + i * 0.05, function()
                TweenService:Create(btn, TWEEN.Fade, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
            end)
        end

        for i, sep in ipairs(buttonSeparators) do
            sep.BackgroundTransparency = 1
            task.delay(0.45 + i * 0.05, function()
                TweenService:Create(sep, TWEEN.Fade, {BackgroundTransparency = 0}):Play()
            end)
        end

        task.delay(0.5, function()
            TweenService:Create(ContentFrame, TWEEN.Open, {
                Size = UDim2.new(1, -(UI_DIMS.SidebarWidth + 1), 1, -(UI_DIMS.TitleBarHeight + 1))
            }):Play()
        end)
    end

    -- ============================================================
    -- REGISTER TAB CONTENT (called by Tabs/*.lua)
    -- ============================================================
    local function registerTabContent(tabName, contentFrame)
        activeContent[tabName] = contentFrame
    end

    -- ============================================================
    -- EXPOSE API
    -- ============================================================
    local Main = {
        sidebarButtons = sidebarButtons,
        buttonSeparators = buttonSeparators,
        setActiveTab = setActiveTab,
        animateAppearance = animateAppearance,
        registerTabContent = registerTabContent,
        toggleMinimize = toggleMinimize,
        destroyScript = destroyScript,
    }

    Context.UI.Main = Main
    print("[MainGUI] Main GUI created and registered.")
end
