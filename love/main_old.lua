local player1 = {}
local player2 = {}
local gravity = 800
local platformsPlayer1 = {}
local enemiesPlayer1 = {}
local platformsPlayer2 = {}
local enemiesPlayer2 = {}
local progressp1 = {}
progressp1.val = 0
progressp1.x = 150
local progressp2 = {}
progressp2.val = 0
progressp2.x = 150
local statep1 = "intro"
local statep2 = "intro"
local num_platforms = 0
local maxPlatformAndEnemyHeightPlayer1 = 0
local lowestPlatformandEnemyHeightPlayer1 = 400
local startingPointForPlayer1 = 200
local count = 0
local direction = 1

local maxPlatformAndEnemyHeightPlayer2 = 600
local lowestPlatformandEnemyHeightPlayer2 = 900
local startingPointForPlayer2 = startingPointForPlayer1 * 2
--co = coroutine.create(function()
  -- while true do
    --  if alreadyedLoaded == false then
      --     love.load()
        --   alreadyedLoadedPlayer2 = true
        --end
        --print("in routine")
        --love.update()
        --love.draw()
        --coroutine.yeild()
    --end
   
--end) 



function love.load()
    require "splash"
    splash.load()
    splash.draw()

    --local sprites = {"sprite1.png", "sprite2.png"}
    


    -- if player == 2 how can we easily do the math
    -- platform = platform.h / 2
    --love.graphics.setBackgroundColor(0.0, 0.5, 0.9)
    background = love.graphics.newImage("back.png")
    playerAnimation = {"player-run-1.png", "player-run-2.png", "player-run-3.png", "player-run-4.png", "player-run-5.png", "player-run-6.png", "player-jump-1.png"}
    playerAnimation2 = {"player-run-1 copy.png", "player-run-2 copy.png", "player-run-3 copy.png", "player-run-4 copy.png", "player-run-5 copy.png", "player-run-6 copy.png", "player-jump-1 copy.png"}
    image = love.graphics.newArrayImage(playerAnimation)
    animate = playerAnimation[1]
    player1.x = 100
    player1.y = startingPointForPlayer1
    player1.width = 30
    player1.height = 60
    player1.speed = 200
    player1.grounded = false
    player1.dy = 0
    player1.jumpHeight = -600
    --player.bottom = player.y + player.height

    platformsPlayer1[1] = {
        x = 0,
        y = 500,
        width = love.graphics.getWidth(),
        height = 100,
    }

    platformsPlayer1[2] = {
        x = math.random(0, 10000),
        y =  math.random(maxPlatformAndEnemyHeightPlayer1, lowestPlatformandEnemyHeightPlayer1),
        width = 200,
        height = 50,
    }

    if splash.playercount == 2  then

    end
    math.randomseed(os.time())

    num_platforms = math.random(100, 150)

    num_enemies = math.random(100, 150)

    for i=2, num_platforms, 1 do
        newx = math.random(0, 10000)
        newy = math.random(maxPlatformAndEnemyHeightPlayer1, lowestPlatformandEnemyHeightPlayer1)
        w = 200
        while true do
            for j=2, #platformsPlayer1, 1 do
                if not (((newx <= (platformsPlayer1[j].x+platformsPlayer1[j].width*2)) and newx >= (platformsPlayer1[j].x-platformsPlayer1[j].width*2)) and ((newy <= platformsPlayer1[j].y+100) and (newy >= (platformsPlayer1[j].y-100)))) then
                    goto addplatform
                end
            end
            newx = math.random(0, 10000)
            newy = math.random(maxPlatformAndEnemyHeightPlayer1, lowestPlatformandEnemyHeightPlayer1)
        end
        ::addplatform::
        platformsPlayer1[i] = {
            x = newx,
            y = newy,
            width = w,
            height = 50,
        }
        platformsPlayer2[i] = {
            x = newx,
            y = 600 + ((1000 - 600) / (0 - 500)) * (newy - 500),
            width = w,
            height = 50,
        }
        if i == num_platforms then
            platformsPlayer1[i+1] = {
                x = 10000,
                y = 200,
                width =150,
                height = 300,
            }
            platformsPlayer2[i+1] = {
                x = 10000,
                y = 600 + ((1000 - 600) / (0 - 500)) * (375 - 500),
                width = 150,
                height = 300,
            }
        end
    end


    enemiesPlayer1[1] = {
        x = math.random(0, 10000),
        y = math.random(maxPlatformAndEnemyHeightPlayer1, lowestPlatformandEnemyHeightPlayer1),
        width = 50,
        height = math.random(100, 200),
        dir = 1,
        skipRound = 0
    }


    for i=1, num_enemies, 1 do
        newx = math.random(400, 10000)
        newy = math.random(maxPlatformAndEnemyHeightPlayer1, lowestPlatformandEnemyHeightPlayer1)
        h = math.random(100, 200)
        while true do
            for j=1, #enemiesPlayer1, 1 do
                if not (((newx <= (enemiesPlayer1[j].x+50)) and (newx >= (enemiesPlayer1[j].x-50))) and ((newy <= enemiesPlayer1[j].y+enemiesPlayer1[j].height) and (newy >= (enemiesPlayer1[j].y-enemiesPlayer1[j].height)))) then
                    goto addenemy
                end
            end
            newx = math.random(0, 10000)
            newy = math.random(maxPlatformAndEnemyHeightPlayer1, lowestPlatformandEnemyHeightPlayer1)
        end
        ::addenemy::         
        enemiesPlayer1[i] = {
            x = newx,
            y = newy,
            width = 50,
            height = h,
            dir = 1,
            skipRound = 0,
        }
        enemiesPlayer2[i] = {
            x = newx,
            y = 600 + ((1000 - 600) / (0 - 500)) * (newy - 500),
            width = 50,
            height = h,
            dir = 1,
            skipRound = 0,
        }
    end
