-----------------------------------------------------
-- snowman.lua
-- Sean O'Sullivan, Charlie Doern, Lauren Chilton
-- CSCI 324
-- Description: Play the game of snowman where
-- you have to guess the word one character at a time
-----------------------------------------------------

allWords = {"hello", "world", "testing", "scheme", 
"snowman", "holycross", "csci324", "classof2023", "PL",
"lisp", "functional", "recusrion", "lua", "incorrect", "Church",
"Turing", "Ada", "Grace", "Alonzo", "parentheses"
}

-- Prints out the previous guesses, current snowman, word progress
function printGame(table, numWrong)
    local g = ""
    local text = ""
    for i=1,#table do
        text = text .. table[i] .. " "
    end

    for i=1,#guessed do
        g = g .. " " .. guessed[i]
    end
    
    printSnowman(numWrong)
    print()
    print()
    print("   " .. text)
    print()
    print("Guesses:  " .. g)
end


function homePage()
    print(" -----------------------------------------------------------")
    print("|       \27[90;36m*\27[0m                   \27[90;36mSNOWMAN\27[0m                         |")
    print("|                    \27[90;36m*\27[0m                         \27[90;36m*\27[0m            |")
    print("|   Options:                                                |")
    print("|                                 \27[90;36m*\27[0m           \27[90;36m*\27[0m             |")
    print("|      \27[1mS - Start Game\27[0m                                       |")
    print("|                                                           |")
    print("|      \27[1mA - Add words to dictionary\27[0m               \27[90;36m*  __   \27[0m   |")
    print("|                         \27[90;36m*\27[0m                       \27[90;36m_|==|_   \27[0m |")
    print("|      \27[1mH - Help\27[0m                                    \27[90;36m('')___/ \27[0m|")
    print("|                                         \27[90;36m*    >--(`^^') \27[0m   |")
    print("|      \27[1mQ - Quit \27[0m                                 \27[90;36m(`^'^'`)  \27[0m |")
    print(" -----------------------------------------------------------")
    
    return io.read()
end

function helpPage()
    print(" -----------------------------------------------------------")
    print("|        \27[90;36m*\27[0m                 \27[90;36mSNOWMAN\27[0m         \27[90;36m*\27[0m                |")
    print("| \27[90;36m*\27[0m             \27[90;36m*\27[0m                     \27[90;36m*\27[0m                     |")
    print("|   Help:                \27[90;36m*\27[0m                        \27[90;36m*\27[0m         |")
    print("|                                           \27[90;36m*\27[0m               |")
    print("|      The objective of the game is to guess the hidden     |")
    print("|      word correctly. You have to guess one letter at a    |")
    print("|    \27[90;36m*\27[0m time and a incorrect guess will build part of the    |")
    print("|      snowman. If the snowman is completley built before   |")
    print("|      you guess the word then you lose the game!           |")
    print("| \27[90;36m*\27[0m                                                 \27[90;36m*\27[0m       |")
    print("|      \27[1mB - Go Back\27[0m              \27[90;36m*\27[0m                           |")
    print(" -----------------------------------------------------------")

    return io.read()
end

function addPage()
    local unique = true
    local newWord = ""
    print("Type a word to be added")
    print("Type '1' when finished")
    while(newWord ~= "1") do
        io.write("Add: ")
        newWord = io.read()
        if(newWord == '1') then return 'b' end
        for i=1,#dictionary do
            if(newWord == dictionary[i]) then
                unique = false
                break
            end
                unique = true
            
        end
        if(unique) then 
            print("Added to dictionary")
            table.insert(dictionary, string.lower(newWord))
            writeFile(file, newWord)
        end
        if(not unique) then print("That word already exists in the dictionary") end
    end
end

-- Function that checks if letter was previously guessed
function didGuess(char)
    for i=1, #guessed do
        if(guessed[i] == char) then
            return true
        end
    end
end

-- Prints current snowman based on wrong guesses.
function printSnowman(numWrong)
    print("\27[90;36m       SNOWMAN \27[0m")
    print("The word is: " .. "\27[102;97m" .. word .. "\27[0m") 
    print("The word is " .. wordLength .. " letters long")
    print()
    local sHat = {"     __", "   _|==|_ "}
    local sHead = {"    ('')", "___/"}
    local sMiddle = {"(`^^')", ">--"}
    local sBottom = "  (`^'^'`)"

    if(numWrong > 0) then -- If atleast one worng guess, print hat.
        for i=1,#sHat do
            print("\27[90;36m" .. sHat[i] .. "\27[0m")
        end
    end
    if(numWrong > 1 and numWrong < 5) then -- If atleast two worng guess, print head.
        print("\27[90;36m" .. sHead[1] .. "\27[0m")
    end
    if(numWrong > 4) then -- If atleast 4 worng guess, print bottom.
        print("\27[90;36m" .. sHead[1] .. sHead[2] .. "\27[0m")
    end
    
    if(numWrong > 2 and numWrong < 6) then -- If atleast 3 worng guess, print body.
        print("\27[90;36m   " .. sMiddle[1] .. "\27[0m")
    end
    if(numWrong > 5) then -- If atleast 4 worng guess, print bottom.
        print("\27[90;36m" .. sMiddle[2] .. sMiddle[1] .. "\27[0m")
    end
    if(numWrong > 3) then -- If atleast 4 worng guess, print bottom.
        print("\27[90;36m" .. sBottom .. "\27[0m")
    end
    
end

