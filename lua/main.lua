
function love.load()
    love.window.setTitle("Connect4")
    connect_board = love.graphics.newImage("assets/connect_board.png")

    -- testimage= love.graphics.newImage("assets/referenceroom.png")
    -- love.window.setMode( testimage:getWidth(), testimage:getHeight())
    --titleImage = love.graphics.newImage("assets/menu_assets/pixelatedtitle.png")
    
    screen_width, screen_height = connect_board:getDimensions()
    love.window.setMode(screen_width, screen_height)
    center_x, center_y = screen_width / 2, screen_height / 2
    local starting_pos = center_x - 52
    local pos_offset = 100
    rail_location = {
        starting_pos, 
        starting_pos + pos_offset, 
        starting_pos + pos_offset * 2, 
        starting_pos + pos_offset * 3, 
        starting_pos + pos_offset * 4-2, 
        starting_pos + pos_offset * 5 -6, 
        starting_pos + pos_offset * 6-8}
    turnstate = "red" -- 'red, 'yellow'
    winner = 0 -- 0 = no winner, 1 = red, 2 = yellow
    
    dropstate = "none"

    dropselected = 1
    board = { -- 7 columns, 6 rows column x row, 0 = empty, 1 = red, 2 = yellow
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0}
    }
end

token_size = 46
colors = {
    red = {1, 0, 0, 1},
    yellow = {1, 1, 0, 1},
    win = {0, 0, 0, 0}
}

--I wonder if table lookup is suitible for enumeration?
player = {
    [0] = "win",
    [1] = "red",
    [2] = "yellow"
}

function love.keypressed(key)
    if turnstate == "win" then
        reset_game()
        return
    end  

    if key == "escape" then
        love.event.quit()
    end

    if key == "right"  then
        if dropselected < 7 then
            dropselected = dropselected + 1
        end
    end
    if key == "left" then
        if dropselected > 1 then
            dropselected = dropselected - 1
        end
    end
    if key == "space" then
        if dropstate ~= "none" then -- prevent multiple drops
            return
        end
        dropstate = "drop"
    end
end

function love.update(dt)
    if dropstate == "drop" then
        -- simulate drop time
        -- in future, animate the drop
        local row_landed = 0
        --find lowest empty row in selected column, set to current player
        for row = 6,1,-1 do
            if board[dropselected][row] == 0 then
                board[dropselected][row] = (turnstate == "red") and 1 or 2
                row_landed = row
                break
            end
        end
        if row_landed == 0 then
            return
        end

        print("Dropped " .. turnstate .. " piece in column " .. dropselected .. " row " .. row_landed)

        winner = check_for_win(dropselected, row_landed)
        if winner == 0 then
            swap_turn()
        else
            print(turnstate .. " player wins!")
            turnstate = "win"
        end
        dropstate = "none"
    end

end


function love.draw()
    love.graphics.setColor(1, 1, 1, 1) -- RED

    for i = 1, #rail_location do
        love.graphics.rectangle("fill", rail_location[i],  50, 5, screen_height- 130)
    end

    love.graphics.setColor(colors[turnstate]) -- DROP INDICATOR
    love.graphics.circle("fill", rail_location[dropselected]+2, 50, token_size)
    draw_pieces()

    love.graphics.setColor(1, 1, 1, 1) -- NORAMAL
    love.graphics.draw(connect_board, 0, 0)

    draw_text()
end


function draw_pieces()
    local offset = token_size * 2+2
    for col = 1, 7 do
        for row = 1, 6 do
            if board[col][row] == 1 then
                love.graphics.setColor(colors["red"])
                love.graphics.circle("fill", rail_location[col]+2, (row * offset)+80, token_size)
            elseif board[col][row] == 2 then
                love.graphics.setColor(colors["yellow"])
                love.graphics.circle("fill", rail_location[col]+2, (row * offset)+80, token_size)
            end
        end
    end
end

function draw_text()
    love.graphics.setColor(1, 1, 1, 1)
    if turnstate == "win" then
        love.graphics.setColor(colors[player[winner]])
        love.graphics.print("Connect 4\n" .. ((winner == 1) and "Red" or "Yellow") .. " player wins!\nPress any key to restart", 10, 10, 0, 1.5, 1.5)
        return
    end
    love.graphics.print("Connect 4\n" .. turnstate .. " player's turn", 10, 10, 0, 1.5, 1.5)
    love.graphics.print("Use LEFT and RIGHT to select column, SPACE to drop piece", 10, screen_height - 30, 0,1.5, 1.5)

end

function check_for_win(column, row)
    local player = board[column][row]
    local count = 1 -- we already counted the starting position

    --NOTE: using for loops works too but while loops uses less lines of code
    -- check horizontal
    local icolumn = column - 1
    while icolumn >= 1 and board[icolumn][row] == player do
        count = count + 1
        icolumn = icolumn - 1
    end

    icolumn = column + 1 
    while icolumn <= 7 and board[icolumn][row] == player do
        count = count + 1
        icolumn = icolumn + 1
    end

    if count >= 4 then
        return player 
    end

    -- check vertical
    local irow = row - 1
    count = 1 -- we already counted the starting position
    while irow >= 1 and board[column][irow] == player do
        count = count + 1
        irow = irow - 1
    end
    
    irow = row + 1  
    while irow <= 6 and board[column][irow] == player do
        count = count + 1
        irow = irow + 1
    end
    if count >= 4 then
        return player 
    end

    -- check diagonal /
    icolumn, irow = column + 1, row - 1
    count = 1 -- we already counted
    while icolumn <= 7 and irow >= 1 and board[icolumn][irow] == player do
        count = count + 1
        icolumn = icolumn + 1
        irow = irow - 1
    end
    icolumn, irow= column - 1,row + 1
    while icolumn >= 1 and irow <= 6 and board[icolumn][irow] == player do
        count = count + 1
        icolumn = icolumn - 1
        irow = irow + 1
    end
    if count >= 4 then
        return player 
    end

    -- check diagonal \
    icolumn, irow = column +1, row + 1
    count = 1 -- we already counted
    while icolumn <= 7 and irow <= 6 and board[icolumn][irow] == player do
        count = count + 1
        icolumn = icolumn + 1
        irow = irow + 1
    end
    icolumn, irow= column - 1,row - 1
    while icolumn >= 1 and irow >= 1 and board[icolumn][irow] == player do
        count = count + 1
        icolumn = icolumn - 1
        irow = irow - 1
    end
    if count >= 4 then
        return player 
    end

    return 0
end

function swap_turn()
    if turnstate == "red" then
        turnstate = "yellow"
    else
        turnstate = "red"
    end
end

function reset_game()
    dropstate = "none"
    turnstate = "red"
    dropselected = 1
    board = { -- 7 columns, 6 rows column x row, 0 = empty, 1 = red, 2 = yellow
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0}
    }
end