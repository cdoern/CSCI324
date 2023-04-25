-- main.lua Charlie Doern, Sean O'Sullivan, Lauren Chilton 4/25/2023
-- this lua program is the main code for our platformer
-- this platformer has a main player (the fox) and enemies (the eagles)
-- the player's goal is to jump on the green platforms and collect gems to become invincible
-- if they reach the end, there will be a brown door to jump into and they win!


Player = {} -- global player table used to create metatables
Player.__index = Player
count = 0

num_platforms = 0 -- used to let us know total number of platforms at certain points int the game

images = love.graphics.newImage("gfx/player-run-1.png") -- player image
imageWidth = images:getWidth() - 5 -- used for rendering image
platformPng = love.graphics.newImage("gfx/platform-long.png") -- platform image
doorPng = love.graphics.newImage("gfx/doorLarge.png") -- door image
background = love.graphics.newImage("gfx/back.png") -- background image
gemAnim = love.graphics.newImage("gfx/gem-1.png") -- gem image
eagleAnim = love.graphics.newImage("gfx/eagle-attack-1.png") -- enemy image
buttons = {} -- used for restart button
font = love.graphics.newFont(32) -- used for text and restart button rendering
BUTTON_HEIGHT = 64 -- restart button height
t1 = nil -- timer variable for invincibility

-- creates a new player
function Player.new(minY, maxY, img)
    local self = setmetatable({}, Player) -- associates playerx with the Player table allowing it to have access to its functions
    -- next lines are common variables
    self.x = 200 -- starting x
    self.y = maxY - 50 -- starting y
    self.maxY = maxY -- maxy and miny vary because player 1 is above player 2 on the same canvas
    self.minY = minY
    self.image = love.graphics.newImage("gfx/player-run-1.png") -- starting image
    self.width = imageWidth -- w
    self.height = imageWidth -- h
    self.speed = 200 -- starting speed, not too fast
    self.grounded = false -- we fall onto our platform when we begin
    self.gravity = 800 -- make it so that we do not float
    self.dy = 0
    self.platforms = {} -- our platforms
    self.enemies = {} -- our enemies
    self.progress = {} -- our progress
    self.progress.val = 0
    self.progress.x = 150
    self.progress.y = maxY
    self.state = "intro" -- we start on the splash screen
    self.jumpHeight = -600 -- makes us fall
    self.coins = {} -- our gems are empty
    self.score = 0 -- our score is 0
    self.collisionRight = false -- these variables help us figure out if we are hitting a platform
    self.collisionLeft = false
    self.invincible = false -- we are not invincible
    self.player = 0 -- helps us figure out what player to set to lost if we win.

    

    -- creates the restart button
    function newButton(text, fn, buttony)
        return {
            text = text,
            fn = fn, 
    
            y = buttony,
            now = false, 
            last = false
        }
    end


    -- add an initial platform that is the ground
    self.platforms[1] = {
        x = 0,
        y = maxY,
        width = love.graphics.getWidth(),
        height = 100,
    }

    -- add an initial platform randomly
    self.platforms[2] = {
        x = math.random(100, 10000),
        y =  math.random(1, 10) * 100,
        width = 200,
        height = 50,
    }

    -- set random seed so things do not clump too much
    math.randomseed(os.time())

    num_platforms = math.random(50, 70)

    num_enemies = math.random(40, 60)

    -- for number of platforms, generate new platforms that are not too close to eachother
    for i=2, num_platforms, 1 do
        newx = math.random(100, 10000)
        newy = math.random(minY, maxY - 100)        
        w = 200
        while true do
            for j=2, #self.platforms, 1 do
                if not (((newx <= (self.platforms[j].x+self.platforms[j].width*2)) and newx >= (self.platforms[j].x-self.platforms[j].width*2)) and ((newy <= self.platforms[j].y+100) and (newy >= (self.platforms[j].y-100)))) then
                    goto addplatform -- goto to break out of our logic
                end
            end
            -- if we are too close, re generage and go again
            newx = math.random(0, 10000)
            newy = math.random(minY, maxY)
        end
        ::addplatform:: -- add this platform and generate 1-3 coins on it.
        local numCoins = math.random(1, 3)
        for j=1, numCoins do
            local coinX = math.random(newx, newx + w)
            local coinY = newy- 20
            table.insert(self.coins, {
                x = coinX,
                y = coinY,
                width = 20,
                height = 20,
            })
        end
        -- add platform
        self.platforms[i] = {
            x = newx,
            y = newy,
            width = w,
            height = 50,
        }
        
        -- the last platform is the door at the end
        if i == num_platforms then
            self.platforms[i+1] = {
                x = 10500,
                y = self.maxY - 400,
                width =150,
                height = 300,
            }
        end
    end

    -- generate a random enemy so the for loop doesn't barf.
    self.enemies[1] = {
        x = math.random(0, 10000),
        y = math.random(minY, maxY - 100),
        width = 50,
        height = math.random(100, 200),
        dir = 1,
        skipRound = 0
    }

    -- generate number of enemy enemies.
    for i=1, num_enemies, 1 do
        newx = math.random(400, 10000)
        newy = math.random(minY, maxY)
        h = math.random(100, 200)
        while true do
            for j=1, #self.enemies, 1 do
                if not (((newx <= (self.enemies[j].x+50)) and (newx >= (self.enemies[j].x-50))) and ((newy <= self.enemies[j].y+self.enemies[j].height) and (newy >= (self.enemies[j].y-self.enemies[j].height)))) then
                    goto addenemy -- same as above, if we are not too close to one another, add the enemy
                end
            end
            newx = math.random(0, 10000)
            newy = math.random(minY, maxY)
        end
        ::addenemy::         
        self.enemies[i] = {
            x = newx,
            y = newy,
            width = 50,
            height = h,
            dir = 1,
            skipRound = 0,
        }
    end
    return self
