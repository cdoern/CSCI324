
Player = {}
Player.__index = Player
count = 0

num_platforms = 0

images = love.graphics.newImage("gfx/player-run-1.png")
imageWidth = images:getWidth() - 5
platformPng = love.graphics.newImage("gfx/platform-long.png")
enemyPng = love.graphics.newImage("gfx/platform-up.png")
doorPng = love.graphics.newImage("gfx/doorLarge.png")
background = love.graphics.newImage("gfx/back.png")
gemAnim = love.graphics.newImage("gfx/gem-1.png")
eagleAnim = love.graphics.newImage("gfx/eagle-attack-1.png")
buttons = {}
font = love.graphics.newFont(32)
BUTTON_HEIGHT = 64
t1 = nil

function Player.new(minY, maxY, img)
    local self = setmetatable({}, Player)
    self.x = 200
    self.y = maxY - 50
    self.maxY = maxY
    self.minY = minY
    self.image = love.graphics.newImage("gfx/player-run-1.png")
    self.width = imageWidth
    self.height = imageWidth
    self.speed = 200
    self.grounded = false
    self.gravity = 800
    self.dy = 0
    self.platforms = {}
    self.enemies = {}
    self.progress = {}
    self.progress.val = 0
    self.progress.x = 150
    self.progress.y = maxY
    self.state = "intro"
    self.jumpHeight = -600
    self.coins = {}
    self.score = 0
    self.collisionRight = false
    self.collisionLeft = false
    self.invincible = false
    self.player = 0

    

    function newButton(text, fn, buttony)
        return {
            text = text,
            fn = fn, 
    
            y = buttony,
            now = false, 
            last = false
        }
    end


    self.platforms[1] = {
        x = 0,
        y = maxY, -- this is going to be wrong
        width = love.graphics.getWidth(),
        height = 100,
    }

    self.platforms[2] = {
        x = math.random(100, 10000),
        y =  math.random(1, 10) * 100,
        width = 200,
        height = 50,
    }

    math.randomseed(os.time())

    num_platforms = math.random(50, 70)

    num_enemies = math.random(40, 60)

    for i=2, num_platforms, 1 do
        newx = math.random(100, 10000)
        newy = math.random(minY, maxY - 100)        
        w = 200
        while true do
            for j=2, #self.platforms, 1 do
                if not (((newx <= (self.platforms[j].x+self.platforms[j].width*2)) and newx >= (self.platforms[j].x-self.platforms[j].width*2)) and ((newy <= self.platforms[j].y+100) and (newy >= (self.platforms[j].y-100)))) then
                    goto addplatform
                end
            end
            newx = math.random(0, 10000)
            newy = math.random(minY, maxY)
        end
        ::addplatform::
        local numCoins = math.random(1, 3)
        for j=1, numCoins do
            local coinX = math.random(newx, newx + w)
            local coinY = newy- 20
            table.insert(self.coins, {
                x = coinX,
                y = coinY,
                width = 20,
                height = 20,
                --image = love.graphics.newImage("gem-1.png"),
            })
        end
        self.platforms[i] = {
            x = newx,
            y = newy,
            width = w,
            height = 50,
        }
        
        if i == num_platforms then
            self.platforms[i+1] = {
                x = 10500,
                y = self.maxY - 400,
                width =150,
                height = 300,
            }
        end
    end

    self.enemies[1] = {
        x = math.random(0, 10000),
        y = math.random(minY, maxY - 100),
        width = 50,
        height = math.random(100, 200),
        dir = 1,
        skipRound = 0
    }

    for i=1, num_enemies, 1 do
        newx = math.random(400, 10000)
        newy = math.random(minY, maxY)
        h = math.random(100, 200)
        while true do
            for j=1, #self.enemies, 1 do
                if not (((newx <= (self.enemies[j].x+50)) and (newx >= (self.enemies[j].x-50))) and ((newy <= self.enemies[j].y+self.enemies[j].height) and (newy >= (self.enemies[j].y-self.enemies[j].height)))) then
                    goto addenemy
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

