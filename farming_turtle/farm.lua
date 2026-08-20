MOVE_SLEEP_TIME = 0
SEED_IDS = {"minecraft:wheat_seeds","minecraft:melon_seeds","minecraft:pumpkin_seeds","minecraft:beetroot_seeds"}
PLANT_IDS = {"minecraft:wheat", "minecraft:melon", "minecraft:pumpkin", "minecraft:beetroots", "minecraft:potatoes"}
FARMLAND_ID = "minecraft:farmland"
DIRT_ID = "minecraft:dirt"
--     sleep between moves TODO will have to write a helper for this
--     if there's nothing two blocks down, turn around and come back down next column
--     if there's nothing underneath two blocks down for two blocks, turn to the left
--     if the crop is folly grown, digDown and suck!
--     if there is no crop, plant the first seed in the inventory
--     if the inventory is full, break the loop

-- basic setup, refeuling and whatnot
-- TODO may want to include refueling in main loop
turtle.select(1)
turtle.refuel()
print(turtle.getFuelLevel())

-- hover one block above the gorund 
-- TODO unsure if plants are considered "solid" blocks
if turtle.detectDown() then
    turtle.up()
end

-- helper to check if item in list
function in_table(item, table)
    for i, v in ipairs(table) do
        if item == v then
            return true
        end
    end
    return false
end

-- select and plant a seed
function plant_seed()
    -- select the seed
    for i = 1, 16 do
        block = turtle.getItemDetail(i)
        if block and in_table(block.name, SEED_IDS) then
            turtle.select(i)
            break
        end
    end
    -- plant it
    return turtle.placeDown()
end

-- main loop, keep moving until you're just sooooo full
while true do
    -- move forward one
    print("moving forward")
    print(turtle.forward())
    -- look undernearth for crop
    local has_block_below, block_below = turtle.inspectDown()
    -- check if the black is a plant
    print(block_below.name)
    print(in_table(block_below.name, PLANT_IDS))
    if in_table(block_below.name, PLANT_IDS) then
        -- check if the plant is age 7 (fully grown)
        if block_below.age == 7 then
            -- break and collect the block
            turtle.digDown()
            turtle.suck()
            -- find and plant a new seed
            while (not plant_seed()) do
                -- till ground and try again until a seed is planted
                turtle.digDown()
            end
        end
    end
    -- if the block below does not exist move down one
    if not has_block_below then
        local has_block_below, block_below = turtle.inspectDown()
        -- if the block below is not a tilled dirt block, turn around
        if block_below.name == FARMLAND_ID then
            plant_seed()
            turtle.up()
        else
            -- if the black below is an un-tilled dirt block, till it
            if block_below.name == DIRT_ID then
                turtle.digDown()
            else
                turtle.turnLeft()
                turtle.up()
            end
        end
    end
end
