local GameState = {}
GameState.__index = GameState
function GameState:new()
    local manager = setmetatable({current = "menu", states = {
        menu = require("states.menu_state"),
        playing = require("states.game_state")
    }}, self)
    manager:switch("menu")
    return manager
end
function GameState:switch(name)
    assert(self.states[name], "Unknown state: " .. tostring(name))
    self.current = name
    self.states[name]:enter(self)
end
function GameState:update(dt)
    self.states[self.current]:update(dt)
end
function GameState:draw()
    self.states[self.current]:draw()
end
function GameState:handleKey(key)
    self.states[self.current].input:handleKey(key)
end
return GameState
