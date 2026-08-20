
print("Starting mob farmer")
while true do
    -- Attack Forward
    turtle.attack()
    turtle.suck()
    turtle.turnRight()

    -- Attack Right
    turtle.attack()
    turtle.suck()
    
    -- Attack Up
    turtle.attackUp()
    turtle.suckUp()

    -- drop
    turtle.turnRight()
    
    for slot = 1, 16 do
        turtle.select(slot)
        turtle.drop()
    end
    turtle.select(1)
    turtle.turnLeft()
    turtle.turnLeft()

end