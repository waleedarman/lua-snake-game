local Input = require("input")
local SnakeGame = require("snake_game")
local Playing = {}
function Playing:enter(manager)
    self.game = SnakeGame:new()
    self.input = Input:new()
    local function bindDirection(key, alternate, dx, dy)
        local function command() self.game:changeDirection(dx, dy) end
        self.input:bind(key, command)
        self.input:bind(alternate, command)
    end
    bindDirection("up", "w", 0, -1)
    bindDirection("down", "s", 0, 1)
    bindDirection("left", "a", -1, 0)
    bindDirection("right", "d", 1, 0)
    local function restart()
        if self.game.gameOver then self.game = SnakeGame:new() end
    end
    self.input:bind("return", restart)
    self.input:bind("space", restart)
    self.input:bind("escape", function() manager:switch("menu") end)
end
function Playing:update(dt) self.game:update(dt) end
function Playing:draw() self.game:draw() end
return Playing
