OAK_SAPLING_ID = "minecraft:oak_sapling"


WIDTH = 9
HEIGHT = 9
--STATE_FARM = 1
STATE_GO_BACK = 2

turtle_state = STATE_FARM
turtle_pos_x = 1
turtle_pos_y = 1
turtle_y_dir = 1

function move_turtle_along_y_axis()
    turtle.forward()
    turtle_pos_y = turtle_pos_y + turtle_y_dir
end

--Helper functions
function mine_tree()
    upCount = 1
    turtle.dig()
    move_turtle_along_y_axis()
    --Check for oak sapling below
    ok, block = turtle.inspectDown()
    if block.name ~= OAK_SAPLING_ID then
        turtle.digDown()
    end

    while turtle.detectUp() do
        turtle.digUp()
        turtle.up()
        upCount = upCount + 1
    end
    for i = 1, upCount - 1 do
        turtle.down()
    end
    turtle.suckDown()
end

function replant_sapling()
    -- mine_tree already cleared the block below, so place a sapling on the dirt.
    -- Check placeDown's return value so a blocked spot doesn't fail silently.
    for i = 1, 16 do
        turtle.select(i)
        block = turtle.getItemDetail(i)
        if block and block.name == OAK_SAPLING_ID then
            if turtle.placeDown() then
                return true
            end
        end
    end
    return false
end

function deposit_to_chest()
    -- The chest sits directly below the turtle at the origin.
    -- Drop everything except up to 64 saplings (one stack kept for replanting).
    local saplings_kept = 0
    for i = 1, 16 do
        turtle.select(i)
        block = turtle.getItemDetail(i)
        if block then
            if block.name == OAK_SAPLING_ID then
                local keep = 64 - saplings_kept
                if keep < 0 then keep = 0 end
                if block.count > keep then
                    turtle.dropDown(block.count - keep)
                    saplings_kept = saplings_kept + keep
                else
                    saplings_kept = saplings_kept + block.count
                end
            else
                turtle.dropDown()
            end
        end
    end
    turtle.select(1)
end

function do_turn()
    if turtle_y_dir == 1 then
        turtle.turnRight()
        turtle.forward()
        turtle.turnRight()
        turtle_y_dir = -1
    elseif turtle_y_dir == -1 then
        turtle.turnLeft()
        turtle.forward()
        turtle.turnLeft()
        turtle_y_dir = 1
    end
    turtle_pos_x = turtle_pos_x + 1
end

function return_to_origin()
    if turtle_pos_y == HEIGHT then
        -- We are at the top left corner
        turtle.turnRight()
        turtle.turnRight()
        for i = 1, HEIGHT - 1 do
            turtle.forward()
        end
    end

    turtle.turnRight()
    for i = 1, WIDTH - 1 do
        turtle.forward()
    end

    turtle.turnRight()

    -- back at the origin, drop the harvest into the chest below
    deposit_to_chest()

    -- delay for 2 minutes
    print("Fuel Level: "..turtle.getFuelLevel())
    print("Origin Delaying")

    turtle_pos_x = 1
    turtle_pos_y = 1
    turtle_y_dir = 1
end

turtle.select(1)
turtle.refuel()

function at_y_edge()
    if turtle_y_dir == 1 then
        if turtle_pos_y == HEIGHT then
            return true
        else
            return false
        end
    elseif turtle_y_dir == -1 then
        if turtle_pos_y == 1 then
            return true
        else
            return false
        end
    end

    print("BAD DIRECTION")
    assert(false)
end

function at_x_edge()
    if turtle_pos_x == WIDTH then
        return true
    else
        return false
    end
end

while true do
    --0.5 suck up saplings
    turtle.suck()

    --0.75 try to plant sapling
    replant_sapling()

    --1. Refuel if below
    if turtle.getFuelLevel() < 120 then
        for i = 1, 16 do
            turtle.select(i)
            block = turtle.getItemDetail(i)
            if block and block.name == "minecraft:oak_log" then
                turtle.refuel(64)
            end
        end
    end

    --2. Mine tree
    if not at_y_edge() then 
        if turtle.detect()  then
            mine_tree()
        end    
    
        --replant sapling
        replant_sapling()

    else
        --3. Move forward
        if at_y_edge() then
            if at_x_edge() then
                return_to_origin()
            else
                do_turn()
            end
        else
            move_turtle_along_y_axis()
        end
    end
end
