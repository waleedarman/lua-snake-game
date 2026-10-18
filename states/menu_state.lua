local Input = require("input")
local HighScore = require("highscore")
local Menu = {}
function Menu:enter(manager)
    self.highScore = HighScore:load()
    self.input = Input:new()
    local function start() manager:switch("playing") end
    self.input:bind("return", start)
    self.input:bind("space", start)
    self.input:bind("escape", function() love.event.quit() end)
end
function Menu:update(dt) end
function Menu:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SNAKE\n\nHighest score: " .. self.highScore ..
        "\n\nEnter / Space: start\nArrows / WASD: move\nEscape: quit",
        0, 180, 600, "center")
end
return Menu
