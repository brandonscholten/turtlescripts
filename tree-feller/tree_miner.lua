OAK_SAPLING_ID = "minecraft:oak_sapling"


WIDTH = 9
HEIGHT = 9

turtle_pos_x = 1
turtle_pos_y = 1
turtle_y_dir = 1

-- Make sure the turtle has fuel to move. If it's empty, burn any logs it has
-- collected. Returns true once there is fuel (or fuel is unlimited).
function ensure_fuel()
    if turtle.getFuelLevel() == "unlimited" then return true end
    if turtle.getFuelLevel() > 0 then return true end
    local prev = turtle.getSelectedSlot()
    for i = 1, 16 do
        turtle.select(i)
        local item = turtle.getItemDetail(i)
        if item and item.name == "minecraft:oak_log" then
            turtle.refuel(8)
            if turtle.getFuelLevel() > 0 then break end
        end
    end
    turtle.select(prev)
    return turtle.getFuelLevel() > 0
end

-- Move forward, digging through any block (e.g. a log) that blocks the path.
-- The turtle travels one block above the planting surface, so saplings sit
-- below its travel level and are never destroyed here; only logs get cleared,
-- which is a free harvest.
--
-- IMPORTANT: this blocks until the turtle has actually moved. It never returns
-- without moving, so callers can safely update the tracked position afterwards.
-- Returning early (e.g. when out of fuel) would let pos_y run ahead of the
-- turtle's real location and make it turn/return before reaching the edge.
function forward_dig()
    while not turtle.forward() do
        if turtle.detect() then
            turtle.dig()
        elseif not ensure_fuel() then
            print("Out of fuel and no logs to burn; waiting...")
            os.sleep(5)
        else
            -- Something transient (e.g. a mob) is in the way; wait and retry.
            os.sleep(0.5)
        end
    end
end

-- Move down one block, digging through anything that blocks the descent
-- (e.g. a log that grew in the trunk column while we were up top). Like
-- forward_dig, this blocks until the turtle has actually descended so we
-- always land back at the correct height.
function down_dig()
    while not turtle.down() do
        if turtle.detectDown() then
            turtle.digDown()
        elseif not ensure_fuel() then
            print("Out of fuel and no logs to burn; waiting...")
            os.sleep(5)
        else
            -- Something transient (e.g. a mob) is below; wait and retry.
            os.sleep(0.5)
        end
    end
end

function move_turtle_along_y_axis()
    forward_dig()
    turtle_pos_y = turtle_pos_y + turtle_y_dir
end

--Helper functions

-- Fell the tree directly in front at travel level: dig into it, step forward,
-- harvest the bottom log and the full trunk above, then return to travel level.
-- Direction-agnostic and does NOT touch the position counters, so it works both
-- when advancing along a row and when turning into the next column.
function mine_tree_ahead()
    local upCount = 1
    turtle.dig()
    forward_dig()
    -- Harvest the bottom log below us, unless a sapling is already there.
    local ok, block = turtle.inspectDown()
    if not ok or block.name ~= OAK_SAPLING_ID then
        turtle.digDown()
    end

    while turtle.detectUp() do
        turtle.digUp()
        turtle.up()
        upCount = upCount + 1
    end
    -- Descend back to travel level, digging through any block that grew in the
    -- column. Descending exactly upCount - 1 times lands us one block above the
    -- planting surface again, so we never dig into the ground or saplings.
    for i = 1, upCount - 1 do
        down_dig()
    end
    turtle.suckDown()
end

function mine_tree()
    mine_tree_ahead()
    turtle_pos_y = turtle_pos_y + turtle_y_dir
end

-- Step one tile sideways into the next column. If a tree is standing there,
-- fell the whole thing and replant, instead of just boring a hole through it.
function enter_next_column()
    if turtle.detect() then
        mine_tree_ahead()
        replant_sapling()
    else
        forward_dig()
    end
end

function replant_sapling()
    -- mine_tree already cleared the block below, so place a sapling on the dirt.
    -- Check placeDown's return value so a blocked spot doesn't fail silently.
    for i = 1, 16 do
        turtle.select(i)
        local block = turtle.getItemDetail(i)
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
        local block = turtle.getItemDetail(i)
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
        enter_next_column()
        turtle.turnRight()
        turtle_y_dir = -1
    elseif turtle_y_dir == -1 then
        turtle.turnLeft()
        enter_next_column()
        turtle.turnLeft()
        turtle_y_dir = 1
    end
    turtle_pos_x = turtle_pos_x + 1
end

function return_to_origin()
    if turtle_pos_y == HEIGHT then
        -- We are at the far corner; turn around and head back down the column.
        turtle.turnRight()
        turtle.turnRight()
        for i = 1, HEIGHT - 1 do
            forward_dig()
        end
    end

    turtle.turnRight()
    for i = 1, WIDTH - 1 do
        forward_dig()
    end

    turtle.turnRight()

    -- back at the origin, drop the harvest into the chest below
    deposit_to_chest()

    -- let the saplings grow back before starting the next pass
    print("Fuel Level: "..turtle.getFuelLevel())
    print("Waiting for trees to grow...")
    os.sleep(120)
    
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
            local block = turtle.getItemDetail(i)
            if block and block.name == "minecraft:oak_log" then
                turtle.refuel(64)
            end
        end
    end

    --2. Mine a tree, or step forward across an empty tile
    if not at_y_edge() then
        if turtle.detect() then
            mine_tree()
            replant_sapling()
        else
            move_turtle_along_y_axis()
        end

    --3. At the end of the row: turn into the next column, or go home
    else
        if at_x_edge() then
            return_to_origin()
        else
            do_turn()
        end
    end
end
