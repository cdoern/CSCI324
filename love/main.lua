
Player = {}
Player.__index = Player

num_platforms = 0

function Player:new(minY, maxY, img)
    local self = setmetatable({}, Player)
    self.x = 200
    self.y = maxY - 100
    self.maxY = maxY
    self.minY = minY
    --self.image = love.graphics.NewImage(img)
    self.width = 30--self.image:getWidth()
    self.height = 60--self.image:getHeight()
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


    self.platforms[1] = {
        x = 0,
        y = maxY, -- this is going to be wrong
        width = love.graphics.getWidth(),
        height = 100,
    }

    self.platforms[2] = {
        x = math.random(0, 10000),
        y =  math.random(minY, maxY),
        width = 200,
        height = 50,
    }

    math.randomseed(os.time())

    num_platforms = math.random(50, 150)

    num_enemies = math.random(50, 150)

    for i=2, num_platforms, 1 do
        newx = math.random(100, 10000)
        newy = math.random(minY, maxY - 150)
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
        self.platforms[i] = {
            x = newx,
            y = newy,
            width = w,
            height = 50,
        }
        if i == num_platforms then
            self.platforms[i+1] = {
                x = 10000,
                y = 200,
                width =150,
                height = 300,
            }
        end
    end

    self.enemies[1] = {
        x = math.random(0, 10000),
        y = math.random(minY, maxY),
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
    if love.keyboard.isDown(self.left_key) then
        if self.x > 60 then 
            self.x = self.x - self.speed * dt
        else
            for i, platform in ipairs(self.platforms) do
                if i > 1 then
                platform.x = platform.x + self.speed * dt
                end
            end
            for i, enemy in ipairs(self.enemies) do
                if i > 1 then
                    enemy.x = enemy.x + self.speed * dt
                end
            end
        end
        self.progress.val = self.progress.val - self.speed * dt / 10000
      elseif love.keyboard.isDown(self.right_key) then
        if self.x < love.graphics.getWidth() - self.width - 100 then
            self.x = self.x + self.speed * dt
        else 
            for i, platform in ipairs(self.platforms) do
                if i > 1 then
                    platform.x = platform.x - player1.speed * dt
                end
            end
            for i, enemy in ipairs(self.enemies) do
                if i > 1 then
                    enemy.x = enemy.x - self.speed * dt
                end
            end
        end
        self.progress.val = self.progress.val + self.speed * dt / 10000
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
            if self.y  <= enemy.y + 100 and self.y >= enemy.y - 75 and self.x <= enemy.x + 40 and self.x >= enemy.x - 40 then
                self.state = "lost"
            end
        end
    
        for i, platform in ipairs(self.platforms) do
            if self.y < platform.y + platform.height and self.y > platform.y and self.x + self.width > platform.x and self.x < platform.x + platform.width then
                if i == num_platforms + 1 then
                    self.state = "won"
                end
                self.y = self.y + platform.height
                self.dy = 0
            end
            if self.y + self.height > platform.y and self.y + self.height < platform.y + platform.height and self.x + self.width > platform.x and self.x < platform.x + platform.width then
                if i == num_platforms + 1 then
                    self.state = "won"
                end
                self.grounded = true
                self.dy = 0
                self.y = platform.y - self.height
            end
        end
    
    
        if love.keyboard.isDown(self.jump_key) and self.grounded then
            self.dy = self.jumpHeight
        end

        if not self.grounded then
            self.dy = self.dy + self.gravity * dt
        end
        self.y = self.y + self.dy * dt
        self.grounded = false
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
            --
        elseif self.state == "won" then
            --
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

            love.graphics.setColor(0, 1, 0.2)
            for i, platform in ipairs(self.platforms) do
                if i > num_platforms then
                    love.graphics.setColor(1, 0.84, 0) 
                end
                love.graphics.rectangle("fill", platform.x, platform.y, platform.width, platform.height)
            end
            love.graphics.setColor(1, 0, 0, 1)
            for i, enemy in ipairs(self.enemies) do 
                love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.width, enemy.height)
            end
            love.graphics.print(self.progress.val*100 .. "%", self.progress.x, self.progress.y)
        end
    end

end

function love.load()
    require "splash"
    splash.load()
    splash.draw()

    player1 = Player:new(0, 500, "")
    player1.left_key = "left"
    player1.right_key = "right"
    player1.jump_key = "space"


    player2 = Player:new(600, 1000, "")
    player2.left_key = "l"
    player2.right_key = "r"
    player2.jump_key = "j"
    
end

function love.update(dt)
    player1:update(dt)
    player2:update(dt)
end

function love.draw()
    player1:draw()
    player2:draw()
end