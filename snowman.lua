-----------------------------------------------------
-- snowman.lua
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
    print("The word is: " .. word)
    printSnowman(numWrong)
    print()
    print()
    print("   " .. text)
    print()
    print("Guesses:  " .. g)
end


function homePage()
    print(" -----------------------------------------------------------")
    print("|       *                   SNOWMAN                         |")
    print("|                    *                         *            |")
    print("|   Options:                                                |")
    print("|                                 *           *             |")
    print("|      S - Start Game                                       |")
    print("|                                                           |")
    print("|      A - Add words to dictionary               *  __      |")
    print("|                         *                       _|==|_    |")
    print("|      H - Help                                    ('')___/ |")
    print("|                                         *    >--(`^^')    |")
    print("|      Q - Quit                                  (`^'^'`)   |")
    print(" -----------------------------------------------------------")
    
    return io.read()
end

function helpPage()
    print(" -----------------------------------------------------------")
    print("|        *                 SNOWMAN         *                |")
    print("| *             *                     *                     |")
    print("|   Help:                *                        *         |")
    print("|                                           *               |")
    print("|      The objective of the game is to guess the hidden     |")
    print("|      word correctly. You have to guess one letter at a    |")
    print("|    * time and a incorrect guess will build part of the    |")
    print("|      snowman. If the snowman is completley built before   |")
    print("|      you guess the word then you lose the game!           |")
    print("| *                                                 *       |")
    print("|      B - Go Back              *                           |")
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
            table.insert(dictionary, newWord)
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
    print("Snowman")
    print("The word is " .. wordLength .. " letters long")
    print()
    local sHat = {"     __", "   _|==|_ "}
    local sHead = {"    ('')", "___/"}
    local sMiddle = {"(`^^')", ">--"}
    local sBottom = "  (`^'^'`)"

    if(numWrong > 0) then -- If atleast one worng guess, print hat.
        for i=1,#sHat do
            print(sHat[i])
        end
    end
    if(numWrong > 1 and numWrong < 5) then -- If atleast two worng guess, print head.
        print(sHead[1])
    end
    if(numWrong > 4) then -- If atleast 4 worng guess, print bottom.
        print(sHead[1] .. sHead[2])
    end
    
    if(numWrong > 2 and numWrong < 6) then -- If atleast 3 worng guess, print body.
        print("   " .. sMiddle[1])
    end
    if(numWrong > 5) then -- If atleast 4 worng guess, print bottom.
        print(sMiddle[2] .. sMiddle[1])
    end
    if(numWrong > 3) then -- If atleast 4 worng guess, print bottom.
        print(sBottom)
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
        wordArray[i] = string.sub(word,i,i)
        guessArray[i] = '_'
    end
    
    print()
    printGame(guessArray, 0)
    print()

    while(badAttempts < attemptsAllowed) do
        print("You have " .. (attemptsAllowed-badAttempts) .. " more attempts")
        print("Type 'quit' to quit")
        if(didWin(guessArray, wordArray)) then
            print("////////////////////////////////////////")
            print("               YOU WIN")
            print("////////////////////////////////////////")
            return
        else
            io.write('Guess a letter:  ')
            char = io.read()
            char = string.lower(char)
            if(char == "quit") then break end
            
            while(#char ~= 1) do
            io.write('Guess a letter:  ')
            char = io.read()
            char = string.lower(char)
            end
            

            if(didGuess(char)) then
                print("You already guessed that letter")
                sleep(1)

            elseif(wordCheck(char, wordArray)) then
                print("That is a correct letter, good guess")
                table.insert(guessed, char)

            else 
                
                print("Nope, that letter is not in the word")
                badAttempts = badAttempts + 1
                table.insert(guessed, char)
            end
            
        end
        table.sort(guessed)
        os.execute("clear")
        printGame(guessArray, badAttempts)
    end
    if(didWin(guessArray, wordArray)) then
        print("////////////////////////////////////////")
        print("               YOU WIN")
        print("////////////////////////////////////////")
        
    else 
        os.execute("clear")
        printGame(wordArray, badAttempts)
        print("////////////////////////////////////////")
        print("               YOU LOST")
        print("////////////////////////////////////////")
        
    end
    
end

function readFile(file)
    local d = {}
    --local csv = require("csv")
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
    f:write(newWord .. "\r")
    f:close()
end

function playAgain()
    io.write("Play again? (y/n) ")
        c = io.read()
        if c == 'y' then return true
        else return false end
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
    while(userIn ~= 'q' or userIn ~= 'Q' or didWin(guessArray, wordArray) or play) do
        
        if(userIn == 's' or userIn == 'S') then
            os.execute("clear")
            playGame(6)
            sleep(3)
            userIn = 'b'
            
            
        elseif (userIn == 'b' or userIn == 'B') then
            os.execute("clear")
            userIn = homePage()
        
        elseif(userIn == 'h' or userIn == 'H' or userIn == 'b' or userIn == 'B') then
             os.execute("clear")
             userIn = helpPage()

        elseif(userIn == 'a' or userIn == 'A') then
            os.execute("clear")
            userIn = addPage()

        elseif(userIn == 'q' or userIn == 'Q') then
            os.execute("clear")
            break
        else userIn = 'b'
        end
        
    end
end

main()