end

function love.update(dt)
    -- need to init p2 upon update
    if splash.mode == "multi" and splash.waitingToResize then
       -- coroutine.resume(co)

        player2.x = 100
        player2.y = startingPointForPlayer2
        player2.width = 30
        player2.height = 60
        player2.speed = 200
        player2.grounded = false
        player2.dy = 0
        player2.jumpHeight = -600

        platformsPlayer2[1] = {
            x = 0,
            y = 1000,
            width = love.graphics.getWidth(),
            height = 100,
        }

        platformsPlayer2[2] = {
            x = math.random(0, 10000),
            y =  math.random(maxPlatformAndEnemyHeightPlayer1, lowestPlatformandEnemyHeightPlayer1),
            width = 200,
            height = 50,
        }
    end
    -- LEFT P1
    if love.keyboard.isDown("left") then
        direction = -1
        if player1.grounded then
            count = count + 0.4
            animate = playerAnimation2[math.floor(count, 1)%6 + 1]
        end
        if  player1.dy ~= 0 then
            animate = playerAnimation2[7]
        end
        
        if player1.x > 60 then 
            player1.x = player1.x - player1.speed * dt
        else
            for i, platform in ipairs(platformsPlayer1) do
                if i > 1 then
                platform.x = platform.x + player1.speed * dt
                end
            end
            for i, enemy in ipairs(enemiesPlayer1) do
                if i > 1 then
                    enemy.x = enemy.x + player1.speed * dt
                end
            end
        end
        progressp1.val = progressp1.val - player1.speed * dt / 10000
    end
    -- RIGHT P1
    if love.keyboard.isDown("right") then
        direction = 1
        if player1.grounded then
        count = count + 0.4
        animate = playerAnimation[math.floor(count, 1)%6 + 1]
        end
        if  player1.dy ~= 0 then
            animate = playerAnimation[7]
        end
        
        if player1.x < love.graphics.getWidth() - player1.width - 100 then
            player1.x = player1.x + player1.speed * dt
        else 
            for i, platform in ipairs(platformsPlayer1) do
                if i > 1 then
                    platform.x = platform.x - player1.speed * dt
                end
            end
            for i, enemy in ipairs(enemiesPlayer1) do
                if i > 1 then
                    enemy.x = enemy.x - player1.speed * dt
                end
            end
        end
        progressp1.val = progressp1.val + player1.speed * dt / 10000
    end
    
    bottom2 = {
        x = 0,
        y = lowestPlatformandEnemyHeightPlayer2,
        width = love.graphics.getWidth(),
        height = 100,
    }

    top2 = {
        x = 0,
        y = maxPlatformAndEnemyHeightPlayer2,
        width = love.graphics.getWidth(),
        height = 0,
    }

    -- P2 COMMANDS
    if splash.mode == "multi" then
        if love.keyboard.isDown("l") then
            if player2.x > 60 then
                player2.x = player2.x - player2.speed * dt
            else
                for i, platform in ipairs(platformsPlayer2) do
                    if i > 1 then
                    platform.x = platform.x + player2.speed * dt
                    end
                end
                if splash.mode == "multi" then
                    for i, enemy in ipairs(enemiesPlayer2) do
                        if i > 1 then
                        enemy.x = enemy.x + player2.speed * dt
                        end
                    end
                end
            end
            progressp2.val = progressp2.val - player2.speed * dt / 10000
        end
        if love.keyboard.isDown("r") then
           if player2.x < love.graphics.getWidth() - player2.width - 100 then
                player2.x = player2.x + player2.speed * dt
           else --player2.x > love.graphics.getWidth() - player2.width - 100 then
                for i, platform in ipairs(platformsPlayer2) do
                    if i > 1 then
                        platform.x = platform.x - player2.speed * dt
                    end
                end
                for i, enemy in ipairs(enemiesPlayer2) do
                    if i > 1 then
                        enemy.x = enemy.x - player2.speed * dt
                    end
                end
            end
            progressp2.val = progressp2.val + player2.speed * dt / 10000
        end
        if love.keyboard.isDown("j") and player2.grounded then
            player2.dy = player2.jumpHeight
        end
        if not player2.grounded then
            player2.dy = player2.dy + gravity * dt
        end
        player2.y = player2.y + player2.dy * dt
        player2.grounded = false
        for i, platform in ipairs(platformsPlayer2) do
            if player2.y < platform.y + platform.height and player2.y > platform.y and player2.x + player2.width > platform.x and player2.x < platform.x + platform.width then
                if i == num_platforms + 1 then
                    statep2 = "won"
                end
                player2.y = platform.y + platform.height
                player2.dy = 0
            end
            if player2.y + player2.height > platform.y and player2.y + player2.height < platform.y + platform.height and player2.x + player2.width > platform.x and player2.x < platform.x + platform.width then
                if i == num_platforms + 1 then
                    statep2 = "won"
                end
                player2.grounded = true
                player2.dy = 0
                player2.y = platform.y - player2.height
            end
        end
        for i, enemy in ipairs(enemiesPlayer2) do 
            if enemy.y <= top2.y or enemy.y >= bottom2.y and enemy.skipRound == 0 then
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
            if player2.y  <= enemy.y + 100 and player2.y >= enemy.y - 75 and player2.x <= enemy.x + 40 and player2.x >= enemy.x - 40 then
                statep2 = "lost"
            end
        end

    end

    if not player1.grounded then
        player1.dy = player1.dy + gravity * dt
    end

    player1.y = player1.y + player1.dy * dt
    player1.grounded = false

    bottom1 = {
        x = 0,
        y = lowestPlatformandEnemyHeightPlayer1,
        width = love.graphics.getWidth(),
        height = 100,
    }
    top1 = {
        x = 0,
        y = maxPlatformAndEnemyHeightPlayer1,
        width = love.graphics.getWidth(),
        height = 0,
    }
    for i, enemy in ipairs(enemiesPlayer1) do 
        if enemy.y <= top1.y or enemy.y >= bottom1.y and enemy.skipRound == 0 then
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
        if player1.y  <= enemy.y + 100 and player1.y >= enemy.y - 75 and player1.x <= enemy.x + 40 and player1.x >= enemy.x - 40 then
            statep1 = "lost"
        end
    end




 

    for i, platform in ipairs(platformsPlayer1) do
        if player1.y < platform.y + platform.height and player1.y > platform.y and player1.x + player1.width > platform.x and player1.x < platform.x + platform.width then
            if i == num_platforms + 1 then
                statep1 = "won"
            end
            player1.y = platform.y + platform.height
            player1.dy = 0
        end
        if player1.y + player1.height > platform.y and player1.y + player1.height < platform.y + platform.height and player1.x + player1.width > platform.x and player1.x < platform.x + platform.width then
            if i == num_platforms + 1 then
                statep1 = "won"
            end
            player1.grounded = true
            player1.dy = 0
            player1.y = platform.y - player1.height
        end
    end


    if love.keyboard.isDown("space") and player1.grounded then
        player1.dy = player1.jumpHeight
    end

    
    
