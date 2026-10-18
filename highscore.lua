local HighScore = {}

-- Lua 5.4's <close> closes a file at scope exit, even when an error occurs.
-- Keep its syntax in a string: LuaJIT cannot parse it as ordinary source.
local withFile
if _VERSION == "Lua 5.4" then
    withFile = assert(load([[
        return function(path, mode, action)
            local file <close>, message = io.open(path, mode)
            if not file then return nil, message end
            return action(file)
        end
    ]], "highscore_lua54"))()
    HighScore.backend = "Lua 5.4 <close>"
else
    -- LuaJIT compatibility: protect the operation and always close explicitly.
    withFile = function(path, mode, action)
        local file, message = io.open(path, mode)
        if not file then return nil, message end
        local ok, result, detail = pcall(action, file)
        local closed, closeError = file:close()
        if not ok then error(result, 0) end
        if not closed then return nil, closeError end
        return result, detail
    end
    HighScore.backend = "explicit close (LuaJIT compatibility)"
end

function HighScore:path()
    if love and love.filesystem then
        return love.filesystem.getSaveDirectory() .. "/highscore.txt"
    end
    -- Standalone Lua stores data outside the submitted source directory too.
    return (os.getenv("TEMP") or ".") .. "/university_snake_highscore.txt"
end

function HighScore:load()
    local content = withFile(self:path(), "r", function(file)
        return file:read("*a")
    end)
    local score = tonumber(content)
    if not score or score < 0 or score == math.huge or score ~= math.floor(score) then
        return 0
    end
    return score
end

function HighScore:save(score)
    assert(type(score) == "number" and score >= 0 and score < math.huge
        and score == math.floor(score), "Score must be a nonnegative integer")
    if score <= self:load() then return true end
    return withFile(self:path(), "w", function(file)
        local ok, message = file:write(tostring(score))
        if not ok then return nil, message end
        -- Check buffered write failures before automatic scope cleanup.
        return file:flush()
    end)
end
return HighScore
