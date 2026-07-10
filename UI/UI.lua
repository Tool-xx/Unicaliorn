-- UI/UI.lua
-- Main GUI manager for Unicaliorn

local UI = {}
local config
local components

-- Internal state
local screenGui
local mainFrame
local titleBar
local titleLabel
local minimizeButton
local closeButton
local topSeparator
local sidebar
local sidebarButtonsContainer
local verticalSeparator
local contentFrame

local tabs = {}          -- { [name] = { button = TextButton, frame = Frame } }
local activeTabName = nil
local isMinimized = false
local isClosing = false
local onCloseCallback = nil
local showCalled = false
local dragCleanup = nil

-- Create all GUI elements
function UI.init(cfg, comp)
    config = cfg
    components = comp

    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Unicaliorn"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui

    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = config.Defaults.WindowSize or UDim2.new(0, 550, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    mainFrame.BackgroundColor3 = config.Colors.Background
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = config.Colors.Border
    mainFrame.BackgroundTransparency = 1 -- will be animated to 0
    mainFrame.Parent = screenGui

    -- Title Bar
    titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = config.Colors.Background
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Unicaliorn"
    titleLabel.TextColor3 = config.Colors.Text
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 35, 0, 35)
    minimizeButton.Position = UDim2.new(1, -70, 0, 0)
    minimizeButton.BackgroundColor3 = config.Colors.Background
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "—"
    minimizeButton.TextColor3 = config.Colors.Text
    minimizeButton.TextSize = 18
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.AutoButtonColor = false
    minimizeButton.Parent = titleBar

    closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Position = UDim2.new(1, -35, 0, 0)
    closeButton.BackgroundColor3 = config.Colors.Background
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = config.Colors.CloseButton
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.AutoButtonColor = false
    closeButton.Parent = titleBar

    topSeparator = Instance.new("Frame")
    topSeparator.Name = "TopSeparator"
    topSeparator.Size = UDim2.new(1, 0, 0, 1)
    topSeparator.Position = UDim2.new(0, 0, 0, 35)
    topSeparator.BackgroundColor3 = config.Colors.Border
    topSeparator.BorderSizePixel = 0
    topSeparator.Parent = mainFrame

    -- Sidebar
    sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 120, 1, -36)
    sidebar.Position = UDim2.new(0, 0, 0, 36)
    sidebar.BackgroundColor3 = config.Colors.Background
    sidebar.BorderSizePixel = 0
    sidebar.ClipsDescendants = true
    sidebar.Parent = mainFrame

    sidebarButtonsContainer = Instance.new("Frame")
    sidebarButtonsContainer.Name = "Buttons"
    sidebarButtonsContainer.Size = UDim2.new(1, 0, 1, 0)
    sidebarButtonsContainer.BackgroundTransparency = 1
    sidebarButtonsContainer.Parent = sidebar

    verticalSeparator = Instance.new("Frame")
    verticalSeparator.Name = "VerticalSeparator"
    verticalSeparator.Size = UDim2.new(0, 1, 1, -36)
    verticalSeparator.Position = UDim2.new(0, 120, 0, 36)
    verticalSeparator.BackgroundColor3 = config.Colors.Border
    verticalSeparator.BorderSizePixel = 0
    verticalSeparator.Parent = mainFrame

    -- Content Frame
    contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -121, 1, -36)
    contentFrame.Position = UDim2.new(0, 121, 0, 36)
    contentFrame.BackgroundColor3 = config.Colors.Background
    contentFrame.BorderSizePixel = 0
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = mainFrame

    -- Setup drag using Components
    dragCleanup = components.setupWindowDrag(mainFrame, titleBar)

    -- Hover effects for title buttons
    local function setupTitleButtonHover(button)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, config.TweenPresets.Hover, {
                BackgroundColor3 = config.Colors.ButtonHover
            }):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, config.TweenPresets.Hover, {
                BackgroundColor3 = config.Colors.Background
            }):Play()
        end)
        button.MouseButton1Down:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.08), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            }):Play()
        end)
        button.MouseButton1Up:Connect(function()
            TweenService:Create(button, config.TweenPresets.Hover, {
                BackgroundColor3 = config.Colors.ButtonHover
            }):Play()
        end)
    end

    setupTitleButtonHover(minimizeButton)
    setupTitleButtonHover(closeButton)

    -- Minimize button logic
    minimizeButton.MouseButton1Click:Connect(function()
        UI.minimize()
    end)

    -- Close button logic
    closeButton.MouseButton1Click:Connect(function()
        UI.close()
    end)
end

