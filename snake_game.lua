local Vector2 = require("vector2")
local Entity = require("entity")
local HighScore = require("highscore")
local Events = require("events")
local SnakeGame = {}
SnakeGame.__index = SnakeGame

-- Subscribe once per module, rather than once per restart.
Events:subscribe("food_eaten", function(data)
    local game = data.game
    game.score = game.score + 1
    if game.score > game.highScore then
        game.highScore = game.score
        game.saveError = not HighScore:save(game.highScore)
    end
end)

function SnakeGame:new()
    local game = setmetatable({grid = 20, cell = 30, stepTime = 0.14,
        timer = 0, score = 0, highScore = HighScore:load(), gameOver = false}, self)
    game.snake = {game:segment(10, 10), game:segment(9, 10), game:segment(8, 10)}
    game.snake[1]:addComponent("Movement", {dx = 1, dy = 0})
    game:spawnFood()
    return game
end
function SnakeGame:segment(x, y)
    local entity = Entity:new()
    entity:addComponent("Position", Vector2:new(x, y))
    entity:addComponent("Renderer", {color = {0.3, 0.85, 0.45}, size = self.cell - 2})
    return entity
end
function SnakeGame:spawnFood()
    local free = {}
    for y = 0, self.grid - 1 do
        for x = 0, self.grid - 1 do
            local position = Vector2:new(x, y)
            local occupied = false
            for _, segment in ipairs(self.snake) do
                if segment:getComponent("Position") == position then
                    occupied = true
                    break
                end
            end
            if not occupied then table.insert(free, position) end
        end
    end
    if #free == 0 then
        self.food = nil
        self.gameOver = true
        self.won = true
    else
        local random = love and love.math and love.math.random or math.random
        self.food = free[random(#free)]
    end
end
function SnakeGame:changeDirection(dx, dy)
    if self.gameOver or self.pendingDirection then return end
    if math.abs(dx) + math.abs(dy) ~= 1 then return end
    local movement = self.snake[1]:getComponent("Movement")
    if dx == -movement.dx and dy == -movement.dy then return end
    if dx == movement.dx and dy == movement.dy then return end
    self.pendingDirection = Vector2:new(dx, dy)
end
function SnakeGame:step()
    local head = self.snake[1]
    local movement = head:getComponent("Movement")
    if self.pendingDirection then
        movement.dx, movement.dy = self.pendingDirection.x, self.pendingDirection.y
        self.pendingDirection = nil
    end
    local position = head:getComponent("Position") + Vector2:new(movement.dx, movement.dy)
    if position.x < 0 or position.y < 0 or position.x >= self.grid or position.y >= self.grid then
        self.gameOver = true
        return
    end
    local eating = position == self.food
    -- A non-growing tail leaves its cell during this same step.
    local last = #self.snake
    if not eating then last = last - 1 end
    for i = 1, last do
        if self.snake[i]:getComponent("Position") == position then
            self.gameOver = true
            return
        end
    end
    local newHead = self:segment(position.x, position.y)
    newHead:addComponent("Movement", movement)
    head.components.Movement = nil
    table.insert(self.snake, 1, newHead)
    if eating then
        Events:emit("food_eaten", {game = self, position = position})
        self:spawnFood()
    else
        table.remove(self.snake)
    end
end
function SnakeGame:update(dt)
    if self.gameOver then return end
    self.timer = self.timer + dt
    while self.timer >= self.stepTime and not self.gameOver do
        self.timer = self.timer - self.stepTime
        self:step()
    end
end
function SnakeGame:draw()
    love.graphics.setColor(0.13, 0.16, 0.19)
    love.graphics.rectangle("fill", 0, 60, 600, 600)
    if self.food then
        love.graphics.setColor(1, 0.35, 0.3)
        love.graphics.rectangle("fill", self.food.x * self.cell, 60 + self.food.y * self.cell,
            self.cell - 2, self.cell - 2)
    end
    for _, segment in ipairs(self.snake) do
        local position = segment:getComponent("Position")
        local renderer = segment:getComponent("Renderer")
        love.graphics.setColor(renderer.color)
        love.graphics.rectangle("fill", position.x * self.cell, 60 + position.y * self.cell,
            renderer.size, renderer.size)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. self.score .. "    Highest: " .. self.highScore, 12, 10)
    love.graphics.print(self.saveError and "High score could not be saved" or "Arrows / WASD: move    Escape: menu", 12, 32)
    if self.gameOver then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 60, 600, 600)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf((self.won and "BOARD COMPLETE!" or "GAME OVER") ..
            "\nScore: " .. self.score .. "    Highest: " .. self.highScore ..
            "\n\nEnter / Space: restart\nEscape: menu", 0, 280, 600, "center")
    end
end
return SnakeGame
