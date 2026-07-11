-- Features/Speedhack.lua (DEBUG VERSION)
return function(Context)
    local FeatureState = Context.FeatureState
    local LocalPlayer = Context.LocalPlayer
    local Config = Context.Config
    local RunService = Context.Services.RunService

    local Speedhack = {}

    local function applySpeed(speed)
        local char = LocalPlayer.Character
        print("[Speedhack DEBUG] applySpeed called, speed=" .. speed .. ", char=" .. tostring(char))
        
        if not char then 
            print("[Speedhack DEBUG] No character!")
            return false 
        end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        print("[Speedhack DEBUG] hum=" .. tostring(hum) .. ", hum.WalkSpeed=" .. (hum and tostring(hum.WalkSpeed) or "N/A"))
        
        if not hum then
            hum = char:WaitForChild("Humanoid", 2)
            print("[Speedhack DEBUG] After WaitForChild, hum=" .. tostring(hum))
            if not hum then return false end
        end
        
        hum.WalkSpeed = speed
        print("[Speedhack DEBUG] Set WalkSpeed to " .. speed .. ", actual=" .. hum.WalkSpeed)
        return true
    end

    function Speedhack.Enable()
        print("[Speedhack DEBUG] Enable called, speedhackEnabled=" .. tostring(FeatureState.speedhackEnabled))
        if FeatureState.speedhackEnabled then return end
        FeatureState.speedhackEnabled = true
        
        local ok = applySpeed(FeatureState.speedhackSpeed)
        print("[Speedhack DEBUG] First applySpeed result=" .. tostring(ok))

        FeatureState.speedhackCharConnection = LocalPlayer.CharacterAdded:Connect(function(char)
            print("[Speedhack DEBUG] CharacterAdded fired, char=" .. tostring(char))
            if not FeatureState.speedhackEnabled then 
                print("[Speedhack DEBUG] Disabled, ignoring")
                return 
            end
            
            task.delay(0.15, function()
                print("[Speedhack DEBUG] Delayed apply, speed=" .. FeatureState.speedhackSpeed)
                applySpeed(FeatureState.speedhackSpeed)
            end)
        end)
    end

    function Speedhack.Disable()
        print("[Speedhack DEBUG] Disable called")
        if not FeatureState.speedhackEnabled then return end
        FeatureState.speedhackEnabled = false
        if FeatureState.speedhackCharConnection then
            FeatureState.speedhackCharConnection:Disconnect()
            FeatureState.speedhackCharConnection = nil
        end
        applySpeed(Config.DEFAULTS.WalkSpeed)
    end

    function Speedhack.SetSpeed(value)
        print("[Speedhack DEBUG] SetSpeed called, value=" .. value)
        FeatureState.speedhackSpeed = value
        if FeatureState.speedhackEnabled then
            applySpeed(value)
        end
    end

    function Speedhack.GetSpeed()
        return FeatureState.speedhackSpeed
    end

    function Speedhack.Toggle()
        print("[Speedhack DEBUG] Toggle called")
        if FeatureState.speedhackEnabled then
            Speedhack.Disable()
            return false
        else
            Speedhack.Enable()
            return true
        end
    end

    function Speedhack.IsEnabled()
        return FeatureState.speedhackEnabled
    end

    print("[Feature] Speedhack module loaded (DEBUG).")
    return Speedhack
end
