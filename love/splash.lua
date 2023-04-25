-- splash.lua Charlie Doern Sean O'Sullivan Lauren Chilton 4/25/23
-- this is the start screen code for our platformer with a start, multiplayer, and quit button.

BUTTON_HEIGHT = 64

splash = {} -- the table to access when requiring the module
splash.play = false -- we do not want to play until we click
splash.mode = "single" -- default is single player
splash.waitingToResize = true


-- creates the 3 buttons when called and assigns a function to them
function splash.newButton(text, fn)
    return {
        text = text,
        fn = fn, 

        now = false, 
        last = false
    }
end

local buttons = {}
local font = nil

-- loads the screen and creates necessary variables
function splash.load()
    font = love.graphics.newFont(32)
    love.graphics.setBackgroundColor(0.1, 0.5, 0.9)
    table.insert(buttons, splash.newButton( -- start button
        "Start Game",
        function()
            splash.play = true
            splash.mode = "single"
        end))

    table.insert(buttons, splash.newButton( -- multiplayer button
        "MultiPlayer",
        function()
            print("Beginning Multiplayer")
            splash.play = true
            splash.mode = "multi"
        end))

    table.insert(buttons, splash.newButton( -- quit button
        "Quit",
        function()
            love.event.quit(0)
        end))

end

-- there is nothing to update in this one but this needs to be defined.
function splash.update(dt)
end


-- draw the buttons and determine if the cursor is hot
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
        local by = 0 + (BUTTON_HEIGHT + margin) * i

        local color = {0.4, 0.4, 0.5, 1.0}
        local mx, my = love.mouse.getPosition(0)
        local cursorHot = (mx > bx and mx < bx + button_width) and (my > by and my < by + BUTTON_HEIGHT)
        
        -- if we are over the button by determining the mouse position, change color
        if cursorHot then 
            color = {0.8, 0.8, 0.9, 1.0}
        end

        -- get if button 1 is pressed
        button.now = love.mouse.isDown(1)
        if button.now and cursorHot then -- if the left mouse button is being pressed and we are on one of our screen buttons, execute the function 
            button.now = false
            button.fn()
        end

        love.graphics.setColor(unpack(color))
    
        -- draw the buttons
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