end

function love.draw()
 --   coroutine.yeild()
    
    require "splash"
    
    if statep1 == "intro" and statep2 == "intro" then
        splash.draw()
        if splash.play then
            
            statep1 = "play"
            if splash.multi then
                statep2 = "play"
            end
        end
    else
        --love.graphics.scale(3.0, 2.0)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(background, 0, 0)

        
        --while true do
            love.graphics.draw(love.graphics.newImage(animate), player1.x, player1.y, 0, 1, 1 )
            
    
       -- end

        
        if splash.mode == "multi" and splash.waitingToResize == true  then
                love.window.setMode(love.graphics.getWidth(), love.graphics.getHeight()*2)
                splash.waitingToResize = false
  

            --splash.mode = "playing"
            --love.load(1)
           -- love.draw()
            --splash.mode = "done"
            -- somehow create a second player
            
            -- so this can dupe things
            -- can we use this to pass arguments?
           --love.load(1)
           --love.draw()
        end
       -- coroutine.resume(co)
        love.graphics.setColor(1, 1, 1)
        if statep1 == "lost" then
            -- clear
        elseif statep1 == "won" then
        
        else
            --love.graphics.rectangle("fill", player1.x, player1.y, player1.width, player1.height)

            love.graphics.setColor(0, 1, 0.2)
            for i, platform in ipairs(platformsPlayer1) do
                if i > num_platforms then
                    love.graphics.setColor(1, 0.84, 0) 
                end
                love.graphics.rectangle("fill", platform.x, platform.y, platform.width, platform.height)
            end
            love.graphics.setColor(1, 0, 0, 1)
            for i, enemy in ipairs(enemiesPlayer1) do 
                love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.width, enemy.height)
            end
            font = love.graphics.newFont(32)
            love.graphics.print(math.floor(progressp1.val*100, 1) .. "%", font, 700, 50)

        end

        if statep2 == "lost" then
            -- clear
        elseif statep2 == "won" then
            -- clear
        elseif splash.mode == "multi" then
            love.graphics.setColor(1, 1, 1)

            love.graphics.rectangle("fill", player2.x, player2.y, player2.width, player2.height)
            
            love.graphics.setColor(0, 1, 0.2)

            for i, platform in ipairs(platformsPlayer2) do
                if i > num_platforms then
                    love.graphics.setColor(1, 1, 1) 
                end
                love.graphics.rectangle("fill", platform.x, platform.y, platform.width, platform.height)
            end

            love.graphics.setColor(1, 0, 0, 1)

            for i, enemy in ipairs(enemiesPlayer2) do 
                love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.width, enemy.height)
            end

            love.graphics.print(progressp2.val*100 .. "%", progressp2.x, 1000)
        end
     --    end
  end


end