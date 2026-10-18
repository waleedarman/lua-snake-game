local GameState = require("gamestate")
local gameState
function love.load()
    love.filesystem.setIdentity("university_lua_snake")
    love.filesystem.createDirectory("")
    love.window.setMode(600, 660)
    love.window.setTitle("Lua Snake Assignment")
    love.graphics.setBackgroundColor(0.08, 0.10, 0.12)
    gameState = GameState:new()
end
function love.update(dt) gameState:update(dt) end
function love.draw() gameState:draw() end
function love.keypressed(key, scancode, isrepeat)
    if not isrepeat then gameState:handleKey(key) end
end
