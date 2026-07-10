-- Tabs/Players.lua
-- Players tab: player list with search, avatars, health, distance, actions
-- Receives Context, returns tab content frame

return function(Context)
    local Players = Context.Services.Players
    local LocalPlayer = Context.LocalPlayer
    local Config = Context.Config
    local COLORS = Config.COLORS
    local Components = Context.UI.Components
    local FeatureState = Context.FeatureState

    -- ============================================================
    -- CREATE CONTENT
    -- ============================================================
    local container = Instance.new("Frame")
    container.Name = "PlayersContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundColor3 = COLORS.Background
    container.BorderSizePixel = 0
    container.Visible = false
    container.Parent = Context.UI.ContentFrame

    -- Search bar
    local searchFrame = Instance.new("Frame")
    searchFrame.Name = "SearchFrame"
    searchFrame.Size = UDim2.new(1, 0, 0, 30)
    searchFrame.Position = UDim2.new(0, 0, 0, 0)
    searchFrame.BackgroundColor3 = COLORS.Background
    searchFrame.BorderSizePixel = 1
    searchFrame.BorderColor3 = COLORS.Border
    searchFrame.Parent = container

    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Size = UDim2.new(0, 24, 0, 24)
    searchIcon.Position = UDim2.new(0, 5, 0.5, -12)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = "rbxassetid://7072725342"
    searchIcon.Parent = searchFrame

    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -35, 0, 28)
    searchBox.Position = UDim2.new(0, 35, 0, 1)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search player..."
    searchBox.TextColor3 = COLORS.Text
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.Gotham
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = searchFrame

    -- Scroll
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "PlayerScroll"
    scroll.Size = UDim2.new(1, 0, 1, -30)
    scroll.Position = UDim2.new(0, 0, 0, 30)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = COLORS.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.Name
    layout.Parent = scroll

    local playerCards = {}

    -- ============================================================
    -- HELPERS
    -- ============================================================
    local function updateCanvasSize()
        task.defer(function()
            local newSize = layout.AbsoluteContentSize.Y + 5
            scroll.CanvasSize = UDim2.new(0, 0, 0, newSize)
        end)
    end

    local function updateCardData(data)
        local player = data.player
        local healthFill = data.healthFill
        local distanceLabel = data.distanceLabel
        local spectateBtn = data.spectateBtn
        local markBtn = data.markBtn

        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = hum and hum.RootPart
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

        local healthPercent = 1
        if hum then
            healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        end
        healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)

        if root and myRoot then
            local dist = (root.Position - myRoot.Position).Magnitude
            distanceLabel.Text = string.format("%.0f studs", dist)
        else
            distanceLabel.Text = "?"
        end

        if FeatureState.activeSpectatePlayer == player then
            spectateBtn.Text = "Stop Spectate"
        else
            spectateBtn.Text = "Spectate"
        end

        if FeatureState.markedPlayers[player] then
            markBtn.Text = "Unmark"
        else
            markBtn.Text = "Mark"
        end
    end

    -- ============================================================
    -- CREATE PLAYER CARD
    -- ============================================================
    local function createPlayerCard(player)
        print("[Players] Card created for " .. player.Name)
        local card = Instance.new("Frame")
        card.Name = "PlayerCard_" .. player.UserId
        card.Size = UDim2.new(1, 0, 0, 60)
        card.BackgroundColor3 = COLORS.Background
        card.BorderSizePixel = 1
        card.BorderColor3 = COLORS.Border
        card.ClipsDescendants = true
        card.Parent = scroll

        local infoFrame = Instance.new("Frame")
        infoFrame.Size = UDim2.new(1, 0, 0, 60)
        infoFrame.BackgroundColor3 = COLORS.Background
        infoFrame.BorderSizePixel = 0
        infoFrame.Parent = card

        -- Avatar
        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 40, 0, 40)
        avatar.Position = UDim2.new(0, 5, 0.5, -20)
        avatar.BackgroundColor3 = COLORS.Border
        task.spawn(function()
            local success, thumb = pcall(function()
                return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if success then avatar.Image = thumb end
        end)
        avatar.Parent = infoFrame

        -- Name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -180, 0, 20)
        nameLabel.Position = UDim2.new(0, 50, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = COLORS.Text
        nameLabel.TextSize = 13
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = infoFrame

        -- Display name
        local displayLabel = Instance.new("TextLabel")
        displayLabel.Size = UDim2.new(1, -180, 0, 16)
        displayLabel.Position = UDim2.new(0, 50, 0, 23)
        displayLabel.BackgroundTransparency = 1
        displayLabel.Text = "@" .. player.DisplayName
        displayLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        displayLabel.TextSize = 11
        displayLabel.Font = Enum.Font.Gotham
        displayLabel.TextXAlignment = Enum.TextXAlignment.Left
        displayLabel.Parent = infoFrame

        -- Health bar
        local healthBg = Instance.new("Frame")
        healthBg.Size = UDim2.new(0, 80, 0, 8)
        healthBg.Position = UDim2.new(0, 50, 0, 42)
        healthBg.BackgroundColor3 = COLORS.HealthRed
        healthBg.BorderSizePixel = 0
        healthBg.Parent = infoFrame

        local healthFill = Instance.new("Frame")
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.BackgroundColor3 = COLORS.HealthGreen
        healthFill.BorderSizePixel = 0
        healthFill.Parent = healthBg

        -- Distance
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Size = UDim2.new(0, 60, 0, 16)
        distanceLabel.Position = UDim2.new(1, -120, 0, 42)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Text = "?"
        distanceLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        distanceLabel.TextSize = 11
        distanceLabel.Font = Enum.Font.Gotham
        distanceLabel.TextXAlignment = Enum.TextXAlignment.Right
        distanceLabel.Parent = infoFrame

        -- Expand button
        local expandBtn = Instance.new("TextButton")
        expandBtn.Size = UDim2.new(0, 40, 0, 30)
        expandBtn.Position = UDim2.new(1, -45, 0, 5)
        expandBtn.BackgroundColor3 = COLORS.Background
        expandBtn.BorderSizePixel = 1
        expandBtn.BorderColor3 = COLORS.Border
        expandBtn.Text = "▼"
        expandBtn.TextColor3 = COLORS.Text
        expandBtn.TextSize = 14
        expandBtn.Font = Enum.Font.GothamBold
        expandBtn.AutoButtonColor = false
        expandBtn.Parent = infoFrame

        -- Actions frame
        local actionsFrame = Instance.new("Frame")
        actionsFrame.Size = UDim2.new(1, 0, 0, 80)
        actionsFrame.Position = UDim2.new(0, 0, 0, 60)
        actionsFrame.BackgroundColor3 = COLORS.ButtonHover
        actionsFrame.BorderSizePixel = 0
        actionsFrame.Visible = false
        actionsFrame.Parent = card

        local function createActionButton(text, pos, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 120, 0, 30)
            btn.Position = UDim2.new(0, pos.X, 0, pos.Y)
            btn.BackgroundColor3 = COLORS.Background
            btn.BorderSizePixel = 1
            btn.BorderColor3 = COLORS.Border
            btn.Text = text
            btn.TextColor3 = COLORS.Text
            btn.TextSize = 11
            btn.Font = Enum.Font.Gotham
            btn.AutoButtonColor = false
            btn.Parent = actionsFrame
            btn.MouseButton1Click:Connect(function()
                print("[Action] " .. text .. " on " .. player.Name)
                callback()
            end)
            return btn
        end

        -- Teleport To
        createActionButton("Teleport To", Vector2.new(5, 5), function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart")
               and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame)
            end
        end)

        -- Spectate
        local spectateBtn = createActionButton("Spectate", Vector2.new(130, 5), function()
            if Context.Features.Spectate and Context.Features.Spectate.Toggle then
                local isSpectating = Context.Features.Spectate.Toggle(player)
                spectateBtn.Text = isSpectating and "Stop Spectate" or "Spectate"
            end
        end)

        -- View Profile
        createActionButton("View Profile", Vector2.new(255, 5), function()
            if Context.Windows.PlayerProfile and Context.Windows.PlayerProfile.Open then
                Context.Windows.PlayerProfile.Open(player)
            end
        end)

        -- Mark
        local markBtn = createActionButton("Mark", Vector2.new(5, 40), function()
            if Context.Features.Mark and Context.Features.Mark.Toggle then
                local marked = Context.Features.Mark.Toggle(player)
                markBtn.Text = marked and "Unmark" or "Mark"
            end
        end)

        -- Expand/collapse
        local isOpen = false
        expandBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            local targetHeight = isOpen and 140 or 60
            actionsFrame.Visible = isOpen
            local tween = Context.Services.TweenService:Create(card, Config.TWEEN.Hover, {
                Size = UDim2.new(1, 0, 0, targetHeight)
            })
            tween:Play()
            tween.Completed:Connect(updateCanvasSize)
            expandBtn.Text = isOpen and "▲" or "▼"
            updateCanvasSize()
        end)

        local data = {
            player = player,
            frame = card,
            healthFill = healthFill,
            distanceLabel = distanceLabel,
            spectateBtn = spectateBtn,
            markBtn = markBtn,
            expandBtn = expandBtn,
            actionsFrame = actionsFrame,
        }
        playerCards[player] = data
        return data
    end

    -- ============================================================
    -- SEARCH
    -- ============================================================
    local function searchPlayer(query)
        if query == "" then return end
        local foundCard = nil
        for player, data in pairs(playerCards) do
            if player.Name:lower():find(query:lower())
               or player.DisplayName:lower():find(query:lower()) then
                foundCard = data.frame
                break
            end
        end
        if foundCard then
            local cardPos = foundCard.AbsolutePosition.Y - scroll.AbsolutePosition.Y + scroll.CanvasPosition.Y
            scroll.CanvasPosition = Vector2.new(0, cardPos - 5)
        end
    end

    -- ============================================================
    -- REBUILD ALL CARDS
    -- ============================================================
    local function rebuildAllCards()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        playerCards = {}
        for _, player in ipairs(Players:GetPlayers()) do
            createPlayerCard(player)
        end
        updateCanvasSize()
        if searchBox.Text ~= "" then
            searchPlayer(searchBox.Text)
        end
    end

    -- ============================================================
    -- EVENTS
    -- ============================================================
    Players.PlayerAdded:Connect(function(player)
        createPlayerCard(player)
        updateCanvasSize()
    end)

    Players.PlayerRemoving:Connect(function(player)
        if FeatureState.activeSpectatePlayer == player then
            if Context.Features.Spectate and Context.Features.Spectate.Stop then
                Context.Features.Spectate.Stop()
            end
        end
        if FeatureState.markedPlayers[player] then
            if Context.Features.Mark and Context.Features.Mark.Unmark then
                Context.Features.Mark.Unmark(player)
            end
        end
        if playerCards[player] then
            playerCards[player].frame:Destroy()
            playerCards[player] = nil
        end
        updateCanvasSize()
    end)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        searchPlayer(searchBox.Text)
    end)

    -- Update loop
    task.spawn(function()
        while container.Parent do
            for _, data in pairs(playerCards) do
                pcall(updateCardData, data)
            end
            task.wait(0.2)
        end
    end)

    -- Initial build
    rebuildAllCards()

    -- Register tab
    Context.UI.Main.registerTabContent("Players", container)

    print("[Tab] Players loaded.")
    return container
end
