
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
    turnstate = "red"
    
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
    yellow = {1, 1, 0, 1}
}

function love.keypressed(key)
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

        for row = 6,1,-1 do
            if board[dropselected][row] == 0 then
                board[dropselected][row] = (turnstate == "red") and 1 or 2
                swap_turn()
                break
            end
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

function swap_turn()
    if turnstate == "red" then
        turnstate = "yellow"
    else
        turnstate = "red"
    end
end