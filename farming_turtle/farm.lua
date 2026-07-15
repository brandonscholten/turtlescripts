MOVE_SLEEP_TIME = 0
--     sleep between moves
--     if there's nothing two blocks down, turn around and come back down next column
--     if there's nothing underneath two blocks down for two blocks, turn to the left
--     if the crop is folly grown, digDown and suck!
--     if there is no crop, plant the first seed in the inventory
--     if the inventory is full, break the loop

-- basic setup, refeuling and whatnot
turtle.select(1)
turtle.refuel()

-- hover one block above the gorund 
-- TODO unsure if plants are considered "solid" blocks
if (!turtle.detectDown()) then
    turtle.up()
end

-- select and plant a seed
function plant_seed()
end

-- main loop, keep moving until you're just sooooo full
while true do
    -- look undernearth for crop
    block_below = turtle.inspectDown()
    -- check if the crop is wheat
    if (block_below.name == "minecraft:wheat") then
        -- check if the wheat is age 7 (fully grown)
        if (block_below.age == 7) then
            -- break and collect the block
            turtle.digDown()
            turtle.suck()
            -- find and plant a new seed
        end
    end
end
