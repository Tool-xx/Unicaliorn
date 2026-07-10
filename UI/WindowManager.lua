-- UI/WindowManager.lua
-- Factory for popup windows: overlay, drag, close, animation
-- Receives Context, populates Context.UI.WindowManager

return function(Context)
    local TweenService = Context.Services.TweenService
    local Config = Context.Config
    local COLORS = Config.COLORS
    local TWEEN = Config.TWEEN
    local Components = Context.UI.Components

    local WindowManager = {}

    -- ============================================================
    -- CREATE BASE WINDOW
    -- ============================================================
    -- Returns: { window = Frame, close = function, cleanupDrag = function }
    function WindowManager.createBaseWindow(options)
        options = options or {}
        local title = options.title or "Window"
        local width = options.width or 400
        local height = options.height or 500
        local startY = options.startY or -250  -- for appear animation
        local targetY = options.targetY or -250
        local hasScroll = options.hasScroll ~= false  -- default true
        local scrollHeight = options.scrollHeight or (height - 72)

        -- Overlay
        local overlay = Instance.new("Frame")
        overlay.Name = title .. "Overlay"
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = COLORS.Overlay
        overlay.BackgroundTransparency = 0.5
        overlay.BorderSizePixel = 0
        overlay.Parent = Context.UI.ScreenGui

        -- Window frame
        local window = Instance.new("Frame")
        window.Name = title .. "Window"
        window.Size = UDim2.new(0, width, 0, height)
        window.Position = UDim2.new(0.5, -width/2, 0.5, startY)
        window.BackgroundColor3 = COLORS.Background
        window.BorderSizePixel = 1
        window.BorderColor3 = COLORS.Border
        window.Parent = overlay

        -- Title bar
        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 30)
        titleBar.BackgroundColor3 = COLORS.Background
        titleBar.BorderSizePixel = 0
        titleBar.Parent = window

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -40, 1, 0)
        titleLabel.Position = UDim2.new(0, 10, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = COLORS.Text
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = titleBar

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 30, 0, 30)
        closeBtn.Position = UDim2.new(1, -30, 0, 0)
        closeBtn.BackgroundColor3 = COLORS.Background
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "X"
        closeBtn.TextColor3 = COLORS.CloseButton
        closeBtn.TextSize = 16
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.AutoButtonColor = false
        closeBtn.Parent = titleBar

        -- Separator
        local sep = Instance.new("Frame")
        sep.Size = UDim2.new(1, 0, 0, 1)
        sep.Position = UDim2.new(0, 0, 0, 30)
        sep.BackgroundColor3 = COLORS.Border
        sep.BorderSizePixel = 0
        sep.Parent = window

        -- Content area (ScrollingFrame or plain Frame)
        local content
        if hasScroll then
            content = Instance.new("ScrollingFrame")
            content.Size = UDim2.new(1, 0, 1, -31)
            content.Position = UDim2.new(0, 0, 0, 31)
            content.BackgroundTransparency = 1
            content.BorderSizePixel = 0
            content.ScrollBarThickness = 4
            content.ScrollBarImageColor3 = COLORS.Border
            content.CanvasSize = UDim2.new(0, 0, 0, 0)
            content.Parent = window
        else
            content = Instance.new("Frame")
            content.Size = UDim2.new(1, 0, 1, -31)
            content.Position = UDim2.new(0, 0, 0, 31)
            content.BackgroundTransparency = 1
            content.BorderSizePixel = 0
            content.Parent = window
        end

        -- Drag
        local cleanupDrag = Components.setupWindowDrag(window, titleBar)

        -- Close function
        local function closeWindow()
            cleanupDrag()
            overlay:Destroy()
        end
        closeBtn.MouseButton1Click:Connect(closeWindow)

        -- Animate appearance
        window.Position = UDim2.new(0.5, -width/2, 0.5, startY - 30)
        window.BackgroundTransparency = 1
        TweenService:Create(window, TWEEN.Appear, {
            Position = UDim2.new(0.5, -width/2, 0.5, targetY),
            BackgroundTransparency = 0
        }):Play()

        return {
            window = window,
            overlay = overlay,
            titleBar = titleBar,
            titleLabel = titleLabel,
            closeBtn = closeBtn,
            sep = sep,
            content = content,
            close = closeWindow,
            cleanupDrag = cleanupDrag,
        }
    end

    -- ============================================================
    -- CREATE BOTTOM BUTTON
    -- ============================================================
    function WindowManager.createBottomButton(parentWindow, text, callback)
        local window = parentWindow.window
        local bottomSep = Instance.new("Frame")
        bottomSep.Size = UDim2.new(1, 0, 0, 1)
        bottomSep.Position = UDim2.new(0, 0, 1, -41)
        bottomSep.BackgroundColor3 = COLORS.Border
        bottomSep.BorderSizePixel = 0
        bottomSep.Parent = window

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 30)
        btn.Position = UDim2.new(0, 10, 1, -35)
        btn.BackgroundColor3 = COLORS.Background
        btn.BorderSizePixel = 1
        btn.BorderColor3 = COLORS.Border
        btn.Text = text
        btn.TextColor3 = COLORS.Text
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.AutoButtonColor = false
        btn.Parent = window

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TWEEN.Hover, {BackgroundColor3 = COLORS.ButtonHover}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TWEEN.Hover, {BackgroundColor3 = COLORS.Background}):Play()
        end)

        btn.MouseButton1Click:Connect(function()
            if callback then callback(btn) end
        end)

        return btn
    end

    -- ============================================================
    -- ADD TEXT LINE TO CONTENT
    -- ============================================================
    function WindowManager.addTextLine(parentContent, text, yOffset, options)
        options = options or {}
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, options.height or 18)
        label.Position = UDim2.new(0, 10, 0, yOffset)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = options.color or COLORS.Text
        label.TextSize = options.size or 13
        label.Font = options.font or Enum.Font.Gotham
        label.TextXAlignment = options.align or Enum.TextXAlignment.Left
        label.TextWrapped = options.wrapped ~= false
        label.Parent = parentContent
        return yOffset + (options.height or 18) + (options.spacing or 2)
    end

    -- ============================================================
    -- UPDATE SCROLL CANVAS SIZE
    -- ============================================================
    function WindowManager.updateCanvasSize(content, totalHeight)
        if content:IsA("ScrollingFrame") then
            content.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
        end
    end

    -- Register in Context
    Context.UI.WindowManager = WindowManager
    print("[WindowManager] Window factory registered.")
end
