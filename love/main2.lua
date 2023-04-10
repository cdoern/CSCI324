require "player"

function love.load()
	player.LOAD()
end

function love.update(dt)
	player.UPDATE(dt)
end

function love.draw()
	player.DRAW()
end