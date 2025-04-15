-- BYPASS COOLDOWN
local originals = {}

pcall(function()
    originals.taskDelay = hookfunction(task.delay, function(delayTime, callback, ...)
        if (delayTime and delayTime > 0.05) then
            return task.spawn(callback, ...)
        end
        return originals.taskDelay(delayTime, callback, ...)
    end)
end)

pcall(function()
    originals.taskWait = hookfunction(task.wait, function(waitTime, ...)
        if (waitTime and waitTime > 0.05) then
            return originals.taskWait(0.01, ...)
        end
        return originals.taskWait(waitTime, ...)
    end)
end)

pcall(function()
    originals.wait = hookfunction(wait, function(waitTime, ...)
        if (waitTime and waitTime > 0.05) then
            return originals.wait(0.01, ...)
        end
        return originals.wait(waitTime, ...)
    end)
end)

-- disable screenshake
local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
local originalShake = hookfunction(CameraShaker.Shake, function(self, ...)
    return -- do nothing (disable shake)
end)