function Player:update(dt, platforms)
    count = count + 0.1
    gemAnim = gems[math.floor(count, 1)%5 + 1]
    eagleAnim = eagle[math.floor(count, 1)%4 + 1]
    if self.score >= 15 then
        if self.invincible then
            current = love.timer.getTime() - t1
            if (current > 10) then
                self.invincible = false
                self.score = 0
            end
        else
            self.invincible = true
            t1 = love.timer.getTime()
        end
    end
    if love.keyboard.isDown(self.left) and not self.collisionLeft then
        self.collisionRight = false
        self.collisionLeft = false           
        self.image = playerAnimation2[math.floor(count, 1)%6 + 1]
        if self.x > 60 then 
            self.x = self.x - self.speed * dt
        else
            for i, platform in ipairs(self.platforms) do
                if i > 1 then
                platform.x = platform.x + self.speed * dt
                end
            end
            for i, coin in ipairs(self.coins) do
                coin.x = coin.x + self.speed * dt

            end
            for i, enemy in ipairs(self.enemies) do
                if i > 1 then
                    enemy.x = enemy.x + self.speed * dt
                end
            end
        end
        if self.progress.val > 0 then 
            self.progress.val = self.progress.val - self.speed * dt / 10400
        end
      elseif love.keyboard.isDown(self.right)  and not self.collisionRight then
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
      
            for i, enemy in ipairs(self.enemies) do 
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
                    self.state = "lost"
                end
        end
    
        for i, platform in ipairs(self.platforms) do
            if self.y + 20 < platform.y + platform.height and self.y + 20 > platform.y and self.x + self.width - 18 > platform.x and self.x + 12 < platform.x + platform.width then
                if i == num_platforms + 1 then
                    self.state = "won"
                end
                self.y = self.y + platform.height
                self.dy = 0
            end
            if self.y + self.height > platform.y and self.y + self.height < platform.y + platform.height and self.x + self.width -18 > platform.x and self.x +12< platform.x + platform.width then
                if i == num_platforms + 1 then
                    self.state = "won"
                end
                self.grounded = true
                self.dy = 0
                self.y = platform.y - self.height
            end
            if self.x + self.width > platform.x and platform.x > self.x and self.y + self.height > platform.y and platform.y + platform.height > self.y then
                self.collisionRight = true
            end
            if self.x < platform.x + platform.width and platform.x < self.x and self.y + self.height > platform.y and platform.y + platform.height > self.y then
                self.collisionLeft = true
            end
        end
    
    
        if love.keyboard.isDown(self.jump) and self.grounded then
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
        for i, coin in ipairs(self.coins) do
            if self.invincible == false and self.y + self.height > coin.y and self.y < coin.y + coin.height and
               self.x + self.width > coin.x and self.x < coin.x + coin.width then
                table.remove(self.coins, i)
                self.score = self.score + 1
            end
        end
end

function Player:draw()
    require "splash"
    if self.state == "intro" then
        splash.draw()
        if splash.play then
            self.state = "play"
        end
    else
        if splash.mode == "multi" and splash.waitingToResize == true then
            love.window.setMode(love.graphics.getWidth(), love.graphics.getHeight()*2)
            splash.waitingToResize = false
        end
        if self.state == "lost" then
            love.graphics.print("You Lose!", font, 50, self.minY + 50)
            font = love.graphics.newFont(32)
            love.graphics.setBackgroundColor(0.1, 0.5, 0.9)
            table.insert(buttons, newButton(
                "Restart",
                function()
                    love.event.quit( "restart" )
                end, self.minY + 200))
        
        elseif self.state == "won" then
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
                    love.event.quit( "restart" )
                end, self.minY + 200))
        else
            love.graphics.setColor(1, 1, 1)
            --love.graphics.setColor(1, 1, 1)
            love.graphics.draw(background, 0, self.minY)
            --love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            if self.invincible == true then
                love.graphics.setColor(1, 0.85, 0)
            end
            love.graphics.draw(self.image, self.x, self.y)
          
            love.graphics.setColor(0, 1, 0.2)
            for i, platform in ipairs(self.platforms) do
                
                love.graphics.rectangle("fill", platform.x, platform.y, platform.width, platform.height)
                if i > 1 then
                    love.graphics.draw(platformPng, platform.x, platform.y)
                end
                if i == num_platforms + 1 then
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(doorPng, platform.x, platform.y)
                end
            end
            for i, coin in ipairs(self.coins) do
                love.graphics.draw(gemAnim, coin.x, coin.y)
            end
            love.graphics.setColor(1, 0, 0, 1)
            for i, enemy in ipairs(self.enemies) do 
              --  love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.width, enemy.height)
                love.graphics.draw(eagleAnim, enemy.x, enemy.y)
            end
            font = love.graphics.newFont(24)
            love.graphics.print(math.floor(self.progress.val*100, 1) .. "%", font, 50, self.minY + 50)
            love.graphics.print("Gems: " .. self.score, font, 50, self.minY+100)
            if self.invincible == true then
                love.graphics.print("INVINCIBLE", font, 50, self.minY+150)

            end

        end
    end

