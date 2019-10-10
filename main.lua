--[[ 
    Hangman

    Author: Allard Quek
    allardqjy@gmail.com
]]

-- defining variables
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

LOWERCASE_A_ASCII =  97
LOWERCASE_Z_ASCII = 122

HEAD_CENTER_Y = 100
HEAD_SIZE = 64
BODY_LENGTH = 200

local largeFont
local word
local gameOver
local gameWon 

local ALPHABET = 'abcdefghijklmnopqrstuvwxyx'
local guessesWrong = 0

-- enum
local UNGUESSED = 1
local GUESSED_RIGHT = 2
local GUESSED_WRONG = 3

local lettersGuessed = {}
local words = {}

-- https://raw.githubusercontent.com/paritytech/wordlist/master/res/wordlist.txt
for line in love.filesystem.lines('large') do
    table.insert(words, line)
end



function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.window.setTitle('Hangman')

    largeFont = love.graphics.newFont(32)
    hugeFont = love.graphics.newFont(128)
    love.graphics.setFont(largeFont)

    math.randomseed(os.time())
    initGame()
end


function love.update(dt)
    -- not needed for this game
end


function love.keypressed(key)
    -- allow user to quit by pressing escape button
    if key == "escape" then 
        love.event.quit()
    end

    if not gameOver and not gameWon then
        for i = 1, #ALPHABET do 
            local c = ALPHABET:sub(i, i)

            if key == c then
                -- make sure letter is not already guessed right or wrong
                if lettersGuessed[c] == UNGUESSED then 
                    -- by default, assume letter guessed is wrong
                    local letterInWord = false
                    
                    -- check if letter in the word
                    for j = 1, #word do 
                        local wordChar = word:sub(j, j)
                        if c == wordChar then
                            letterInWord = true
                        end
                    end

                    if letterInWord then
                        lettersGuessed[c] = GUESSED_RIGHT
                        -- initally, gameWon and gameOver are false
                        local counter = 0

                        for j = 1, #word do
                            local wordChar = word:sub(j, j)
                            if lettersGuessed[wordChar] == GUESSED_RIGHT then
                                counter = counter + 1
                                if counter == #word then
                                    gameWon = true
                                end
                            end
                        end 
                    
                    else
                        lettersGuessed[c] = GUESSED_WRONG
                        guessesWrong = guessesWrong + 1

                        if guessesWrong == 6 then
                            gameOver = true
                        end
                    end
                end
            end
        end
    else
        if key == 'space' then
            initGame()
        end
    end
end


function love.draw()
    
    drawAlphabet()
    drawStickFigure()
    drawWord()

    -- if game ended; win or lose
    if gameOver or gameWon then
        -- set faded grey color for rectangle
        love.graphics.setColor(0.2, 0.2, 0.2, 1)
        love.graphics.rectangle('fill', 64, 64, WINDOW_WIDTH - 128, WINDOW_HEIGHT - 128)
        -- set white color only for Game Over text
        love.graphics.setFont(hugeFont)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(gameWon and 'GAME WON' or 'GAME OVER', 0, WINDOW_HEIGHT / 2 - 64, WINDOW_WIDTH, 'center')
        -- remember to reset font
        love.graphics.setFont(largeFont)
        love.graphics.printf('Press Space to Restart', 0, WINDOW_HEIGHT / 2 + 64, WINDOW_WIDTH, 'center')
    end 
end



function initGame()
    -- iterate over alphabet, setting each letter as UNGUESSED for word game start
    for i = 1, #ALPHABET do 
        local c = ALPHABET:sub(i, i)
        lettersGuessed[c] = UNGUESSED
    end

    guessesWrong = 0
    word = words[math.random(#words)]
    gameOver = false
    gameWon = false
end


function drawAlphabet()
    local x = 190
    -- print lowercase alphabet
    for i = 1, #ALPHABET do 
        local c = ALPHABET:sub(i, i)

        if lettersGuessed[c] == GUESSED_RIGHT then
            -- setColor parameters are: R, G, B, opacity
            love.graphics.setColor(0, 1, 0, 1)
        elseif lettersGuessed[c] == GUESSED_WRONG then 
            love.graphics.setColor(1, 0, 0, 1)
        end

        love.graphics.print(c, x, WINDOW_HEIGHT - 100)
        x = x + 32

        -- reset to color to white after changing to green/red
        love.graphics.setColor(1, 1, 1, 1)
    end
end


function drawStickFigure()
    -- draw head
    if guessesWrong >= 1 then 
        -- parameters are x, y, and pixel size
        love.graphics.circle('line', WINDOW_WIDTH / 2 , HEAD_CENTER_Y, HEAD_SIZE)
    end

    -- draw body 
    if guessesWrong >= 2 then
        -- line() takes 2 x, y values 
        love.graphics.line(WINDOW_WIDTH / 2, HEAD_CENTER_Y + HEAD_SIZE, 
            WINDOW_WIDTH / 2, HEAD_CENTER_Y + HEAD_SIZE + BODY_LENGTH)
    end

    -- draw right arm
    if guessesWrong >= 3 then
        -- line() takes 2 x, y values 
        love.graphics.line(WINDOW_WIDTH / 2, HEAD_CENTER_Y + HEAD_SIZE + BODY_LENGTH / 4, 
            WINDOW_WIDTH / 2 + HEAD_SIZE, HEAD_CENTER_Y + HEAD_SIZE + BODY_LENGTH / 4 + HEAD_SIZE)
    end

    -- draw left arm 
    if guessesWrong >= 4 then
        -- line() takes 2 x, y values 
        love.graphics.line(WINDOW_WIDTH / 2, HEAD_CENTER_Y + HEAD_SIZE + BODY_LENGTH / 4, 
            WINDOW_WIDTH / 2 - HEAD_SIZE, HEAD_CENTER_Y + HEAD_SIZE + BODY_LENGTH / 4 + HEAD_SIZE)
    end

    -- draw right leg
    if guessesWrong >= 5 then
        -- line() takes 2 x, y values 
        love.graphics.line(WINDOW_WIDTH / 2, HEAD_CENTER_Y + HEAD_SIZE + BODY_LENGTH, 
            WINDOW_WIDTH / 2 + HEAD_SIZE, HEAD_CENTER_Y + HEAD_SIZE + BODY_LENGTH + HEAD_SIZE)
    end

    -- draw left leg
    if guessesWrong >= 6 then
        -- line() takes 2 x, y values 
        love.graphics.line(WINDOW_WIDTH / 2, HEAD_CENTER_Y + HEAD_SIZE + BODY_LENGTH, 
            WINDOW_WIDTH / 2 - HEAD_SIZE, HEAD_CENTER_Y + HEAD_SIZE + BODY_LENGTH + HEAD_SIZE)
    end
end


function drawWord()
    local x = WINDOW_WIDTH / 2 - 180
    local y = WINDOW_HEIGHT / 2 + 120

    -- display each char of the word at a time (use monospace fonts if want uniform interbals)
    for i = 1, #word do
        local c = word:sub(i, i)

        -- print '_' as long as letter not guessed right yet
        if lettersGuessed[c] ~= GUESSED_RIGHT then
            c = '_'
        end

        love.graphics.print(c, x, y)
        x = x + 32
    end
end