end

-- updates each player
function Player:update(dt, platforms)
    count = count + 0.1 -- count tells us which animation to choose
    gemAnim = gems[math.floor(count, 1)%5 + 1] -- change anim
    eagleAnim = eagle[math.floor(count, 1)%4 + 1] -- chanfe anim
    if self.score >= 15 then -- if we have a score of 15, we are invincible!
        if self.invincible then
            current = love.timer.getTime() - t1
            if (current > 15) then -- after 15 seconds, no longer invicible
                self.invincible = false
                self.score = 0
            end
        else
            self.invincible = true
            t1 = love.timer.getTime()
        end
    end
    if love.keyboard.isDown(self.left) and not self.collisionLeft then -- if we are going left, udate animation and check if we are on a platform or hitting an enemy
        self.collisionRight = false
        self.collisionLeft = false           
        self.image = playerAnimation2[math.floor(count, 1)%6 + 1]
        if self.x > 60 then 
            self.x = self.x - self.speed * dt
        else
            for i, platform in ipairs(self.platforms) do
                if i > 1 then
                platform.x = platform.x + self.speed * dt -- the player stops moving once they get past the window width, instead, the objects begin to move in the opposite direction to mimic movement
                end
            end
            for i, coin in ipairs(self.coins) do
                coin.x = coin.x + self.speed * dt

            end
            for i, enemy in ipairs(self.enemies) do
                if i > 1 then
                    enemy.x = enemy.x + self.speed * dt --the player stops moving once they get past the window width, instead, the objects begin to move in the opposite direction to mimic movement
                end
            end
        end
        if self.progress.val > 0 then 
            self.progress.val = self.progress.val - self.speed * dt / 10400
        end
      elseif love.keyboard.isDown(self.right)  and not self.collisionRight then -- same as above, if going right update a lot of status
        self.collisionRight = false
        self.collisionLeft = false
            self.image = playerAnimation[math.floor(count, 1)%6 + 1]
  
        if self.x < love.graphics.getWidth() - self.width - 100 then
            self.x = self.x + self.speed * dt
        else 
            for i, platform in ipairs(self.platforms) do
                if i > 1 then
                    platform.x = platform.x - player1.speed * dt
                end
            end
            for i, coin in ipairs(self.coins) do
                coin.x = coin.x - self.speed * dt
            end
            for i, enemy in ipairs(self.enemies) do
                if i > 1 then
                    enemy.x = enemy.x - self.speed * dt
                end
            end
        end
        self.progress.val = self.progress.val + self.speed * dt / 10400
      end

      bottom1 = {
        x = 0,
        y = self.minY,
        width = love.graphics.getWidth(),
        height = 100,
        }
        top1 = {
        x = 0,
        y = self.maxY,
        width = love.graphics.getWidth(),
        height = 0,
        }
      
            for i, enemy in ipairs(self.enemies) do  -- checks if we are hitting an enemy or if an enemy has hit the ceiling/botton
                if enemy.y >= top1.y - 100 or enemy.y <= bottom1.y and enemy.skipRound == 0 then
                    enemy.dir = enemy.dir * -1
                    enemy.y = enemy.y + 4 * enemy.dir
                    enemy.skipRound = 3
                else  
                    enemy.y = enemy.y + enemy.dir
                    if enemy.skipRound ~= 0 then
                        enemy.y = enemy.y + 4 * enemy.dir
                        enemy.skipRound = enemy.skipRound - 1
                    end
                end
                if self.invincible == false and self.y  <= enemy.y + 40 and self.y >= enemy.y - 40 and self.x <= enemy.x + 40 and self.x >= enemy.x - 40 then
                    self.state = "lost" -- this is used in draw to draw the you lost screen
                end
        end
    
        for i, platform in ipairs(self.platforms) do -- checks our postion in reference to the platforms
            if self.y + 20 < platform.y + platform.height and self.y + 20 > platform.y and self.x + self.width - 18 > platform.x and self.x + 12 < platform.x + platform.width then
                if i == num_platforms + 1 then  -- if we are touching the final door platform, we are winners!
                    self.state = "won"
                end
                self.y = self.y + platform.height
                self.dy = 0
            end
            if self.y + self.height > platform.y and self.y + self.height < platform.y + platform.height and self.x + self.width -18 > platform.x and self.x +12< platform.x + platform.width then
                if i == num_platforms + 1 then
                    self.state = "won"
                end
                self.grounded = true -- when on top of a platform we are at its height and grounded on it
                self.dy = 0
                self.y = platform.y - self.height
            end
            if self.x + self.width > platform.x and platform.x > self.x and self.y + self.height > platform.y and platform.y + platform.height > self.y then
                self.collisionRight = true -- does not let us glitch through platforms
            end
            if self.x < platform.x + platform.width and platform.x < self.x and self.y + self.height > platform.y and platform.y + platform.height > self.y then
                self.collisionLeft = true -- does not let us glitch through platforms
            end
        end
    
    
        if love.keyboard.isDown(self.jump) and self.grounded then -- if we are jumping, jump!
            self.collisionRight = false
            self.collisionLeft = false
            self.dy = self.jumpHeight
        end

        if not self.grounded then
            self.dy = self.dy + self.gravity * dt
        else
            self.collisionRight = false
            self.collisionLeft = false
        end
        self.y = self.y + self.dy * dt
        self.grounded = false
        for i, coin in ipairs(self.coins) do -- if we are touching a coin, add to our score and get rid of the coin
            if self.invincible == false and self.y + self.height > coin.y and self.y < coin.y + coin.height and
               self.x + self.width > coin.x and self.x < coin.x + coin.width then
                table.remove(self.coins, i)
                self.score = self.score + 1
            end
        end
