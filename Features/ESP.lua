-- Features/ESP.lua
-- ESP Feature module
-- Wraps Utils ESP functions into a clean Feature API
-- All colors are dynamic black-white gradient (no manual color selection)
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

    function ESP.IsSkeletonEnabled()
        return FeatureState.espSkeletonEnabled
    end

    print("[Feature] ESP module loaded (dynamic gradient).")
    return ESP
end