end

function love.load()
    require "splash"
    splash.load()
    splash.draw()

    player1 = Player.new(0, 500, "")
    player1.left = "left"
    player1.right = "right"
    player1.jump = "up"
    player1.player = 1


    player2 = Player.new(600, 1100, "")
    player2.left = "a"
    player2.right = "d"
    player2.jump = "w"
    player2.player = 2

    playerAnimation = {love.graphics.newImage("gfx/player-run-1.png"), love.graphics.newImage("gfx/player-run-2.png"), love.graphics.newImage("gfx/player-run-3.png"), love.graphics.newImage("gfx/player-run-4.png"), love.graphics.newImage("gfx/player-run-5.png"), love.graphics.newImage("gfx/player-run-6.png"), love.graphics.newImage("gfx/player-jump-1.png")}
    playerAnimation2 = {love.graphics.newImage("gfx/player-run-1 copy.png"), love.graphics.newImage("gfx/player-run-2 copy.png"), love.graphics.newImage("gfx/player-run-3 copy.png"), love.graphics.newImage("gfx/player-run-4 copy.png"), love.graphics.newImage("gfx/player-run-5 copy.png"), love.graphics.newImage("gfx/player-run-6 copy.png"), love.graphics.newImage("gfx/player-jump-1 copy.png")}
    gems = {love.graphics.newImage("gfx/gem-1.png"), love.graphics.newImage("gfx/gem-2.png"), love.graphics.newImage("gfx/gem-3.png"), love.graphics.newImage("gfx/gem-4.png"),love.graphics.newImage("gfx/gem-5.png")}
    eagle = {love.graphics.newImage("gfx/eagle-attack-1.png"), love.graphics.newImage("gfx/eagle-attack-2.png"), love.graphics.newImage("gfx/eagle-attack-3.png"), love.graphics.newImage("gfx/eagle-attack-4.png")}
end

function love.update(dt)
    player1:update(dt)
    if splash.mode == "multi" then
        player2:update(dt)
    end
end

function love.draw()
    player1:draw()
    if splash.mode == "multi" then
        player2:draw()
    end

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
            local mx, my = love.mouse.getPosition()
  

              local cursorHot = (mx > bx and mx < bx + button_width) and (my > button.y and my < button.y + BUTTON_HEIGHT)
              
              if cursorHot then 
                  color = {0.8, 0.8, 0.9, 1.0}
              else
                  color = {0.4, 0.4, 0.5, 1.0}
            end

            love.graphics.setColor(unpack(color))
        
            love.graphics.rectangle(
                "fill", 
                bx,
                button.y,
                button_width,
                BUTTON_HEIGHT
            )
            love.graphics.setColor(0, 0, 0, 1)

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

function love.mousepressed(x, y, button, istouch)
    print("pressed")
    if button == 1 then 
        if player1.state == "lost" or player2.state == "lost" or player1.state == "won" or player2.state == "won" then
            local ww = love.graphics.getWidth()
            local wh = love.graphics.getHeight()
            local total_height = (BUTTON_HEIGHT) 
    
            local BUTTON_WIDTH = ww * (1/3)
            for i, button in ipairs(buttons) do 
                local bx = (ww * 0.5) - (BUTTON_WIDTH * 0.5)
                local cursor_y = 0

                local by = (wh * 0.5) - (total_height * 0.5) + cursor_y
                local BUTTON_WIDTH = ww * (1/3)
                local cursorHot = (x > bx and x < bx + BUTTON_WIDTH) and (y > button.y and y < button.y + BUTTON_HEIGHT)
    
                if cursorHot then
                    button.fn()
                end
            end
        end
    end
 end