end

-- draws each player
function Player:draw()
    require "splash" -- get module splash, draw the splash screen if we have not begun.
    if self.state == "intro" then
        splash.draw()
        if splash.play then -- once a splash fn is triggered, time to play.
            self.state = "play"
        end
    else
        if splash.mode == "multi" and splash.waitingToResize == true then -- if we are in multiplayer mode, resize the window to be 2x
            love.window.setMode(love.graphics.getWidth(), love.graphics.getHeight()*2)
            splash.waitingToResize = false
        end
        if self.state == "lost" then -- if we lost, print that and do not let us play anymore.
            love.graphics.print("You Lose!", font, 50, self.minY + 50)
            font = love.graphics.newFont(32)
            love.graphics.setBackgroundColor(0.1, 0.5, 0.9)
            table.insert(buttons, newButton(
                "Restart",
                function()
                    love.event.quit( "restart" )
                end, self.minY + 200))
        
        elseif self.state == "won" then -- if we won, the other player lost.
            if self.player == 1 then
                player2.state = "lost"
            else
                player1.state = "lost"
            end
            love.graphics.print("You Win!", font, 50, self.minY + 50)
            font = love.graphics.newFont(32)
            love.graphics.setBackgroundColor(0.1, 0.5, 0.9)
            table.insert(buttons, newButton(
                "Restart",
                function()
                    love.event.quit( "restart" ) -- reboots the whole game
                end, self.minY + 200))
        else
            love.graphics.setColor(1, 1, 1) -- this is when you want to draw an image
            love.graphics.draw(background, 0, self.minY) -- draw background.
            if self.invincible == true then -- set our color to gold when invincible
                love.graphics.setColor(1, 0.85, 0)
            end
            love.graphics.draw(self.image, self.x, self.y)
          
            love.graphics.setColor(0, 1, 0.2) -- used to make platforms green
            for i, platform in ipairs(self.platforms) do
                
                love.graphics.rectangle("fill", platform.x, platform.y, platform.width, platform.height)
                if i > 1 then
                    love.graphics.draw(platformPng, platform.x, platform.y) -- draw each platform
                end
                if i == num_platforms + 1 then
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(doorPng, platform.x, platform.y) -- draw the door with accurate colors
                end
            end
            for i, coin in ipairs(self.coins) do
                love.graphics.draw(gemAnim, coin.x, coin.y) -- draw the gems
            end
            love.graphics.setColor(1, 0, 0, 1)
            for i, enemy in ipairs(self.enemies) do 
                love.graphics.draw(eagleAnim, enemy.x, enemy.y) -- draw the eagles in red
            end
            font = love.graphics.newFont(24) -- now print all of the text
            love.graphics.print(math.floor(self.progress.val*100, 1) .. "%", font, 50, self.minY + 50)
            love.graphics.print("Gems: " .. self.score, font, 50, self.minY+100)
            if self.invincible == true then
                love.graphics.print("INVINCIBLE", font, 50, self.minY+150)

            end

        end
    end

