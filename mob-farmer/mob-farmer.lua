
print("Running Mob Farmer")
while true do
    attacked, reason_not_attacked = turtle.attack()
    if not attacked then
        print("Didn't attack: " .. reason_not_attacked)
    end
    turtle.suck()
    turtle.dropDown()
end