player = {}

--this is where we set atributes of the player
function player.load()
	player.x = 10
	player.y = 10
	player.width = 10
	player.height = 10
	player.xvel = 0
	player.yvel = 0
	player.friction = 1
	player.speed = 500
end

--this is where the player is drawn from
function player.draw()
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("fill",player.x,player.y,player.width,player.height)

end

--this is where the phusics are handled
function player.physics(dt)
	player.x = player.x + player.xvel * dt
	player.y = player.y + player.yvel * dt
	player.xvel = player.xvel * (1 - math.min(dt*player.friction, 1))
	player.yvel = player.yvel * (1 - math.min(dt*player.friction, 1))
end

--this is where the movement is handled
function player.move(dt)
	if love.keyboard.isDown("d") and
	player.xvel < player.speed then
		player.xvel = player.xvel + player.speed * dt
	end

	if love.keyboard.isDown("a") and
	player.xvel > -player.speed then
		player.xvel = player.xvel - player.speed * dt
	end

	if love.keyboard.isDown("s") and
	player.yvel < player.speed then
		player.yvel = player.yvel + player.speed * dt
	end

	if love.keyboard.isDown("w") and
	player.yvel > -player.speed then
		player.yvel = player.yvel - player.speed * dt
	end
end

--functions are put here to be easily managaed in the main file
function player.LOAD()
	player.load()
end

function player.UPDATE(dt)
	player.physics(dt)
	player.move(dt)
end

function player.DRAW()
	player.draw()
end