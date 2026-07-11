-- Features/Speedhack.lua
-- Speedhack feature: modifies WalkSpeed with auto-apply on respawn
-- Receives Context, returns Feature table

return function(Context)
    local FeatureState = Context.FeatureState
    local LocalPlayer = Context.LocalPlayer
    local Config = Context.Config
    local RunService = Context.Services.RunService

    local Speedhack = {}
    local heartbeatConnection = nil

    -- ============================================================
    -- APPLY SPEED TO CURRENT CHARACTER
    -- ============================================================
    local function applySpeed(speed)
        local char = LocalPlayer.Character
        if not char then return false end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then
            -- Пробуем по имени
            hum = char:FindFirstChild("Humanoid")
            if not hum then return false end
        end
        
        hum.WalkSpeed = speed
        return true
    end

    -- ============================================================
    -- START HEARTBEAT LOOP (для игр, которые сбрасывают WalkSpeed)
    -- ============================================================
    local function startHeartbeatLoop(speed)
        if heartbeatConnection then return end
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            if not FeatureState.speedhackEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if hum.WalkSpeed ~= speed then
                hum.WalkSpeed = speed
            end
        end)
    end

    local function stopHeartbeatLoop()
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        end
    end

    -- ============================================================
    -- ENABLE SPEEDHACK
    -- ============================================================
    function Speedhack.Enable()
        if FeatureState.speedhackEnabled then return end
        FeatureState.speedhackEnabled = true
        print("[Speedhack] Enabled (" .. FeatureState.speedhackSpeed .. ")")
        
        -- Применяем сразу
        applySpeed(FeatureState.speedhackSpeed)
        
        -- Запускаем heartbeat для persistent применения
        startHeartbeatLoop(FeatureState.speedhackSpeed)

        -- Коннекшен на респавн
        FeatureState.speedhackCharConnection = LocalPlayer.CharacterAdded:Connect(function(char)
            if not FeatureState.speedhackEnabled then return end
            
            -- Ждём Humanoid
            local hum = char:WaitForChild("Humanoid", 3)
            if not hum then return end
            
            -- Небольшая задержка чтобы обойти игровой reset
            task.delay(0.1, function()
                if FeatureState.speedhackEnabled then
                    hum.WalkSpeed = FeatureState.speedhackSpeed
                end
            end)
        end)
    end

    -- ============================================================
    -- DISABLE SPEEDHACK
    -- ============================================================
    function Speedhack.Disable()
        if not FeatureState.speedhackEnabled then return end
        FeatureState.speedhackEnabled = false
        print("[Speedhack] Disabled")
        
        stopHeartbeatLoop()
        
        if FeatureState.speedhackCharConnection then
            FeatureState.speedhackCharConnection:Disconnect()
            FeatureState.speedhackCharConnection = nil
        end
        
        applySpeed(Config.DEFAULTS.WalkSpeed)
    end

    -- ============================================================
    -- SET SPEED VALUE
    -- ============================================================
    function Speedhack.SetSpeed(value)
        FeatureState.speedhackSpeed = value
        if FeatureState.speedhackEnabled then
            -- Перезапускаем heartbeat с новой скоростью
            stopHeartbeatLoop()
            startHeartbeatLoop(value)
            applySpeed(value)
        end
    end

    -- ============================================================
    -- GET SPEED VALUE
    -- ============================================================
    function Speedhack.GetSpeed()
        return FeatureState.speedhackSpeed
    end

    -- ============================================================
    -- TOGGLE
    -- ============================================================
    function Speedhack.Toggle()
        if FeatureState.speedhackEnabled then
            Speedhack.Disable()
            return false
        else
            Speedhack.Enable()
            return true
        end
    end

    -- ============================================================
    -- IS ENABLED
    -- ============================================================
    function Speedhack.IsEnabled()
        return FeatureState.speedhackEnabled
    end

    print("[Feature] Speedhack module loaded.")
    return Speedhack
end