end

-- generic love.load function, loads all images and creates the players
function love.load()
    require "splash"
    splash.load()
    splash.draw() -- draw the start screen

    player1 = Player.new(0, 500, "") -- create player 1 at the proper value
    player1.left = "left"
    player1.right = "right"
    player1.jump = "up"
    player1.player = 1 -- set up right left buttons and which player


    player2 = Player.new(600, 1100, "") -- create player 2 at proper value
    player2.left = "a"
    player2.right = "d"
    player2.jump = "w"
    player2.player = 2

    -- init all images once to reduce lag so that when updating players we can rotate through them properly
    playerAnimation = {love.graphics.newImage("gfx/player-run-1.png"), love.graphics.newImage("gfx/player-run-2.png"), love.graphics.newImage("gfx/player-run-3.png"), love.graphics.newImage("gfx/player-run-4.png"), love.graphics.newImage("gfx/player-run-5.png"), love.graphics.newImage("gfx/player-run-6.png"), love.graphics.newImage("gfx/player-jump-1.png")}
    playerAnimation2 = {love.graphics.newImage("gfx/player-run-1 copy.png"), love.graphics.newImage("gfx/player-run-2 copy.png"), love.graphics.newImage("gfx/player-run-3 copy.png"), love.graphics.newImage("gfx/player-run-4 copy.png"), love.graphics.newImage("gfx/player-run-5 copy.png"), love.graphics.newImage("gfx/player-run-6 copy.png"), love.graphics.newImage("gfx/player-jump-1 copy.png")}
    gems = {love.graphics.newImage("gfx/gem-1.png"), love.graphics.newImage("gfx/gem-2.png"), love.graphics.newImage("gfx/gem-3.png"), love.graphics.newImage("gfx/gem-4.png"),love.graphics.newImage("gfx/gem-5.png")}
    eagle = {love.graphics.newImage("gfx/eagle-attack-1.png"), love.graphics.newImage("gfx/eagle-attack-2.png"), love.graphics.newImage("gfx/eagle-attack-3.png"), love.graphics.newImage("gfx/eagle-attack-4.png")}
