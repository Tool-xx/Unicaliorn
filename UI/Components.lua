-- UI/Components.lua
-- Reusable UI components: toggle, slider, button, color menu, window drag
-- Receives Context, populates Context.UI.Components

return function(Context)
    local TweenService = Context.Services.TweenService
    local UserInputService = Context.Services.UserInputService
    local Config = Context.Config
    local COLORS = Config.COLORS
    local TWEEN = Config.TWEEN

    local Components = {}

    -- ============================================================
    -- CREATE TOGGLE
    -- ============================================================
    function Components.createToggle(parent, name, yPos, callback)
        local container = Instance.new("Frame")
        container.Name = "Toggle_" .. name
        container.Size = UDim2.new(1, -20, 0, 30)
        container.Position = UDim2.new(0, 10, 0, yPos)
        container.BackgroundColor3 = COLORS.Background
        container.BorderSizePixel = 0
        container.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 5, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = COLORS.Text
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container

        local toggleBg = Instance.new("TextButton")
        toggleBg.Size = UDim2.new(0, 50, 0, 22)
        toggleBg.Position = UDim2.new(1, -55, 0.5, -11)
        toggleBg.BackgroundColor3 = COLORS.ToggleOff
        toggleBg.BorderSizePixel = 1
        toggleBg.BorderColor3 = COLORS.Border
        toggleBg.Text = ""
        toggleBg.AutoButtonColor = false
        toggleBg.Parent = container

        local toggleKnob = Instance.new("Frame")
        toggleKnob.Size = UDim2.new(0, 18, 0, 18)
        toggleKnob.Position = UDim2.new(0, 2, 0.5, -9)
        toggleKnob.BackgroundColor3 = COLORS.Text
        toggleKnob.BorderSizePixel = 0
        toggleKnob.Parent = toggleBg

        local enabled = false

        toggleBg.MouseButton1Click:Connect(function()
            enabled = not enabled
            if enabled then
                TweenService:Create(toggleBg, TWEEN.Hover, {BackgroundColor3 = COLORS.ToggleOn}):Play()
                TweenService:Create(toggleKnob, TWEEN.Hover, {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
            else
                TweenService:Create(toggleBg, TWEEN.Hover, {BackgroundColor3 = COLORS.ToggleOff}):Play()
                TweenService:Create(toggleKnob, TWEEN.Hover, {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
            end
            if callback then callback(enabled) end
        end)

        return {
            container = container,
            toggleBg = toggleBg,
            toggleKnob = toggleKnob,
            setEnabled = function(state)
                enabled = state
                if enabled then
                    toggleBg.BackgroundColor3 = COLORS.ToggleOn
                    toggleKnob.Position = UDim2.new(1, -20, 0.5, -9)
                else
                    toggleBg.BackgroundColor3 = COLORS.ToggleOff
                    toggleKnob.Position = UDim2.new(0, 2, 0.5, -9)
                end
            end,
            isEnabled = function() return enabled end
        }
    end

    -- ============================================================
    -- CREATE SLIDER
    -- ============================================================
    function Components.createSlider(parent, name, yPos, min, max, default, callback)
        local container = Instance.new("Frame")
        container.Name = "Slider_" .. name
        container.Size = UDim2.new(1, -20, 0, 40)
        container.Position = UDim2.new(0, 10, 0, yPos)
        container.BackgroundColor3 = COLORS.Background
        container.BorderSizePixel = 0
        container.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -80, 0, 15)
        label.Position = UDim2.new(0, 5, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = COLORS.Text
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 70, 0, 15)
        valueLabel.Position = UDim2.new(1, -75, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = COLORS.Text
        valueLabel.TextSize = 12
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = container

        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -10, 0, 6)
        sliderBg.Position = UDim2.new(0, 5, 0, 25)
        sliderBg.BackgroundColor3 = COLORS.SliderBg
        sliderBg.BorderSizePixel = 1
        sliderBg.BorderColor3 = COLORS.Border
        sliderBg.Parent = container

        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = COLORS.SliderFill
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBg

        local sliderKnob = Instance.new("TextButton")
        sliderKnob.Size = UDim2.new(0, 14, 0, 14)
        sliderKnob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
        sliderKnob.BackgroundColor3 = COLORS.Text
        sliderKnob.BorderSizePixel = 0
        sliderKnob.Text = ""
        sliderKnob.AutoButtonColor = false
        sliderKnob.Parent = sliderBg

        local currentValue = default
        local dragging = false

        local function updateSlider(input)
            local relX = input.Position.X - sliderBg.AbsolutePosition.X
            local percent = math.clamp(relX / sliderBg.AbsoluteSize.X, 0, 1)
            local newValue = math.floor(min + (max - min) * percent)
            currentValue = newValue
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderKnob.Position = UDim2.new(percent, -7, 0.5, -7)
            valueLabel.Text = tostring(newValue)
            if callback then callback(newValue) end
        end

        sliderKnob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local moveConn, releaseConn
                moveConn = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if dragging then updateSlider(input) end
                    end
                end)
                releaseConn = UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                        moveConn:Disconnect()
                        releaseConn:Disconnect()
                    end
                end)
            end
        end)

        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then updateSlider(input) end
        end)

        return {
            container = container,
            getValue = function() return currentValue end,
            setValue = function(val)
                currentValue = val
                local percent = (val - min) / (max - min)
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                sliderKnob.Position = UDim2.new(percent, -7, 0.5, -7)
                valueLabel.Text = tostring(val)
            end
        }
    end

    -- ============================================================
    -- CREATE BUTTON
    -- ============================================================
    function Components.createButton(parent, name, yPos, callback)
        local button = Instance.new("TextButton")
        button.Name = "Button_" .. name
        button.Size = UDim2.new(1, -20, 0, 35)
        button.Position = UDim2.new(0, 10, 0, yPos)
        button.BackgroundColor3 = COLORS.Background
        button.BorderSizePixel = 1
        button.BorderColor3 = COLORS.Border
        button.Text = name
        button.TextColor3 = COLORS.Text
        button.TextSize = 14
        button.Font = Enum.Font.Gotham
        button.AutoButtonColor = false
        button.Parent = parent

        button.MouseEnter:Connect(function()
            TweenService:Create(button, TWEEN.Hover, {BackgroundColor3 = COLORS.ButtonHover}):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TWEEN.Hover, {BackgroundColor3 = COLORS.Background}):Play()
        end)
        button.MouseButton1Down:Connect(function()
            TweenService:Create(button, TWEEN.Press, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        end)
        button.MouseButton1Up:Connect(function()
            TweenService:Create(button, TWEEN.Hover, {BackgroundColor3 = COLORS.ButtonHover}):Play()
        end)

        button.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)

        return button
    end

    -- ============================================================
    -- COLOR MENU (Gear icon popup)
    -- ============================================================
    local function closeColorMenu()
        local state = Context.State
        if state.activeColorMenu then
            for _, conn in ipairs(state.colorMenuConnections) do
                pcall(function() conn:Disconnect() end)
            end
            state.colorMenuConnections = {}
            if state.activeColorMenu and state.activeColorMenu.Parent then
                TweenService:Create(state.activeColorMenu, TWEEN.Close, {Size = UDim2.new(0, 0, 0, 0)}):Play()
                task.delay(0.35, function()
                    if state.activeColorMenu and state.activeColorMenu.Parent then
                        state.activeColorMenu:Destroy()
                    end
                    state.activeColorMenu = nil
                end)
            else
                state.activeColorMenu = nil
            end
        end
    end

    function Components.createColorMenu(anchorButton, currentColor, callback)
        closeColorMenu()

        local menuFrame = Instance.new("Frame")
        menuFrame.Name = "ColorMenu"
        menuFrame.Size = UDim2.new(0, 0, 0, 0)
        menuFrame.BackgroundColor3 = COLORS.Background
        menuFrame.BorderSizePixel = 1
        menuFrame.BorderColor3 = COLORS.Border
        menuFrame.ZIndex = 100
        menuFrame.Parent = Context.UI.ScreenGui

        local absPos = anchorButton.AbsolutePosition
        local absSize = anchorButton.AbsoluteSize
        menuFrame.Position = UDim2.new(0, absPos.X + absSize.X + 5, 0, absPos.Y)

        -- Close button (X)
        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "CloseBtn"
        closeBtn.Size = UDim2.new(0, 20, 0, 20)
        closeBtn.Position = UDim2.new(1, -22, 0, 2)
        closeBtn.BackgroundColor3 = COLORS.Background
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "X"
        closeBtn.TextColor3 = COLORS.CloseButton
        closeBtn.TextSize = 12
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.AutoButtonColor = false
        closeBtn.ZIndex = 101
        closeBtn.Parent = menuFrame

        local closeConn = closeBtn.MouseButton1Click:Connect(closeColorMenu)
        table.insert(Context.State.colorMenuConnections, closeConn)

        -- Title
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -25, 0, 20)
        titleLabel.Position = UDim2.new(0, 5, 0, 2)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "Color"
        titleLabel.TextColor3 = COLORS.Text
        titleLabel.TextSize = 12
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.ZIndex = 101
        titleLabel.Parent = menuFrame

        -- Color options
        for i, option in ipairs(Config.COLOR_OPTIONS) do
            local colorBtn = Instance.new("TextButton")
            colorBtn.Size = UDim2.new(0, 30, 0, 30)
            colorBtn.Position = UDim2.new(0, 5 + ((i-1) * 35), 0, 28)
            colorBtn.BackgroundColor3 = option.color
            colorBtn.BorderSizePixel = 1
            colorBtn.BorderColor3 = COLORS.Border
            colorBtn.Text = ""
            colorBtn.AutoButtonColor = false
            colorBtn.ZIndex = 101
            colorBtn.Parent = menuFrame

            if option.name == "Black" then
                local whiteBorder = Instance.new("UIStroke")
                whiteBorder.Color = Color3.fromRGB(100, 100, 100)
                whiteBorder.Thickness = 1
                whiteBorder.Parent = colorBtn
            end

            local colorConn = colorBtn.MouseButton1Click:Connect(function()
                if callback then callback(option.color) end
                closeColorMenu()
            end)
            table.insert(Context.State.colorMenuConnections, colorConn)

            colorBtn.MouseEnter:Connect(function()
                TweenService:Create(colorBtn, TWEEN.Hover, {Size = UDim2.new(0, 32, 0, 32)}):Play()
            end)
            colorBtn.MouseLeave:Connect(function()
                TweenService:Create(colorBtn, TWEEN.Hover, {Size = UDim2.new(0, 30, 0, 30)}):Play()
            end)
        end

        -- Click outside to close
        local clickOutsideConn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                local menuPos = menuFrame.AbsolutePosition
                local menuSize = menuFrame.AbsoluteSize
                if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or
                   mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then
                    local anchorPos = anchorButton.AbsolutePosition
                    local anchorSize = anchorButton.AbsoluteSize
                    if mousePos.X < anchorPos.X or mousePos.X > anchorPos.X + anchorSize.X or
                       mousePos.Y < anchorPos.Y or mousePos.Y > anchorPos.Y + anchorSize.Y then
                        closeColorMenu()
                    end
                end
            end
        end)
        table.insert(Context.State.colorMenuConnections, clickOutsideConn)

        Context.State.activeColorMenu = menuFrame

        TweenService:Create(menuFrame, TWEEN.Open, {Size = UDim2.new(0, 150, 0, 65)}):Play()

        return menuFrame
    end

    -- ============================================================
    -- WINDOW DRAG HELPER
    -- ============================================================
    function Components.setupWindowDrag(window, dragElement)
        local connections = {}
        local dragging, dragInput, dragStart, startPos

        local function onInputBegan(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = window.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end

        local function onInputChanged(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end

        local function onInputService(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                TweenService:Create(window, TWEEN.Drag, {Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )}):Play()
            end
        end

        table.insert(connections, dragElement.InputBegan:Connect(onInputBegan))
        table.insert(connections, dragElement.InputChanged:Connect(onInputChanged))
        table.insert(connections, UserInputService.InputChanged:Connect(onInputService))

        return function()
            for _, conn in ipairs(connections) do
                conn:Disconnect()
            end
        end
    end

    -- ============================================================
    -- SETUP HOVER EFFECT (for sidebar buttons, minimize, close)
    -- ============================================================
    function Components.setupHoverEffect(button, activeButtonRef)
        button.MouseEnter:Connect(function()
            if (not activeButtonRef) or (activeButtonRef[1] ~= button.Name) then
                TweenService:Create(button, TWEEN.Hover, {BackgroundColor3 = COLORS.ButtonHover}):Play()
            end
        end)
        button.MouseLeave:Connect(function()
            if (not activeButtonRef) or (activeButtonRef[1] ~= button.Name) then
                TweenService:Create(button, TWEEN.Hover, {BackgroundColor3 = COLORS.Background}):Play()
            end
        end)
        button.MouseButton1Down:Connect(function()
            if (not activeButtonRef) or (activeButtonRef[1] ~= button.Name) then
                TweenService:Create(button, TWEEN.Press, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            end
        end)
        button.MouseButton1Up:Connect(function()
            if (not activeButtonRef) or (activeButtonRef[1] ~= button.Name) then
                TweenService:Create(button, TWEEN.Hover, {BackgroundColor3 = COLORS.ButtonHover}):Play()
            end
        end)
    end

    -- ============================================================
    -- MAKE DRAGGABLE (legacy alias for MainFrame drag)
    -- ============================================================
    function Components.makeDraggable(frame, dragPart)
        local dragging, dragInput, dragStart, startPos
        dragPart.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        dragPart.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                TweenService:Create(frame, TWEEN.Drag, {
                    Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                         startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                }):Play()
            end
        end)
    end

    -- ============================================================
    -- TOGGLE WITH GEAR (for Visual tab ESP settings)
    -- ============================================================
    function Components.createToggleWithGear(parent, yPos, labelText, defaultColor, toggleCallback, colorCallback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 30)
        row.Position = UDim2.new(0, 5, 0, yPos)
        row.BackgroundColor3 = COLORS.Background
        row.BorderSizePixel = 0
        row.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -90, 1, 0)
        label.Position = UDim2.new(0, 5, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = COLORS.Text
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = row

        -- Toggle
        local toggleBg = Instance.new("TextButton")
        toggleBg.Size = UDim2.new(0, 50, 0, 22)
        toggleBg.Position = UDim2.new(1, -105, 0.5, -11)
        toggleBg.BackgroundColor3 = COLORS.ToggleOff
        toggleBg.BorderSizePixel = 1
        toggleBg.BorderColor3 = COLORS.Border
        toggleBg.Text = ""
        toggleBg.AutoButtonColor = false
        toggleBg.Parent = row

        local toggleKnob = Instance.new("Frame")
        toggleKnob.Size = UDim2.new(0, 18, 0, 18)
        toggleKnob.Position = UDim2.new(0, 2, 0.5, -9)
        toggleKnob.BackgroundColor3 = COLORS.Text
        toggleKnob.BorderSizePixel = 0
        toggleKnob.Parent = toggleBg

        local enabled = false
        toggleBg.MouseButton1Click:Connect(function()
            enabled = not enabled
            if enabled then
                TweenService:Create(toggleBg, TWEEN.Hover, {BackgroundColor3 = COLORS.ToggleOn}):Play()
                TweenService:Create(toggleKnob, TWEEN.Hover, {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
            else
                TweenService:Create(toggleBg, TWEEN.Hover, {BackgroundColor3 = COLORS.ToggleOff}):Play()
                TweenService:Create(toggleKnob, TWEEN.Hover, {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
            end
            if toggleCallback then toggleCallback(enabled) end
        end)

        -- Gear icon button
        local gearBtn = Instance.new("TextButton")
        gearBtn.Size = UDim2.new(0, 24, 0, 24)
        gearBtn.Position = UDim2.new(1, -30, 0.5, -12)
        gearBtn.BackgroundColor3 = COLORS.Background
        gearBtn.BorderSizePixel = 1
        gearBtn.BorderColor3 = COLORS.Border
        gearBtn.Text = "⚙"
        gearBtn.TextColor3 = COLORS.Text
        gearBtn.TextSize = 14
        gearBtn.Font = Enum.Font.GothamBold
        gearBtn.AutoButtonColor = false
        gearBtn.Parent = row

        gearBtn.MouseEnter:Connect(function()
            TweenService:Create(gearBtn, TWEEN.Hover, {BackgroundColor3 = COLORS.ButtonHover}):Play()
        end)
        gearBtn.MouseLeave:Connect(function()
            TweenService:Create(gearBtn, TWEEN.Hover, {BackgroundColor3 = COLORS.Background}):Play()
        end)

        gearBtn.MouseButton1Click:Connect(function()
            Components.createColorMenu(gearBtn, defaultColor, function(newColor)
                if colorCallback then colorCallback(newColor) end
            end)
        end)

        return row
    end

    -- ============================================================
    -- CLOSE COLOR MENU (exposed for external use)
    -- ============================================================
    Components.closeColorMenu = closeColorMenu

    -- Register in Context
    Context.UI.Components = Components
    print("[Components] UI components registered.")
end
