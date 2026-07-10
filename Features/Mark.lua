-- Features/Mark.lua
-- Mark feature: highlights a player with a persistent colored outline
-- Receives Context, returns Feature table

return function(Context)
    local FeatureState = Context.FeatureState
    local Config = Context.Config
    local COLORS = Config.COLORS

    local Mark = {}

    -- ============================================================
    -- MARK PLAYER
    -- ============================================================
    function Mark.Mark(player)
        local char = player.Character
        if not char then return false end

        if FeatureState.markedPlayers[player] then
            return false  -- already marked
        end

        print("[Mark] Marked " .. player.Name)
        local highlight = Instance.new("Highlight")
        highlight.FillColor = COLORS.MarkColor
        highlight.OutlineColor = COLORS.MarkColor
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Adornee = char
        highlight.Parent = char
        FeatureState.markedPlayers[player] = highlight
        return true
    end

    -- ============================================================
    -- UNMARK PLAYER
    -- ============================================================
    function Mark.Unmark(player)
        if not FeatureState.markedPlayers[player] then
            return false
        end

        print("[Mark] Unmarked " .. player.Name)
        FeatureState.markedPlayers[player]:Destroy()
        FeatureState.markedPlayers[player] = nil
        return true
    end

    -- ============================================================
    -- TOGGLE MARK
    -- ============================================================
    function Mark.Toggle(player)
        if FeatureState.markedPlayers[player] then
            Mark.Unmark(player)
            return false
        else
            Mark.Mark(player)
            return true
        end
    end

    -- ============================================================
    -- UNMARK ALL (used on destroy)
    -- ============================================================
    function Mark.UnmarkAll()
        for player, highlight in pairs(FeatureState.markedPlayers) do
            pcall(function()
                if highlight then highlight:Destroy() end
            end)
        end
        FeatureState.markedPlayers = {}
        print("[Mark] All marks cleared.")
    end

    -- ============================================================
    -- IS MARKED
    -- ============================================================
    function Mark.IsMarked(player)
        return FeatureState.markedPlayers[player] ~= nil
    end

    -- ============================================================
    -- GET MARKED PLAYERS
    -- ============================================================
    function Mark.GetMarked()
        local list = {}
        for player, _ in pairs(FeatureState.markedPlayers) do
            table.insert(list, player)
        end
        return list
    end

    print("[Feature] Mark module loaded.")
    return Mark
end
