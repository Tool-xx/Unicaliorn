-- Features/ESP.lua
-- ESP Feature module
-- Wraps Utils ESP functions into a clean Feature API
-- Receives Context, returns Feature table

return function(Context)
    local Utils = Context.Utils
    local FeatureState = Context.FeatureState

    local ESP = {}

    -- ============================================================
    -- ENABLE / DISABLE (global ESP toggle)
    -- ============================================================
    function ESP.Enable()
        Utils.enableESP()
    end

    function ESP.Disable()
        Utils.disableESP()
    end

    function ESP.IsEnabled()
        return FeatureState.espEnabled
    end

    -- ============================================================
    -- BOX
    -- ============================================================
    function ESP.EnableBox()
        Utils.setBoxEnabled(true)
    end

    function ESP.DisableBox()
        Utils.setBoxEnabled(false)
    end

    function ESP.SetBoxColor(r, g, b)
        Utils.setBoxColor(r, g, b)
    end

    function ESP.SetBoxColor3(color3)
        Utils.setBoxColor(math.floor(color3.R * 255), math.floor(color3.G * 255), math.floor(color3.B * 255))
    end

    function ESP.IsBoxEnabled()
        return FeatureState.espBoxEnabled
    end

    -- ============================================================
    -- HITBOX
    -- ============================================================
    function ESP.EnableHitbox()
        Utils.setHitboxEnabled(true)
    end

    function ESP.DisableHitbox()
        Utils.setHitboxEnabled(false)
    end

    function ESP.SetHitboxColor(r, g, b)
        Utils.setHitboxColor(r, g, b)
    end

    function ESP.SetHitboxColor3(color3)
        Utils.setHitboxColor(math.floor(color3.R * 255), math.floor(color3.G * 255), math.floor(color3.B * 255))
    end

    function ESP.IsHitboxEnabled()
        return FeatureState.espHitboxEnabled
    end

    -- ============================================================
    -- SKELETON
    -- ============================================================
    function ESP.EnableSkeleton()
        Utils.setSkeletonEnabled(true)
    end

    function ESP.DisableSkeleton()
        Utils.setSkeletonEnabled(false)
    end

    function ESP.SetSkeletonColor(r, g, b)
        Utils.setSkeletonColor(r, g, b)
    end

    function ESP.SetSkeletonColor3(color3)
        Utils.setSkeletonColor(math.floor(color3.R * 255), math.floor(color3.G * 255), math.floor(color3.B * 255))
    end

    function ESP.IsSkeletonEnabled()
        return FeatureState.espSkeletonEnabled
    end

    -- ============================================================
    -- GET CURRENT COLORS
    -- ============================================================
    function ESP.GetBoxColor()
        return FeatureState.espBoxColor
    end

    function ESP.GetHitboxColor()
        return FeatureState.espHitboxColor
    end

    function ESP.GetSkeletonColor()
        return FeatureState.espSkeletonColor
    end

    print("[Feature] ESP module loaded.")
    return ESP
end