-- Checks if the guessed character is in the word and is added to the guessArray if it is and returns true.
function wordCheck(char, actual)
    local correct = false
    for i=1, #actual do
        if(actual[i] == char) then
            guessArray[i] = char
            correct = true
        end
    end
    return correct
end

-- Returns true if players guesses the word correctly
function didWin(guess, actual)
    for i=1, #actual do
        if(actual[i] ~= guess[i]) then
            return false
        end
    end
    return true
end

-- Sleep function
function sleep(n)
    local clock = os.clock
    local t0 = clock()
    while clock() - t0 <= n do end
end

-- Checks the validity of a given character
function checkValidity(char)
    for match in string.gmatch(char, "%W") do -- if not a letter
        print("invalid char")
        char = ''
    end
    for match in string.gmatch(char, "%d") do -- if a number
        print("invalid char")
        char = ''
    end
    if (string.find(char, "&") ~= nil or string.find(char, "/%") ~= nil) then -- or if these two special cases
        print("invalid character!")
        char = ''
    end      
    return char       
end

-- Plays game
function playGame(attemptsAllowed)
    local badAttempts = 0
    guessArray = {}
    guessed = {}
    wordArray = {}
    
    r = math.random(1,#dictionary)
    word = dictionary[r]
    wordLength = string.len(word)


    for i=1,wordLength do
        inserted = false
        wordArray[i] = string.sub(word,i,i)
        for match in string.gmatch(wordArray[i], "%W") do -- make sure to insert non letters so people dont need to guess them.
            guessArray[i] = wordArray[i]
            inserted= true
        end
        for match in string.gmatch(wordArray[i], "%d") do
            guessArray[i] = wordArray[i]
            inserted = true
        end
        if (not inserted) then
            guessArray[i] = '_'
        end
    end
    
    print()
    printGame(guessArray, 0)
    print()
    ::playloop::
    while(badAttempts < attemptsAllowed) do
        print("You have " .. (attemptsAllowed-badAttempts) .. " more attempts")
        print("Type 'quit' to quit")
        if(didWin(guessArray, wordArray)) then
            print("\27[42;31m                                         \27[0m")
            print("\27[42;31m                 YOU WIN                 \27[0m")
            print("\27[42;31m                                         \27[0m")
            return
        else
            io.write('Guess a letter:  ')
            char = io.read()
            char = string.lower(char)
            if(char == "quit") then break end

            char = checkValidity(char)    -- checks if what we have is a valid char
            if(char == '') then
                sleep(1)
                os.execute("clear")
                printGame(guessArray, badAttempts)
                goto playloop
            end 
            
            while(#char ~= 1) do
                io.write('Guess a letter:  ')
                char = io.read()
                char = string.lower(char)
                char = checkValidity(char)
                if(char == '') then
                    sleep(1)
                    os.execute("clear")
                    printGame(guessArray, badAttempts)
                    goto playloop
                end 
            end
            if(didGuess(char)) then
                print("You already guessed that letter")
                sleep(1)

            elseif(wordCheck(char, wordArray)) then
                print("That is a correct letter, good guess")
                sleep(1)
                table.insert(guessed, char)
            else 
                print("Nope, that letter is not in the word")
                sleep(1)
                badAttempts = badAttempts + 1
                table.insert(guessed, char)
            end
            
        end
        table.sort(guessed)
        os.execute("clear")
        printGame(guessArray, badAttempts)
    end
    if(didWin(guessArray, wordArray)) then
        print("\27[42;31m                                         \27[0m")
        print("\27[42;31m                 YOU WIN                 \27[0m")
        print("\27[42;31m                                         \27[0m")
        
    else 
        os.execute("clear")
        printGame(wordArray, badAttempts)
        print("\27[41;31m                                         \27[0m")
        print("\27[41;32m                YOU LOSE                 \27[0m")
        print("\27[41;31m                                         \27[0m")
 
        
    end
    
end

-- readFile opens and reads the dictionary
function readFile(file)
    local d = {}
    local f = io.open(file) 
    for fields in f:lines() do
        w = string.gsub(fields,"\r", "")
        table.insert(dictionary, string.lower(w))
    end
    f:close()
    return dictionary
end

function writeFile(file, newWord)
    local f = io.open(file, "a+")
    f:write(newWord .. "\n")
    f:close()
end

-- asks the user if they want to play again
function playAgain()
    io.write("Play again? (y/n) ")
        c = io.read()
        if c == 'y' then return true
        else return false end
end 

function play(userIn)
    if(string.lower(userIn) == 's') then
        os.execute("clear")
        playGame(6)
        sleep(3)
        userIn = 'b'
        return userIn

    elseif (string.lower(userIn) == 'b') then
        os.execute("clear")
        return homePage() -- go back to homepage

    elseif(string.lower(userIn) == 'h' or string.lower(userIn) == 'b') then
         os.execute("clear")
         return helpPage() -- goto help page

    elseif(string.lower(userIn) == 'a') then
        os.execute("clear")
        return addPage() -- go to the page to add words

    elseif(string.lower(userIn) == 'q') then
        os.execute("clear")
        return userIn -- quit

    end
    return 'b'
end

function main()
    dictionary = {}
    
    if(#arg == 1) then 
        dictionary = readFile(arg[1])
        file = arg[1]
    else
        dictionary = allWords
    end
    wordArray = {}
    guessArray = {}
    guessed = {}
    os.execute("clear")
 
    
    userIn = homePage()
    while(string.lower(userIn) ~= 'q' and (didWin(guessArray, wordArray) or play)) do
      userIn = play(userIn)
    end
end

main()