-- Register a new tab
function UI.registerTab(name, contentFrame)
    if not mainFrame then return end

    local TweenService = game:GetService("TweenService")

    -- Create sidebar button
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Position = UDim2.new(0, 0, 0, #tabs * 40) -- simple stacking, will adjust later if needed
    button.BackgroundColor3 = config.Colors.Background
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = config.Colors.Text
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.Parent = sidebarButtonsContainer

    -- Separator line inside button (always present)
    local sep = Instance.new("Frame")
    sep.Name = "Separator"
    sep.Size = UDim2.new(1, -20, 0, 1)
    sep.Position = UDim2.new(0, 10, 1, 0)
    sep.BackgroundColor3 = config.Colors.Border
    sep.BorderSizePixel = 0
    sep.Parent = button

    -- Store tab data
    table.insert(tabs, { name = name, button = button, frame = contentFrame })
    contentFrame.Visible = false
    contentFrame.Parent = contentFrame -- ensure it's parented to main contentFrame

    -- Hover and click logic
    local function onHoverEnter()
        if activeTabName ~= name then
            TweenService:Create(button, config.TweenPresets.Hover, {
                BackgroundColor3 = config.Colors.ButtonHover
            }):Play()
        end
    end
    local function onHoverLeave()
        if activeTabName ~= name then
            TweenService:Create(button, config.TweenPresets.Hover, {
                BackgroundColor3 = config.Colors.Background
            }):Play()
        end
    end
    button.MouseEnter:Connect(onHoverEnter)
    button.MouseLeave:Connect(onHoverLeave)

    button.MouseButton1Click:Connect(function()
        UI.switchTab(name)
    end)
end

-- Switch to a tab by name
function UI.switchTab(name)
    if isClosing then return end
    if activeTabName == name then return end

    local TweenService = game:GetService("TweenService")

    -- Deactivate previous tab
    if activeTabName then
        for _, tab in ipairs(tabs) do
            if tab.name == activeTabName then
                tab.frame.Visible = false
                TweenService:Create(tab.button, config.TweenPresets.Hover, {
                    BackgroundColor3 = config.Colors.Background
                }):Play()
                break
            end
        end
    end

    -- Activate new tab
    local newTab = nil
    for _, tab in ipairs(tabs) do
        if tab.name == name then
            newTab = tab
            break
        end
    end
    if not newTab then return end

    newTab.frame.Visible = true
    TweenService:Create(newTab.button, config.TweenPresets.Hover, {
        BackgroundColor3 = config.Colors.ButtonActive
    }):Play()

    -- Fade in content label if it has a TextLabel child (optional)
    local label = newTab.frame:FindFirstChild("TextLabel")
    if label then
        label.TextTransparency = 1
        TweenService:Create(label, config.TweenPresets.Open, {
            TextTransparency = 0
        }):Play()
    end

    activeTabName = name
end

-- Show the UI with entrance animation
function UI.show()
    if not mainFrame or showCalled then return end
    showCalled = true

    local TweenService = game:GetService("TweenService")

    -- Prepare initial state
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -250)
    mainFrame.Size = UDim2.new(0, 500, 0, 350)
    mainFrame.BackgroundTransparency = 1

    -- Animate
    TweenService:Create(mainFrame, config.TweenPresets.Appear, {
        Position = UDim2.new(0.5, -275, 0.5, -200),
        Size = config.Defaults.WindowSize or UDim2.new(0, 550, 0, 400),
        BackgroundTransparency = 0
    }):Play()

    titleLabel.TextTransparency = 1
    task.delay(0.15, function()
        TweenService:Create(titleLabel, config.TweenPresets.Fade, {
            TextTransparency = 0
        }):Play()
    end)

    minimizeButton.BackgroundTransparency = 1
    minimizeButton.TextTransparency = 1
    closeButton.BackgroundTransparency = 1
    closeButton.TextTransparency = 1
    task.delay(0.25, function()
        TweenService:Create(minimizeButton, config.TweenPresets.Fade, {
            BackgroundTransparency = 0, TextTransparency = 0
        }):Play()
    end)
    task.delay(0.35, function()
        TweenService:Create(closeButton, config.TweenPresets.Fade, {
            BackgroundTransparency = 0, TextTransparency = 0
        }):Play()
    end)

    topSeparator.BackgroundTransparency = 1
    task.delay(0.3, function()
        TweenService:Create(topSeparator, config.TweenPresets.Fade, {
            BackgroundTransparency = 0
        }):Play()
    end)

    verticalSeparator.BackgroundTransparency = 1
    task.delay(0.35, function()
        TweenService:Create(verticalSeparator, config.TweenPresets.Fade, {
            BackgroundTransparency = 0
        }):Play()
    end)

    -- Animate sidebar buttons
    for i, tab in ipairs(tabs) do
        tab.button.BackgroundTransparency = 1
        tab.button.TextTransparency = 1
        local delay = 0.4 + i * 0.05
        task.delay(delay, function()
            TweenService:Create(tab.button, config.TweenPresets.Fade, {
                BackgroundTransparency = 0, TextTransparency = 0
            }):Play()
        end)
    end

    task.delay(0.5, function()
        TweenService:Create(contentFrame, config.TweenPresets.Open, {
            Size = UDim2.new(1, -121, 1, -36)
        }):Play()
    end)

    -- Select first tab after animation
    if #tabs > 0 then
        task.delay(0.6, function()
            UI.switchTab(tabs[1].name)
        end)
    end
