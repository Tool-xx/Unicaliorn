-- Features/ESP.lua
-- ESP Feature module
-- Wraps Utils ESP functions into a clean Feature API
-- All colors are dynamic neon green gradient (no manual color selection)
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
    -- HEALTH BAR
    -- ============================================================
    function ESP.EnableHealth()
        Utils.setHealthEnabled(true)
    end

    function ESP.DisableHealth()
        Utils.setHealthEnabled(false)
    end

    function ESP.IsHealthEnabled()
        return FeatureState.espHealthEnabled
    end

    -- ============================================================
    -- NAME
    -- ============================================================
    function ESP.EnableName()
        Utils.setNameEnabled(true)
    end

    function ESP.DisableName()
        Utils.setNameEnabled(false)
    end

    function ESP.IsNameEnabled()
        return FeatureState.espNameEnabled
    end

    -- ============================================================
    -- DISTANCE
    -- ============================================================
    function ESP.EnableDistance()
        Utils.setDistanceEnabled(true)
    end

    function ESP.DisableDistance()
        Utils.setDistanceEnabled(false)
    end

    function ESP.IsDistanceEnabled()
        return FeatureState.espDistanceEnabled
    end

    print("[Feature] ESP module loaded (full suite with gradient).")
    return ESP
end
