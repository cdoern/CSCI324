-- Purpose: Creates a basic start menu for a interactive game

BUTTON_HEIGHT = 64

splash = {}
splash.play = false
splash.mode = "single"
splash.playercount = 1
splash.waitingToResize = true
local Play = false
splash.co = {}





local 
function newButton(text, fn)
    return {
        text = text,
        fn = fn, 

        now = false, 
        last = false
    }
end

local buttons = {}
local font = nil

function splash.load()
    font = love.graphics.newFont(32)
    love.graphics.setBackgroundColor(0.1, 0.5, 0.9)
    table.insert(buttons, newButton(
        "Start Game",
        function()
            splash.play = true
            splash.mode = "single"
            --print("Starting game") -- this is where you can code what to do when user clicks button
        end))

    table.insert(buttons, newButton(
        "MultiPlayer",
        function()
            print("Beginning Multiplayer")
            splash.playercount = 2
            splash.play = true
            splash.mode = "multi"
        end))

    table.insert(buttons, newButton(
        "Help",
        function()
            print("Going to settings menu")
        end))

    table.insert(buttons, newButton(
        "Quit",
        function()
            love.event.quit(0)
        end))

end

function splash.update(dt)
end

function splash.draw()
    local ww = love.graphics.getWidth()
    local wh = love.graphics.getHeight()

    local button_width = ww * (1/3)
    local margin = 16

    local total_height = (BUTTON_HEIGHT + margin) * #buttons
    local cursor_y = 0

    for i, button in ipairs(buttons) do 
        button.last = button.now

        local bx = (ww * 0.5) - (button_width * 0.5)
        local by = (wh * 0.5) - (total_height * 0.5) + cursor_y

        local color = {0.4, 0.4, 0.5, 1.0}
        local mx, my = love.mouse.getPosition()

        local cursorHot = (mx > bx and mx < bx + button_width) and (my > by and my < by + BUTTON_HEIGHT)
        
        if cursorHot then 
            color = {0.8, 0.8, 0.9, 1.0}
        end

        button.now = love.mouse.isDown(1)
     --   print(button.now)
        if button.now and cursorHot then --and not button.last and hot then
            button.now = false
            button.fn()
        end

        love.graphics.setColor(unpack(color))
    
        love.graphics.rectangle(
            "fill", 
            bx,
            by,
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
            by + textH * 0.5
        )
        cursor_y = cursor_y + (BUTTON_HEIGHT + margin)
    end

end



