-- Features/Speedhack.lua
-- Speedhack feature: uses GetPropertyChangedSignal to persist WalkSpeed
-- Receives Context, returns Feature table

return function(Context)
    local FeatureState = Context.FeatureState
    local LocalPlayer = Context.LocalPlayer
    local Config = Context.Config

    local Speedhack = {}
    local walkSpeedConnection = nil

    -- ============================================================
    -- APPLY SPEED WITH PROPERTY LOCK
    -- ============================================================
    local function applySpeed(speed)
        local char = LocalPlayer.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then
            hum = char:WaitForChild("Humanoid", 3)
            if not hum then return end
        end
        
        hum.WalkSpeed = speed
    end

    -- ============================================================
    -- LOCK WALKSPEED (GetPropertyChangedSignal)
    -- ============================================================
    local function lockWalkSpeed(speed)
        local char = LocalPlayer.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        -- Отключаем старый коннекшен если есть
        if walkSpeedConnection then
            walkSpeedConnection:Disconnect()
            walkSpeedConnection = nil
        end
        
        -- Ловим любые попытки игры изменить WalkSpeed
        walkSpeedConnection = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if not FeatureState.speedhackEnabled then return end
            if hum.WalkSpeed ~= FeatureState.speedhackSpeed then
                hum.WalkSpeed = FeatureState.speedhackSpeed
            end
        end)
        
        -- Устанавливаем начальное значение
        hum.WalkSpeed = speed
    end

    local function unlockWalkSpeed()
        if walkSpeedConnection then
            walkSpeedConnection:Disconnect()
            walkSpeedConnection = nil
        end
    end

    -- ============================================================
    -- ENABLE SPEEDHACK
    -- ============================================================
    function Speedhack.Enable()
        if FeatureState.speedhackEnabled then return end
        FeatureState.speedhackEnabled = true
        print("[Speedhack] Enabled (" .. FeatureState.speedhackSpeed .. ")")
        
        lockWalkSpeed(FeatureState.speedhackSpeed)

        -- На респавн переподключаем ловушку
        FeatureState.speedhackCharConnection = LocalPlayer.CharacterAdded:Connect(function(char)
            if not FeatureState.speedhackEnabled then return end
            
            local hum = char:WaitForChild("Humanoid", 3)
            if not hum then return end
            
            -- Небольшая задержка для стабильности
            task.delay(0.1, function()
                if FeatureState.speedhackEnabled then
                    lockWalkSpeed(FeatureState.speedhackSpeed)
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
        
        unlockWalkSpeed()
        
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
            -- Переподключаем с новой скоростью
            lockWalkSpeed(value)
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