end

-- generic love update function, update each player
function love.update(dt)
    player1:update(dt) -- update player 1
    if splash.mode == "multi" then -- if multiplayer, update player2
        player2:update(dt)
    end
end

-- generic love draw function
function love.draw()
    player1:draw() -- draw player 1
    if splash.mode == "multi" then -- if multiplayer draw player 2
        player2:draw()
    end

    -- if we are drawing the reset button, do that too.
    if buttons ~= nil then

        local ww = love.graphics.getWidth()
        local wh = love.graphics.getHeight()

        local button_width = ww * (1/3)
        local margin = 16

        local color = {0.4, 0.4, 0.5, 1.0}
        local bx = (ww * 0.5) - (button_width * 0.5)
        local total_height = (BUTTON_HEIGHT + margin) * #buttons
        local cursor_y = 0
         for i, button in ipairs(buttons) do 
            local mx, my = love.mouse.getPosition() -- get mouse position
              local cursorHot = (mx > bx and mx < bx + button_width) and (my > button.y and my < button.y + BUTTON_HEIGHT) -- if our cursor is on the button
              if cursorHot then 
                  color = {0.8, 0.8, 0.9, 1.0} -- change color when on button
              else
                  color = {0.4, 0.4, 0.5, 1.0} -- generic color when not on button
            end

            love.graphics.setColor(unpack(color))
        
            -- draw button
            love.graphics.rectangle(
                "fill", 
                bx,
                button.y,
                button_width,
                BUTTON_HEIGHT
            )
            love.graphics.setColor(0, 0, 0, 1)

            -- write the text on each (restart), but there can be two buttons one for each player
            local textW = font:getWidth(button.text)
            local textH = font:getHeight(button.text)
            love.graphics.print(
                button.text, 
                font,
                (ww * 0.5) - textW * 0.5,
                button.y + textH * 0.5
            )
        end
    end
   
end

-- redefining love.mousepressed
function love.mousepressed(x, y, button, istouch)
    print("pressed")
    if button == 1 then  -- if left button
        if player1.state == "lost" or player2.state == "lost" or player1.state == "won" or player2.state == "won" then -- if we are waiting for a restart click
            local ww = love.graphics.getWidth()
            local wh = love.graphics.getHeight()
            local total_height = (BUTTON_HEIGHT) 
    
            local BUTTON_WIDTH = ww * (1/3)
            for i, button in ipairs(buttons) do 
                local bx = (ww * 0.5) - (BUTTON_WIDTH * 0.5)
                local cursor_y = 0

                local by = (wh * 0.5) - (total_height * 0.5) + cursor_y
                local BUTTON_WIDTH = ww * (1/3)
                local cursorHot = (x > bx and x < bx + BUTTON_WIDTH) and (y > button.y and y < button.y + BUTTON_HEIGHT) -- if we are on the button
    
                if cursorHot then
                    button.fn() -- restart the game by executing the buttons functions if cursor hot and click.
                end
            end
        end
    end
 end