end

-- Minimize or restore the window
function UI.minimize()
    if isClosing then return end
    local TweenService = game:GetService("TweenService")

    if not isMinimized then
        isMinimized = true
        -- Minimize
        TweenService:Create(sidebar, config.TweenPresets.Close, {
            Size = UDim2.new(0, 120, 0, 0)
        }):Play()
        TweenService:Create(contentFrame, config.TweenPresets.Close, {
            Size = UDim2.new(1, -121, 0, 0)
        }):Play()
        TweenService:Create(verticalSeparator, config.TweenPresets.Close, {
            Size = UDim2.new(0, 1, 0, 0)
        }):Play()
        for _, tab in ipairs(tabs) do
            TweenService:Create(tab.button, config.TweenPresets.Close, {
                TextTransparency = 1
            }):Play()
        end
        TweenService:Create(mainFrame, config.TweenPresets.Open, {
            Size = UDim2.new(0, 550, 0, 36)
        }):Play()
        TweenService:Create(minimizeButton, TweenInfo.new(0.2), {
            TextTransparency = 1
        }):Play()
        task.delay(0.15, function()
            minimizeButton.Text = "□"
            TweenService:Create(minimizeButton, TweenInfo.new(0.2), {
                TextTransparency = 0
            }):Play()
        end)
    else
        isMinimized = false
        -- Restore
        TweenService:Create(minimizeButton, TweenInfo.new(0.2), {
            TextTransparency = 1
        }):Play()
        task.delay(0.15, function()
            minimizeButton.Text = "—"
            TweenService:Create(minimizeButton, TweenInfo.new(0.2), {
                TextTransparency = 0
            }):Play()
        end)
        TweenService:Create(mainFrame, config.TweenPresets.Open, {
            Size = config.Defaults.WindowSize or UDim2.new(0, 550, 0, 400)
        }):Play()
        task.delay(0.1, function()
            TweenService:Create(sidebar, config.TweenPresets.Open, {
                Size = UDim2.new(0, 120, 1, -36)
            }):Play()
            TweenService:Create(contentFrame, config.TweenPresets.Open, {
                Size = UDim2.new(1, -121, 1, -36)
            }):Play()
            TweenService:Create(verticalSeparator, config.TweenPresets.Open, {
                Size = UDim2.new(0, 1, 1, -36)
            }):Play()
            for _, tab in ipairs(tabs) do
                TweenService:Create(tab.button, config.TweenPresets.Open, {
                    TextTransparency = 0
                }):Play()
            end
        end)
    end
end

-- Close and destroy the UI
function UI.close()
    if isClosing then return end
    isClosing = true

    local TweenService = game:GetService("TweenService")

    -- Cleanup drag
    if dragCleanup then
        dragCleanup()
        dragCleanup = nil
    end

    -- Fade out all elements
    local fadeOut = TweenService:Create(mainFrame, config.TweenPresets.Close, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 550, 0, 380)
    })
    TweenService:Create(titleBar, config.TweenPresets.Close, { BackgroundTransparency = 1 }):Play()
    TweenService:Create(titleLabel, config.TweenPresets.Close, { TextTransparency = 1 }):Play()
    TweenService:Create(minimizeButton, config.TweenPresets.Close, {
        BackgroundTransparency = 1, TextTransparency = 1
    }):Play()
    TweenService:Create(closeButton, config.TweenPresets.Close, {
        BackgroundTransparency = 1, TextTransparency = 1
    }):Play()
    TweenService:Create(topSeparator, config.TweenPresets.Close, {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(sidebar, config.TweenPresets.Close, {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(verticalSeparator, config.TweenPresets.Close, {
        BackgroundTransparency = 1
    }):Play()
    for _, tab in ipairs(tabs) do
        TweenService:Create(tab.button, config.TweenPresets.Close, {
            BackgroundTransparency = 1, TextTransparency = 1
        }):Play()
    end
    TweenService:Create(contentFrame, config.TweenPresets.Close, {
        BackgroundTransparency = 1
    }):Play()
    fadeOut:Play()

    fadeOut.Completed:Connect(function()
        -- Destroy all floating windows
        if screenGui then
            for _, child in ipairs(screenGui:GetChildren()) do
                if child:IsA("Frame") and (child.Name:find("Overlay") or child.Name:find("Window")) then
                    child:Destroy()
                end
            end
            screenGui:Destroy()
            screenGui = nil
        end
        -- Call onClose callback
        if onCloseCallback then
            onCloseCallback()
        end
    end)
end

-- Register a callback to be called when GUI is fully closed
function UI.onClose(callback)
    onCloseCallback = callback
end

-- Get the ScreenGui reference (for floating windows)
function UI.getScreenGui()
    return screenGui
end

return UI
