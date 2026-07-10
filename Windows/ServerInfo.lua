-- Windows/ServerInfo.lua
-- Server Info window: displays place info, players list, server stats
-- Receives Context, returns Window table

return function(Context)
    local MarketplaceService = Context.Services.MarketplaceService
    local Players = Context.Services.Players
    local LocalPlayer = Context.LocalPlayer
    local WindowManager = Context.UI.WindowManager
    local Config = Context.Config
    local SCRIPT_START_TIME = Context.SCRIPT_START_TIME

    local ServerInfo = {}

    -- ============================================================
    -- OPEN SERVER INFO WINDOW
    -- ============================================================
    function ServerInfo.Open()
        print("[ServerInfo] Opened")

        local win = WindowManager.createBaseWindow({
            title = "Server Info",
            width = 400,
            height = 500,
            startY = -280,
            targetY = -250,
            hasScroll = true,
        })

        local content = win.content

        -- Gather data
        local placeId = game.PlaceId
        local jobId = game.JobId
        local placeInfo
        local success = pcall(function()
            placeInfo = MarketplaceService:GetProductInfo(placeId)
        end)
        local placeName = (success and placeInfo and placeInfo.Name) or "Unknown"
        local creatorName = (success and placeInfo and placeInfo.Creator and placeInfo.Creator.Name) or "Unknown"
        local placeVersion = game.PlaceVersion
        local robloxVersion = version()
        local serverType = "Public"
        if game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0 then
            serverType = "Private"
        end
        local playerCount = #Players:GetPlayers()
        local maxPlayers = Players.MaxPlayers
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) .. " ms"
        local uptime = os.time() - SCRIPT_START_TIME
        local uptimeStr = string.format("%d min %d sec", math.floor(uptime/60), uptime % 60)
        local workspaceObjects = 0
        pcall(function() workspaceObjects = #workspace:GetDescendants() end)

        local playersList = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            table.insert(playersList, plr.Name .. " (@" .. plr.DisplayName .. ")")
        end
        table.sort(playersList)
        local playersText = table.concat(playersList, "\n")

        local lines = {
            "=== Server Info ===",
            "Place: " .. placeName,
            "Place ID: " .. placeId,
            "Creator: " .. creatorName,
            "Version: " .. placeVersion,
            "Roblox Version: " .. robloxVersion,
            "Server Type: " .. serverType,
            "Job ID: " .. jobId,
            "Players: " .. playerCount .. " / " .. maxPlayers,
            "Ping: " .. ping,
            "Script Uptime: " .. uptimeStr,
            "Workspace Objects: " .. workspaceObjects,
            "",
            "=== Player List ===",
            playersText
        }
        local fullInfoText = table.concat(lines, "\n")

        -- Build content
        local yOffset = 5
        for _, line in ipairs(lines) do
            yOffset = WindowManager.addTextLine(content, line, yOffset, {
                height = 18,
                spacing = 2,
                size = 13,
                font = Enum.Font.Gotham,
            })
        end
        WindowManager.updateCanvasSize(content, yOffset + 10)

        -- Copy button
        WindowManager.createBottomButton(win, "Copy to Clipboard", function(btn)
            pcall(function() setclipboard(fullInfoText) end)
            btn.Text = "Copied!"
            task.delay(1.5, function()
                if btn and btn.Parent then
                    btn.Text = "Copy to Clipboard"
                end
            end)
        end)

        return win
    end

    print("[Window] ServerInfo module loaded.")
    return ServerInfo
end
